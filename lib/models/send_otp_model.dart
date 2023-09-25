// // To parse this JSON data, do
// //
// //     final sendOtpModel = sendOtpModelFromJson(jsonString);

// import 'dart:convert';

// SendOtpModel sendOtpModelFromJson(String str) =>
//     SendOtpModel.fromJson(json.decode(str));

// String sendOtpModelToJson(SendOtpModel data) => json.encode(data.toJson());

// class SendOtpModel {
//   String? status;
//   String? message;

//   SendOtpModel({
//     this.status,
//     this.message,
//   });

//   factory SendOtpModel.fromJson(Map<String, dynamic> json) => SendOtpModel(
//         status: json["status"],
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//       };
// }
