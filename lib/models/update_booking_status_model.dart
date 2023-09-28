// To parse this JSON data, do
//
//     final updateBookingStatusModel = updateBookingStatusModelFromJson(jsonString);

import 'dart:convert';

UpdateBookingStatusModel updateBookingStatusModelFromJson(String str) =>
    UpdateBookingStatusModel.fromJson(json.decode(str));

String updateBookingStatusModelToJson(UpdateBookingStatusModel data) =>
    json.encode(data.toJson());

class UpdateBookingStatusModel {
  String? status;
  Data? data;

  UpdateBookingStatusModel({
    this.status,
    this.data,
  });

  factory UpdateBookingStatusModel.fromJson(Map<String, dynamic> json) =>
      UpdateBookingStatusModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };
}

class Data {
  int? bookingsId;
  int? usersCustomersId;
  int? bookingsTypesId;
  String? deliveryType;
  String? pickupAddress;
  String? pickupLatitude;
  String? pickupLongitude;
  String? scheduled;
  dynamic deliveryDate;
  dynamic deliveryTime;
  String? totalDeliveryCharges;
  String? totalVatCharges;
  String? totalCharges;
  String? totalDiscount;
  String? totalDiscountedCharges;
  int? paymentGatewaysId;
  String? paymentBy;
  String? paymentStatus;
  String? dateAdded;
  String? dateModified;
  String? status;
  BookingsTypes? bookingsTypes;
  PaymentGateways? paymentGateways;
  List<BookingsFleet>? bookingsFleet;
  UsersCustomers? usersCustomers;

  Data({
    this.bookingsId,
    this.usersCustomersId,
    this.bookingsTypesId,
    this.deliveryType,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.scheduled,
    this.deliveryDate,
    this.deliveryTime,
    this.totalDeliveryCharges,
    this.totalVatCharges,
    this.totalCharges,
    this.totalDiscount,
    this.totalDiscountedCharges,
    this.paymentGatewaysId,
    this.paymentBy,
    this.paymentStatus,
    this.dateAdded,
    this.dateModified,
    this.status,
    this.bookingsTypes,
    this.paymentGateways,
    this.bookingsFleet,
    this.usersCustomers,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        bookingsId: json["bookings_id"],
        usersCustomersId: json["users_customers_id"],
        bookingsTypesId: json["bookings_types_id"],
        deliveryType: json["delivery_type"],
        pickupAddress: json["pickup_address"],
        pickupLatitude: json["pickup_latitude"],
        pickupLongitude: json["pickup_longitude"],
        scheduled: json["scheduled"],
        deliveryDate: json["delivery_date"],
        deliveryTime: json["delivery_time"],
        totalDeliveryCharges: json["total_delivery_charges"],
        totalVatCharges: json["total_vat_charges"],
        totalCharges: json["total_charges"],
        totalDiscount: json["total_discount"],
        totalDiscountedCharges: json["total_discounted_charges"],
        paymentGatewaysId: json["payment_gateways_id"],
        paymentBy: json["payment_by"],
        paymentStatus: json["payment_status"],
        dateAdded: json["date_added"],
        dateModified: json["date_modified"],
        status: json["status"],
        bookingsTypes: BookingsTypes.fromJson(json["bookings_types"]),
        paymentGateways: PaymentGateways.fromJson(json["payment_gateways"]),
        bookingsFleet: List<BookingsFleet>.from(
            json["bookings_fleet"].map((x) => BookingsFleet.fromJson(x))),
        usersCustomers: UsersCustomers.fromJson(json["users_customers"]),
      );

  Map<String, dynamic> toJson() => {
        "bookings_id": bookingsId,
        "users_customers_id": usersCustomersId,
        "bookings_types_id": bookingsTypesId,
        "delivery_type": deliveryType,
        "pickup_address": pickupAddress,
        "pickup_latitude": pickupLatitude,
        "pickup_longitude": pickupLongitude,
        "scheduled": scheduled,
        "delivery_date": deliveryDate,
        "delivery_time": deliveryTime,
        "total_delivery_charges": totalDeliveryCharges,
        "total_vat_charges": totalVatCharges,
        "total_charges": totalCharges,
        "total_discount": totalDiscount,
        "total_discounted_charges": totalDiscountedCharges,
        "payment_gateways_id": paymentGatewaysId,
        "payment_by": paymentBy,
        "payment_status": paymentStatus,
        "date_added": dateAdded,
        "date_modified": dateModified,
        "status": status,
        "bookings_types": bookingsTypes?.toJson(),
        "payment_gateways": paymentGateways?.toJson(),
        "bookings_fleet":
            List<dynamic>.from(bookingsFleet!.map((x) => x.toJson())),
        "users_customers": usersCustomers?.toJson(),
      };
}

class BookingsFleet {
  int? bookingsFleetId;
  int? bookingsId;
  int? bookingsDestinationsId;
  int? usersFleetId;
  int? vehiclesId;
  dynamic reason;
  String? fleetAmount;
  String? dateAdded;
  String? dateModified;
  String? status;
  BookingsDestinations? bookingsDestinations;
  Vehicles? vehicles;
  UsersFleet? usersFleet;

  BookingsFleet({
    this.bookingsFleetId,
    this.bookingsId,
    this.bookingsDestinationsId,
    this.usersFleetId,
    this.vehiclesId,
    this.reason,
    this.fleetAmount,
    this.dateAdded,
    this.dateModified,
    this.status,
    this.bookingsDestinations,
    this.vehicles,
    this.usersFleet,
  });

  factory BookingsFleet.fromJson(Map<String, dynamic> json) => BookingsFleet(
        bookingsFleetId: json["bookings_fleet_id"],
        bookingsId: json["bookings_id"],
        bookingsDestinationsId: json["bookings_destinations_id"],
        usersFleetId: json["users_fleet_id"],
        vehiclesId: json["vehicles_id"],
        reason: json["reason"],
        fleetAmount: json["fleet_amount"],
        dateAdded: json["date_added"],
        dateModified: json["date_modified"],
        status: json["status"],
        bookingsDestinations:
            BookingsDestinations.fromJson(json["bookings_destinations"]),
        vehicles: Vehicles.fromJson(json["vehicles"]),
        usersFleet: UsersFleet.fromJson(json["users_fleet"]),
      );

  Map<String, dynamic> toJson() => {
        "bookings_fleet_id": bookingsFleetId,
        "bookings_id": bookingsId,
        "bookings_destinations_id": bookingsDestinationsId,
        "users_fleet_id": usersFleetId,
        "vehicles_id": vehiclesId,
        "reason": reason,
        "fleet_amount": fleetAmount,
        "date_added": dateAdded,
        "date_modified": dateModified,
        "status": status,
        "bookings_destinations": bookingsDestinations?.toJson(),
        "vehicles": vehicles?.toJson(),
        "users_fleet": usersFleet?.toJson(),
      };
}

class BookingsDestinations {
  int? bookingsDestinationsId;
  int? bookingsId;
  String? destinAddress;
  String? destinLatitude;
  String? destinLongitude;
  String? destinDistance;
  String? destinTime;
  String? destinDeliveryCharges;
  String? destinVatCharges;
  String? destinTotalCharges;
  String? destinDiscount;
  String? destinDiscountedCharges;
  String? receiverName;
  String? receiverPhone;
  int? bookingsDestinationsStatusId;
  BookingsDestinationsStatus? bookingsDestinationsStatus;

  BookingsDestinations({
    this.bookingsDestinationsId,
    this.bookingsId,
    this.destinAddress,
    this.destinLatitude,
    this.destinLongitude,
    this.destinDistance,
    this.destinTime,
    this.destinDeliveryCharges,
    this.destinVatCharges,
    this.destinTotalCharges,
    this.destinDiscount,
    this.destinDiscountedCharges,
    this.receiverName,
    this.receiverPhone,
    this.bookingsDestinationsStatusId,
    this.bookingsDestinationsStatus,
  });

  factory BookingsDestinations.fromJson(Map<String, dynamic> json) =>
      BookingsDestinations(
        bookingsDestinationsId: json["bookings_destinations_id"],
        bookingsId: json["bookings_id"],
        destinAddress: json["destin_address"],
        destinLatitude: json["destin_latitude"],
        destinLongitude: json["destin_longitude"],
        destinDistance: json["destin_distance"],
        destinTime: json["destin_time"],
        destinDeliveryCharges: json["destin_delivery_charges"],
        destinVatCharges: json["destin_vat_charges"],
        destinTotalCharges: json["destin_total_charges"],
        destinDiscount: json["destin_discount"],
        destinDiscountedCharges: json["destin_discounted_charges"],
        receiverName: json["receiver_name"],
        receiverPhone: json["receiver_phone"],
        bookingsDestinationsStatusId: json["bookings_destinations_status_id"],
        bookingsDestinationsStatus: BookingsDestinationsStatus.fromJson(
            json["bookings_destinations_status"]),
      );

  Map<String, dynamic> toJson() => {
        "bookings_destinations_id": bookingsDestinationsId,
        "bookings_id": bookingsId,
        "destin_address": destinAddress,
        "destin_latitude": destinLatitude,
        "destin_longitude": destinLongitude,
        "destin_distance": destinDistance,
        "destin_time": destinTime,
        "destin_delivery_charges": destinDeliveryCharges,
        "destin_vat_charges": destinVatCharges,
        "destin_total_charges": destinTotalCharges,
        "destin_discount": destinDiscount,
        "destin_discounted_charges": destinDiscountedCharges,
        "receiver_name": receiverName,
        "receiver_phone": receiverPhone,
        "bookings_destinations_status_id": bookingsDestinationsStatusId,
        "bookings_destinations_status": bookingsDestinationsStatus?.toJson(),
      };
}

class BookingsDestinationsStatus {
  int? bookingsDestinationsStatusId;
  String? name;
  String? status;

  BookingsDestinationsStatus({
    this.bookingsDestinationsStatusId,
    this.name,
    this.status,
  });

  factory BookingsDestinationsStatus.fromJson(Map<String, dynamic> json) =>
      BookingsDestinationsStatus(
        bookingsDestinationsStatusId: json["bookings_destinations_status_id"],
        name: json["name"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "bookings_destinations_status_id": bookingsDestinationsStatusId,
        "name": name,
        "status": status,
      };
}

class UsersFleet {
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

  UsersFleet({
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
  });

  factory UsersFleet.fromJson(Map<String, dynamic> json) => UsersFleet(
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

class PaymentGateways {
  int? paymentGatewaysId;
  String? paymentType;
  String? name;
  String? status;

  PaymentGateways({
    this.paymentGatewaysId,
    this.paymentType,
    this.name,
    this.status,
  });

  factory PaymentGateways.fromJson(Map<String, dynamic> json) =>
      PaymentGateways(
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

class UsersCustomers {
  int? usersCustomersId;
  String? oneSignalId;
  String? walletAmount;
  dynamic lastActivity;
  dynamic bookingsRatings;
  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  dynamic password;
  String? profilePic;
  dynamic latitude;
  dynamic longitude;
  dynamic googleAccessToken;
  String? accountType;
  String? socialAccountType;
  String? badgeVerified;
  String? notifications;
  String? messages;
  dynamic updateProfile;
  dynamic verifyEmailOtp;
  dynamic verifyEmailOtpCreatedAt;
  String? emailVerified;
  dynamic verifyPhoneOtp;
  dynamic verifyPhoneOtpCreatedAt;
  String? phoneVerified;
  dynamic forgotPwdOtp;
  dynamic forgotPwdOtpCreatedAt;
  String? dateAdded;
  dynamic dateModified;
  String? status;

  UsersCustomers({
    this.usersCustomersId,
    this.oneSignalId,
    this.walletAmount,
    this.lastActivity,
    this.bookingsRatings,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.password,
    this.profilePic,
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
  });

  factory UsersCustomers.fromJson(Map<String, dynamic> json) => UsersCustomers(
        usersCustomersId: json["users_customers_id"],
        oneSignalId: json["one_signal_id"],
        walletAmount: json["wallet_amount"],
        lastActivity: json["last_activity"],
        bookingsRatings: json["bookings_ratings"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        phone: json["phone"],
        email: json["email"],
        password: json["password"],
        profilePic: json["profile_pic"],
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
      );

  Map<String, dynamic> toJson() => {
        "users_customers_id": usersCustomersId,
        "one_signal_id": oneSignalId,
        "wallet_amount": walletAmount,
        "last_activity": lastActivity,
        "bookings_ratings": bookingsRatings,
        "first_name": firstName,
        "last_name": lastName,
        "phone": phone,
        "email": email,
        "password": password,
        "profile_pic": profilePic,
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
      };
}
