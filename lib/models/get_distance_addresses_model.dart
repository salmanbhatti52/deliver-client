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
  Data? data;

  GetDistanceAddressesModel({
    this.status,
    this.message,
    this.data,
  });

  factory GetDistanceAddressesModel.fromJson(Map<String, dynamic> json) =>
      GetDistanceAddressesModel(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data!.toJson(),
      };
}

class Data {
  String? totalDeliveryCharges;
  String? totalVatCharges;
  String? totalCharges;
  String? totalServiceCharges;
  String? totalTollGateCharges;
  String? serviceRunning;
  List<BookingsDestination>? bookingsDestinations;

  Data(
      {this.totalDeliveryCharges,
      this.totalVatCharges,
      this.totalCharges,
      this.totalServiceCharges,
      this.bookingsDestinations,
      this.serviceRunning,
      this.totalTollGateCharges});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totalDeliveryCharges: json["total_delivery_charges"],
        totalVatCharges: json["total_vat_charges"],
        totalCharges: json["total_charges"],
        totalTollGateCharges: json["total_tollgate_charges"],
        totalServiceCharges: json["total_svc_running_charges"],
        serviceRunning: json["service_running"],
        bookingsDestinations: List<BookingsDestination>.from(
            json["bookings_destinations"]
                .map((x) => BookingsDestination.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "total_delivery_charges": totalDeliveryCharges,
        "total_vat_charges": totalVatCharges,
        "total_charges": totalCharges,
        "total_tollgate_charges": totalTollGateCharges,
        "total_svc_running_charges": totalServiceCharges,
        "service_running": serviceRunning,
        "bookings_destinations":
            List<dynamic>.from(bookingsDestinations!.map((x) => x.toJson())),
      };
}

class BookingsDestination {
  double? pickupLatitude;
  double? pickupLongitude;
  double? destinLatitude;
  double? destinLongitude;
  String? destinDistance;
  String? destinTime;
  String? destinDeliveryCharges;
  String? destinVatCharges;
  String? destinTotalCharges;
  String? totalServiceCharges;
  String? totalTollGateCharges;

  BookingsDestination({
    this.pickupLatitude,
    this.pickupLongitude,
    this.destinLatitude,
    this.destinLongitude,
    this.destinDistance,
    this.destinTime,
    this.destinDeliveryCharges,
    this.destinVatCharges,
    this.destinTotalCharges,
    this.totalServiceCharges,
    this.totalTollGateCharges,
  });

  factory BookingsDestination.fromJson(Map<String, dynamic> json) =>
      BookingsDestination(
        pickupLatitude: json["pickup_latitude"].toDouble(),
        pickupLongitude: json["pickup_longitude"].toDouble(),
        destinLatitude: json["destin_latitude"].toDouble(),
        destinLongitude: json["destin_longitude"].toDouble(),
        destinDistance: json["destin_distance"],
        destinTime: json["destin_time"],
        destinDeliveryCharges: json["destin_delivery_charges"],
        destinVatCharges: json["destin_vat_charges"],
        destinTotalCharges: json["destin_total_charges"],
        totalServiceCharges: json["svc_running_charges"],
        totalTollGateCharges: json["total_tollgate_charges"],
      );

  Map<String, dynamic> toJson() => {
        "pickup_latitude": pickupLatitude,
        "pickup_longitude": pickupLongitude,
        "destin_latitude": destinLatitude,
        "destin_longitude": destinLongitude,
        "destin_distance": destinDistance,
        "destin_time": destinTime,
        "destin_delivery_charges": destinDeliveryCharges,
        "destin_vat_charges": destinVatCharges,
        "destin_total_charges": destinTotalCharges,
        "svc_running_charges": totalServiceCharges,
        "total_tollgate_charges": totalTollGateCharges,
      };
}
