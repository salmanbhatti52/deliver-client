// To parse this JSON data, do
//
//     final getReasonModel = getReasonModelFromJson(jsonString);

import 'dart:convert';

GetReasonModel getReasonModelFromJson(String str) =>
    GetReasonModel.fromJson(json.decode(str));

String getReasonModelToJson(GetReasonModel data) => json.encode(data.toJson());

class GetReasonModel {
  String? status;
  List<Datum>? data;

  GetReasonModel({
    this.status,
    this.data,
  });

  factory GetReasonModel.fromJson(Map<String, dynamic> json) => GetReasonModel(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? bookingsReportsReasonsId;
  String? reason;
  String? status;

  Datum({
    this.bookingsReportsReasonsId,
    this.reason,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        bookingsReportsReasonsId: json["bookings_reports_reasons_id"],
        reason: json["reason"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "bookings_reports_reasons_id": bookingsReportsReasonsId,
        "reason": reason,
        "status": status,
      };
}
