// To parse this JSON data, do
//
//     final searchRiderModel = searchRiderModelFromJson(jsonString);

import 'dart:convert';

SearchRiderModel searchRiderModelFromJson(String str) =>
    SearchRiderModel.fromJson(json.decode(str));

String searchRiderModelToJson(SearchRiderModel data) =>
    json.encode(data.toJson());

class SearchRiderModel {
  String? status;
  List<SearchRiderData>? data;

  SearchRiderModel({
    this.status,
    this.data,
  });

  factory SearchRiderModel.fromJson(Map<String, dynamic> json) =>
      SearchRiderModel(
        status: json["status"],
        data: List<SearchRiderData>.from(
            json["data"].map((x) => SearchRiderData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class SearchRiderData {
  int? usersFleetId;
  String? oneSignalId;
  String? userType;
  String? walletAmount;
  String? availability;
  String? onlineStatus;
  dynamic lastActivity;
  String? bookingsRatings;
  int? parentId;
  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  String? password;
  String? profilePic;
  String? address;
  String? nationalIdentificationNo;
  String? drivingLicenseNo;
  String? drivingLicenseFrontImage;
  String? drivingLicenseBackImage;
  dynamic cacCertificate;
  String? latitude;
  String? longitude;
  dynamic googleAccessToken;
  String? accountType;
  String? socialAccountType;
  String? badgeVerified;
  String? notifications;
  String? messages;
  String? updateProfile;
  dynamic verifyEmailOtp;
  dynamic verifyEmailOtpCreatedAt;
  String? emailVerified;
  dynamic verifyPhoneOtp;
  dynamic verifyPhoneOtpCreatedAt;
  String? phoneVerified;
  dynamic forgotPwdOtp;
  dynamic forgotPwdOtpCreatedAt;
  String? dateAdded;
  String? dateModified;
  String? status;
  UsersFleetVehicles? usersFleetVehicles;
  String? distance;
  int? trips;
  String? experience;

  SearchRiderData({
    this.usersFleetId,
    this.oneSignalId,
    this.userType,
    this.walletAmount,
    this.availability,
    this.onlineStatus,
    this.lastActivity,
    this.bookingsRatings,
    this.parentId,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.password,
    this.profilePic,
    this.address,
    this.nationalIdentificationNo,
    this.drivingLicenseNo,
    this.drivingLicenseFrontImage,
    this.drivingLicenseBackImage,
    this.cacCertificate,
    this.latitude,
    this.longitude,
    this.googleAccessToken,
    this.accountType,
    this.socialAccountType,
    this.badgeVerified,
    this.notifications,
    this.messages,
    this.updateProfile,
    this.verifyEmailOtp,
    this.verifyEmailOtpCreatedAt,
    this.emailVerified,
    this.verifyPhoneOtp,
    this.verifyPhoneOtpCreatedAt,
    this.phoneVerified,
    this.forgotPwdOtp,
    this.forgotPwdOtpCreatedAt,
    this.dateAdded,
    this.dateModified,
    this.status,
    this.usersFleetVehicles,
    this.distance,
    this.trips,
    this.experience,
  });

  factory SearchRiderData.fromJson(Map<String, dynamic> json) =>
      SearchRiderData(
        usersFleetId: json["users_fleet_id"],
        oneSignalId: json["one_signal_id"],
        userType: json["user_type"],
        walletAmount: json["wallet_amount"],
        availability: json["availability"],
        onlineStatus: json["online_status"],
        lastActivity: json["last_activity"],
        bookingsRatings: json["bookings_ratings"],
        parentId: json["parent_id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        phone: json["phone"],
        email: json["email"],
        password: json["password"],
        profilePic: json["profile_pic"],
        address: json["address"],
        nationalIdentificationNo: json["national_identification_no"],
        drivingLicenseNo: json["driving_license_no"],
        drivingLicenseFrontImage: json["driving_license_front_image"],
        drivingLicenseBackImage: json["driving_license_back_image"],
        cacCertificate: json["cac_certificate"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        googleAccessToken: json["google_access_token"],
        accountType: json["account_type"],
        socialAccountType: json["social_account_type"],
        badgeVerified: json["badge_verified"],
        notifications: json["notifications"],
        messages: json["messages"],
        updateProfile: json["update_profile"],
        verifyEmailOtp: json["verify_email_otp"],
        verifyEmailOtpCreatedAt: json["verify_email_otp_created_at"],
        emailVerified: json["email_verified"],
        verifyPhoneOtp: json["verify_phone_otp"],
        verifyPhoneOtpCreatedAt: json["verify_phone_otp_created_at"],
        phoneVerified: json["phone_verified"],
        forgotPwdOtp: json["forgot_pwd_otp"],
        forgotPwdOtpCreatedAt: json["forgot_pwd_otp_created_at"],
        dateAdded: json["date_added"],
        dateModified: json["date_modified"],
        status: json["status"],
        usersFleetVehicles:
            UsersFleetVehicles.fromJson(json["users_fleet_vehicles"]),
        distance: json["distance"],
        trips: json["trips"],
        experience: json["experience"],
      );

  Map<String, dynamic> toJson() => {
        "users_fleet_id": usersFleetId,
        "one_signal_id": oneSignalId,
        "user_type": userType,
        "wallet_amount": walletAmount,
        "availability": availability,
        "online_status": onlineStatus,
        "last_activity": lastActivity,
        "bookings_ratings": bookingsRatings,
        "parent_id": parentId,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "email": email,
        "password": password,
        "profile_pic": profilePic,
        "address": address,
        "national_identification_no": nationalIdentificationNo,
        "driving_license_no": drivingLicenseNo,
        "driving_license_front_image": drivingLicenseFrontImage,
        "driving_license_back_image": drivingLicenseBackImage,
        "cac_certificate": cacCertificate,
        "latitude": latitude,
        "longitude": longitude,
        "google_access_token": googleAccessToken,
        "account_type": accountType,
        "social_account_type": socialAccountType,
        "badge_verified": badgeVerified,
        "notifications": notifications,
        "messages": messages,
        "update_profile": updateProfile,
        "verify_email_otp": verifyEmailOtp,
        "verify_email_otp_created_at": verifyEmailOtpCreatedAt,
        "email_verified": emailVerified,
        "verify_phone_otp": verifyPhoneOtp,
        "verify_phone_otp_created_at": verifyPhoneOtpCreatedAt,
        "phone_verified": phoneVerified,
        "forgot_pwd_otp": forgotPwdOtp,
        "forgot_pwd_otp_created_at": forgotPwdOtpCreatedAt,
        "date_added": dateAdded,
        "date_modified": dateModified,
        "status": status,
        "users_fleet_vehicles": usersFleetVehicles?.toJson(),
        "distance": distance,
        "trips": trips,
        "experience": experience,
      };
}

class UsersFleetVehicles {
  int? usersFleetVehiclesId;
  int? usersFleetId;
  int? vehiclesId;
  String? model;
  String? color;
  String? vehicleRegistrationNo;
  String? vehicleIdentificationNo;
  String? vehicleLicenseExpiryDate;
  String? vehicleInsuranceExpiryDate;
  String? rwcExpiryDate;
  dynamic cost;
  String? manufactureYear;
  String? image;
  String? dateAdded;
  String? dateModified;
  String? status;
  Vehicles? vehicles;

  UsersFleetVehicles({
    this.usersFleetVehiclesId,
    this.usersFleetId,
    this.vehiclesId,
    this.model,
    this.color,
    this.vehicleRegistrationNo,
    this.vehicleIdentificationNo,
    this.vehicleLicenseExpiryDate,
    this.vehicleInsuranceExpiryDate,
    this.rwcExpiryDate,
    this.cost,
    this.manufactureYear,
    this.image,
    this.dateAdded,
    this.dateModified,
    this.status,
    this.vehicles,
  });

  factory UsersFleetVehicles.fromJson(Map<String, dynamic> json) =>
      UsersFleetVehicles(
        usersFleetVehiclesId: json["users_fleet_vehicles_id"],
        usersFleetId: json["users_fleet_id"],
        vehiclesId: json["vehicles_id"],
        model: json["model"],
        color: json["color"],
        vehicleRegistrationNo: json["vehicle_registration_no"],
        vehicleIdentificationNo: json["vehicle_identification_no"],
        vehicleLicenseExpiryDate: json["vehicle_license_expiry_date"],
        vehicleInsuranceExpiryDate: json["vehicle_insurance_expiry_date"],
        rwcExpiryDate: json["rwc_expiry_date"],
        cost: json["cost"],
        manufactureYear: json["manufacture_year"],
        image: json["image"],
        dateAdded: json["date_added"],
        dateModified: json["date_modified"],
        status: json["status"],
        vehicles: Vehicles.fromJson(json["vehicles"]),
      );

  Map<String, dynamic> toJson() => {
        "users_fleet_vehicles_id": usersFleetVehiclesId,
        "users_fleet_id": usersFleetId,
        "vehicles_id": vehiclesId,
        "model": model,
        "color": color,
        "vehicle_registration_no": vehicleRegistrationNo,
        "vehicle_identification_no": vehicleIdentificationNo,
        "vehicle_license_expiry_date": vehicleLicenseExpiryDate,
        "vehicle_insurance_expiry_date": vehicleInsuranceExpiryDate,
        "rwc_expiry_date": rwcExpiryDate,
        "cost": cost,
        "manufacture_year": manufactureYear,
        "image": image,
        "date_added": dateAdded,
        "date_modified": dateModified,
        "status": status,
        "vehicles": vehicles?.toJson(),
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
