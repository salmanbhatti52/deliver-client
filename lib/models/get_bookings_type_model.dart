// To parse this JSON data, do
//
//     final getBookingsTypeModel = getBookingsTypeModelFromJson(jsonString);

import 'dart:convert';

GetBookingsTypeModel getBookingsTypeModelFromJson(String str) =>
    GetBookingsTypeModel.fromJson(json.decode(str));

String getBookingsTypeModelToJson(GetBookingsTypeModel data) =>
    json.encode(data.toJson());

class GetBookingsTypeModel {
  String? status;
  List<Datum>? data;

  GetBookingsTypeModel({
    this.status,
    this.data,
  });

  factory GetBookingsTypeModel.fromJson(Map<String, dynamic> json) =>
      GetBookingsTypeModel(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? bookingsTypesId;
  String? name;
  String? sameDay;
  String? firstMilesFrom;
  String? firstMilesTo;
  String? firstMilesAmount;
  String? perMilesExtra;
  String? amount;
  String? status;

  Datum({
    this.bookingsTypesId,
    this.name,
    this.sameDay,
    this.firstMilesFrom,
    this.firstMilesTo,
    this.firstMilesAmount,
    this.perMilesExtra,
    this.amount,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        bookingsTypesId: json["bookings_types_id"],
        name: json["name"],
        sameDay: json["same_day"],
        firstMilesFrom: json["first_miles_from"],
        firstMilesTo: json["first_miles_to"],
        firstMilesAmount: json["first_miles_amount"],
        perMilesExtra: json["per_miles_extra"],
        amount: json["amount"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "bookings_types_id": bookingsTypesId,
        "name": name,
        "same_day": sameDay,
        "first_miles_from": firstMilesFrom,
        "first_miles_to": firstMilesTo,
        "first_miles_amount": firstMilesAmount,
        "per_miles_extra": perMilesExtra,
        "amount": amount,
        "status": status,
      };
}
