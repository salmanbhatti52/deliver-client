// To parse this JSON data, do
//
//     final getDistanceAddressesModel = getDistanceAddressesModelFromJson(jsonString);

import 'dart:convert';

GetDistanceAddressesModel getDistanceAddressesModelFromJson(String str) =>
    GetDistanceAddressesModel.fromJson(json.decode(str));

String getDistanceAddressesModelToJson(GetDistanceAddressesModel data) =>
    json.encode(data.toJson());

class GetDistanceAddressesModel {
  String? status;
  String? message;
  List<Datum>? data;

  GetDistanceAddressesModel({
    this.status,
    this.message,
    this.data,
  });

  factory GetDistanceAddressesModel.fromJson(Map<String, dynamic> json) =>
      GetDistanceAddressesModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] != null
            ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  double? pickupLat;
  double? pickupLong;
  double? destinLat;
  double? destinLong;
  String? distance;
  String? duration;

  Datum({
    this.pickupLat,
    this.pickupLong,
    this.destinLat,
    this.destinLong,
    this.distance,
    this.duration,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        pickupLat: json["pickup_lat"].toDouble(),
        pickupLong: json["pickup_long"].toDouble(),
        destinLat: json["destin_lat"].toDouble(),
        destinLong: json["destin_long"].toDouble(),
        distance: json["distance"],
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "pickup_lat": pickupLat,
        "pickup_long": pickupLong,
        "destin_lat": destinLat,
        "destin_long": destinLong,
        "distance": distance,
        "duration": duration,
      };
}
