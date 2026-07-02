import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/ProductsController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../data/model/Products_Model.dart';
import 'ProductFormDialogContent.dart';

void showProductFormDialog(BuildContext context, {required bool isAddMode, ProductData? product}) {
  final controller = Get.find<Productscontroller>();
  if (isAddMode) {
    controller.nameController.clear();
    controller.priceController.clear();
    controller.selectedCatUuid = null;
    controller.selectedGender = null;
  }

  final isDark = Theme.of(context).brightness == Brightness.dark;

  Get.defaultDialog(
    title: isAddMode ? "إضافة منتج جديد" : "تعديل بيانات المنتج",
    titleStyle: TextStyle(
      fontFamily: "Cairo", 
      fontWeight: FontWeight.bold, 
      fontSize: 16, 
      color: isDark ? Colors.white : const Color(0xFF800000)
    ),
    backgroundColor: isDark ? AppColor.cardDark : Colors.white,
    radius: 18,
    contentPadding: const EdgeInsets.all(20),
    content: ProductFormDialogContent(
      formKey: controller.formstate,
      nameController: isAddMode ? controller.nameController : controller.editNameController,
      priceController: isAddMode ? controller.priceController : controller.editPriceController,
      categories: controller.categories,
      initialCatUuid: isAddMode ? null : controller.editSelectedCatUuid,
      initialGender: isAddMode ? null : controller.editSelectedGender,
      confirmBtnText: isAddMode ? "إضافة" : "حفظ",
      onConfirm: (catUuid, gender) async {
        if (isAddMode) {
          controller.selectedCatUuid = catUuid;
          controller.selectedGender = gender;
          await controller.addProduct();
        } else {
          controller.editSelectedCatUuid = catUuid;
          controller.editSelectedGender = gender;
          await controller.editProduct();
        }
      },
      onCancel: () => Get.back(),
    ),
  );
}
