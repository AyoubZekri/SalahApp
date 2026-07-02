import 'package:flutter/material.dart';
import '../../../../core/constant/Colorapp.dart';
import '../../../../data/model/Customers_Model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerData customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final String name = customer.username ?? "";
    final String phone = customer.phoneNumper ?? "";
    final String firstLetter = name.isNotEmpty ? name.substring(0, 1) : "ع";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF),
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF1F1), Color(0xFFFDE8E8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            firstLetter,
            style: const TextStyle(
              fontFamily: "Cairo",
              color: Color(0xFF800000),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Icon(Icons.phone, size: 14, color: isDark ? Colors.grey : Colors.black54),
              const SizedBox(width: 4),
              Text(
                phone,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  color: isDark ? AppColor.textDarkSub : AppColor.textLightSub,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit Button
            Container(
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                onPressed: onEdit,
              ),
            ),
            // Delete Button
            Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
