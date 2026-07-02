import 'package:flutter/material.dart';
import '../../../controller/SalesController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/format_number.dart';
import '../CustomTextField.dart';

class InvoiceSummarySection extends StatelessWidget {
  final SalesController controller;
  final bool isDark;

  const InvoiceSummarySection({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF)),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
              "الإجمالي الفرعي",
              "${formatAmount(controller.subtotal)} دج"),
          const SizedBox(height: 10),

          // Discount Input Field
          // Discount Input Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "الخصم الممنوح (دج)",
                style: TextStyle(
                    fontFamily: "Cairo", fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: controller.discountController,
                hintText: "0.0",
                iconData: Icons.local_offer_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => null,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Total Paid Amount Input Field (prefilled with netTotal if empty)
          // Total Paid Amount Input Field (prefilled with netTotal if empty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "المبلغ المدفوع (دج)",
                style: TextStyle(
                    fontFamily: "Cairo", fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: controller.paidAmountController,
                hintText: "0.0",
                iconData: Icons.payments_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => null,
              ),
            ],
          ),
          const Divider(height: 24, thickness: 0.8),
          if (controller.selectedCustomer != null && controller.customerOldDebt > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  const Text("ديون العميل السابقة",
                      style: TextStyle(
                          fontFamily: "Cairo",
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.amber)),
                  const SizedBox(width: 5),
                  Text("${formatAmount(controller.customerOldDebt)} دج",
                      style: const TextStyle(
                        fontFamily: "Cairo",
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          _buildSummaryRow(
              "المبلغ الصافي المستحق", "${formatAmount(controller.netTotal)} دج",
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 14 : 13,
            color: isTotal ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 16 : 14,
            color: isTotal ? const Color(0xFF800000) : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
