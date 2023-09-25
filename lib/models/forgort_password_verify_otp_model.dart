// // To parse this JSON data, do
// //
// //     final forgotPasswordVerifyOtpModel = forgotPasswordVerifyOtpModelFromJson(jsonString);

// import 'dart:convert';

// ForgotPasswordVerifyOtpModel forgotPasswordVerifyOtpModelFromJson(String str) =>
//     ForgotPasswordVerifyOtpModel.fromJson(json.decode(str));

// String forgotPasswordVerifyOtpModelToJson(ForgotPasswordVerifyOtpModel data) =>
//     json.encode(data.toJson());

// class ForgotPasswordVerifyOtpModel {
//   String? status;
//   String? message;

//   ForgotPasswordVerifyOtpModel({
//     this.status,
//     this.message,
//   });

//   factory ForgotPasswordVerifyOtpModel.fromJson(Map<String, dynamic> json) =>
//       ForgotPasswordVerifyOtpModel(
//         status: json["status"],
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//       };
// }
