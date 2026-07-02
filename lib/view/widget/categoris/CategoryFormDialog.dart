import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/ShwocatController.dart';
import '../../../core/constant/Colorapp.dart';
import '../../../data/model/Categoris_Model.dart';
import 'CategoryFormDialogContent.dart';

void showCategoryFormDialog(BuildContext context, {required bool isAddMode, Catdata? cat}) {
  final controller = Get.find<Shwocatcontroller>();
  if (isAddMode) {
    controller.nameController.clear();
  }

  final isDark = Theme.of(context).brightness == Brightness.dark;

  Get.defaultDialog(
    title: isAddMode ? "إضافة فئة جديدة" : "تعديل الفئة",
    titleStyle: TextStyle(
      fontFamily: "Cairo", 
      fontWeight: FontWeight.bold, 
      fontSize: 16, 
      color: isDark ? Colors.white : const Color(0xFF800000)
    ),
    backgroundColor: isDark ? AppColor.cardDark : Colors.white,
    radius: 18,
    contentPadding: const EdgeInsets.all(20),
    content: CategoryFormDialogContent(
      formKey: controller.formstate,
      textController: isAddMode ? controller.nameController : controller.editnameController,
      labelText: isAddMode ? "اسم الفئة" : "اسم الفئة الجديد",
      confirmBtnText: isAddMode ? "إضافة" : "حفظ",
      onConfirm: () async {
        if (isAddMode) {
          await controller.addcat();
        } else {
          await controller.Editcat();
        }
        controller.getcat();
      },
      onCancel: () => Get.back(),
    ),
  );
}
