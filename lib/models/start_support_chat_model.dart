// To parse this JSON data, do
//
//     final startSupportChatModel = startSupportChatModelFromJson(jsonString);

import 'dart:convert';

StartSupportChatModel startSupportChatModelFromJson(String str) =>
    StartSupportChatModel.fromJson(json.decode(str));

String startSupportChatModelToJson(StartSupportChatModel data) =>
    json.encode(data.toJson());

class StartSupportChatModel {
  String? status;
  String? message;

  StartSupportChatModel({
    this.status,
    this.message,
  });

  factory StartSupportChatModel.fromJson(Map<String, dynamic> json) =>
      StartSupportChatModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
