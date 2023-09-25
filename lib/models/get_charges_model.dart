// To parse this JSON data, do
//
//     final getChargesModel = getChargesModelFromJson(jsonString);

import 'dart:convert';

GetChargesModel getChargesModelFromJson(String str) =>
    GetChargesModel.fromJson(json.decode(str));

String getChargesModelToJson(GetChargesModel data) =>
    json.encode(data.toJson());

class GetChargesModel {
  String? status;
  Data? data;

  GetChargesModel({
    this.status,
    this.data,
  });

  factory GetChargesModel.fromJson(Map<String, dynamic> json) =>
      GetChargesModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };
}

class Data {
  int? bookingsTypesMilesId;
  int? bookingsTypesId;
  int? vehiclesId;
  String? firstMilesFrom;
  String? firstMilesTo;
  String? firstMilesAmount;
  String? perMilesExtra;
  String? status;
  Vehicles? vehicles;
  String? vatCharges;
  ServiceRunning? serviceRunning;

  Data({
    this.bookingsTypesMilesId,
    this.bookingsTypesId,
    this.vehiclesId,
    this.firstMilesFrom,
    this.firstMilesTo,
    this.firstMilesAmount,
    this.perMilesExtra,
    this.status,
    this.vehicles,
    this.vatCharges,
    this.serviceRunning,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        bookingsTypesMilesId: json["bookings_types_miles_id"],
        bookingsTypesId: json["bookings_types_id"],
        vehiclesId: json["vehicles_id"],
        firstMilesFrom: json["first_miles_from"],
        firstMilesTo: json["first_miles_to"],
        firstMilesAmount: json["first_miles_amount"],
        perMilesExtra: json["per_miles_extra"],
        status: json["status"],
        vehicles: json["vehicles"] != null
            ? Vehicles.fromJson(json["vehicles"])
            : null,
        // vehicles: Vehicles.fromJson(json["vehicles"]),
        vatCharges: json["vat_charges"],
        serviceRunning: json["service_running"] != null
            ? ServiceRunning.fromJson(json["service_running"])
            : null,
        // serviceRunning: ServiceRunning.fromJson(json["service_running"]),
      );

  Map<String, dynamic> toJson() => {
        "bookings_types_miles_id": bookingsTypesMilesId,
        "bookings_types_id": bookingsTypesId,
        "vehicles_id": vehiclesId,
        "first_miles_from": firstMilesFrom,
        "first_miles_to": firstMilesTo,
        "first_miles_amount": firstMilesAmount,
        "per_miles_extra": perMilesExtra,
        "status": status,
        "vehicles": vehicles?.toJson(),
        "vat_charges": vatCharges,
        "service_running": serviceRunning?.toJson(),
      };
}

class ServiceRunning {
  String? name;
  String? perKmCharges;

  ServiceRunning({
    this.name,
    this.perKmCharges,
  });

  factory ServiceRunning.fromJson(Map<String, dynamic> json) => ServiceRunning(
        name: json["name"],
        perKmCharges: json["per_km_charges"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "per_km_charges": perKmCharges,
      };
}

class Vehicles {
  int? vehiclesId;
  String? name;
  String? weightAllowed;
  String? numberOfParcels;
  String? amount;
  String? dateAdded;
  String? dateModified;
  String? status;

  Vehicles({
    this.vehiclesId,
    this.name,
    this.weightAllowed,
    this.numberOfParcels,
    this.amount,
    this.dateAdded,
    this.dateModified,
    this.status,
  });

  factory Vehicles.fromJson(Map<String, dynamic> json) => Vehicles(
        vehiclesId: json["vehicles_id"],
        name: json["name"],
        weightAllowed: json["weight_allowed"],
        numberOfParcels: json["number_of_parcels"],
        amount: json["amount"],
        dateAdded: json["date_added"],
        dateModified: json["date_modified"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "vehicles_id": vehiclesId,
        "name": name,
        "weight_allowed": weightAllowed,
        "number_of_parcels": numberOfParcels,
        "amount": amount,
        "date_added": dateAdded,
        "date_modified": dateModified,
        "status": status,
      };
}
