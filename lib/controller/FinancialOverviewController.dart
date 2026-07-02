import 'package:get/get.dart';
import '../data/datasource/Remote/FinancialOverview_data.dart';
import 'package:intl/intl.dart';

class FinancialOverviewController extends GetxController {
  final FinancialOverviewData financialData = FinancialOverviewData();

  DateTime? startDate;
  DateTime? endDate;
  String periodLabel = "";

  bool isLoading = true;

  int invoicesCount = 0;
  double sales = 0.0;
  double expenses = 0.0;
  double debts = 0.0;

  List<Map<String, dynamic>> detailedList = [];

  // Initialize with selected dates and fetch
  void initData(DateTime start, DateTime end, String label) {
    startDate = start;
    endDate = end;
    periodLabel = label;
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    update();

    if (startDate == null || endDate == null) return;

    // We add one day to endDate and use < in SQL to catch all times including ISO8601 'T' or space
    DateTime nextDay = DateTime(endDate!.year, endDate!.month, endDate!.day).add(const Duration(days: 1));

    String startStr = DateFormat('yyyy-MM-dd').format(startDate!);
    String endStr = DateFormat('yyyy-MM-dd').format(nextDay);

    // Fetch invoices within the range with total paid
    List<Map<String, dynamic>> invoices = await financialData.getInvoicesByDateRange(startStr, endStr);

    invoicesCount = invoices.length;
    sales = 0.0;
    expenses = 0.0;
    debts = 0.0;
    
    // Structure for grouping the detailed list
    Duration diff = endDate!.difference(startDate!);
    bool groupByMonth = diff.inDays > 60; 

    Map<String, Map<String, dynamic>> grouped = {};

    for (var inv in invoices) {
      double price = (inv['price'] as num?)?.toDouble() ?? 0.0;
      double paid = (inv['paid'] as num?)?.toDouble() ?? 0.0;
      String type = inv['type'] ?? '';
      String dateStr = inv['date'] ?? '';

      double currentDebt = price - paid;
      if (currentDebt < 0) currentDebt = 0; // Just in case

      if (type == 'sales') {
        sales += price;
        debts += currentDebt;
      } else if (type == 'purchases') {
        expenses += price;
      }

      // Determine grouping key
      if (dateStr.isNotEmpty) {
        try {
          DateTime d = DateTime.parse(dateStr);
          String groupKey;
          if (groupByMonth) {
            groupKey = DateFormat('MMM yyyy').format(d);
          } else {
            groupKey = DateFormat('dd MMM yyyy').format(d);
          }

          if (!grouped.containsKey(groupKey)) {
            grouped[groupKey] = {"period": groupKey, "sales": 0.0, "debts": 0.0, "expenses": 0.0, "rawDate": d};
          }
          
          if (type == 'sales') {
            grouped[groupKey]!["sales"] += price;
            grouped[groupKey]!["debts"] += currentDebt;
          } else if (type == 'purchases') {
            grouped[groupKey]!["expenses"] += price;
          }

        } catch (e) {
          // Ignore invalid dates
        }
      }
    }

    // Convert map to list and sort descending by date
    detailedList = grouped.values.toList();
    detailedList.sort((a, b) => (b["rawDate"] as DateTime).compareTo(a["rawDate"] as DateTime));

    isLoading = false;
    update();
  }
}
