import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/class/Statusrequest.dart';
import '../../core/functions/Snacpar.dart';
import '../../core/functions/handlingdatacontroller.dart';
import '../../core/services/Services.dart';
import '../../data/datasource/Remote/Customers_data.dart';
import '../../data/model/Customers_Model.dart';

class Customerscontroller extends GetxController {
  String? uuid;
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final editUsernameController = TextEditingController();
  final editPhoneController = TextEditingController();

  GlobalKey<FormState> formstate = GlobalKey<FormState>();

  CustomersData customersData = CustomersData(Get.find());
  Statusrequest statusrequest = Statusrequest.none;
  List<CustomerData> customers = [];

  getCustomers() async {
    try {
      var response = await customersData.viewdata();
      print("Customers response: $response");

      if (response.isNotEmpty) {
        customers = (response as List)
            .map((e) => CustomerData.fromJson(e as Map<String, dynamic>))
            .toList();
        statusrequest = Statusrequest.success;
      } else {
        customers = [];
        statusrequest = Statusrequest.failure;
      }
    } catch (e) {
      print("❌ getCustomers error: $e");
      statusrequest = Statusrequest.serverfailure;
    }
    update();
  }

  addCustomer() async {
    if (formstate.currentState!.validate()) {
      update();
      var response = await customersData.Adddata(
        usernameController.text,
        phoneController.text,
      );

      statusrequest = handlingData(response);
      if (response != false) {
        if (Get.isRegistered<RefreshService>()) {
          Get.find<RefreshService>().fire();
        }
        Get.back(result: true);
      } else {
        showSnackbar("error".tr, "operationFailed".tr, Colors.red);
      }
      getCustomers();
    }
  }

  void initData(CustomerData customer) {
    uuid = customer.uuid;
    editUsernameController.text = customer.username ?? "";
    editPhoneController.text = customer.phoneNumper ?? "";
  }

  Future<void> editCustomer() async {
    if (formstate.currentState!.validate()) {
      if (uuid == null) {
        showSnackbar("error".tr, "Invalid customer ID", Colors.red);
        return;
      }
      update();
      final success = await customersData.Updatecustomer(
        uuid!,
        editUsernameController.text,
        editPhoneController.text,
      );

      if (success) {
        if (Get.isRegistered<RefreshService>()) {
          Get.find<RefreshService>().fire();
        }
        statusrequest = Statusrequest.success;
        Get.back(result: true);
      } else {
        statusrequest = Statusrequest.failure;
        showSnackbar("error", "operationFailed", Colors.red);
      }
      getCustomers();
    }
  }

  Future<void> deleteCustomer(String uuid) async {
    final success = await customersData.deletecustomer(uuid);

    if (success) {
      Get.find<RefreshService>().fire();
      statusrequest = Statusrequest.success;
      getCustomers();
    } else {
      showSnackbar("error".tr, "operationFailed".tr, Colors.red);
    }
    update();
  }

  @override
  void onInit() {
    super.onInit();
    getCustomers();
  }

  refreshData() async {
    await getCustomers();
  }
}
