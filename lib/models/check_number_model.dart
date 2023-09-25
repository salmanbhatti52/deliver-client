// To parse this JSON data, do
//
//     final checkNumberModel = checkNumberModelFromJson(jsonString);

import 'dart:convert';

CheckNumberModel checkNumberModelFromJson(String str) => CheckNumberModel.fromJson(json.decode(str));

String checkNumberModelToJson(CheckNumberModel data) => json.encode(data.toJson());

class CheckNumberModel {
  String? status;
  Data? data;

  CheckNumberModel({
    this.status,
    this.data,
  });

  factory CheckNumberModel.fromJson(Map<String, dynamic> json) => CheckNumberModel(
    status: json["status"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "data": data?.toJson(),
  };
}

class Data {
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

  Data({
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
