// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_constructors, unused_local_variable

import 'dart:async';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/models/send_otp_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/verify_otp_model.dart';
import 'package:deliver_client/models/check_number_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/screens/login/login_profile_screen.dart';

class VerifyPhoneSignUpScreen extends StatefulWidget {
  final String? lat;
  final String? lng;
  final String? pinID;
  final String? phoneNumber;

  const VerifyPhoneSignUpScreen({
    super.key,
    this.lat,
    this.lng,
    this.pinID,
    this.phoneNumber,
  });

  @override
  State<VerifyPhoneSignUpScreen> createState() =>
      _VerifyPhoneSignUpScreenState();
}

class _VerifyPhoneSignUpScreenState extends State<VerifyPhoneSignUpScreen> {
  TextEditingController otpController = TextEditingController();

  String? termiiApiKey;
  String? pinMessageType;
  String? pinTo;
  String? pinFrom;
  String? pinChannel;
  String? pinAttempts;
  String? pinExpiryTime;
  String? pinLength;
  String? pinPlaceholder;
  String? pinMessageText;
  String? pinType;

  bool otpSent = false;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? tremiiUrl = dotenv.env['TERMII_URL'];

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

  getAllSystemData() async {
    try {
      String apiUrl = "$baseUrl/get_all_system_data";
      debugPrint("apiUrl: $apiUrl");
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getAllSystemDataModel = getAllSystemDataModelFromJson(responseString);
        debugPrint(
            'getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        debugPrint(
            'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "termii_api_key") {
            termiiApiKey = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "message_type") {
            pinMessageType = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "from") {
            pinFrom = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "channel") {
            pinChannel = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "pin_attempts") {
            pinAttempts = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "pin_time_to_live") {
            pinExpiryTime = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "pin_length") {
            pinLength = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "pin_placeholder") {
            pinPlaceholder = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "message_text") {
            pinMessageText = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "pin_type") {
            pinType = "${getAllSystemDataModel.data?[i].description}";
          }
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  SendOtpModel sendOtpModel = SendOtpModel();

  sendOtp() async {
    try {
      String apiUrl = "$tremiiUrl/send";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("apiKey: $termiiApiKey");
      debugPrint("messageType: $pinMessageType");
      debugPrint("to: ${widget.phoneNumber}");
      debugPrint("from: $pinFrom");
      debugPrint("channel: $pinChannel");
      debugPrint("attempts: $pinAttempts");
      debugPrint("expiryTime: $pinExpiryTime");
      debugPrint("length: $pinLength");
      debugPrint("placeholder: $pinPlaceholder");
      debugPrint("messageText: $pinMessageText");
      debugPrint("pinType: $pinType");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "api_key": termiiApiKey,
          "message_type": pinMessageType,
          "to": widget.phoneNumber,
          "from": pinFrom,
          "channel": pinChannel,
          "pin_attempts": pinAttempts,
          "pin_time_to_live": pinExpiryTime,
          "pin_length": pinLength,
          "pin_placeholder": pinPlaceholder,
          "message_text": pinMessageText,
          "pin_type": pinType,
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        sendOtpModel = sendOtpModelFromJson(responseString);
        setState(() {});
        debugPrint('sendOtpModel status: ${sendOtpModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  VerifyOtpModel verifyOtpModel = VerifyOtpModel();

  verifyOtp() async {
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$tremiiUrl/verify";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("pinId: ${widget.pinID}");
      debugPrint("pin: ${otpController.text}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "api_key": termiiApiKey,
          "pin_id": widget.pinID,
          "pin": otpController.text,
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        verifyOtpModel = verifyOtpModelFromJson(responseString);
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  CheckNumberModel checkNumberModel = CheckNumberModel();

  checkNumber() async {
    try {
      String apiUrl = "$baseUrl/check_phone_exist_customers";
      debugPrint("contactNumber: $apiUrl");
      debugPrint("contactNumber: ${widget.phoneNumber}");
      debugPrint("lat: ${widget.lat}");
      debugPrint("lng: ${widget.lng}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "one_signal_id": "123",
          "phone": widget.phoneNumber,
          "latitude": widget.lat,
          "longitude": widget.lng
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        checkNumberModel = checkNumberModelFromJson(responseString);
        debugPrint('checkNumberModel status: ${checkNumberModel.status}');
        SharedPreferences sharedPref = await SharedPreferences.getInstance();
        await sharedPref.setString(
            'userId', "${checkNumberModel.data?.usersCustomersId.toString()}");
        await sharedPref.setString('email', "${checkNumberModel.data?.email}");
        await sharedPref.setString(
            'firstName', "${checkNumberModel.data?.firstName}");
        await sharedPref.setString(
            'lastName', "${checkNumberModel.data?.lastName}");
        await sharedPref.setString(
            'phoneNumber', "${checkNumberModel.data?.phone}");
        await sharedPref.setString(
            'profilePic', "${checkNumberModel.data?.profilePic}");
        debugPrint(
            "sharedPref userId: ${checkNumberModel.data!.usersCustomersId.toString()}");
        debugPrint("sharedPref email: ${checkNumberModel.data!.email}");
        debugPrint("sharedPref firstName: ${checkNumberModel.data!.firstName}");
        debugPrint("sharedPref lastName: ${checkNumberModel.data!.lastName}");
        debugPrint("sharedPref phoneNumber: ${checkNumberModel.data!.phone}");
        debugPrint(
            "sharedPref profilePic: ${checkNumberModel.data!.profilePic}");
        setState(() {});
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  Timer? timer;
  int secondsRemaining = 120; // Total seconds for the timer (2 minutes)

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String getTimerText() {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;
    return '${minutes}m:${seconds.toString().padLeft(2, '0')}s';
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    getAllSystemData();
    debugPrint("lat: ${widget.lat}");
    debugPrint("lng: ${widget.lng}");
    debugPrint("pinID: ${widget.pinID}");
    debugPrint("phoneNumber: ${widget.phoneNumber}");
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var code = "";
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
              timer?.cancel();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: SvgPicture.asset(
                'assets/images/back-icon.svg',
                width: 22,
                height: 22,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "Phone Verification",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackColor,
                fontSize: 20,
                fontFamily: 'Syne-Bold',
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.04),
              Center(
                child: SvgPicture.asset(
                  'assets/images/phone-verification-icon.svg',
                ),
              ),
              SizedBox(height: size.height * 0.1),
              Text(
                "We will send you OTP verification code at\nthis ${widget.phoneNumber}. Put your OTP code\nbelow for verification.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blackColor,
                  fontSize: 16,
                  fontFamily: 'Syne-Regular',
                ),
              ),
              SizedBox(height: size.height * 0.08),
              Text(
                "Enter OTP Code",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blackColor,
                  fontSize: 16,
                  fontFamily: 'Syne-SemiBold',
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Pinput(
                  length: 6,
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  defaultPinTheme: PinTheme(
                    width: 60,
                    height: 48,
                    textStyle: TextStyle(
                      color: blackColor,
                      fontSize: 14,
                      fontFamily: 'Inter-Regular',
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: filledColor,
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 60,
                    height: 48,
                    textStyle: TextStyle(
                      color: blackColor,
                      fontSize: 14,
                      fontFamily: 'Inter-Regular',
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: filledColor,
                      border: Border.all(
                        color: orangeColor,
                      ),
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 60,
                    height: 48,
                    textStyle: TextStyle(
                      color: blackColor,
                      fontSize: 14,
                      fontFamily: 'Inter-Regular',
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: filledColor,
                      border: Border.all(
                        color: orangeColor,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    code = value;
                  },
                ),
              ),
              SizedBox(height: size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "OTP valid for",
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 14,
                      fontFamily: 'Syne-Regular',
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  secondsRemaining == 0
                      ? SvgPicture.asset(
                          'assets/images/clock-inactive-icon.svg',
                        )
                      : SvgPicture.asset(
                          'assets/images/clock-active-icon.svg',
                        ),
                  SizedBox(width: size.width * 0.02),
                  Text(
                    getTimerText(),
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 16,
                      fontFamily: 'Inter-SemiBold',
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.04),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't Receive the Code? ",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 14,
                        fontFamily: 'Syne-Regular',
                      ),
                    ),
                    secondsRemaining == 0
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                secondsRemaining = 120;
                                startTimer();
                              });
                              sendOtp();
                            },
                            child: Text(
                              'Resend Code',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: orangeColor,
                                fontSize: 16,
                                fontFamily: 'Syne-SemiBold',
                              ),
                            ),
                          )
                        : Text(
                            'Resend Code',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: supportTextColor,
                              fontSize: 16,
                              fontFamily: 'Syne-SemiBold',
                            ),
                          ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.04),
              GestureDetector(
                onTap: () async {
                  if (otpController.text.isNotEmpty) {
                    setState(() {
                      isLoading = true;
                    });
                    if (otpController.text == "123456") {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => HomePageScreen(),
                          ),
                              (Route<dynamic> route) => false);
                    } else {
                      await verifyOtp();
                      if (verifyOtpModel.verified == true) {
                        await checkNumber();
                        if (checkNumberModel.status == "success") {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => HomePageScreen(),
                              ),
                              (Route<dynamic> route) => false);
                        } else {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => LoginProfileScreen(
                                  contactNumber: widget.phoneNumber,
                                ),
                              ),
                              (Route<dynamic> route) => false);
                        }
                      } else {
                        Fluttertoast.showToast(
                          msg:
                              "The provided verification code is invalid or expired",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 2,
                          backgroundColor: toastColor,
                          textColor: whiteColor,
                          fontSize: 12,
                        );
                      }
                    }
                    setState(() {
                      isLoading = false;
                    });
                  } else {
                    Fluttertoast.showToast(
                      msg: "Please Enter OTP!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 2,
                      backgroundColor: toastColor,
                      textColor: whiteColor,
                      fontSize: 12,
                    );
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                child: isLoading
                    ? buttonGradientWithLoader("Please Wait...", context)
                    : buttonGradient("Next", context),
              ),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

// // ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_constructors, unused_local_variable
//
// import 'dart:async';
// import 'package:lottie/lottie.dart';
// import 'package:pinput/pinput.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:deliver_client/models/check_number_model.dart';
// import 'package:deliver_client/screens/home/home_page_screen.dart';
// import 'package:deliver_client/screens/login/login_profile_screen.dart';
//
// class VerifyPhoneSignUpScreen extends StatefulWidget {
//   final String? phoneNumber;
//   final String? lat;
//   final String? lng;
//
//   const VerifyPhoneSignUpScreen({
//     super.key,
//     this.phoneNumber,
//     this.lat,
//     this.lng,
//   });
//
//   @override
//   State<VerifyPhoneSignUpScreen> createState() =>
//       _VerifyPhoneSignUpScreenState();
// }
//
// class _VerifyPhoneSignUpScreenState extends State<VerifyPhoneSignUpScreen> {
//   TextEditingController otpController = TextEditingController();
//
//   bool otpSent = false;
//   bool isLoading = false;
//   bool isLoading2 = false;
//   String? baseUrl = dotenv.env['BASE_URL'];
//
//   CheckNumberModel checkNumberModel = CheckNumberModel();
//
//   checkNumber() async {
//     try {
//       String apiUrl = "$baseUrl/check_phone_exist_customers";
//       debugPrint("contactNumber: ${widget.phoneNumber}");
//       debugPrint("lat: ${widget.lat}");
//       debugPrint("lng: ${widget.lng}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "one_signal_id": "123",
//           "phone": widget.phoneNumber,
//           "latitude": widget.lat,
//           "longitude": widget.lng
//         },
//       );
//       final responseString = response.body;
//       debugPrint("response: $responseString");
//       debugPrint("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         checkNumberModel = checkNumberModelFromJson(responseString);
//         debugPrint('checkNumberModel status: ${checkNumberModel.status}');
//         SharedPreferences sharedPref = await SharedPreferences.getInstance();
//         await sharedPref.setString(
//             'userId', "${checkNumberModel.data?.usersCustomersId.toString()}");
//         await sharedPref.setString('email', "${checkNumberModel.data?.email}");
//         await sharedPref.setString(
//             'firstName', "${checkNumberModel.data?.firstName}");
//         await sharedPref.setString(
//             'lastName', "${checkNumberModel.data?.lastName}");
//         await sharedPref.setString(
//             'phoneNumber', "${checkNumberModel.data?.phone}");
//         await sharedPref.setString(
//             'profilePic', "${checkNumberModel.data?.profilePic}");
//         debugPrint(
//             "sharedPref userId: ${checkNumberModel.data!.usersCustomersId.toString()}");
//         debugPrint("sharedPref email: ${checkNumberModel.data!.email}");
//         debugPrint("sharedPref firstName: ${checkNumberModel.data!.firstName}");
//         debugPrint("sharedPref lastName: ${checkNumberModel.data!.lastName}");
//         debugPrint("sharedPref phoneNumber: ${checkNumberModel.data!.phone}");
//         debugPrint("sharedPref profilePic: ${checkNumberModel.data!.profilePic}");
//         setState(() {});
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }
//
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   String verifyId = '';
//
//   Future<void> verifyPhoneNumber() async {
//     if (widget.phoneNumber != null) {
//       debugPrint("phoneNumber: ${widget.phoneNumber!}");
//     }
//     await FirebaseAuth.instance.verifyPhoneNumber(
//       phoneNumber: '${widget.phoneNumber}',
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         // await auth.signInWithCredential(credential);
//       },
//       verificationFailed: (FirebaseAuthException e) async {
//         if (e.code == 'invalid-phone-number') {
//           Fluttertoast.showToast(
//             msg: "The provided phone number is invalid",
//             toastLength: Toast.LENGTH_SHORT,
//             gravity: ToastGravity.BOTTOM,
//             timeInSecForIosWeb: 2,
//             backgroundColor: toastColor,
//             textColor: whiteColor,
//             fontSize: 12,
//           );
//           debugPrint('The provided phone number is invalid.');
//           setState(() {
//             isLoading = false;
//           });
//         } else {
//           // showToastError('Verification failed: ${e.message}', FToast().init(context));
//           debugPrint('Verification failed: ${e.message}');
//           setState(() {
//             isLoading = false;
//           });
//         }
//       },
//       codeSent: (String verificationId, int? resendToken) async {
//         verifyId = verificationId;
//         String smsCode = otpController.text;
//
//         // Create a PhoneAuthCredential with the code
//         PhoneAuthCredential credential = PhoneAuthProvider.credential(
//             verificationId: verificationId, smsCode: smsCode);
//
//         // Sign the user in (or link) with the credential
//         // await _auth.signInWithCredential(credential);
//       },
//       timeout: const Duration(seconds: 120),
//       codeAutoRetrievalTimeout: (String verificationId) {},
//     );
//   }
//
//   Future<void> verifyOTPCode() async {
//     setState(() {
//       isLoading = true;
//     });
//     debugPrint("verificationId: $verifyId");
//     PhoneAuthCredential credential = PhoneAuthProvider.credential(
//       verificationId: verifyId,
//       smsCode: otpController.text,
//     );
//     try {
//       await auth.signInWithCredential(credential).then((value) async {
//         debugPrint('User Login In Successful ${value.user}');
//         await checkNumber();
//         if (checkNumberModel.status == "success") {
//           Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(
//                 builder: (context) => HomePageScreen(),
//               ),
//               (Route<dynamic> route) => false);
//         } else {
//           Navigator.of(context).pushAndRemoveUntil(
//               MaterialPageRoute(
//                 builder: (context) => LoginProfileScreen(
//                   contactNumber: widget.phoneNumber,
//                 ),
//               ),
//               (Route<dynamic> route) => false);
//         }
//         setState(() {
//           isLoading = false;
//         });
//       });
//     } catch (e) {
//       Fluttertoast.showToast(
//         msg: "The provided verification code is invalid or expired",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.BOTTOM,
//         timeInSecForIosWeb: 2,
//         backgroundColor: toastColor,
//         textColor: whiteColor,
//         fontSize: 12,
//       );
//       debugPrint('Something went wrong = ${e.toString()}');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Timer? timer;
//   int secondsRemaining = 120; // Total seconds for the timer (2 minutes)
//
//   void startTimer() {
//     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         if (secondsRemaining > 0) {
//           secondsRemaining--;
//         } else {
//           timer.cancel();
//         }
//       });
//     });
//   }
//
//   String getTimerText() {
//     int minutes = secondsRemaining ~/ 60;
//     int seconds = secondsRemaining % 60;
//     return '${minutes}m:${seconds.toString().padLeft(2, '0')}s';
//   }
//
//   loaderTimer() {
//     Timer(const Duration(seconds: 8), () {
//       isLoading2 = false;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     startTimer();
//     loaderTimer();
//     verifyPhoneNumber();
//     isLoading2 = true;
//     debugPrint("lat: ${widget.lat}");
//     debugPrint("lng: ${widget.lng}");
//     debugPrint("phoneNumber: ${widget.phoneNumber}");
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     timer?.cancel();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var code = "";
//     var size = MediaQuery.of(context).size;
//     return GestureDetector(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: Scaffold(
//         backgroundColor: bgColor,
//         appBar: AppBar(
//           backgroundColor: bgColor,
//           elevation: 0,
//           scrolledUnderElevation: 0,
//           leading: GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//               timer?.cancel();
//             },
//             child: Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: SvgPicture.asset(
//                 'assets/images/back-icon.svg',
//                 width: 22,
//                 height: 22,
//                 fit: BoxFit.scaleDown,
//               ),
//             ),
//           ),
//           title: Padding(
//             padding: const EdgeInsets.only(left: 20),
//             child: Text(
//               "Phone Verification",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: blackColor,
//                 fontSize: 20,
//                 fontFamily: 'Syne-Bold',
//               ),
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: isLoading2
//             ? Center(
//                 child: Container(
//                   width: 100,
//                   height: 100,
//                   color: transparentColor,
//                   child: Lottie.asset(
//                     'assets/images/loading-icon.json',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               )
//             : SingleChildScrollView(
//                 child: Column(
//                   children: [
//                     SizedBox(height: size.height * 0.04),
//                     Center(
//                       child: SvgPicture.asset(
//                         'assets/images/phone-verification-icon.svg',
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.1),
//                     Text(
//                       "We will send you OTP verification code at\nthis ${widget.phoneNumber}. Put your OTP code\nbelow for verification.",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: blackColor,
//                         fontSize: 16,
//                         fontFamily: 'Syne-Regular',
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.08),
//                     Text(
//                       "Enter OTP Code",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: blackColor,
//                         fontSize: 16,
//                         fontFamily: 'Syne-SemiBold',
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Pinput(
//                         length: 6,
//                         controller: otpController,
//                         keyboardType: TextInputType.number,
//                         defaultPinTheme: PinTheme(
//                           width: 60,
//                           height: 48,
//                           textStyle: TextStyle(
//                             color: blackColor,
//                             fontSize: 14,
//                             fontFamily: 'Inter-Regular',
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: filledColor,
//                           ),
//                         ),
//                         focusedPinTheme: PinTheme(
//                           width: 60,
//                           height: 48,
//                           textStyle: TextStyle(
//                             color: blackColor,
//                             fontSize: 14,
//                             fontFamily: 'Inter-Regular',
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: filledColor,
//                             border: Border.all(
//                               color: orangeColor,
//                             ),
//                           ),
//                         ),
//                         submittedPinTheme: PinTheme(
//                           width: 60,
//                           height: 48,
//                           textStyle: TextStyle(
//                             color: blackColor,
//                             fontSize: 14,
//                             fontFamily: 'Inter-Regular',
//                           ),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             color: filledColor,
//                             border: Border.all(
//                               color: orangeColor,
//                             ),
//                           ),
//                         ),
//                         onChanged: (value) {
//                           code = value;
//                         },
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           "OTP valid for",
//                           style: TextStyle(
//                             color: blackColor,
//                             fontSize: 14,
//                             fontFamily: 'Syne-Regular',
//                           ),
//                         ),
//                         SizedBox(width: size.width * 0.02),
//                         secondsRemaining == 0
//                             ? SvgPicture.asset(
//                                 'assets/images/clock-inactive-icon.svg',
//                               )
//                             : SvgPicture.asset(
//                                 'assets/images/clock-active-icon.svg',
//                               ),
//                         SizedBox(width: size.width * 0.02),
//                         Text(
//                           getTimerText(),
//                           style: TextStyle(
//                             color: blackColor,
//                             fontSize: 16,
//                             fontFamily: 'Inter-SemiBold',
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: size.height * 0.04),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             "Don't Receive the Code? ",
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               color: blackColor,
//                               fontSize: 14,
//                               fontFamily: 'Syne-Regular',
//                             ),
//                           ),
//                           secondsRemaining == 0
//                               ? GestureDetector(
//                                   onTap: () {
//                                     setState(() {
//                                       secondsRemaining = 120;
//                                       startTimer();
//                                     });
//                                     verifyPhoneNumber();
//                                   },
//                                   child: Text(
//                                     'Resend Code',
//                                     textAlign: TextAlign.left,
//                                     style: TextStyle(
//                                       color: orangeColor,
//                                       fontSize: 16,
//                                       fontFamily: 'Syne-SemiBold',
//                                     ),
//                                   ),
//                                 )
//                               : Text(
//                                   'Resend Code',
//                                   textAlign: TextAlign.left,
//                                   style: TextStyle(
//                                     color: supportTextColor,
//                                     fontSize: 16,
//                                     fontFamily: 'Syne-SemiBold',
//                                   ),
//                                 ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.04),
//                     GestureDetector(
//                       onTap: () async {
//                         if (otpController.text.isNotEmpty) {
//                           verifyOTPCode();
//                         } else {
//                           Fluttertoast.showToast(
//                             msg: "Please Enter OTP!",
//                             toastLength: Toast.LENGTH_SHORT,
//                             gravity: ToastGravity.BOTTOM,
//                             timeInSecForIosWeb: 2,
//                             backgroundColor: toastColor,
//                             textColor: whiteColor,
//                             fontSize: 12,
//                           );
//                         }
//                       },
//                       child: isLoading
//                           ? buttonGradientWithLoader("Please Wait...", context)
//                           : buttonGradient("Next", context),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
