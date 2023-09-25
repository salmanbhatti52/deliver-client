// // To parse this JSON data, do
// //
// //     final signUpModel = signUpModelFromJson(jsonString);

// import 'dart:convert';

// SignUpModel signUpModelFromJson(String str) =>
//     SignUpModel.fromJson(json.decode(str));

// String signUpModelToJson(SignUpModel data) => json.encode(data.toJson());

// class SignUpModel {
//   String? status;
//   String? message;

//   SignUpModel({
//     this.status,
//     this.message,
//   });

//   factory SignUpModel.fromJson(Map<String, dynamic> json) => SignUpModel(
//         status: json["status"],
//         message: json["message"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//       };
// }
