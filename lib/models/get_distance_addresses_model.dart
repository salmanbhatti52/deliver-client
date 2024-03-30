// To parse this JSON data, do
//
//     final getDistanceAddressesModel = getDistanceAddressesModelFromJson(jsonString);

import 'dart:convert';

GetDistanceAddressesModel getDistanceAddressesModelFromJson(String str) => GetDistanceAddressesModel.fromJson(json.decode(str));

String getDistanceAddressesModelToJson(GetDistanceAddressesModel data) => json.encode(data.toJson());

class GetDistanceAddressesModel {
  String? status;
  List<Datum>? data;

  GetDistanceAddressesModel({
    this.status,
    this.data,
  });

  factory GetDistanceAddressesModel.fromJson(Map<String, dynamic> json) => GetDistanceAddressesModel(
    status: json["status"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? distance;

  Datum({
    this.distance,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    distance: json["distance"],
  );

  Map<String, dynamic> toJson() => {
    "distance": distance,
  };
}
