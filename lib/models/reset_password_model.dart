// // To parse this JSON data, do
// //
// //     final resetPasswordModel = resetPasswordModelFromJson(jsonString);

// import 'dart:convert';

// ResetPasswordModel resetPasswordModelFromJson(String str) =>
//     ResetPasswordModel.fromJson(json.decode(str));

// String resetPasswordModelToJson(ResetPasswordModel data) =>
//     json.encode(data.toJson());

// class ResetPasswordModel {
//   String? status;
//   String? message;

//   ResetPasswordModel({
//     this.status,
//     this.message,
//   });

//   factory ResetPasswordModel.fromJson(Map<String, dynamic> json) =>
//       ResetPasswordModel(
//         status: json["status"],
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//       };
// }
