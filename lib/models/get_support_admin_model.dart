// To parse this JSON data, do
//
//     final getSupportAdminModel = getSupportAdminModelFromJson(jsonString);

import 'dart:convert';

GetSupportAdminModel getSupportAdminModelFromJson(String str) => GetSupportAdminModel.fromJson(json.decode(str));

String getSupportAdminModelToJson(GetSupportAdminModel data) => json.encode(data.toJson());

class GetSupportAdminModel {
  String? status;
  List<Datum>? data;

  GetSupportAdminModel({
    this.status,
    this.data,
  });

  factory GetSupportAdminModel.fromJson(Map<String, dynamic> json) => GetSupportAdminModel(
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
  String? name;
  String? email;
  String? password;
  String? mobile;
  String? city;
  String? address;
  String? profilePic;
  String? forgotPwdOtp;
  String? dateAdded;
  String? dateModified;
  String? status;

  Datum({
    this.usersSystemId,
    this.usersSystemRolesId,
    this.name,
    this.email,
    this.password,
    this.mobile,
    this.city,
    this.address,
    this.profilePic,
    this.forgotPwdOtp,
    this.dateAdded,
    this.dateModified,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    usersSystemId: json["users_system_id"],
    usersSystemRolesId: json["users_system_roles_id"],
    name: json["name"],
    email: json["email"],
    password: json["password"],
    mobile: json["mobile"],
    city: json["city"],
    address: json["address"],
    profilePic: json["profile_pic"],
    forgotPwdOtp: json["forgot_pwd_otp"],
    dateAdded: json["date_added"],
    dateModified: json["date_modified"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "users_system_id": usersSystemId,
    "users_system_roles_id": usersSystemRolesId,
    "name": name,
    "email": email,
    "password": password,
    "mobile": mobile,
    "city": city,
    "address": address,
    "profile_pic": profilePic,
    "forgot_pwd_otp": forgotPwdOtp,
    "date_added": dateAdded,
    "date_modified": dateModified,
    "status": status,
  };
}
