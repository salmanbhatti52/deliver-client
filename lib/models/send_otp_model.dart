// To parse this JSON data, do
//
//     final sendOtpModel = sendOtpModelFromJson(jsonString);

import 'dart:convert';

SendOtpModel sendOtpModelFromJson(String str) => SendOtpModel.fromJson(json.decode(str));

String sendOtpModelToJson(SendOtpModel data) => json.encode(data.toJson());

class SendOtpModel {
    String? smsStatus;
    String? phoneNumber;
    String? to;
    String? pinId;
    String? sendOtpModelPinId;
    String? status;

    SendOtpModel({
         this.smsStatus,
         this.phoneNumber,
         this.to,
         this.pinId,
         this.sendOtpModelPinId,
         this.status,
    });

    factory SendOtpModel.fromJson(Map<String, dynamic> json) => SendOtpModel(
        smsStatus: json["smsStatus"],
        phoneNumber: json["phone_number"],
        to: json["to"],
        pinId: json["pinId"],
        sendOtpModelPinId: json["pin_id"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "smsStatus": smsStatus,
        "phone_number": phoneNumber,
        "to": to,
        "pinId": pinId,
        "pin_id": sendOtpModelPinId,
        "status": status,
    };
}
