import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/SalesController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustomTextField.dart';

// Custom BottomSheet Content supporting Inline Expansion
class ProductSelectionSheetContent extends StatefulWidget {
  final SalesController controller;
  final bool isDark;
  const ProductSelectionSheetContent(
      {super.key, required this.controller, this.isDark = false});

  @override
  State<ProductSelectionSheetContent> createState() =>
      _ProductSelectionSheetContentState();
}

class _ProductSelectionSheetContentState
    extends State<ProductSelectionSheetContent> {
  int? expandedIndex;
  final qtyController = TextEditingController();
  final customPriceController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "اختر المنتج لإضافته للفاتورة",
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF800000),
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: widget.controller.products.isEmpty
              ? const Center(
                  child: Text(
                    "لا توجد منتجات مسجلة بقاعدة البيانات",
                    style: TextStyle(fontFamily: "Cairo"),
                  ),
                )
              : ListView.builder(
                  itemCount: widget.controller.products.length,
                  itemBuilder: (context, index) {
                    final prod = widget.controller.products[index];
                    final isExpanded = expandedIndex == index;
                    final formattedPrice = prod.price != null
                        ? (prod.price! % 1 == 0
                            ? prod.price!.toInt().toString()
                            : prod.price!.toString())
                        : "0";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: widget.isDark ? AppColor.cardDark : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: widget.isDark
                              ? AppColor.borderDark
                              : const Color(0xFFEFEFEF),
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  const Color(0xFF800000).withOpacity(0.1),
                              child: const Icon(Icons.inventory_2_rounded,
                                  color: Color(0xFF800000)),
                            ),
                            title: Text(
                              prod.name ?? "",
                              style: const TextStyle(
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            subtitle: Text(
                              "الفئة: ${prod.categoryName ?? 'غير مصنف'} - الجنس: ${prod.gender ?? 'غير حدد'}",
                              style: const TextStyle(
                                  fontFamily: "Cairo", fontSize: 11),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "$formattedPrice دج",
                                  style: const TextStyle(
                                      fontFamily: "Cairo",
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF800000)),
                                ),
                                const SizedBox(width: 8),
                                Icon(isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  expandedIndex = null;
                                } else {
                                  expandedIndex = index;
                                  qtyController.text = "";
                                  customPriceController.text = prod.price != null
                                      ? (prod.price! % 1 == 0
                                          ? prod.price!.toInt().toString()
                                          : prod.price!.toString())
                                      : "0";
                                }
                              });
                            },
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 16.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Quantity (Weight) input
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "الكمية (بالميزان / الوحدات)",
                                                style: TextStyle(
                                                    fontFamily: "Cairo",
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              CustomTextField(
                                                controller: qtyController,
                                                hintText: "مثال: 1.5 أو 5",
                                                iconData: Icons.scale_rounded,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                validator: (val) => validInput(
                                                    val!, 20, 1, "decimal"),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Price Override Input
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "سعر بيع مخصص (دج)",
                                                style: TextStyle(
                                                    fontFamily: "Cairo",
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              CustomTextField(
                                                controller:
                                                    customPriceController,
                                                hintText: "السعر",
                                                iconData: Icons
                                                    .monetization_on_rounded,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(
                                                        decimal: true),
                                                validator: (val) => validInput(
                                                    val!, 20, 1, "decimal"),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    // Confirm button inside bottom sheet
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF800000),
                                            Color(0xFFB30000)
                                          ],
                                        ),
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          if (formKey.currentState!
                                              .validate()) {
                                            final qty = double.tryParse(
                                                    qtyController.text) ??
                                                1.0;
                                            final price = double.tryParse(
                                                    customPriceController
                                                        .text) ??
                                                (prod.price ?? 0.0);
                                            widget.controller.addProductToCart(
                                                prod, qty, price);

                                            // Show success feedback

                                            setState(() {
                                              expandedIndex = null;
                                            });
                                          }
                                        },
                                        child: const Text(
                                          "تأكيد وإضافة للسلة",
                                          style: TextStyle(
                                              fontFamily: "Cairo",
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
