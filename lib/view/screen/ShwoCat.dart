import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/ShwocatController.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/constant/Colorapp.dart';
import '../../data/model/Categoris_Model.dart';
import '../widget/categoris/CategoryStatCard.dart';
import '../widget/categoris/CategoryCard.dart';
import '../widget/categoris/CategoryFormDialog.dart';
import '../../core/functions/showDeleteDialog.dart';

class ShwoCat extends StatefulWidget {
  const ShwoCat({super.key});

  @override
  State<ShwoCat> createState() => _ShwoCatState();
}

class _ShwoCatState extends State<ShwoCat> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    Get.put(Shwocatcontroller());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColor.bgDark : const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: const Text(
          "إدارة الفئات",
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
        onPressed: () => showCategoryFormDialog(context, isAddMode: true),
        label: const Row(
          children: [
            Icon(Icons.add, color: Colors.white, size: 20),
            SizedBox(width: 6),
            Text(
              "فئة جديدة",
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
        child: GetBuilder<Shwocatcontroller>(
          builder: (controller) {
            // Filter categories based on search query
            final filteredList = controller.Categoris.where((cat) {
              final name = cat.categorisName?.toLowerCase() ?? "";
              return name.contains(searchQuery.toLowerCase());
            }).toList();

            return Column(
              children: [
                // Top Search Bar & Stat Bar (using transparent background to make the page background uniform)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      // Stat Summary Card (separated widget)
                      CategoryStatCard(count: controller.Categoris.length),
                      const SizedBox(height: 14),
                      // Search TextField
                      TextField(
                        onChanged: (val) {
                          setState(() {
                            searchQuery = val;
                          });
                        },
                        style: const TextStyle(fontFamily: "Cairo", fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "ابحث عن فئة...",
                          hintStyle: const TextStyle(fontFamily: "Cairo", fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF800000)),
                          filled: true,
                          fillColor: isDark ? AppColor.cardDark : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Categories List
                Expanded(
                  child: controller.statusrequest == Statusrequest.loadeng
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF800000)))
                      : filteredList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.category_outlined,
                                    size: 80,
                                    color: isDark ? AppColor.textDarkSub : AppColor.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    searchQuery.isEmpty ? "لا توجد فئات حالياً" : "لا توجد نتائج بحث تطابق استفسارك",
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final cat = filteredList[index];
                                return CategoryCard(
                                  cat: cat,
                                  onEdit: () {
                                    controller.initData(cat);
                                    showCategoryFormDialog(context, isAddMode: false, cat: cat);
                                  },
                                  onDelete: () {
                                    showDeleteDialog(
                                      itemName: "الفئة: (${cat.categorisName})",
                                      onConfirm: () {
                                        if (cat.uuid != null) {
                                          controller.deletecat(cat.uuid!);
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
