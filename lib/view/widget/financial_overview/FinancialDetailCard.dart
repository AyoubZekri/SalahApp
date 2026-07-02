import 'package:flutter/material.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/format_number.dart';

class FinancialDetailCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;

  const FinancialDetailCard({
    Key? key,
    required this.item,
    required this.isDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : AppColor.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Header
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: AppColor.primaryApp, size: 20),
              const SizedBox(width: 8),
              Text(
                item["period"],
                style: TextStyle(
                  fontFamily: "Cairo",
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: isDark ? Colors.white10 : Colors.grey[200], height: 1),
          ),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat("المبيعات", formatAmount(item["sales"]), Colors.blue, isDark),
              _buildMiniStat("الديون", formatAmount(item["debts"]), Colors.orange, isDark),
              _buildMiniStat("المصاريف", formatAmount(item["expenses"]), Colors.red, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String title, String amount, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontFamily: "Cairo",
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: TextStyle(
              fontFamily: "Cairo",
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
