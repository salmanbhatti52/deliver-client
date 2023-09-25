// To parse this JSON data, do
//
//     final sendUserChatModel = sendUserChatModelFromJson(jsonString);

import 'dart:convert';

SendUserChatModel sendUserChatModelFromJson(String str) =>
    SendUserChatModel.fromJson(json.decode(str));

String sendUserChatModelToJson(SendUserChatModel data) =>
    json.encode(data.toJson());

class SendUserChatModel {
  String? status;
  String? message;

  SendUserChatModel({
    this.status,
    this.message,
  });

  factory SendUserChatModel.fromJson(Map<String, dynamic> json) =>
      SendUserChatModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
