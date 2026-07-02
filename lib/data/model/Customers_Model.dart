class CustomersModel {
  int? status;
  String? message;
  List<CustomerData>? data;

  CustomersModel({this.status, this.message, this.data});

  CustomersModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CustomerData>[];
      json['data'].forEach((v) {
        data!.add(CustomerData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CustomerData {
  int? id;
  String? uuid;
  String? username;
  String? phoneNumper;
  String? createdAt;
  String? updatedAt;

  CustomerData({
    this.id,
    this.uuid,
    this.username,
    this.phoneNumper,
    this.createdAt,
    this.updatedAt,
  });

  CustomerData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    username = json['username'];
    phoneNumper = json['phone_numper'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['username'] = username;
    data['phone_numper'] = phoneNumper;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
