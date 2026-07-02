class ProductsModel {
  int? status;
  String? message;
  List<ProductData>? data;

  ProductsModel({this.status, this.message, this.data});

  ProductsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <ProductData>[];
      json['data'].forEach((v) {
        data!.add(ProductData.fromJson(v));
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

class ProductData {
  int? id;
  String? uuid;
  String? catUuid;
  String? name;
  double? price;
  String? gender;
  String? createdAt;
  String? updatedAt;
  String? categoryName; // Optional field populated during DB join query

  ProductData({
    this.id,
    this.uuid,
    this.catUuid,
    this.name,
    this.price,
    this.gender,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
  });

  ProductData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    catUuid = json['cat_uuid'];
    name = json['name'];
    price = double.tryParse(json['price'].toString());
    gender = json['Gender'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    categoryName = json['category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uuid'] = uuid;
    data['cat_uuid'] = catUuid;
    data['name'] = name;
    data['price'] = price;
    data['Gender'] = gender;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['category_name'] = categoryName;
    return data;
  }
}
