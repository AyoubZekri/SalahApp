import '../../../core/class/Sqldb.dart';

class FinancialOverviewData {
  final SQLDB sqldb = SQLDB();

  Future<List<Map<String, dynamic>>> getInvoicesByDateRange(String startStr, String endStr) async {
    // Fetch invoices within the range with total paid
    return await sqldb.readData('''
      SELECT 
        i.type, 
        CAST(i.Payment_price AS REAL) as price, 
        i.date,
        (SELECT SUM(CAST(p.Payment_price AS REAL)) FROM payments p WHERE p.invoice_uuid = i.uuid) as paid
      FROM invoice i
      WHERE i.date >= '$startStr' AND i.date < '$endStr'
    ''');
  }
}
