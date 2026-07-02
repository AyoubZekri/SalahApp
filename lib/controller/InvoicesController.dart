import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/class/Statusrequest.dart';
import '../data/datasource/Remote/Sales_data.dart';

class InvoicesController extends GetxController {
  SalesData salesData = SalesData(Get.find());
  Statusrequest statusrequest = Statusrequest.none;

  List<Map<String, dynamic>> invoices = [];
  List<Map<String, dynamic>> filteredInvoices = [];
  
  final searchController = TextEditingController();
  
  int currentTab = 0; // 0 = الكل, 1 = المدفوعة, 2 = غير مدفوعة
  int invoiceTypeTab = 0; // 0 = مبيعات, 1 = مشتريات

  @override
  void onInit() {
    getInvoices();
    super.onInit();
  }

  void changeTab(int index) {
    currentTab = index;
    filterInvoices(searchController.text);
    update();
  }

  void changeTypeTab(int index) {
    invoiceTypeTab = index;
    filterInvoices(searchController.text);
    update();
  }

  Future<void> getInvoices() async {
    try {
      final res = await salesData.getInvoices();
      if (res.isNotEmpty) {
        invoices = res;
        filterInvoices(searchController.text);
        statusrequest = Statusrequest.success;
      } else {
        invoices = [];
        filteredInvoices = [];
        statusrequest = Statusrequest.failure;
      }
    } catch (e) {
      print("❌ getInvoices error: $e");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  void filterInvoices(String query) {
    // Apply Type Filter
    List<Map<String, dynamic>> tempList = invoices.where((inv) {
      if (invoiceTypeTab == 0) return inv["type"] != "purchases";
      return inv["type"] == "purchases";
    }).toList();

    // Apply Tab Filter
    if (currentTab == 1) { // المدفوعة (Paid)
      tempList = tempList.where((inv) {
        final double netTotal = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
        final double totalPaid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
        return totalPaid >= netTotal && netTotal > 0;
      }).toList();
    } else if (currentTab == 2) { // غير مدفوعة (Unpaid)
      tempList = tempList.where((inv) {
        final double netTotal = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
        final double totalPaid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
        return totalPaid < netTotal;
      }).toList();
    }

    // Apply Search Filter
    if (query.isNotEmpty) {
      tempList = tempList.where((inv) {
        final number = inv["numper"]?.toString() ?? "";
        final custName = inv["customer_name"]?.toString()?.toLowerCase() ?? "";
        return number.contains(query) || custName.contains(query.toLowerCase());
      }).toList();
    }

    filteredInvoices = tempList;
    update();
  }

  // Get items details for a specific invoice
  Future<List<Map<String, dynamic>>> getInvoiceItems(String uuid) async {
    return await salesData.getInvoiceItems(uuid);
  }
}
