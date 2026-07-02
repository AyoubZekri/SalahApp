import 'package:get/get.dart';
import '../data/datasource/Remote/Statistics_data.dart';
import '../core/services/Services.dart';

enum FilterType { day, week, month, year }

class StatisticsController extends GetxController {
  final StatisticsData statsData = StatisticsData();

  FilterType currentFilter = FilterType.month;
  DateTime selectedDate = DateTime.now();

  double totalSales = 0.0;
  double totalPurchases = 0.0;
  double totalDebt = 0.0;
  int invoicesCount = 0;

  List<Map<String, dynamic>> breakdownList = [];
  double maxAmount = 100.0;

  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    fetchData();

    if (Get.isRegistered<RefreshService>()) {
      ever(Get.find<RefreshService>().refreshTrigger, (_) {
        fetchData();
      });
    }
  }

  void changeFilter(FilterType type) {
    currentFilter = type;
    fetchData();
  }

  void changeDate(DateTime date) {
    selectedDate = date;
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading = true;
    update();

    DateTime start;
    DateTime end;

    if (currentFilter == FilterType.day) {
      start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      end = start;
    } else if (currentFilter == FilterType.week) {
      int w = selectedDate.weekday; // 1 = Mon .. 7 = Sun
      // Let's make Sunday = 0
      int offset = w == 7 ? 0 : w; 
      start = selectedDate.subtract(Duration(days: offset));
      start = DateTime(start.year, start.month, start.day);
      end = start.add(const Duration(days: 6));
    } else if (currentFilter == FilterType.month) {
      start = DateTime(selectedDate.year, selectedDate.month, 1);
      end = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    } else { // year
      start = DateTime(selectedDate.year, 1, 1);
      end = DateTime(selectedDate.year, 12, 31);
    }

    String startStr = "${start.year.toString().padLeft(4, '0')}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
    String endStr = "${end.year.toString().padLeft(4, '0')}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

    final rawData = await statsData.getRawData(startStr, endStr);
    print("====== STATISTICS RAW DATA ======");
    print("StartStr: $startStr, EndStr: $endStr");
    print("rawData: $rawData");
    print("=================================");
    List<dynamic> invoices = rawData["invoices"];
    List<dynamic> payments = rawData["payments"];

    totalSales = 0.0;
    totalPurchases = 0.0;
    totalDebt = 0.0;
    invoicesCount = invoices.length;
    double totalPaid = 0.0;

    // Grouping structure
    Map<String, Map<String, dynamic>> grouped = {};

    // Initialize groups
    if (currentFilter == FilterType.day) {
      for (int i = 0; i < 24; i++) {
        String p = i.toString().padLeft(2, '0') + ":00";
        grouped[p] = {"period": p, "sales": 0.0, "expenses": 0.0, "invoices_count": 0};
      }
    } else if (currentFilter == FilterType.week) {
      List<String> days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
      for (String d in days) {
        grouped[d] = {"period": d, "sales": 0.0, "expenses": 0.0, "invoices_count": 0};
      }
    } else if (currentFilter == FilterType.month) {
      for (int i = 1; i <= 4; i++) {
        String p = "الأسبوع $i";
        grouped[p] = {"period": p, "sales": 0.0, "expenses": 0.0, "invoices_count": 0};
      }
    } else {
      List<String> months = ['جانفي', 'فيفري', 'مارس', 'أفريل', 'ماي', 'جوان', 'جويلية', 'أوت', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
      for (String m in months) {
        grouped[m] = {"period": m, "sales": 0.0, "expenses": 0.0, "invoices_count": 0};
      }
    }

    for (var inv in invoices) {
      double price = (inv['price'] as num?)?.toDouble() ?? 0.0;
      String type = inv['type'] ?? '';
      String dateStr = inv['date'] ?? ''; // e.g. 2026-06-29 14:30:00

      if (type == 'sales') {
        totalSales += price;
      } else if (type == 'purchases') {
        totalPurchases += price;
      }

      // Determine group key
      String groupKey = "";
      try {
        DateTime d = DateTime.parse(dateStr);
        if (currentFilter == FilterType.day) {
          groupKey = d.hour.toString().padLeft(2, '0') + ":00";
        } else if (currentFilter == FilterType.week) {
          int w = d.weekday; // 1 Mon, 7 Sun
          int offset = w == 7 ? 0 : w; 
          List<String> days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
          groupKey = days[offset];
        } else if (currentFilter == FilterType.month) {
          int weekNum = ((d.day - 1) ~/ 7) + 1;
          if (weekNum > 4) weekNum = 4;
          groupKey = "الأسبوع $weekNum";
        } else {
          List<String> months = ['جانفي', 'فيفري', 'مارس', 'أفريل', 'ماي', 'جوان', 'جويلية', 'أوت', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
          groupKey = months[d.month - 1];
        }

        if (grouped.containsKey(groupKey)) {
          if (type == 'sales') {
            grouped[groupKey]!['sales'] += price;
          } else if (type == 'purchases') {
            grouped[groupKey]!['expenses'] += price;
          }
          grouped[groupKey]!['invoices_count'] += 1;
        }
      } catch (e) {
        // Parse error, ignore
      }
    }

    for (var pay in payments) {
      double paid = (pay['paid'] as num?)?.toDouble() ?? 0.0;
      totalPaid += paid;
    }

    totalDebt = totalSales - totalPaid;
    if (totalDebt < 0) totalDebt = 0;

    breakdownList = grouped.values.toList();
    // No need to sort, it's already in the initialized order

    maxAmount = 0.0;
    for (var item in breakdownList) {
      double sales = item["sales"];
      double expenses = item["expenses"];
      if (sales > maxAmount) maxAmount = sales;
      if (expenses > maxAmount) maxAmount = expenses;
    }
    if (maxAmount == 0.0) maxAmount = 100.0;
    maxAmount = maxAmount * 1.2;

    isLoading = false;
    update();
  }
}
