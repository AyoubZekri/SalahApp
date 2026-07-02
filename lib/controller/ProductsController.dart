import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/class/Statusrequest.dart';
import '../core/functions/Snacpar.dart';
import '../core/functions/handlingdatacontroller.dart';
import '../core/services/Services.dart';
import '../data/datasource/Remote/Products_data.dart';
import '../data/datasource/Remote/Categoris_data.dart';
import '../data/model/Products_Model.dart';
import '../data/model/Categoris_Model.dart';

class Productscontroller extends GetxController {
  String? uuid;
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final editNameController = TextEditingController();
  final editPriceController = TextEditingController();

  String? selectedCatUuid;
  String? selectedGender;
  String? editSelectedCatUuid;
  String? editSelectedGender;

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  ProductsData productsData = ProductsData(Get.find());
  CategorisData categorisData = CategorisData(Get.find());
  Statusrequest statusrequest = Statusrequest.none;

  List<ProductData> products = [];
  List<Catdata> categories = [];

  // Fetch both products and categories
  getProducts() async {
    update();
    try {
      // 1. Get Categories for dropdowns
      var catResponse = await categorisData.viewdata();
      if (catResponse.isNotEmpty) {
        categories = (catResponse as List)
            .map((e) => Catdata.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // 2. Get Products
      var response = await productsData.viewdata();
      print("Products response: $response");

      if (response.isNotEmpty) {
        products = (response as List)
            .map((e) => ProductData.fromJson(e as Map<String, dynamic>))
            .toList();
        statusrequest = Statusrequest.success;
      } else {
        products = [];
        statusrequest = Statusrequest.failure;
      }
    } catch (e) {
      print("❌ getProducts error: $e");
      statusrequest = Statusrequest.serverfailure;
    }
    update();
  }

  addProduct() async {
    if (formstate.currentState!.validate()) {
      if (selectedCatUuid == null) {
        showSnackbar("خطأ", "الرجاء اختيار فئة للمنتج", Colors.red);
        return;
      }
      if (selectedGender == null) {
        showSnackbar("خطأ", "الرجاء اختيار الجنس", Colors.red);
        return;
      }

      double? priceVal = double.tryParse(priceController.text);
      if (priceVal == null) {
        showSnackbar("خطأ", "سعر المنتج غير صحيح", Colors.red);
        return;
      }

      update();
      var response = await productsData.Adddata(
        nameController.text,
        priceVal,
        selectedCatUuid!,
        selectedGender!,
      );

      statusrequest = handlingData(response);
      if (response != false) {
        Get.back(result: true);
      } else {
        showSnackbar("error".tr, "operationFailed".tr, Colors.red);
      }
      getProducts();
    }
  }

  void initData(ProductData product) {
    uuid = product.uuid;
    editNameController.text = product.name ?? "";
    if (product.price != null) {
      editPriceController.text = product.price! % 1 == 0
          ? product.price!.toInt().toString()
          : product.price!.toString();
    } else {
      editPriceController.clear();
    }
    editSelectedCatUuid = product.catUuid;
    editSelectedGender = product.gender;
  }

  Future<void> editProduct() async {
    if (formstate.currentState!.validate()) {
      if (uuid == null) {
        showSnackbar("error".tr, "Invalid product ID", Colors.red);
        return;
      }
      if (editSelectedCatUuid == null) {
        showSnackbar("خطأ", "الرجاء اختيار فئة للمنتج", Colors.red);
        return;
      }
      if (editSelectedGender == null) {
        showSnackbar("خطأ", "الرجاء اختيار الجنس", Colors.red);
        return;
      }

      double? priceVal = double.tryParse(editPriceController.text);
      if (priceVal == null) {
        showSnackbar("خطأ", "سعر المنتج غير صحيح", Colors.red);
        return;
      }

      update();
      final success = await productsData.Updateproduct(
        uuid!,
        editNameController.text,
        priceVal,
        editSelectedCatUuid!,
        editSelectedGender!,
      );

      if (success) {
        statusrequest = Statusrequest.success;
        Get.back(result: true);
      } else {
        statusrequest = Statusrequest.failure;
        showSnackbar("error", "operationFailed", Colors.red);
      }
      getProducts();
    }
  }

  Future<void> deleteProduct(String uuid) async {
    final success = await productsData.deleteproduct(uuid);

    if (success) {
      Get.find<RefreshService>().fire();
      statusrequest = Statusrequest.success;
      getProducts();
    } else {
      showSnackbar("error".tr, "operationFailed".tr, Colors.red);
    }
    update();
  }

  @override
  void onInit() {
    super.onInit();
    getProducts();
  }

  refreshData() async {
    await getProducts();
  }
}
