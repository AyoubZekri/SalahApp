import 'package:Saleh/core/class/Crud.dart';
import 'package:uuid/uuid.dart';
import '../../../core/class/Sqldb.dart';
import '../../../core/class/SyncServer.dart';

class SalesData {
  Crud crud;
  final SQLDB _db = SQLDB();
  final SyncService _syncService = SyncService();

  SalesData(this.crud);

  // Get all customers to select from
  Future<List<Map<String, Object?>>> getCustomers() async {
    try {
      return await _db
          .readData("SELECT * FROM Customers ORDER BY username ASC");
    } catch (e) {
      print("❌ SalesData.getCustomers error: $e");
      return [];
    }
  }

  // Get all products to select from
  Future<List<Map<String, Object?>>> getProducts() async {
    try {
      return await _db.readData('''
        SELECT p.*, c.name AS category_name 
        FROM products p 
        LEFT JOIN Categories c ON p.cat_uuid = c.uuid 
        ORDER BY p.name ASC
        ''');
    } catch (e) {
      print("❌ SalesData.getProducts error: $e");
      return [];
    }
  }

  // Quick customer creation directly from the sale dialog
  Future<Map<String, dynamic>?> quickCreateCustomer(
      String name, String phone) async {
    final String uuid = Uuid().v4();
    try {
      final data = {
        "uuid": uuid,
        "username": name,
        "phone_numper": phone,
        "created_at": DateTime.now().toIso8601String(),
        "updated_at": DateTime.now().toIso8601String(),
      };
      final result = await _db.insert("Customers", data);
      if (result > 0) {
        await _syncService.addToQueue("Customers", uuid, "insert", data);
        return data;
      }
      return null;
    } catch (e) {
      print("❌ SalesData.quickCreateCustomer error: $e");
      return null;
    }
  }

  // Save invoice and invoice items inside a transaction
  Future<bool> saveInvoice({
    required String? customerUuid,
    required double netTotal,
    required double discount,
    required List<Map<String, dynamic>> items,
    String type = "sales",
  }) async {
    final String invoiceUuid = Uuid().v4();
    final String nowStr = DateTime.now().toIso8601String();

    try {
      // Get the next invoice number
      int nextNum = 1;
      final maxIdRes =
          await _db.readData("SELECT MAX(id) as max_id FROM invoice");
      if (maxIdRes.isNotEmpty && maxIdRes[0]['max_id'] != null) {
        nextNum = (maxIdRes[0]['max_id'] as int) + 1;
      }

      final dbClient = await _db.db;
      final Map<String, dynamic> invoiceData = {
        "uuid": invoiceUuid,
        "Customers_uuid": customerUuid,
        "type": type,
        "numper": nextNum.toString(),
        "date": nowStr,
        "Payment_price": netTotal.toString(),
        "discount": discount.toString(),
        "created_at": nowStr,
        "updated_at": nowStr,
      };

      final List<Map<String, dynamic>> itemsData = [];

      final transactionSuccess = await dbClient!.transaction((txn) async {
        // 1. Insert Invoice
        final invRes = await txn.insert("invoice", invoiceData);
        if (invRes <= 0) return false;

        // 2. Insert Invoice Items
        for (var item in items) {
          final String itemUuid = Uuid().v4();
          final itemData = {
            "uuid": itemUuid,
            "invoice_uuid": invoiceUuid,
            "product_uuid": item.containsKey("product_uuid")
                ? item["product_uuid"]
                : item["uuid"],
            "product_name": item["name"],
            "unit_price": double.parse(item["price"].toString()),
            "quantity": double.parse(item["quantity"].toString()),
            "type": type,
            "created_at": nowStr,
            "updated_at": nowStr,
          };

          final itemRes = await txn.insert("InvoiceItems", itemData);
          if (itemRes <= 0) return false;
          
          itemsData.add(itemData);
        }

        return true;
      });

      if (transactionSuccess) {
        // Add to Sync Queue after the transaction has committed successfully to prevent deadlock/db lock issues.
        await _syncService.addToQueue("invoice", invoiceUuid, "insert", invoiceData);
        
        for (var iData in itemsData) {
          await _syncService.addToQueue("InvoiceItems", iData["uuid"], "insert", iData);
        }
      }
      return transactionSuccess;
    } catch (e) {
      print("❌ SalesData.saveInvoice error: $e");
      return false;
    }
  }

  // Get all invoices with customer details
  Future<List<Map<String, dynamic>>> getInvoices() async {
    try {
      final res = await _db.readData('''
        SELECT i.*, c.username AS customer_name, c.phone_numper AS customer_phone,
               (SELECT COALESCE(SUM(Payment_price), 0) FROM payments WHERE invoice_uuid = i.uuid) AS total_paid
        FROM invoice i
        LEFT JOIN Customers c ON i.Customers_uuid = c.uuid
        ORDER BY i.id DESC
      ''');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ SalesData.getInvoices error: $e");
      return [];
    }
  }

  // Get items for a specific invoice
  Future<List<Map<String, dynamic>>> getInvoiceItems(String invoiceUuid) async {
    try {
      final res = await _db.readData('''
        SELECT * FROM InvoiceItems 
        WHERE invoice_uuid = '$invoiceUuid'
      ''');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ SalesData.getInvoiceItems error: $e");
      return [];
    }
  }

  // Delete an invoice completely (including its items and payments)
  Future<bool> deleteInvoice(String invoiceUuid) async {
    try {
      final dbClient = await _db.db;
      final success = await dbClient!.transaction((txn) async {
        await txn.delete("InvoiceItems",
            where: "invoice_uuid = ?", whereArgs: [invoiceUuid]);
        await txn.delete("payments",
            where: "invoice_uuid = ?", whereArgs: [invoiceUuid]);
        final res = await txn
            .delete("invoice", where: "uuid = ?", whereArgs: [invoiceUuid]);
        return res > 0;
      });

      if (success) {
        await _syncService.addToQueue(
            "invoice", invoiceUuid, "delete", {"uuid": invoiceUuid});
      }
      return success;
    } catch (e) {
      print("❌ SalesData.deleteInvoice error: $e");
      return false;
    }
  }

  // Update invoice discount
  Future<bool> updateInvoiceDiscount(
      String invoiceUuid, double newDiscount) async {
    try {
      final dbClient = await _db.db;
      final res = await dbClient!.update(
        "invoice",
        {
          "discount": newDiscount.toString(),
          "updated_at": DateTime.now().toIso8601String()
        },
        where: "uuid = ?",
        whereArgs: [invoiceUuid],
      );
      if (res > 0) {
        await _syncService.addToQueue("invoice", invoiceUuid, "update",
            {"uuid": invoiceUuid, "discount": newDiscount.toString()});
        return true;
      }
      return false;
    } catch (e) {
      print("❌ SalesData.updateInvoiceDiscount error: $e");
      return false;
    }
  }

  // Update invoice total payment_price
  Future<bool> updateInvoiceTotal(String invoiceUuid, double newTotal) async {
    try {
      final dbClient = await _db.db;
      final res = await dbClient!.update(
        "invoice",
        {
          "Payment_price": newTotal.toString(),
          "updated_at": DateTime.now().toIso8601String()
        },
        where: "uuid = ?",
        whereArgs: [invoiceUuid],
      );
      if (res > 0) {
        await _syncService.addToQueue("invoice", invoiceUuid, "update",
            {"uuid": invoiceUuid, "Payment_price": newTotal.toString()});
        return true;
      }
      return false;
    } catch (e) {
      print("❌ SalesData.updateInvoiceTotal error: $e");
      return false;
    }
  }

  // Delete a specific product from an invoice
  Future<bool> deleteInvoiceItem(String itemUuid) async {
    try {
      final dbClient = await _db.db;
      final res = await dbClient!.delete(
        "InvoiceItems",
        where: "uuid = ?",
        whereArgs: [itemUuid],
      );
      if (res > 0) {
        await _syncService
            .addToQueue("InvoiceItems", itemUuid, "delete", {"uuid": itemUuid});
        return true;
      }
      return false;
    } catch (e) {
      print("❌ SalesData.deleteInvoiceItem error: $e");
      return false;
    }
  }

  // Update a specific product's quantity and price in an invoice
  Future<bool> updateInvoiceItem(
      String itemUuid, double newQty, double newPrice) async {
    try {
      final dbClient = await _db.db;
      final res = await dbClient!.update(
        "InvoiceItems",
        {
          "quantity": newQty,
          "unit_price": newPrice,
          "updated_at": DateTime.now().toIso8601String(),
        },
        where: "uuid = ?",
        whereArgs: [itemUuid],
      );
      if (res > 0) {
        await _syncService.addToQueue("InvoiceItems", itemUuid, "update", {
          "uuid": itemUuid,
          "quantity": newQty,
          "unit_price": newPrice,
        });
        return true;
      }
      return false;
    } catch (e) {
      print("❌ SalesData.updateInvoiceItem error: $e");
      return false;
    }
  }

  // Add a payment to an invoice
  Future<bool> addPayment(String invoiceUuid, double amount) async {
    try {
      final String paymentUuid = Uuid().v4();
      final nowStr = DateTime.now().toIso8601String();
      final data = {
        "uuid": paymentUuid,
        "invoice_uuid": invoiceUuid,
        "Payment_price": amount.toString(),
        "created_at": nowStr,
        "updated_at": nowStr,
      };

      final dbClient = await _db.db;
      final res = await dbClient!.insert("payments", data);

      if (res > 0) {
        await _syncService.addToQueue("payments", paymentUuid, "insert", data);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ SalesData.addPayment error: $e");
      return false;
    }
  }

  // Get payments for a specific invoice
  Future<List<Map<String, dynamic>>> getInvoicePayments(
      String invoiceUuid) async {
    try {
      final res = await _db.readData('''
        SELECT * FROM payments 
        WHERE invoice_uuid = '$invoiceUuid'
        ORDER BY id DESC
      ''');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      print("❌ SalesData.getInvoicePayments error: $e");
      return [];
    }
  }
}
