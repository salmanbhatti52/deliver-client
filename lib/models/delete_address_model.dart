// To parse this JSON data, do
//
//     final deleteAddressModel = deleteAddressModelFromJson(jsonString);

import 'dart:convert';

DeleteAddressModel deleteAddressModelFromJson(String str) =>
    DeleteAddressModel.fromJson(json.decode(str));

String deleteAddressModelToJson(DeleteAddressModel data) =>
    json.encode(data.toJson());

class DeleteAddressModel {
  String? status;
  String? message;

  DeleteAddressModel({
    this.status,
    this.message,
  });

  factory DeleteAddressModel.fromJson(Map<String, dynamic> json) =>
      DeleteAddressModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
