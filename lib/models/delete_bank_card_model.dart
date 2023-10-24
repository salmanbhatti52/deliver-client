// // To parse this JSON data, do
// //
// //     final deleteBankCardModel = deleteBankCardModelFromJson(jsonString);
//
// import 'dart:convert';
//
// DeleteBankCardModel deleteBankCardModelFromJson(String str) => DeleteBankCardModel.fromJson(json.decode(str));
//
// String deleteBankCardModelToJson(DeleteBankCardModel data) => json.encode(data.toJson());
//
// class DeleteBankCardModel {
//   String? status;
//   String? message;
//
//   DeleteBankCardModel({
//     this.status,
//     this.message,
//   });
//
//   factory DeleteBankCardModel.fromJson(Map<String, dynamic> json) => DeleteBankCardModel(
//     status: json["status"],
//     message: json["message"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "message": message,
//   };
// }
