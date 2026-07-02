import 'package:flutter/material.dart';
import '../../../core/constant/Colorapp.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status; // 'مدفوع' or 'معلق'
  final String weight;
  final String count;
  final String price;

  const ActivityCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.weight,
    required this.count,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isPaid = status == 'مدفوع';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColor.borderDark : const Color(0xFFF3E5E5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? AppColor.softGreen : AppColor.softOrange,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPaid ? AppColor.textGreen : AppColor.textOrange,
                  ),
                ),
              ),
              // Name / Title
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: isDark ? AppColor.textDarkSub : AppColor.grey,
              ),
            ),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              RichText(
                textDirection: TextDirection.rtl,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "المبلغ\n",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: isDark ? AppColor.textDarkSub : AppColor.grey,
                      ),
                    ),
                    TextSpan(
                      text: price,
                      style: TextStyle(
                        fontFamily: "Cairo",
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColor.textDark : const Color(0xFF800000),
                      ),
                    ),
                  ],
                ),
              ),
              // Count
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "الرؤوس",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isDark ? AppColor.textDarkSub : AppColor.grey,
                    ),
                  ),
                  Text(
                    count,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Weight
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "الوزن",
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isDark ? AppColor.textDarkSub : AppColor.grey,
                    ),
                  ),
                  Text(
                    weight,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
