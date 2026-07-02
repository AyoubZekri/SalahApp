import '../../../core/class/Sqldb.dart';

class StatisticsData {
  final SQLDB _db = SQLDB();

  // datePrefix: e.g., '2026-06' for a month, '2026' for a year
  Future<Map<String, dynamic>> getOverview(String datePrefix) async {
    try {
      final dbClient = await _db.db;

      // Overview aggregates
      // 1. Total sales
      final salesRes = await dbClient!.rawQuery('''
        SELECT SUM(CAST(Payment_price AS REAL)) as total_sales 
        FROM invoice 
        WHERE type = 'sales' AND date LIKE '$datePrefix%'
      ''');

      // 2. Total purchases
      final purchasesRes = await dbClient.rawQuery('''
        SELECT SUM(CAST(Payment_price AS REAL)) as total_purchases 
        FROM invoice 
        WHERE type = 'purchases' AND date LIKE '$datePrefix%'
      ''');

      // 3. Invoices count
      final countRes = await dbClient.rawQuery('''
        SELECT COUNT(*) as invoices_count 
        FROM invoice 
        WHERE date LIKE '$datePrefix%'
      ''');

      double totalSales = 0.0;
      double totalPurchases = 0.0;
      int invoicesCount = 0;

      if (salesRes.isNotEmpty) {
        totalSales = (salesRes.first['total_sales'] as num?)?.toDouble() ?? 0.0;
      }
      if (purchasesRes.isNotEmpty) {
        totalPurchases = (purchasesRes.first['total_purchases'] as num?)?.toDouble() ?? 0.0;
      }
      if (countRes.isNotEmpty) {
        invoicesCount = (countRes.first['invoices_count'] as num?)?.toInt() ?? 0;
      }

      // Debt calculation (Sales not paid)
      final paymentsRes = await dbClient.rawQuery('''
        SELECT SUM(CAST(p.Payment_price AS REAL)) as total_paid
        FROM payments p
        JOIN invoice i ON p.invoice_uuid = i.uuid
        WHERE i.type = 'sales' AND i.date LIKE '$datePrefix%'
      ''');
      
      double totalPaid = 0.0;
      if (paymentsRes.isNotEmpty) {
        totalPaid = (paymentsRes.first['total_paid'] as num?)?.toDouble() ?? 0.0;
      }

      double totalDebt = totalSales - totalPaid;
      if (totalDebt < 0) totalDebt = 0;

      return {
        "totalSales": totalSales,
        "totalPurchases": totalPurchases,
        "totalDebt": totalDebt,
        "invoicesCount": invoicesCount,
      };
    } catch (e) {
      print("❌ StatisticsData.getOverview error: $e");
      return {
        "totalSales": 0.0,
        "totalPurchases": 0.0,
        "totalDebt": 0.0,
        "invoicesCount": 0,
      };
    }
  }

  // groupByLength: 10 for daily (YYYY-MM-DD), 7 for monthly (YYYY-MM)
  Future<List<Map<String, dynamic>>> getBreakdown(String datePrefix, int groupByLength) async {
    try {
      final dbClient = await _db.db;
      // For breakdown, since SQLite might struggle with CASE WHEN in some versions,
      // we'll fetch sales and purchases separately and merge them in Dart.
      
      final salesRes = await dbClient!.rawQuery('''
        SELECT 
          substr(date, 1, $groupByLength) as period,
          SUM(CAST(Payment_price AS REAL)) as sales,
          COUNT(*) as invoices_count
        FROM invoice
        WHERE type = 'sales' AND date LIKE '$datePrefix%'
        GROUP BY substr(date, 1, $groupByLength)
      ''');

      final purchasesRes = await dbClient.rawQuery('''
        SELECT 
          substr(date, 1, $groupByLength) as period,
          SUM(CAST(Payment_price AS REAL)) as expenses,
          COUNT(*) as invoices_count
        FROM invoice
        WHERE type = 'purchases' AND date LIKE '$datePrefix%'
        GROUP BY substr(date, 1, $groupByLength)
      ''');

      Map<String, Map<String, dynamic>> merged = {};
      
      for (var row in salesRes) {
        String p = row['period'].toString();
        merged[p] = {
          "period": p,
          "sales": (row['sales'] as num?)?.toDouble() ?? 0.0,
          "expenses": 0.0,
          "invoices_count": (row['invoices_count'] as num?)?.toInt() ?? 0,
        };
      }

      for (var row in purchasesRes) {
        String p = row['period'].toString();
        if (merged.containsKey(p)) {
          merged[p]!["expenses"] = (row['expenses'] as num?)?.toDouble() ?? 0.0;
          merged[p]!["invoices_count"] = (merged[p]!["invoices_count"] as int) + ((row['invoices_count'] as num?)?.toInt() ?? 0);
        } else {
          merged[p] = {
            "period": p,
            "sales": 0.0,
            "expenses": (row['expenses'] as num?)?.toDouble() ?? 0.0,
            "invoices_count": (row['invoices_count'] as num?)?.toInt() ?? 0,
          };
        }
      }

      var resultList = merged.values.toList();
      resultList.sort((a, b) => a['period'].compareTo(b['period']));
      return resultList;
    } catch (e) {
      print("❌ StatisticsData.getBreakdown error: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> getRawData(String startDate, String endDate) async {
    try {
      final dbClient = await _db.db;
      DateTime endDt = DateTime.parse(endDate).add(const Duration(days: 1));
      String nextDay = "${endDt.year.toString().padLeft(4, '0')}-${endDt.month.toString().padLeft(2, '0')}-${endDt.day.toString().padLeft(2, '0')}";

      final invoices = await dbClient!.rawQuery('''
        SELECT type, CAST(Payment_price AS REAL) as price, date
        FROM invoice
        WHERE date >= '$startDate' AND date < '$nextDay'
      ''');

      final payments = await dbClient.rawQuery('''
        SELECT p.invoice_uuid, CAST(p.Payment_price AS REAL) as paid, i.date, i.type
        FROM payments p
        JOIN invoice i ON p.invoice_uuid = i.uuid
        WHERE i.date >= '$startDate' AND i.date < '$nextDay' AND i.type = 'sales'
      ''');

      return {
        "invoices": invoices,
        "payments": payments,
      };
    } catch (e) {
      print("❌ StatisticsData.getRawData error: $e");
      return {"invoices": [], "payments": []};
    }
  }
}
