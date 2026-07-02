import 'package:Saleh/core/class/Crud.dart';
import 'package:Saleh/core/services/Services.dart';
import 'package:get/get.dart';


class Initialbindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud());
    Get.put(Myservices());
  }
}
