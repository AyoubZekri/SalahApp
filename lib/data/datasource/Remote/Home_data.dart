import '../../../core/class/Sqldb.dart';

class HomeData {
  final SQLDB _db = SQLDB();

  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final now = DateTime.now();
      final todayStr = "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      final dbClient = await _db.db;
      
      // 1. Today's sales (Total net price of sales invoices created today)
      final salesRes = await dbClient!.rawQuery('''
        SELECT SUM(CAST(Payment_price AS REAL)) as today_sales 
        FROM invoice 
        WHERE type = 'sales' AND date LIKE '$todayStr%'
      ''');
      double todaySales = salesRes.isNotEmpty && salesRes.first['today_sales'] != null 
          ? (salesRes.first['today_sales'] as num).toDouble() 
          : 0.0;

      // 2. Uncollected today (Total sales today - Total payments made for today's sales)
      final paymentsRes = await dbClient.rawQuery('''
        SELECT SUM(CAST(p.Payment_price AS REAL)) as today_paid
        FROM payments p
        JOIN invoice i ON p.invoice_uuid = i.uuid
        WHERE i.type = 'sales' AND i.date LIKE '$todayStr%'
      ''');
      double todayPaid = paymentsRes.isNotEmpty && paymentsRes.first['today_paid'] != null 
          ? (paymentsRes.first['today_paid'] as num).toDouble() 
          : 0.0;
          
      double uncollectedToday = todaySales - todayPaid;
      if (uncollectedToday < 0) uncollectedToday = 0;

      // 3. Total customers
      final custRes = await dbClient.rawQuery('SELECT COUNT(*) as total_customers FROM Customers');
      int totalCustomers = custRes.isNotEmpty && custRes.first['total_customers'] != null 
          ? (custRes.first['total_customers'] as num).toInt() 
          : 0;

      // 4. Today's invoices count
      final invRes = await dbClient.rawQuery('''
        SELECT COUNT(*) as invoices_today 
        FROM invoice 
        WHERE date LIKE '$todayStr%'
      ''');
      int invoicesToday = invRes.isNotEmpty && invRes.first['invoices_today'] != null 
          ? (invRes.first['invoices_today'] as num).toInt() 
          : 0;

      return {
        "todaySales": todaySales,
        "uncollectedToday": uncollectedToday,
        "totalCustomers": totalCustomers,
        "invoicesToday": invoicesToday,
      };
    } catch (e) {
      print("❌ HomeData.getStatistics error: $e");
      return {
        "todaySales": 0.0,
        "uncollectedToday": 0.0,
        "totalCustomers": 0,
        "invoicesToday": 0,
      };
    }
  }
}
