import 'package:flutter/material.dart';
import '../../../core/constant/Colorapp.dart';

class GeneralOverviewButton extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  const GeneralOverviewButton({
    Key? key,
    required this.theme,
    required this.isDark,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColor.cardDark : AppColor.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? AppColor.borderDark : AppColor.borderLight,
              width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColor.primaryApp.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.analytics,
                      color: AppColor.primaryApp, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  "التقارير المالية العامة",
                  style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
