import 'package:flutter/material.dart';
import '../../../../core/constant/Colorapp.dart';
import '../../../../data/model/Products_Model.dart';

class ProductCard extends StatelessWidget {
  final ProductData product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final String name = product.name ?? "";
    final String formattedPrice = product.price != null
        ? (product.price! % 1 == 0
            ? product.price!.toInt().toString()
            : product.price!.toString())
        : "0";
    final String priceStr = "$formattedPrice دج";
    final String category = product.categoryName ?? "غير مصنف";
    final String gender = product.gender ?? "غير محدد";

    final isMale = gender == "ذكر" || gender == "Male";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColor.borderDark : const Color(0xFFF3F4F6),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icon + Product Name & Price Tag
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Beautiful Icon Frame with soft gradient
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isMale
                            ? [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)]
                            : [
                                const Color(0xFFFCE7F3),
                                const Color(0xFFFBCFE8)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isMale ? Icons.male_rounded : Icons.female_rounded,
                      color:
                          isMale ? Colors.blue.shade700 : Colors.pink.shade700,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontFamily: "Cairo",
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Premium Price Tag
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF800000).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF800000).withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      priceStr,
                      style: const TextStyle(
                        fontFamily: "Cairo",
                        color: Color(0xFF800000),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 0.8),
              const SizedBox(height: 12),
              // Footer: Gender Badge + Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gender Info Badge
                  Row(
                    children: [
                      // Icon(
                      //   Icons.wc,
                      //   size: 16,
                      //   color: isDark
                      //       ? AppColor.textDarkSub
                      //       : AppColor.textLightSub,
                      // ),
                      // const SizedBox(width: 6),
                      Text(
                        "الجنس: $gender",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColor.textDarkSub
                              : AppColor.textLightSub,
                        ),
                      ),
                    ],
                  ),
                  // Actions buttons
                  Row(
                    children: [
                      // Edit Button
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: Colors.blue, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete Button
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              color: Colors.red, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
