// To parse this JSON data, do
//
//     final getSupportAdminModel = getSupportAdminModelFromJson(jsonString);

import 'dart:convert';

GetSupportAdminModel getSupportAdminModelFromJson(String str) =>
    GetSupportAdminModel.fromJson(json.decode(str));

String getSupportAdminModelToJson(GetSupportAdminModel data) =>
    json.encode(data.toJson());

class GetSupportAdminModel {
  String? status;
  List<Datum>? data;

  GetSupportAdminModel({
    this.status,
    this.data,
  });

  factory GetSupportAdminModel.fromJson(Map<String, dynamic> json) =>
      GetSupportAdminModel(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? usersSystemId;
  int? usersSystemRolesId;
  String? firstName;
  String? email;
  String? password;
  String? mobile;
  String? city;
  String? address;
  String? userImage;
  String? isDeleted;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic deletedAt;
  String? status;

  Datum({
    this.usersSystemId,
    this.usersSystemRolesId,
    this.firstName,
    this.email,
    this.password,
    this.mobile,
    this.city,
    this.address,
    this.userImage,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        usersSystemId: json["users_system_id"],
        usersSystemRolesId: json["users_system_roles_id"],
        firstName: json["first_name"],
        email: json["email"],
        password: json["password"],
        mobile: json["mobile"],
        city: json["city"],
        address: json["address"],
        userImage: json["user_image"],
        isDeleted: json["is_deleted"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "users_system_id": usersSystemId,
        "users_system_roles_id": usersSystemRolesId,
        "first_name": firstName,
        "email": email,
        "password": password,
        "mobile": mobile,
        "city": city,
        "address": address,
        "user_image": userImage,
        "is_deleted": isDeleted,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "status": status,
      };
}
