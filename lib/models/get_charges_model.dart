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
  List<Datum>? data;

  GetChargesModel({
    this.status,
    this.data,
  });

  factory GetChargesModel.fromJson(Map<String, dynamic> json) =>
      GetChargesModel(
        status: json["status"],
        data: json["data"] != null
            ? List<Datum>.from(json["data"].map((x) => Datum.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data != null
            ? List<dynamic>.from(data!.map((x) => x.toJson()))
            : null,
      };
}

class Datum {
  int? bookingsTypesMilesId;
  int? bookingsTypesId;
  int? vehiclesId;
  String? firstMilesFrom;
  String? firstMilesTo;
  String? firstMilesAmount;
  String? perMilesExtra;
  String? status;
  BookingsTypes? bookingsTypes;
  Vehicles? vehicles;

  Datum({
    this.bookingsTypesMilesId,
    this.bookingsTypesId,
    this.vehiclesId,
    this.firstMilesFrom,
    this.firstMilesTo,
    this.firstMilesAmount,
    this.perMilesExtra,
    this.status,
    this.bookingsTypes,
    this.vehicles,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        bookingsTypesMilesId: json["bookings_types_miles_id"],
        bookingsTypesId: json["bookings_types_id"],
        vehiclesId: json["vehicles_id"],
        firstMilesFrom: json["first_miles_from"],
        firstMilesTo: json["first_miles_to"],
        firstMilesAmount: json["first_miles_amount"],
        perMilesExtra: json["per_miles_extra"],
        status: json["status"],
        bookingsTypes: BookingsTypes.fromJson(json["bookings_types"]),
        vehicles: json["vehicles"] != null
            ? Vehicles.fromJson(json["vehicles"])
            : null,
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
        "bookings_types": bookingsTypes?.toJson(),
        "vehicles": vehicles?.toJson(),
      };
}

class BookingsTypes {
  int? bookingsTypesId;
  String? name;
  String? sameDay;
  String? status;

  BookingsTypes({
    this.bookingsTypesId,
    this.name,
    this.sameDay,
    this.status,
  });

  factory BookingsTypes.fromJson(Map<String, dynamic> json) => BookingsTypes(
        bookingsTypesId: json["bookings_types_id"],
        name: json["name"],
        sameDay: json["same_day"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "bookings_types_id": bookingsTypesId,
        "name": name,
        "same_day": sameDay,
        "status": status,
      };
}

class Vehicles {
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

  Vehicles({
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

  factory Vehicles.fromJson(Map<String, dynamic> json) => Vehicles(
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
        serviceTypes: ServiceTypes.fromJson(json["service_types"]),
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
