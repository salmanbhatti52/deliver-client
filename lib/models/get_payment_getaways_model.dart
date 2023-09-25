// To parse this JSON data, do
//
//     final getPaymentGatewaysModel = getPaymentGatewaysModelFromJson(jsonString);

import 'dart:convert';

GetPaymentGatewaysModel getPaymentGatewaysModelFromJson(String str) =>
    GetPaymentGatewaysModel.fromJson(json.decode(str));

String getPaymentGatewaysModelToJson(GetPaymentGatewaysModel data) =>
    json.encode(data.toJson());

class GetPaymentGatewaysModel {
  String? status;
  List<Datum>? data;

  GetPaymentGatewaysModel({
    this.status,
    this.data,
  });

  factory GetPaymentGatewaysModel.fromJson(Map<String, dynamic> json) =>
      GetPaymentGatewaysModel(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  int? paymentGatewaysId;
  String? paymentType;
  String? name;
  String? status;

  Datum({
    this.paymentGatewaysId,
    this.paymentType,
    this.name,
    this.status,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        paymentGatewaysId: json["payment_gateways_id"],
        paymentType: json["payment_type"],
        name: json["name"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "payment_gateways_id": paymentGatewaysId,
        "payment_type": paymentType,
        "name": name,
        "status": status,
      };
}
