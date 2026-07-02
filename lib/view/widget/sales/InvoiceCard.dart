import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constant/Colorapp.dart';

class InvoiceCard extends StatelessWidget {
  final Map<String, dynamic> invoice;
  final bool isDark;
  final VoidCallback onTap;

  const InvoiceCard({
    super.key,
    required this.invoice,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String dateStr = invoice["date"] ?? "";
    String formattedDate = dateStr;
    try {
      if (dateStr.isNotEmpty) {
        final parsed = DateTime.parse(dateStr);
        formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(parsed);
      }
    } catch (_) {}

    final double discount = double.tryParse(invoice["discount"]?.toString() ?? "0") ?? 0;
    final double netTotal = double.tryParse(invoice["Payment_price"]?.toString() ?? "0") ?? 0;
    final double subtotal = netTotal + discount;

    final String formattedSub = subtotal % 1 == 0 ? subtotal.toInt().toString() : subtotal.toString();
    final String formattedDiscount = discount % 1 == 0 ? discount.toInt().toString() : discount.toString();
    final String formattedNet = netTotal % 1 == 0 ? netTotal.toInt().toString() : netTotal.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              // Header row (Invoice # and Date)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFF800000).withOpacity(0.06),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            size: 18, color: Color(0xFF800000)),
                        const SizedBox(width: 8),
                        Text(
                          "فاتورة رقم #${invoice["numper"] ?? invoice["id"]}",
                          style: const TextStyle(
                            fontFamily: "Cairo",
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF800000),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Body (Customer and calculations summary)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.withOpacity(0.1),
                          child: Icon(Icons.person_rounded,
                              size: 18,
                              color: isDark ? Colors.white70 : Colors.black54),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice["customer_name"] ?? "عميل غير محدد",
                                style: const TextStyle(
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (invoice["customer_phone"] != null)
                                Text(
                                  invoice["customer_phone"],
                                  style: const TextStyle(
                                    fontFamily: "Cairo",
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Total Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF800000),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "$formattedNet دج",
                            style: const TextStyle(
                              fontFamily: "Cairo",
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 0.6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSummaryItem("الإجمالي", "$formattedSub دج"),
                        _buildSummaryItem("الخصم", "$formattedDiscount دج"),
                        _buildSummaryItem("الصافي", "$formattedNet دج", isBold: true),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String val, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: "Cairo",
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
            color: isBold ? const Color(0xFF800000) : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
