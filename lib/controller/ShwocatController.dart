import 'package:Saleh/core/class/Statusrequest.dart';
import 'package:Saleh/core/constant/routes.dart';
import 'package:Saleh/data/datasource/Remote/Categoris_data.dart';
import 'package:Saleh/data/model/Categoris_Model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/functions/Snacpar.dart';
import '../core/functions/handlingdatacontroller.dart';
import '../core/services/Services.dart';

class Shwocatcontroller extends GetxController {
  late int id;
  String? uuid;
  final nameController = TextEditingController();
  final editnameController = TextEditingController();

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  CategorisData categorisData = CategorisData(Get.find());
  Statusrequest statusrequest = Statusrequest.none;
  List<Catdata> Categoris = [];

  getcat() async {
    try {
      var response = await categorisData.viewdata();

      print("============================================== $response");

      if (response.isNotEmpty) {
        Categoris = (response as List)
            .map((e) => Catdata.fromJson(e as Map<String, dynamic>))
            .toList();
        statusrequest = Statusrequest.success;
      } else {
        statusrequest = Statusrequest.failure;
      }
    } catch (e) {
      print("❌ getcat error: $e");
      statusrequest = Statusrequest.serverfailure;
    }

    update();
  }

  addcat() async {
    if (formstate.currentState!.validate()) {
      update();
      var response = await categorisData.Adddata(
        nameController.text,
      );

      // ignore: avoid_print
      print("==================================================$response");
      statusrequest = handlingData(response);
      if (response != false) {
        Get.back(result: true);
        // showSnackbar("success".tr, "operationSuccess".tr, Colors.green);
      } else {
        showSnackbar("error".tr, "operationFailed".tr, Colors.red);
      }
    }
  }

  void initData(Catdata cat) {
    uuid = cat.uuid;
    editnameController.text = cat.categorisName ?? "";
  }

  Future<void> Editcat() async {
    if (formstate.currentState!.validate()) {
      if (uuid == null) {
        showSnackbar("error".tr, "Invalid category ID", Colors.red);
        return;
      }

      final success = await categorisData.Updatecat(
        uuid!,
        editnameController.text,
      );

      if (success) {
        statusrequest = Statusrequest.success;
        Get.back(result: true);
        // showSnackbar("success".tr, "operationSuccess".tr, Colors.green);
      } else {
        statusrequest = Statusrequest.failure;
        showSnackbar("error", "operationFailed", Colors.red);
      }

      update();
    }
  }

  Future<void> deletecat(String uuid) async {
    final success = await categorisData.deletecat(uuid);

    if (success) {
      Get.find<RefreshService>().fire();
      statusrequest = Statusrequest.success;
      Get.back();
      // showSnackbar("success".tr, "operationSuccess".tr, Colors.green);
      getcat();
    } else {
      showSnackbar("error".tr, "operationFailed".tr, Colors.red);
    }

    update();
  }

  @override
  void onInit() {
    super.onInit();
    // getProdact();
    getcat();
  }

  refreshData() async {
    await getcat();
  }
}
