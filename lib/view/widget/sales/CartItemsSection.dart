import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/SalesController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustomTextField.dart';

class CartItemsSection extends StatelessWidget {
  final SalesController controller;
  final bool isDark;

  const CartItemsSection({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (controller.cartItems.isEmpty) {
      return _buildEmptyCartPlaceholder();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.cartItems.length,
      itemBuilder: (context, index) {
        final item = controller.cartItems[index];
        return _buildCartItemTile(context, index, item);
      },
    );
  }

  Widget _buildEmptyCartPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF)),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_basket_outlined,
              size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Text(
            "لم يتم إضافة أي منتج بعد",
            style: TextStyle(
                fontFamily: "Cairo", color: Colors.grey, fontSize: 13),
          )
        ],
      ),
    );
  }

  Widget _buildCartItemTile(BuildContext context, int index, Map<String, dynamic> item) {
    final double price = item["price"];
    final double quantity = item["quantity"];
    final double total = price * quantity;

    final String formattedPrice =
        price % 1 == 0 ? price.toInt().toString() : price.toString();
    final String formattedQty =
        quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString();
    final String formattedTotal =
        total % 1 == 0 ? total.toInt().toString() : total.toString();

    return InkWell(
      onTap: () => _showEditCartItemDialog(context, index, item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColor.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isDark ? AppColor.borderDark : const Color(0xFFF3F4F6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item["name"] ?? "",
                        style: const TextStyle(
                            fontFamily: "Cairo",
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_note_rounded,
                          size: 16, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "سعر الوحدة: $formattedPrice دج  ×  الكمية: $formattedQty",
                    style: const TextStyle(
                        fontFamily: "Cairo", fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  "$formattedTotal دج",
                  style: const TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF800000),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: Colors.red, size: 22),
                  onPressed: () => controller.removeProductFromCart(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCartItemDialog(BuildContext context, int index, Map<String, dynamic> item) {
    final double qty = double.tryParse(item["quantity"].toString()) ?? 1.0;
    final double price = double.tryParse(item["price"].toString()) ?? 0.0;
    
    final qtyController = TextEditingController(
        text: qty % 1 == 0 ? qty.toInt().toString() : qty.toString());
    final priceController = TextEditingController(
        text: price % 1 == 0 ? price.toInt().toString() : price.toString());
    final formKey = GlobalKey<FormState>();

    Get.defaultDialog(
      title: "تعديل الكمية أو السعر",
      titleStyle: TextStyle(
        fontFamily: "Cairo",
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: isDark ? Colors.white : const Color(0xFF800000),
      ),
      backgroundColor: isDark ? AppColor.cardDark : Colors.white,
      radius: 18,
      contentPadding: const EdgeInsets.all(20),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "المنتج: ${item["name"]}",
                style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 14),

              // Quantity
              Text(
                "الكمية",
                style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: qtyController,
                hintText: "مثال: 1.5 أو 5",
                iconData: Icons.scale_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => validInput(val!, 20, 1, "decimal"),
              ),
              const SizedBox(height: 14),

              // Price override
              Text(
                "سعر البيع المخصص (دج)",
                style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: priceController,
                hintText: "السعر المخصص",
                iconData: Icons.monetization_on_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => validInput(val!, 20, 1, "decimal"),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: isDark ? Colors.white54 : Colors.grey.shade300),
                        ),
                        onPressed: () => Get.back(),
                        child: Text(
                          "إلغاء",
                          style: TextStyle(
                              fontFamily: "Cairo",
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold),
                        ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF800000), Color(0xFFB30000)],
                        ),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final qty =
                                double.tryParse(qtyController.text) ?? 1.0;
                            final price =
                                double.tryParse(priceController.text) ?? 0.0;
                            controller.updateCartItemQuantity(index, qty);
                            controller.updateCartItemPrice(index, price);
                            Get.back();
                          }
                        },
                        child: const Text(
                          "حفظ",
                          style: TextStyle(
                              fontFamily: "Cairo",
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
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
