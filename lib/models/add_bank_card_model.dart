// // To parse this JSON data, do
// //
// //     final addBankCardModel = addBankCardModelFromJson(jsonString);
//
// import 'dart:convert';
//
// AddBankCardModel addBankCardModelFromJson(String str) => AddBankCardModel.fromJson(json.decode(str));
//
// String addBankCardModelToJson(AddBankCardModel data) => json.encode(data.toJson());
//
// class AddBankCardModel {
//   String? status;
//   Data? data;
//
//   AddBankCardModel({
//     this.status,
//     this.data,
//   });
//
//   factory AddBankCardModel.fromJson(Map<String, dynamic> json) => AddBankCardModel(
//     status: json["status"],
//     data: Data.fromJson(json["data"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "data": data?.toJson(),
//   };
// }
//
// class Data {
//   int? banksCardsId;
//   int? usersCustomersId;
//   String? cardHolderName;
//   String? cardNumber;
//   String? expiryMonth;
//   String? expiryYear;
//   String? cvv;
//   String? dateAdded;
//   dynamic dateModified;
//   String? status;
//   UsersCustomers? usersCustomers;
//
//   Data({
//     this.banksCardsId,
//     this.usersCustomersId,
//     this.cardHolderName,
//     this.cardNumber,
//     this.expiryMonth,
//     this.expiryYear,
//     this.cvv,
//     this.dateAdded,
//     this.dateModified,
//     this.status,
//     this.usersCustomers,
//   });
//
//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//     banksCardsId: json["banks_cards_id"],
//     usersCustomersId: json["users_customers_id"],
//     cardHolderName: json["card_holder_name"],
//     cardNumber: json["card_number"],
//     expiryMonth: json["expiry_month"],
//     expiryYear: json["expiry_year"],
//     cvv: json["cvv"],
//     dateAdded: json["date_added"],
//     dateModified: json["date_modified"],
//     status: json["status"],
//     usersCustomers: UsersCustomers.fromJson(json["users_customers"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "banks_cards_id": banksCardsId,
//     "users_customers_id": usersCustomersId,
//     "card_holder_name": cardHolderName,
//     "card_number": cardNumber,
//     "expiry_month": expiryMonth,
//     "expiry_year": expiryYear,
//     "cvv": cvv,
//     "date_added": dateAdded,
//     "date_modified": dateModified,
//     "status": status,
//     "users_customers": usersCustomers?.toJson(),
//   };
// }
//
// class UsersCustomers {
//   int? usersCustomersId;
//   String? oneSignalId;
//   String? walletAmount;
//   dynamic lastActivity;
//   dynamic bookingsRatings;
//   String? firstName;
//   String? lastName;
//   String? phone;
//   String? email;
//   dynamic password;
//   String? profilePic;
//   String? latitude;
//   String? longitude;
//   dynamic googleAccessToken;
//   String? accountType;
//   String? socialAccountType;
//   dynamic badgeVerified;
//   String? notifications;
//   String? messages;
//   dynamic updateProfile;
//   String? verifyEmailOtp;
//   String? verifyEmailOtpCreatedAt;
//   dynamic emailVerified;
//   dynamic verifyPhoneOtp;
//   dynamic verifyPhoneOtpCreatedAt;
//   dynamic phoneVerified;
//   dynamic forgotPwdOtp;
//   dynamic forgotPwdOtpCreatedAt;
//   String? dateAdded;
//   String? dateModified;
//   String? status;
//
//   UsersCustomers({
//     this.usersCustomersId,
//     this.oneSignalId,
//     this.walletAmount,
//     this.lastActivity,
//     this.bookingsRatings,
//     this.firstName,
//     this.lastName,
//     this.phone,
//     this.email,
//     this.password,
//     this.profilePic,
//     this.latitude,
//     this.longitude,
//     this.googleAccessToken,
//     this.accountType,
//     this.socialAccountType,
//     this.badgeVerified,
//     this.notifications,
//     this.messages,
//     this.updateProfile,
//     this.verifyEmailOtp,
//     this.verifyEmailOtpCreatedAt,
//     this.emailVerified,
//     this.verifyPhoneOtp,
//     this.verifyPhoneOtpCreatedAt,
//     this.phoneVerified,
//     this.forgotPwdOtp,
//     this.forgotPwdOtpCreatedAt,
//     this.dateAdded,
//     this.dateModified,
//     this.status,
//   });
//
//   factory UsersCustomers.fromJson(Map<String, dynamic> json) => UsersCustomers(
//     usersCustomersId: json["users_customers_id"],
//     oneSignalId: json["one_signal_id"],
//     walletAmount: json["wallet_amount"],
//     lastActivity: json["last_activity"],
//     bookingsRatings: json["bookings_ratings"],
//     firstName: json["first_name"],
//     lastName: json["last_name"],
//     phone: json["phone"],
//     email: json["email"],
//     password: json["password"],
//     profilePic: json["profile_pic"],
//     latitude: json["latitude"],
//     longitude: json["longitude"],
//     googleAccessToken: json["google_access_token"],
//     accountType: json["account_type"],
//     socialAccountType: json["social_account_type"],
//     badgeVerified: json["badge_verified"],
//     notifications: json["notifications"],
//     messages: json["messages"],
//     updateProfile: json["update_profile"],
//     verifyEmailOtp: json["verify_email_otp"],
//     verifyEmailOtpCreatedAt: json["verify_email_otp_created_at"],
//     emailVerified: json["email_verified"],
//     verifyPhoneOtp: json["verify_phone_otp"],
//     verifyPhoneOtpCreatedAt: json["verify_phone_otp_created_at"],
//     phoneVerified: json["phone_verified"],
//     forgotPwdOtp: json["forgot_pwd_otp"],
//     forgotPwdOtpCreatedAt: json["forgot_pwd_otp_created_at"],
//     dateAdded: json["date_added"],
//     dateModified: json["date_modified"],
//     status: json["status"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "users_customers_id": usersCustomersId,
//     "one_signal_id": oneSignalId,
//     "wallet_amount": walletAmount,
//     "last_activity": lastActivity,
//     "bookings_ratings": bookingsRatings,
//     "first_name": firstName,
//     "last_name": lastName,
//     "phone": phone,
//     "email": email,
//     "password": password,
//     "profile_pic": profilePic,
//     "latitude": latitude,
//     "longitude": longitude,
//     "google_access_token": googleAccessToken,
//     "account_type": accountType,
//     "social_account_type": socialAccountType,
//     "badge_verified": badgeVerified,
//     "notifications": notifications,
//     "messages": messages,
//     "update_profile": updateProfile,
//     "verify_email_otp": verifyEmailOtp,
//     "verify_email_otp_created_at": verifyEmailOtpCreatedAt,
//     "email_verified": emailVerified,
//     "verify_phone_otp": verifyPhoneOtp,
//     "verify_phone_otp_created_at": verifyPhoneOtpCreatedAt,
//     "phone_verified": phoneVerified,
//     "forgot_pwd_otp": forgotPwdOtp,
//     "forgot_pwd_otp_created_at": forgotPwdOtpCreatedAt,
//     "date_added": dateAdded,
//     "date_modified": dateModified,
//     "status": status,
//   };
// }
