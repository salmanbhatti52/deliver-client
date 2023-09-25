// To parse this JSON data, do
//
//     final getSupportMessageModel = getSupportMessageModelFromJson(jsonString);

import 'dart:convert';

GetSupportMessageModel getSupportMessageModelFromJson(String str) =>
    GetSupportMessageModel.fromJson(json.decode(str));

String getSupportMessageModelToJson(GetSupportMessageModel data) =>
    json.encode(data.toJson());

class GetSupportMessageModel {
  String? status;
  List<Datum>? data;

  GetSupportMessageModel({
    this.status,
    this.data,
  });

  factory GetSupportMessageModel.fromJson(Map<String, dynamic> json) =>
      GetSupportMessageModel(
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
  int? chatMessagesLiveId;
  String? senderType;
  String? receiverType;
  int? senderId;
  int? receiverId;
  String? messageType;
  String? message;
  String? sendDate;
  String? sendTime;
  String? dateAdded;
  dynamic dateRead;
  String? status;
  SenderData? senderData;
  ReceiverData? receiverData;

  Datum({
    this.chatMessagesLiveId,
    this.senderType,
    this.receiverType,
    this.senderId,
    this.receiverId,
    this.messageType,
    this.message,
    this.sendDate,
    this.sendTime,
    this.dateAdded,
    this.dateRead,
    this.status,
    this.senderData,
    this.receiverData,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        chatMessagesLiveId: json["chat_messages_live_id"],
        senderType: json["sender_type"],
        receiverType: json["receiver_type"],
        senderId: json["sender_id"],
        receiverId: json["receiver_id"],
        messageType: json["message_type"],
        message: json["message"],
        sendDate: json["send_date"],
        sendTime: json["send_time"],
        dateAdded: json["date_added"],
        dateRead: json["date_read"],
        status: json["status"],
        senderData: SenderData.fromJson(json["sender_data"]),
        receiverData: ReceiverData.fromJson(json["receiver_data"]),
      );

  Map<String, dynamic> toJson() => {
        "chat_messages_live_id": chatMessagesLiveId,
        "sender_type": senderType,
        "receiver_type": receiverType,
        "sender_id": senderId,
        "receiver_id": receiverId,
        "message_type": messageType,
        "message": message,
        "send_date": sendDate,
        "date_added": dateAdded,
        "date_read": dateRead,
        "status": status,
        "sender_data": senderData?.toJson(),
        "receiver_data": receiverData?.toJson(),
      };
}

class ReceiverData {
  int? usersCustomersId;
  String? oneSignalId;
  String? walletAmount;
  dynamic lastActivity;
  dynamic bookingsRatings;
  String? firstName;
  String? lastName;
  String? phone;
  String? email;
  String? password;
  String? profilePic;
  String? latitude;
  String? longitude;
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
  String? forgotPwdOtp;
  String? forgotPwdOtpCreatedAt;
  String? dateAdded;
  String? dateModified;
  String? status;

  ReceiverData({
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

  factory ReceiverData.fromJson(Map<String, dynamic> json) => ReceiverData(
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

class SenderData {
  int? usersSystemId;
  int? usersSystemRolesId;
  String? firstName;
  String? email;
  String? password;
  String? mobile;
  String? city;
  String? address;
  String? userImage;
  String? isDeleted;
  dynamic createdAt;
  dynamic updatedAt;
  dynamic deletedAt;
  String? status;

  SenderData({
    this.usersSystemId,
    this.usersSystemRolesId,
    this.firstName,
    this.email,
    this.password,
    this.mobile,
    this.city,
    this.address,
    this.userImage,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.status,
  });

  factory SenderData.fromJson(Map<String, dynamic> json) => SenderData(
        usersSystemId: json["users_system_id"],
        usersSystemRolesId: json["users_system_roles_id"],
        firstName: json["first_name"],
        email: json["email"],
        password: json["password"],
        mobile: json["mobile"],
        city: json["city"],
        address: json["address"],
        userImage: json["user_image"],
        isDeleted: json["is_deleted"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        deletedAt: json["deleted_at"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "users_system_id": usersSystemId,
        "users_system_roles_id": usersSystemRolesId,
        "first_name": firstName,
        "email": email,
        "password": password,
        "mobile": mobile,
        "city": city,
        "address": address,
        "user_image": userImage,
        "is_deleted": isDeleted,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "deleted_at": deletedAt,
        "status": status,
      };
}
