import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../core/class/Statusrequest.dart';
import '../core/functions/Snacpar.dart';
import '../core/services/Services.dart';
import '../data/datasource/Remote/Sales_data.dart';
import '../data/model/Customers_Model.dart';
import 'CustomerProfileController.dart';

class PurchasesController extends GetxController {
  final SalesData salesData = SalesData(Get.find());
  Statusrequest statusrequest = Statusrequest.none;

  List<CustomerData> customers = [];

  // Selected customer for this purchase
  CustomerData? selectedCustomer;
  double customerOldDebt = 0.0;

  // Items added to purchase cart
  // Layout: { "uuid": String, "name": String, "price": double, "quantity": double }
  List<Map<String, dynamic>> cartItems = [];

  final discountController = TextEditingController();
  final paidAmountController = TextEditingController();

  // Fetch initial customers
  Future<void> loadInitialData() async {
    update();
    try {
      final custRes = await salesData.getCustomers();
      customers = custRes.map((e) => CustomerData.fromJson(e)).toList();

      if (Get.arguments != null && Get.arguments["customer"] != null) {
        final custArg = Get.arguments["customer"];
        selectedCustomer = customers.firstWhereOrNull((c) => c.uuid == custArg.uuid) ?? custArg;
        if (selectedCustomer != null) {
          fetchCustomerDebt(selectedCustomer!.uuid!);
        }
      }

      statusrequest = Statusrequest.success;
    } catch (e) {
      print("❌ PurchasesController.loadInitialData error: $e");
      statusrequest = Statusrequest.serverfailure;
    }
    update();
  }

  Future<void> fetchCustomerDebt(String customerUuid) async {
    try {
      final res = await salesData.getInvoices();
      final customerInvoices = res.where((inv) => inv["Customers_uuid"] == customerUuid).toList();
      
      double totalDebt = 0;
      double totalPaid = 0;
      for (var inv in customerInvoices) {
        final isPurchase = inv["type"] == "purchases";
        final netTotal = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
        final paid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
        
        if (isPurchase) {
          totalPaid += (netTotal - paid);
        } else {
          totalDebt += netTotal;
          totalPaid += paid;
        }
      }
      customerOldDebt = totalDebt - totalPaid;
      update();
    } catch (e) {
      print("❌ fetchCustomerDebt error: $e");
    }
  }

  // Cart operations
  void addProductToCart(String name, double quantity, double price) {
    if (name.trim().isEmpty || quantity <= 0 || price < 0) return;
    
    cartItems.add({
      "uuid": Uuid().v4(), // generate custom uuid since it's not from DB products
      "name": name,
      "price": price,
      "quantity": quantity,
    });
    update();
  }

  void updateProductInCart(int index, String name, double quantity, double price) {
    if (index >= 0 && index < cartItems.length) {
      if (name.trim().isEmpty || quantity <= 0 || price < 0) return;
      cartItems[index] = {
        "uuid": cartItems[index]["uuid"],
        "name": name,
        "price": price,
        "quantity": quantity,
      };
      update();
    }
  }

  void removeProductFromCart(String itemUuid) {
    cartItems.removeWhere((element) => element["uuid"] == itemUuid);
    update();
  }

  void updateProductQuantity(String itemUuid, double newQty) {
    if (newQty <= 0) {
      removeProductFromCart(itemUuid);
      return;
    }
    int index = cartItems.indexWhere((element) => element["uuid"] == itemUuid);
    if (index != -1) {
      cartItems[index]["quantity"] = newQty;
      update();
    }
  }

  void updateProductPrice(String itemUuid, double newPrice) {
    if (newPrice < 0) return;
    int index = cartItems.indexWhere((element) => element["uuid"] == itemUuid);
    if (index != -1) {
      cartItems[index]["price"] = newPrice;
      update();
    }
  }

  // Calculations
  double get subtotal {
    double total = 0.0;
    for (var item in cartItems) {
      total += (item["price"] as double) * (item["quantity"] as double);
    }
    return total;
  }

  double get discountAmount {
    return double.tryParse(discountController.text) ?? 0.0;
  }

  double get netTotal {
    double net = subtotal - discountAmount;
    return net < 0 ? 0.0 : net;
  }

  double get paidAmount {
    if (paidAmountController.text.trim().isEmpty) {
      return 0.0;
    }
    return double.tryParse(paidAmountController.text) ?? 0.0;
  }

  // Save transaction to DB
  Future<void> checkout() async {
    if (selectedCustomer == null) {
      showSnackbar("تنبيه", "الرجاء اختيار المورد لإتمام فاتورة الشراء",
          Colors.amber.shade800);
      return;
    }
    if (cartItems.isEmpty) {
      showSnackbar("تنبيه", "سلة المشتريات فارغة! قم بإضافة منتجات أولاً",
          Colors.amber.shade800);
      return;
    }

    update();

    final success = await salesData.saveInvoice(
      customerUuid: selectedCustomer?.uuid,
      netTotal: netTotal,
      discount: discountAmount,
      items: cartItems,
      type: "purchases", // Explicitly passing purchases type
    );

    if (success) {
      statusrequest = Statusrequest.success;

      // Note: A purchase reduces customer debt in CustomerProfileController.
      // If paidAmount is > 0, it means we PAID cash to the customer. We should record this payment.
      // We record the cash given by the user to the customer to track cash flow and reduce the debt-payment effect.
      if (paidAmount > 0) {
        try {
          final allInvoices = await salesData.getInvoices();
          // Find the newly inserted purchase invoice (highest id for this customer with type purchases)
          final newInvoice = allInvoices.firstWhere(
            (inv) => inv["Customers_uuid"] == selectedCustomer!.uuid && inv["type"] == "purchases",
          );
          if (newInvoice != null) {
            await salesData.addPayment(newInvoice["uuid"], paidAmount);
          }
        } catch (e) {
          print("Error recording purchase payment: $e");
        }
      }

      cartItems.clear();
      discountController.clear();
      paidAmountController.clear();
      selectedCustomer = null;
      
      if (Get.isRegistered<CustomerProfileController>()) {
        Get.find<CustomerProfileController>().getInvoicesForCustomer();
      }
      if (Get.isRegistered<RefreshService>()) {
        Get.find<RefreshService>().fire();
      }
      
      Get.back();
      showSnackbar("نجاح", "تم تسجيل وحفظ فاتورة الشراء بنجاح", Colors.green);
    } else {
      statusrequest = Statusrequest.failure;
      showSnackbar("خطأ", "فشل حفظ الفاتورة بقاعدة البيانات", Colors.red);
    }
    update();
  }

  @override
  void onInit() {
    loadInitialData();
    discountController.addListener(() => update());
    paidAmountController.addListener(() => update());
    super.onInit();
  }

  @override
  void onClose() {
    discountController.dispose();
    paidAmountController.dispose();
    super.onClose();
  }
}
