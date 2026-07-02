import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/InvoiceDetailsController.dart';
import '../../../core/class/Statusrequest.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/showDeleteDialog.dart';
import '../../../core/functions/format_number.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  const InvoiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InvoiceDetailsController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColor.bgDark : const Color(0xFFF9FAFC);
    final cardColor = isDark ? AppColor.cardDark : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "تفاصيل الفاتورة #${controller.invoice["numper"] ?? controller.invoice["id"]}",
          style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.cardColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF800000)),
            onPressed: () => controller.exportToPdf(),
            tooltip: "طباعة/تصدير الفاتورة",
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            onPressed: () => _confirmDeleteInvoice(context, controller),
            tooltip: "حذف الفاتورة",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GetBuilder<InvoiceDetailsController>(
          builder: (controller) {
            if (controller.statusrequest == Statusrequest.loadeng) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF800000)),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.person_pin_rounded, color: Color(0xFF800000), size: 24),
                                SizedBox(width: 8),
                                Text(
                                  "معلومات العميل",
                                  style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF800000)),
                                ),
                              ],
                            ),
                            _buildPaymentStatusBadge(controller),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          "الاسم: ${controller.invoice["customer_name"] ?? 'عميل غير محدد'}",
                          style: const TextStyle(fontFamily: "Cairo", fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        if (controller.invoice["customer_phone"] != null && controller.invoice["customer_phone"].toString().isNotEmpty)
                          Text(
                            "الهاتف: ${controller.invoice["customer_phone"]}",
                            style: const TextStyle(fontFamily: "Cairo", fontSize: 14, color: Colors.grey),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          "التاريخ: ${controller.invoice["date"]?.split('T').first ?? ''}",
                          style: const TextStyle(fontFamily: "Cairo", fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Products List
                  const Row(
                    children: [
                      Icon(Icons.shopping_cart_rounded, color: Color(0xFF800000), size: 22),
                      SizedBox(width: 8),
                      Text(
                        "المنتجات المشتراة:",
                        style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (controller.items.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: const Center(
                        child: Text(
                          "لا توجد منتجات في هذه الفاتورة", 
                          style: TextStyle(fontFamily: "Cairo", color: Colors.grey, fontSize: 15)
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = controller.items[index];
                        final double qty = double.tryParse(item["quantity"]?.toString() ?? "1") ?? 1.0;
                        final double unitPrice = double.tryParse(item["unit_price"]?.toString() ?? "0") ?? 0.0;
                        final double total = qty * unitPrice;

                        final formattedQty = qty % 1 == 0 ? qty.toInt().toString() : qty.toString();
                        final formattedPrice = unitPrice % 1 == 0 ? unitPrice.toInt().toString() : unitPrice.toString();
                        final formattedTotal = total % 1 == 0 ? total.toInt().toString() : total.toString();

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item["product_name"] ?? "منتج غير معروف",
                                      style: const TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: bgColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "الكمية: $formattedQty × $formattedPrice دج = $formattedTotal دج",
                                        style: TextStyle(fontFamily: "Cairo", fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, size: 22, color: Colors.blue),
                                    onPressed: () => _showEditItemDialog(context, controller, item, qty, unitPrice),
                                    tooltip: "تعديل",
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_rounded, size: 22, color: Colors.red),
                                    onPressed: () => _confirmDeleteItem(context, controller, item["uuid"]),
                                    tooltip: "حذف",
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // Totals and Payments section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF800000), // Primary color card for totals
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF800000).withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRowWhite("الإجمالي الفرعي:", controller.subtotal),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("الخصم:", style: TextStyle(fontFamily: "Cairo", fontSize: 14, color: Colors.white70)),
                            Row(
                              children: [
                                Text("${_formatCurrency(controller.discount)} دج", style: const TextStyle(fontFamily: "Cairo", fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _showEditDiscountDialog(context, controller),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Colors.white24, height: 1),
                        ),
                        _buildSummaryRowWhite("الصافي المستحق:", controller.netTotal, isBold: true, size: 18),
                        const SizedBox(height: 20),
                        
                        // Payments Card (inner)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildSummaryRow("إجمالي المدفوع:", controller.totalPaid, color: Colors.green.shade700, isBold: true),
                              const SizedBox(height: 10),
                              _buildSummaryRow("المبلغ المتبقي:", controller.remaining, color: controller.remaining > 0 ? Colors.red : Colors.black, isBold: true, size: 16),
                              
                              if (controller.remaining > 0) ...[
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _showAddPaymentDialog(context, controller),
                                    icon: const Icon(Icons.add_card_rounded, color: Colors.white),
                                    label: const Text(
                                      "إضافة دفعة",
                                      style: TextStyle(fontFamily: "Cairo", color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                )
                              ]
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(InvoiceDetailsController controller) {
    Color badgeColor;
    String badgeText;
    IconData icon;

    if (controller.isPaid) {
      badgeColor = Colors.green;
      badgeText = "مدفوعة";
      icon = Icons.check_circle_rounded;
    } else if (controller.isPartiallyPaid) {
      badgeColor = Colors.orange.shade700;
      badgeText = "مدفوعة جزئياً";
      icon = Icons.timelapse_rounded;
    } else {
      badgeColor = Colors.red;
      badgeText = "غير مدفوعة";
      icon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 16),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontFamily: "Cairo",
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isBold = false, Color? color, double size = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: size,
          ),
        ),
        Text(
          "${_formatCurrency(value)} دج",
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: size,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRowWhite(String label, double value, {bool isBold = false, double size = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: size,
            color: isBold ? Colors.white : Colors.white70,
          ),
        ),
        Text(
          "${_formatCurrency(value)} دج",
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: size,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double value) {
    return formatAmount(value);
  }

  // --- Styled Dialogs ---

  void _showAddPaymentDialog(BuildContext context, InvoiceDetailsController controller) {
    final TextEditingController amountController = TextEditingController(text: _formatCurrency(controller.remaining));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.defaultDialog(
      title: "إضافة دفعة",
      titleStyle: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.green, fontSize: 18),
      backgroundColor: isDark ? AppColor.cardDark : Colors.white,
      radius: 18,
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.payments_rounded, color: Colors.green, size: 50),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: "المبلغ (دج)",
                labelStyle: TextStyle(fontFamily: "Cairo", color: isDark ? Colors.white70 : Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 2)),
                prefixIcon: const Icon(Icons.attach_money_rounded, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
        onPressed: () {
          double amount = double.tryParse(amountController.text) ?? 0;
          if (amount > 0) {
            Get.back();
            controller.addPayment(amount);
          } else {
            Get.snackbar("تنبيه", "الرجاء إدخال مبلغ صحيح");
          }
        },
        child: const Text("تأكيد الدفع", style: TextStyle(fontFamily: "Cairo", color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Colors.grey),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
        onPressed: () => Get.back(),
        child: const Text("إلغاء", style: TextStyle(fontFamily: "Cairo", color: Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showEditDiscountDialog(BuildContext context, InvoiceDetailsController controller) {
    final TextEditingController discountController = TextEditingController(text: _formatCurrency(controller.discount));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.defaultDialog(
      title: "تعديل الخصم",
      titleStyle: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF800000), fontSize: 18),
      backgroundColor: isDark ? AppColor.cardDark : Colors.white,
      radius: 18,
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_rounded, color: Color(0xFF800000), size: 50),
          const SizedBox(height: 16),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: discountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: "قيمة الخصم (دج)",
                labelStyle: TextStyle(fontFamily: "Cairo", color: isDark ? Colors.white70 : Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF800000), width: 2)),
                prefixIcon: const Icon(Icons.money_off_rounded, color: Color(0xFF800000)),
              ),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF800000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
        onPressed: () {
          double newDiscount = double.tryParse(discountController.text) ?? 0;
          if (newDiscount >= 0) {
            Get.back();
            controller.updateDiscount(newDiscount);
          }
        },
        child: const Text("حفظ", style: TextStyle(fontFamily: "Cairo", color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Colors.grey),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
        onPressed: () => Get.back(),
        child: const Text("إلغاء", style: TextStyle(fontFamily: "Cairo", color: Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showEditItemDialog(BuildContext context, InvoiceDetailsController controller, Map<String, dynamic> item, double currentQty, double currentPrice) {
    final TextEditingController qtyController = TextEditingController(text: _formatCurrency(currentQty));
    final TextEditingController priceController = TextEditingController(text: _formatCurrency(currentPrice));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Get.defaultDialog(
      title: "تعديل ${item['product_name']}",
      titleStyle: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.blue, fontSize: 16),
      backgroundColor: isDark ? AppColor.cardDark : Colors.white,
      radius: 18,
      contentPadding: const EdgeInsets.all(20),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_note_rounded, color: Colors.blue, size: 50),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: "الكمية",
                labelStyle: TextStyle(fontFamily: "Cairo", color: isDark ? Colors.white70 : Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                prefixIcon: const Icon(Icons.production_quantity_limits_rounded, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontFamily: "Cairo", fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                labelText: "السعر (دج)",
                labelStyle: TextStyle(fontFamily: "Cairo", color: isDark ? Colors.white70 : Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
                prefixIcon: const Icon(Icons.price_change_rounded, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
        onPressed: () {
          double newQty = double.tryParse(qtyController.text) ?? currentQty;
          double newPrice = double.tryParse(priceController.text) ?? currentPrice;
          if (newQty > 0 && newPrice >= 0) {
            Get.back();
            controller.updateItem(item["uuid"], newQty, newPrice);
          }
        },
        child: const Text("حفظ التعديل", style: TextStyle(fontFamily: "Cairo", color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      cancel: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Colors.grey),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        ),
        onPressed: () => Get.back(),
        child: const Text("إلغاء", style: TextStyle(fontFamily: "Cairo", color: Colors.grey, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, InvoiceDetailsController controller, String itemUuid) {
    showDeleteDialog(
      itemName: "هذا المنتج من الفاتورة",
      onConfirm: () => controller.deleteItem(itemUuid),
    );
  }

  void _confirmDeleteInvoice(BuildContext context, InvoiceDetailsController controller) {
    showDeleteDialog(
      itemName: "الفاتورة بالكامل بجميع محتوياتها",
      onConfirm: () => controller.deleteInvoice(),
    );
  }
}
