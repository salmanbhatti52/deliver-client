// // To parse this JSON data, do
// //
// //     final verifyOtpModel = verifyOtpModelFromJson(jsonString);

// import 'dart:convert';

// VerifyOtpModel verifyOtpModelFromJson(String str) =>
//     VerifyOtpModel.fromJson(json.decode(str));

// String verifyOtpModelToJson(VerifyOtpModel data) => json.encode(data.toJson());

// class VerifyOtpModel {
//   String? status;
//   String? message;

//   VerifyOtpModel({
//     this.status,
//     this.message,
//   });

//   factory VerifyOtpModel.fromJson(Map<String, dynamic> json) => VerifyOtpModel(
//         status: json["status"],
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//       };
// }
