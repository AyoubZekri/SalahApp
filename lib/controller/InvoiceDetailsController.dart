import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/class/Statusrequest.dart';
import '../data/datasource/Remote/Sales_data.dart';
import 'InvoicesController.dart';
import '../core/services/InvoicePdfService.dart';
import '../core/functions/Snacpar.dart';
import '../core/services/Services.dart';

class InvoiceDetailsController extends GetxController {
  final SalesData salesData = SalesData(Get.find());
  Statusrequest statusrequest = Statusrequest.none;

  late Map<String, dynamic> invoice;
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> payments = [];

  double discount = 0.0;
  double netTotal = 0.0;
  double subtotal = 0.0;
  double totalPaid = 0.0;
  double remaining = 0.0;

  bool isPaid = false;
  bool isPartiallyPaid = false;

  @override
  void onInit() {
    super.onInit();
    // The invoice should be passed as arguments when navigating
    invoice = Map<String, dynamic>.from(Get.arguments as Map<String, dynamic>);
    discount = double.tryParse(invoice["discount"]?.toString() ?? "0") ?? 0.0;
    netTotal =
        double.tryParse(invoice["Payment_price"]?.toString() ?? "0") ?? 0.0;
    loadInvoiceData();
  }

  Future<void> loadInvoiceData() async {
    statusrequest = Statusrequest.loadeng;
    update();

    try {
      items = await salesData.getInvoiceItems(invoice["uuid"]);
      payments = await salesData.getInvoicePayments(invoice["uuid"]);

      _calculateTotals();

      statusrequest = Statusrequest.success;
    } catch (e) {
      print("❌ Error loading invoice data: $e");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  void _calculateTotals() {
    subtotal = 0.0;
    for (var item in items) {
      double qty = double.tryParse(item["quantity"]?.toString() ?? "1") ?? 1.0;
      double price =
          double.tryParse(item["unit_price"]?.toString() ?? "0") ?? 0.0;
      subtotal += (qty * price);
    }

    netTotal = subtotal - discount;
    if (netTotal < 0) netTotal = 0; // Discount shouldn't make total negative

    totalPaid = 0.0;
    for (var payment in payments) {
      totalPaid +=
          double.tryParse(payment["Payment_price"]?.toString() ?? "0") ?? 0.0;
    }

    remaining = netTotal - totalPaid;

    if (remaining <= 0) {
      isPaid = true;
      isPartiallyPaid = false;
      remaining = 0.0;
    } else if (totalPaid > 0) {
      isPaid = false;
      isPartiallyPaid = true;
    } else {
      isPaid = false;
      isPartiallyPaid = false;
    }
  }

  Future<void> addPayment(double amount) async {
    if (amount <= 0) return;

    statusrequest = Statusrequest.loadeng;
    update();

    bool success = await salesData.addPayment(invoice["uuid"], amount);
    if (success) {
      if (Get.isRegistered<RefreshService>()) {
        Get.find<RefreshService>().fire();
      }
      await loadInvoiceData();
    } else {
      showSnackbar("خطأ", "فشل في إضافة الدفعة", Colors.red);
      statusrequest = Statusrequest.failure;
      update();
    }
  }

  Future<void> updateDiscount(double newDiscount) async {
    statusrequest = Statusrequest.loadeng;
    update();

    bool success =
        await salesData.updateInvoiceDiscount(invoice["uuid"], newDiscount);
    if (success) {
      discount = newDiscount;
      _calculateTotals();
      // Update invoice total payment_price in DB if discount changes
      await salesData.updateInvoiceTotal(invoice["uuid"], netTotal);

      invoice["discount"] = discount.toString();
      invoice["Payment_price"] = netTotal.toString();
    } else {
      showSnackbar("خطأ", "فشل في تحديث الخصم", Colors.red);
    }
    statusrequest = Statusrequest.success;
    update();

    // Refresh the invoices list in the background
    if (Get.isRegistered<InvoicesController>()) {
      Get.find<InvoicesController>().getInvoices();
    }
    if (Get.isRegistered<RefreshService>()) {
      Get.find<RefreshService>().fire();
    }
  }

  Future<void> deleteItem(String itemUuid) async {
    statusrequest = Statusrequest.loadeng;
    update();

    bool success = await salesData.deleteInvoiceItem(itemUuid);
    if (success) {
      items.removeWhere((element) => element["uuid"] == itemUuid);
      _calculateTotals();
      await salesData.updateInvoiceTotal(invoice["uuid"], netTotal);
      invoice["Payment_price"] = netTotal.toString();
    } else {
      showSnackbar("خطأ", "فشل في حذف المنتج", Colors.red);
    }
    statusrequest = Statusrequest.success;
    update();

    if (Get.isRegistered<InvoicesController>()) {
      Get.find<InvoicesController>().getInvoices();
    }
    if (Get.isRegistered<RefreshService>()) {
      Get.find<RefreshService>().fire();
    }
  }

  Future<void> updateItem(
      String itemUuid, double newQty, double newPrice) async {
    statusrequest = Statusrequest.loadeng;
    update();

    bool success =
        await salesData.updateInvoiceItem(itemUuid, newQty, newPrice);
    if (success) {
      await loadInvoiceData(); // Reload items to reflect changes
      await salesData.updateInvoiceTotal(invoice["uuid"], netTotal);
      invoice["Payment_price"] = netTotal.toString();
    } else {
      showSnackbar("خطأ", "فشل في تحديث المنتج", Colors.red);
      statusrequest = Statusrequest.failure;
      update();
    }

    if (Get.isRegistered<InvoicesController>()) {
      Get.find<InvoicesController>().getInvoices();
    }
    if (Get.isRegistered<RefreshService>()) {
      Get.find<RefreshService>().fire();
    }
  }

  Future<void> deleteInvoice() async {
    bool success = await salesData.deleteInvoice(invoice["uuid"]);
    if (success) {
      if (Get.isRegistered<InvoicesController>()) {
        Get.find<InvoicesController>().getInvoices();
      }
      if (Get.isRegistered<RefreshService>()) {
        Get.find<RefreshService>().fire();
      }
      Get.back(); // Go back to invoices list
    } else {
      showSnackbar("خطأ", "فشل في حذف الفاتورة", Colors.red);
    }
  }

  Future<void> exportToPdf() async {
    await InvoicePdfService.generateAndPrintInvoice(
      invoice: invoice,
      items: items,
      subtotal: subtotal,
      discount: discount,
      netTotal: netTotal,
      totalPaid: totalPaid,
      remaining: remaining,
    );
  }
}
