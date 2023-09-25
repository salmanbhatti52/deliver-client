// To parse this JSON data, do
//
//     final getVehiclesByServiceTypeModel = getVehiclesByServiceTypeModelFromJson(jsonString);

import 'dart:convert';

GetVehiclesByServiceTypeModel getVehiclesByServiceTypeModelFromJson(
        String str) =>
    GetVehiclesByServiceTypeModel.fromJson(json.decode(str));

String getVehiclesByServiceTypeModelToJson(
        GetVehiclesByServiceTypeModel data) =>
    json.encode(data.toJson());

class GetVehiclesByServiceTypeModel {
  String? status;
  List<Datum>? data;

  GetVehiclesByServiceTypeModel({
    this.status,
    this.data,
  });

  factory GetVehiclesByServiceTypeModel.fromJson(Map<String, dynamic> json) =>
      GetVehiclesByServiceTypeModel(
        status: json["status"],
        data: json["data"] != null
            ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
            : null,
        // data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? vehiclesId;
  int? serviceTypesId;
  String? name;
  String? weightAllowed;
  String? numberOfParcels;
  String? amount;
  String? tollgateAmount;
  String? cancellationAmount;
  String? dateAdded;
  String? dateModified;
  String? status;
  ServiceTypes? serviceTypes;

  Datum({
    this.vehiclesId,
    this.serviceTypesId,
    this.name,
    this.weightAllowed,
    this.numberOfParcels,
    this.amount,
    this.tollgateAmount,
    this.cancellationAmount,
    this.dateAdded,
    this.dateModified,
    this.status,
    this.serviceTypes,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        vehiclesId: json["vehicles_id"],
        serviceTypesId: json["service_types_id"],
        name: json["name"],
        weightAllowed: json["weight_allowed"],
        numberOfParcels: json["number_of_parcels"],
        amount: json["amount"],
        tollgateAmount: json["tollgate_amount"],
        cancellationAmount: json["cancellation_amount"],
        dateAdded: json["date_added"],
        dateModified: json["date_modified"],
        status: json["status"],
        serviceTypes: json["service_types"] != null
            ? ServiceTypes.fromJson(json["service_types"])
            : null,
        // serviceTypes: ServiceTypes.fromJson(json["service_types"]),
      );

  Map<String, dynamic> toJson() => {
        "vehicles_id": vehiclesId,
        "service_types_id": serviceTypesId,
        "name": name,
        "weight_allowed": weightAllowed,
        "number_of_parcels": numberOfParcels,
        "amount": amount,
        "tollgate_amount": tollgateAmount,
        "cancellation_amount": cancellationAmount,
        "date_added": dateAdded,
        "date_modified": dateModified,
        "status": status,
        "service_types": serviceTypes?.toJson(),
      };
}

class ServiceTypes {
  int? serviceTypesId;
  String? name;
  String? status;

  ServiceTypes({
    this.serviceTypesId,
    this.name,
    this.status,
  });

  factory ServiceTypes.fromJson(Map<String, dynamic> json) => ServiceTypes(
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
