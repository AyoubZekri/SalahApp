import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/SalesController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../core/functions/valiedinput.dart';
import '../CustomDropdown.dart';
import '../CustomTextField.dart';

class CustomerSelectionSection extends StatelessWidget {
  final SalesController controller;
  final bool isDark;

  const CustomerSelectionSection({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? AppColor.borderDark : const Color(0xFFEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "اختر العميل المشتري",
            style: TextStyle(
                fontFamily: "Cairo",
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomDropdown<String>(
                  value: controller.selectedCustomer?.uuid,
                  items: controller.customers.map((cust) {
                    return DropdownMenuItem<String>(
                      value: cust.uuid,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(cust.username ?? "",
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                      ),
                    );
                  }).toList(),
                  hintText: "اختر عميلاً من القائمة",
                  onChanged: (val) {
                    controller.selectedCustomer = val == null
                        ? null
                        : controller.customers.firstWhere((e) => e.uuid == val);
                    if (val != null) {
                      controller.fetchCustomerDebt(val);
                    } else {
                      controller.customerOldDebt = 0.0;
                    }
                    controller.update();
                  },
                ),
              ),
              const SizedBox(width: 8),
              // Shortcut Button to quick add customer
              InkWell(
                onTap: () => _showQuickCustomerDialog(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF800000).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF800000).withOpacity(0.2)),
                  ),
                  child: const Icon(Icons.person_add_rounded,
                      color: Color(0xFF800000)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQuickCustomerDialog(BuildContext context) {
    controller.quickCustomerNameController.clear();
    controller.quickCustomerPhoneController.clear();

    Get.defaultDialog(
      title: "إضافة عميل سريع",
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
          key: controller.quickCustomerFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "اسم العميل",
                style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: controller.quickCustomerNameController,
                hintText: "أدخل اسم العميل هنا",
                iconData: Icons.person_rounded,
                validator: (val) => validInput(val!, 50, 2, "text"),
              ),
              const SizedBox(height: 14),
              Text(
                "رقم الهاتف",
                style: TextStyle(
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 6),
              CustomTextField(
                controller: controller.quickCustomerPhoneController,
                hintText: "أدخل رقم الهاتف",
                iconData: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (val) => validInput(val!, 20, 9, "phone"),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: isDark ? Colors.white54 : const Color(0xFF800000)),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "إلغاء",
                        style: TextStyle(
                            fontFamily: "Cairo",
                            color: isDark ? Colors.white : const Color(0xFF800000),
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
                        onPressed: () async {
                          if (controller.quickCustomerFormKey.currentState!
                              .validate()) {
                            await controller.addCustomerDirectly(
                              controller.quickCustomerNameController.text,
                              controller.quickCustomerPhoneController.text,
                            );
                            Get.back();
                          }
                        },
                        child: const Text(
                          "إضافة",
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
