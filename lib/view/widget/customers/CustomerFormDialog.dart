import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/CustomersController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../data/model/Customers_Model.dart';
import 'CustomerFormDialogContent.dart';

void showCustomerFormDialog(BuildContext context, {required bool isAddMode, CustomerData? customer}) {
  final controller = Get.find<Customerscontroller>();
  if (isAddMode) {
    controller.usernameController.clear();
    controller.phoneController.clear();
  }

  final isDark = Theme.of(context).brightness == Brightness.dark;

  Get.defaultDialog(
    title: isAddMode ? "إضافة عميل جديد" : "تعديل بيانات العميل",
    titleStyle: TextStyle(
      fontFamily: "Cairo", 
      fontWeight: FontWeight.bold, 
      fontSize: 16, 
      color: isDark ? Colors.white : const Color(0xFF800000)
    ),
    backgroundColor: isDark ? AppColor.cardDark : Colors.white,
    radius: 18,
    contentPadding: const EdgeInsets.all(20),
    content: CustomerFormDialogContent(
      formKey: controller.formstate,
      nameController: isAddMode ? controller.usernameController : controller.editUsernameController,
      phoneController: isAddMode ? controller.phoneController : controller.editPhoneController,
      confirmBtnText: isAddMode ? "إضافة" : "حفظ",
      onConfirm: () async {
        if (isAddMode) {
          await controller.addCustomer();
        } else {
          await controller.editCustomer();
        }
      },
      onCancel: () => Get.back(),
    ),
  );
}
