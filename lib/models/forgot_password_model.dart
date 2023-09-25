// // To parse this JSON data, do
// //
// //     final forgotPasswordModel = forgotPasswordModelFromJson(jsonString);

// import 'dart:convert';

// ForgotPasswordModel forgotPasswordModelFromJson(String str) =>
//     ForgotPasswordModel.fromJson(json.decode(str));

// String forgotPasswordModelToJson(ForgotPasswordModel data) =>
//     json.encode(data.toJson());

// class ForgotPasswordModel {
//   String? status;
//   String? message;

//   ForgotPasswordModel({
//     this.status,
//     this.message,
//   });

//   factory ForgotPasswordModel.fromJson(Map<String, dynamic> json) =>
//       ForgotPasswordModel(
//         status: json["status"],
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//       };
// }
