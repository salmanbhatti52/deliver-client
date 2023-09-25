// To parse this JSON data, do
//
//     final sendSupportMessageModel = sendSupportMessageModelFromJson(jsonString);

import 'dart:convert';

SendSupportMessageModel sendSupportMessageModelFromJson(String str) =>
    SendSupportMessageModel.fromJson(json.decode(str));

String sendSupportMessageModelToJson(SendSupportMessageModel data) =>
    json.encode(data.toJson());

class SendSupportMessageModel {
  String? status;
  String? message;

  SendSupportMessageModel({
    this.status,
    this.message,
  });

  factory SendSupportMessageModel.fromJson(Map<String, dynamic> json) =>
      SendSupportMessageModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
