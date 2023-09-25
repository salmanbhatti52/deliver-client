// // To parse this JSON data, do
// //
// //     final updateEmailModel = updateEmailModelFromJson(jsonString);

// import 'dart:convert';

// UpdateEmailModel updateEmailModelFromJson(String str) =>
//     UpdateEmailModel.fromJson(json.decode(str));

// String updateEmailModelToJson(UpdateEmailModel data) =>
//     json.encode(data.toJson());

// class UpdateEmailModel {
//   String? status;
//   String? message;

//   UpdateEmailModel({
//     this.status,
//     this.message,
//   });

//   factory UpdateEmailModel.fromJson(Map<String, dynamic> json) =>
//       UpdateEmailModel(
//         status: json["status"],
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//       };
// }
