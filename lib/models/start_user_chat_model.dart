// To parse this JSON data, do
//
//     final startUserChatModel = startUserChatModelFromJson(jsonString);

import 'dart:convert';

StartUserChatModel startUserChatModelFromJson(String str) =>
    StartUserChatModel.fromJson(json.decode(str));

String startUserChatModelToJson(StartUserChatModel data) =>
    json.encode(data.toJson());

class StartUserChatModel {
  String? status;
  String? message;

  StartUserChatModel({
    this.status,
    this.message,
  });

  factory StartUserChatModel.fromJson(Map<String, dynamic> json) =>
      StartUserChatModel(
        status: json["status"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
      };
}
