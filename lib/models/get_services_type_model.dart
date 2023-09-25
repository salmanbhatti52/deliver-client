// To parse this JSON data, do
//
//     final getServiceTypesModel = getServiceTypesModelFromJson(jsonString);

import 'dart:convert';

GetServiceTypesModel getServiceTypesModelFromJson(String str) =>
    GetServiceTypesModel.fromJson(json.decode(str));

String getServiceTypesModelToJson(GetServiceTypesModel data) =>
    json.encode(data.toJson());

class GetServiceTypesModel {
  String? status;
  List<Datum>? data;

  GetServiceTypesModel({
    this.status,
    this.data,
  });

  factory GetServiceTypesModel.fromJson(Map<String, dynamic> json) =>
      GetServiceTypesModel(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? serviceTypesId;
  String? name;
  String? status;

  Datum({
    this.serviceTypesId,
    this.name,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        serviceTypesId: json["service_types_id"],
        name: json["name"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "service_types_id": serviceTypesId,
        "name": name,
        "status": status,
      };
}
