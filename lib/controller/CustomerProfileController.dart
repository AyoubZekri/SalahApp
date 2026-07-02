import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/class/Statusrequest.dart';
import '../core/services/Services.dart';
import '../data/datasource/Remote/Sales_data.dart';
import '../data/model/Customers_Model.dart';

class CustomerProfileController extends GetxController {
  final SalesData salesData = SalesData(Get.find());
  Statusrequest statusrequest = Statusrequest.none;

  late CustomerData customer;

  List<Map<String, dynamic>> allInvoices = [];
  List<Map<String, dynamic>> filteredInvoices = [];

  double totalDebt = 0; // Total
  double totalPaid = 0; // Paid
  double totalRemaining = 0; // Remaining

  int currentTab = 0; // 0 = الكل, 1 = المدفوعة, 2 = غير مدفوعة
  int invoiceTypeTab = 0; // 0 = مبيعات, 1 = مشتريات

  @override
  void onInit() {
    customer = Get.arguments;
    getInvoicesForCustomer();
    super.onInit();
  }

  void changeTab(int index) {
    currentTab = index;
    filterInvoices();
  }

  void changeTypeTab(int index) {
    invoiceTypeTab = index;
    filterInvoices();
  }

  Future<void> getInvoicesForCustomer() async {
    statusrequest = Statusrequest.loadeng;
    update();

    try {
      final res = await salesData.getInvoices();
      if (res.isNotEmpty) {
        // Filter only this customer's invoices
        allInvoices = res.where((inv) => inv["Customers_uuid"] == customer.uuid).toList();
        
        // Calculate Totals
        totalDebt = 0;
        totalPaid = 0;
        
        for (var inv in allInvoices) {
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
        totalRemaining = totalDebt - totalPaid;

        filterInvoices();
        statusrequest = Statusrequest.success;
      } else {
        allInvoices = [];
        filteredInvoices = [];
        statusrequest = Statusrequest.failure;
      }
    } catch (e) {
      print("❌ getInvoicesForCustomer error: $e");
      statusrequest = Statusrequest.failure;
    }
    update();
  }

  void filterInvoices() {
    // Filter by Type First
    List<Map<String, dynamic>> typeFiltered = allInvoices.where((inv) {
      if (invoiceTypeTab == 0) return inv["type"] != "purchases";
      return inv["type"] == "purchases";
    }).toList();

    // Filter by Payment Status
    if (currentTab == 0) { // الكل
      filteredInvoices = typeFiltered;
    } else if (currentTab == 1) { // المدفوعة
      filteredInvoices = typeFiltered.where((inv) {
        final double netTotal = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
        final double paid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
        return paid >= netTotal && netTotal > 0;
      }).toList();
    } else if (currentTab == 2) { // غير مدفوعة
      filteredInvoices = typeFiltered.where((inv) {
        final double netTotal = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
        final double paid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
        return paid < netTotal;
      }).toList();
    }
    update();
  }

  Future<void> payDebt(double amount) async {
    if (amount <= 0) return;
    
    statusrequest = Statusrequest.loadeng;
    update();

    try {
      // get invoices that are unpaid or partially paid
      List<Map<String, dynamic>> unpaidInvoices = allInvoices.where((inv) {
        if (inv["type"] == "purchases") return false;
        double netTotal = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
        double paid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
        return (netTotal - paid) > 0;
      }).toList();

      // Sort oldest first (ascending by ID or Date)
      unpaidInvoices.sort((a, b) => (a["id"] as int? ?? 0).compareTo(b["id"] as int? ?? 0));

      double remainingAmountToPay = amount;

      for (var inv in unpaidInvoices) {
        if (remainingAmountToPay <= 0) break;

        double netTotal = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
        double paid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
        double invoiceDebt = netTotal - paid;

        double paymentForThisInvoice = remainingAmountToPay > invoiceDebt ? invoiceDebt : remainingAmountToPay;
        
        await salesData.addPayment(inv["uuid"], paymentForThisInvoice);
        
        remainingAmountToPay -= paymentForThisInvoice;
      }

      Get.back(); // close dialog
      if (Get.isRegistered<RefreshService>()) {
        Get.find<RefreshService>().fire();
      }
      getInvoicesForCustomer(); // reload
    } catch(e) {
      statusrequest = Statusrequest.failure;
      update();
    }
  }

  Future<void> paySupplierDebt(double amount) async {
    if (amount <= 0) return;
    
    statusrequest = Statusrequest.loadeng;
    update();

    try {
      // get invoices that are unpaid or partially paid (purchases only)
      List<Map<String, dynamic>> unpaidPurchases = allInvoices.where((inv) {
        if (inv["type"] != "purchases") return false;
        double netTotal = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
        double paid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
        return (netTotal - paid) > 0;
      }).toList();

      // Sort oldest first (ascending by ID or Date)
      unpaidPurchases.sort((a, b) => (a["id"] as int? ?? 0).compareTo(b["id"] as int? ?? 0));

      double remainingAmountToPay = amount;

      for (var inv in unpaidPurchases) {
        if (remainingAmountToPay <= 0) break;

        double netTotal = double.tryParse(inv["Payment_price"]?.toString() ?? "0") ?? 0.0;
        double paid = double.tryParse(inv["total_paid"]?.toString() ?? "0") ?? 0.0;
        double invoiceDebt = netTotal - paid;

        double paymentForThisInvoice = remainingAmountToPay > invoiceDebt ? invoiceDebt : remainingAmountToPay;
        
        await salesData.addPayment(inv["uuid"], paymentForThisInvoice);
        
        remainingAmountToPay -= paymentForThisInvoice;
      }

      if (Get.isRegistered<RefreshService>()) {
        Get.find<RefreshService>().fire();
      }
      await getInvoicesForCustomer();
    } catch (e) {
      print("paySupplierDebt error: $e");
      statusrequest = Statusrequest.failure;
      update();
    }
  }
}
