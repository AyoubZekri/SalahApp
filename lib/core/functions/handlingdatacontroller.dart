import 'package:Saleh/core/class/Statusrequest.dart';

handlingData(response) {
  if (response is Statusrequest) {
    return response;
  } else {
    return Statusrequest.success;
  }
}
