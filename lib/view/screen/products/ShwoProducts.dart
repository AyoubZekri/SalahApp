import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/ProductsController.dart';
import '../../../core/class/Statusrequest.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/showDeleteDialog.dart';
import '../../widget/products/ProductStatCard.dart';
import '../../widget/products/ProductCard.dart';
import '../../widget/products/ProductFormDialog.dart';

class ShwoProducts extends StatefulWidget {
  const ShwoProducts({super.key});

  @override
  State<ShwoProducts> createState() => _ShwoProductsState();
}

class _ShwoProductsState extends State<ShwoProducts> {
  String searchQuery = "";
  String? selectedCategoryUuid;

  @override
  Widget build(BuildContext context) {
    Get.put(Productscontroller());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColor.bgDark : const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text(
          "إدارة المنتجات",
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColor.cardDark, AppColor.bgDark]
                  : [Colors.white, const Color(0xFFF9FAFC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF800000),
        elevation: 4,
        onPressed: () => showProductFormDialog(context, isAddMode: true),
        label: const Row(
          children: [
            Icon(Icons.add_shopping_cart_rounded,
                color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              "منتج جديد",
              style: TextStyle(
                fontFamily: "Cairo",
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GetBuilder<Productscontroller>(
          builder: (controller) {
            // Filter products by name, category, or selected Category filter
            final filteredList = controller.products.where((prod) {
              final name = prod.name?.toLowerCase() ?? "";
              final category = prod.categoryName?.toLowerCase() ?? "";
              final query = searchQuery.toLowerCase();
              final matchesQuery =
                  name.contains(query) || category.contains(query);
              final matchesCategory = selectedCategoryUuid == null ||
                  prod.catUuid == selectedCategoryUuid;
              return matchesQuery && matchesCategory;
            }).toList();

            return Column(
              children: [
                // Top Search Bar & Stat Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      // Stat Summary Card
                      ProductStatCard(count: controller.products.length),
                      const SizedBox(height: 14),
                      // Search TextField
                      TextField(
                        onChanged: (val) {
                          setState(() {
                            searchQuery = val;
                          });
                        },
                        style:
                            const TextStyle(fontFamily: "Cairo", fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "ابحث عن منتج بالاسم أو الفئة...",
                          hintStyle: const TextStyle(
                              fontFamily: "Cairo", fontSize: 13),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF800000)),
                          filled: true,
                          fillColor: isDark ? AppColor.cardDark : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColor.borderDark
                                  : const Color(0xFFEFEFEF),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? AppColor.borderDark
                                  : const Color(0xFFEFEFEF),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Category Filter Tags
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller.categories.length + 1,
                          itemBuilder: (context, index) {
                            final isAll = index == 0;
                            final String title = isAll
                                ? "الكل"
                                : (controller
                                        .categories[index - 1].categorisName ??
                                    "");
                            final String? catUuid = isAll
                                ? null
                                : controller.categories[index - 1].uuid;
                            final bool isSelected =
                                selectedCategoryUuid == catUuid;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategoryUuid = catUuid;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                constraints: const BoxConstraints(minWidth: 80),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF800000)
                                      : (isDark
                                          ? AppColor.cardDark
                                          : Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF800000)
                                        : (isDark
                                            ? AppColor.borderDark
                                            : const Color(0xFFEFEFEF)),
                                    width: 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF800000)
                                                .withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontFamily: "Cairo",
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Products List
                Expanded(
                  child: controller.statusrequest == Statusrequest.loadeng
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF800000)))
                      : filteredList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 80,
                                    color: isDark
                                        ? AppColor.textDarkSub
                                        : AppColor.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    searchQuery.isEmpty
                                        ? "لا توجد منتجات حالياً"
                                        : "لا توجد نتائج بحث تطابق استفسارك",
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final product = filteredList[index];
                                return ProductCard(
                                  product: product,
                                  onEdit: () {
                                    controller.initData(product);
                                    showProductFormDialog(context,
                                        isAddMode: false, product: product);
                                  },
                                  onDelete: () {
                                    showDeleteDialog(
                                      itemName: "المنتج: (${product.name})",
                                      onConfirm: () {
                                        if (product.uuid != null) {
                                          controller
                                              .deleteProduct(product.uuid!);
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
