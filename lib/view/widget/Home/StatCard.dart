import 'package:flutter/material.dart';
import '../../../core/constant/Colorapp.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final String? percentage;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : const Color(0xFFFBF4F4), // Light pinkish-brown in light mode
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColor.borderDark : const Color(0xFFF3E5E5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: const Color(0xFF800000), // Primary maroon color
                size: 24,
              ),
              if (percentage != null)
                Row(
                  children: [
                    Text(
                      percentage!,
                      style: const TextStyle(
                        color: AppColor.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    const Icon(
                      Icons.trending_up,
                      color: AppColor.green,
                      size: 14,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: isDark ? AppColor.textDarkSub : AppColor.textLightSub,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColor.textDark : const Color(0xFF800000),
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: isDark ? AppColor.textDarkSub.withOpacity(0.7) : AppColor.grey,
            ),
          ),
        ],
      ),
    );
  }
}
