// To parse this JSON data, do
//
//     final getAllSystemDataModel = getAllSystemDataModelFromJson(jsonString);

import 'dart:convert';

GetAllSystemDataModel getAllSystemDataModelFromJson(String str) =>
    GetAllSystemDataModel.fromJson(json.decode(str));

String getAllSystemDataModelToJson(GetAllSystemDataModel data) =>
    json.encode(data.toJson());

class GetAllSystemDataModel {
  String? status;
  List<Datum>? data;

  GetAllSystemDataModel({
    this.status,
    this.data,
  });

  factory GetAllSystemDataModel.fromJson(Map<String, dynamic> json) =>
      GetAllSystemDataModel(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? systemSettingsId;
  String? type;
  String? description;

  Datum({
    this.systemSettingsId,
    this.type,
    this.description,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        systemSettingsId: json["system_settings_id"],
        type: json["type"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "system_settings_id": systemSettingsId,
        "type": type,
        "description": description,
      };
}
