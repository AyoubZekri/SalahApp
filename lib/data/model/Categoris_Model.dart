class Categoris_Model {
  int? status;
  String? message;
  Data? data;

  Categoris_Model({this.status, this.message, this.data});

  Categoris_Model.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Catdata>? catdata;

  Data({this.catdata});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['catdata'] != null) {
      catdata = <Catdata>[];
      json['catdata'].forEach((v) {
        catdata!.add(new Catdata.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.catdata != null) {
      data['catdata'] = this.catdata!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Catdata {
  int? id;
  String? uuid;
  int? userId;
  String? categorisName;
  String? categorisNameFr;
  String? categorisImage;
  String? createdAt;
  String? updatedAt;

  Catdata(
      {this.id,
      this.userId,
      this.uuid,
      this.categorisName,
      this.categorisNameFr,
      this.categorisImage,
      this.createdAt,
      this.updatedAt});

  Catdata.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uuid = json['uuid'];
    userId = json['user_id'];
    categorisName = json['categoris_name'];
    categorisNameFr = json['categoris_name_fr'];
    categorisImage = json['categoris_image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['uuid'] = this.uuid;
    data['user_id'] = this.userId;
    data['categoris_name'] = this.categorisName;
    data['categoris_name_fr'] = this.categorisNameFr;
    data['categoris_image'] = this.categorisImage;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
