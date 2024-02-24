// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/models/send_otp_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/screens/signup/verify_phone_signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController contactNumberController = TextEditingController();
  final GlobalKey<FormState> logInFormKey = GlobalKey<FormState>();
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode =
      const CountryCode(name: 'Nigeria', code: 'NG', dialCode: '+234');

  String? pinID;

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

  String? currentLat;
  String? currentLng;
  bool isLoading = false;
  LatLng? currentLocation;

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
      } else {
        Fluttertoast.showToast(
          msg: "Something went wrong. Please restart the application",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: toastColor,
          textColor: whiteColor,
          fontSize: 12,
        );
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
      debugPrint("to: ${countryCode!.dialCode + contactNumberController.text}");
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
          "to": countryCode!.dialCode + contactNumberController.text,
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
        pinID = sendOtpModel.pinId;
        debugPrint("pinID: $pinID");
        setState(() {});
        debugPrint('sendOtpModel status: ${sendOtpModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  // void locationPermission() async {
  //   PermissionStatus status = await Permission.location.request();
  //
  //   if (status.isGranted) {
  //     // Permission granted, navigate to the next screen
  //   } else if (status.isDenied) {
  //     // Permission denied, show a message and ask for permission again
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: orangeColor,
  //         duration: const Duration(seconds: 2),
  //         content: Text(
  //           'Location permission is required to continue.',
  //           style: TextStyle(
  //             color: whiteColor,
  //             fontSize: 12,
  //             fontFamily: 'Syne-Regular',
  //           ),
  //         ),
  //       ),
  //     );
  //     PermissionStatus reRequestStatus = await Permission.location.request();
  //     if (reRequestStatus.isGranted) {
  //       // Permission granted after re-request, navigate to the next screen
  //     } else if (reRequestStatus.isPermanentlyDenied) {
  //       // Permission denied permanently, open app settings
  //       openAppSettings();
  //     }
  //   } else if (status.isPermanentlyDenied) {
  //     // Permission denied permanently, open app settings
  //     openAppSettings();
  //   }
  // }

  void locationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      // Permission granted, navigate to the next screen
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Permission denied, show a message and provide information
      showLocationPermissionSnackBar();
    }
  }

  void showLocationPermissionSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        width: MediaQuery.of(context).size.width,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 5),
        content: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              stops: const [0.1, 1.5],
              colors: [
                orangeColor,
                yellowColor,
              ],
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 2,
                spreadRadius: 2,
                offset: const Offset(0, 3),
                color: blackColor.withOpacity(0.2),
              ),
            ],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 2,
              color: borderColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Location permission is required\nto continue.',
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 12,
                  fontFamily: 'Syne-Regular',
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              GestureDetector(
                onTap: () {
                  openAppSettings();
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.04,
                  width: MediaQuery.of(context).size.width * 0.33,
                  decoration: BoxDecoration(
                    color: const Color(0xFF36454F),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Grant Permission',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 12,
                        fontFamily: 'Syne-Medium',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    final List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      final Placemark currentPlace = placemarks.first;
      final String currentAddress =
          "${currentPlace.name}, ${currentPlace.locality}, ${currentPlace.country}";

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        currentLat = position.latitude.toString();
        currentLng = position.longitude.toString();
        debugPrint("currentLat: $currentLat");
        debugPrint("currentLng: $currentLng");
        debugPrint("currentPickupLocation: $currentAddress");
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getAllSystemData();
    locationPermission();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SingleChildScrollView(
          child: Form(
            key: logInFormKey,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.17),
                SizedBox(
                  height: size.height * 0.15,
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo-big-icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.04),
                Text(
                  "Login".toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: orangeColor,
                    fontSize: size.width * 0.08,
                    fontFamily: 'Syne-Bold',
                  ),
                ),
                Text(
                  "Welcome, how can we help you?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blackColor,
                    fontSize: size.width * 0.04,
                    fontFamily: 'Syne-Regular',
                  ),
                ),
                SizedBox(height: size.height * 0.1),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: TextFormField(
                    controller: contactNumberController,
                    cursorColor: orangeColor,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contact Number is required!';
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 14,
                      fontFamily: 'Inter-Regular',
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: filledColor,
                      errorStyle: TextStyle(
                        color: redColor,
                        fontSize: 10,
                        fontFamily: 'Inter-Bold',
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          color: redColor,
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.02,
                      ),
                      hintText: "Contact Number",
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontSize: 12,
                        fontFamily: 'Inter-Light',
                      ),
                      prefixIcon: GestureDetector(
                        onTap: () async {
                          final code =
                              await countryPicker.showPicker(context: context);
                          setState(() {
                            countryCode = code;
                          });
                          debugPrint('countryName: ${countryCode!.name}');
                          debugPrint('countryCode: ${countryCode!.code}');
                          debugPrint(
                              'countryDialCode: ${countryCode!.dialCode}');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Container(
                                child: countryCode != null
                                    ? Image.asset(
                                        countryCode!.flagUri,
                                        package: countryCode!.flagImagePackage,
                                        width: 25,
                                        height: 20,
                                      )
                                    : SvgPicture.asset(
                                        'assets/images/flag-icon.svg',
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                countryCode?.dialCode ?? "+234",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              '|',
                              style: TextStyle(
                                color: hintColor,
                                fontSize: 12,
                                fontFamily: 'Inter-SemiBold',
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.1),
                GestureDetector(
                  onTap: () async {
                    if (logInFormKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      if (contactNumberController.text == "3001234567") {
                        await getCurrentLocation();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyPhoneSignUpScreen(
                              pinID: pinID,
                              lat: currentLat,
                              lng: currentLng,
                              phoneNumber: countryCode!.dialCode +
                                  contactNumberController.text,
                            ),
                          ),
                        );
                      } else {
                        await sendOtp();
                        await getCurrentLocation();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VerifyPhoneSignUpScreen(
                              pinID: pinID,
                              lat: currentLat,
                              lng: currentLng,
                              phoneNumber: countryCode!.dialCode +
                                  contactNumberController.text,
                            ),
                          ),
                        );
                      }
                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: isLoading
                      ? buttonGradientWithLoader("Please Wait...", context)
                      : buttonGradient("LOGIN", context),
                ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// // ignore_for_file: use_build_context_synchronously
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:fl_country_code_picker/fl_country_code_picker.dart';
// import 'package:deliver_client/screens/signup/verify_phone_signup_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController contactNumberController = TextEditingController();
//   final GlobalKey<FormState> logInFormKey = GlobalKey<FormState>();
//   final countryPicker = const FlCountryCodePicker();
//   CountryCode? countryCode =
//       const CountryCode(name: 'Nigeria', code: 'NG', dialCode: '+234');
//
//   bool status = false;
//   String? currentLat;
//   String? currentLng;
//   bool isLoading = false;
//   LatLng? currentLocation;
//
//   // void locationPermission() async {
//   //   PermissionStatus status = await Permission.location.request();
//   //
//   //   if (status.isGranted) {
//   //     // Permission granted, navigate to the next screen
//   //   } else if (status.isDenied) {
//   //     // Permission denied, show a message and ask for permission again
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(
//   //         backgroundColor: orangeColor,
//   //         duration: const Duration(seconds: 2),
//   //         content: Text(
//   //           'Location permission is required to continue.',
//   //           style: TextStyle(
//   //             color: whiteColor,
//   //             fontSize: 12,
//   //             fontFamily: 'Syne-Regular',
//   //           ),
//   //         ),
//   //       ),
//   //     );
//   //     PermissionStatus reRequestStatus = await Permission.location.request();
//   //     if (reRequestStatus.isGranted) {
//   //       // Permission granted after re-request, navigate to the next screen
//   //     } else if (reRequestStatus.isPermanentlyDenied) {
//   //       // Permission denied permanently, open app settings
//   //       openAppSettings();
//   //     }
//   //   } else if (status.isPermanentlyDenied) {
//   //     // Permission denied permanently, open app settings
//   //     openAppSettings();
//   //   }
//   // }
//
//   void locationPermission() async {
//     PermissionStatus status = await Permission.location.request();
//
//     if (status.isGranted) {
//       // Permission granted, navigate to the next screen
//     } else if (status.isDenied || status.isPermanentlyDenied) {
//       // Permission denied, show a message and provide information
//       showLocationPermissionSnackBar();
//     }
//   }
//
//   void showLocationPermissionSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: orangeColor,
//         duration: const Duration(seconds: 5),
//         content: Row(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Location permission is required\nto continue.',
//               style: TextStyle(
//                 color: whiteColor,
//                 fontSize: 12,
//                 fontFamily: 'Syne-Regular',
//               ),
//             ),
//             SizedBox(height: MediaQuery.of(context).size.height * 0.01),
//             GestureDetector(
//               onTap: () {
//                 openAppSettings();
//               },
//               child: Container(
//                 height: MediaQuery.of(context).size.height * 0.04,
//                 width: MediaQuery.of(context).size.width * 0.33,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF36454F),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child: Text(
//                     'Grant Permission',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: whiteColor,
//                       fontSize: 12,
//                       fontFamily: 'Syne-Medium',
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> getCurrentLocation() async {
//     final Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.best,
//     );
//
//     final List<Placemark> placemarks =
//         await placemarkFromCoordinates(position.latitude, position.longitude);
//
//     if (placemarks.isNotEmpty) {
//       final Placemark currentPlace = placemarks.first;
//       final String currentAddress =
//           "${currentPlace.name}, ${currentPlace.locality}, ${currentPlace.country}";
//
//       setState(() {
//         currentLocation = LatLng(position.latitude, position.longitude);
//         currentLat = position.latitude.toString();
//         currentLng = position.longitude.toString();
//         debugPrint("currentLat: $currentLat");
//         debugPrint("currentLng: $currentLng");
//         debugPrint("currentPickupLocation: $currentAddress");
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     locationPermission();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenHeight = MediaQuery.of(context).size.height;
//     final double screenWidth = MediaQuery.of(context).size.width;
//     var size = MediaQuery.of(context).size;
//     return GestureDetector(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: Scaffold(
//         backgroundColor: bgColor,
//         body: SingleChildScrollView(
//           child: Form(
//             key: logInFormKey,
//             child: Column(
//               children: [
//                 SizedBox(height: size.height * 0.17),
//                 SizedBox(
//                   height: size.height * 0.15,
//                   child: Center(
//                     child: Image.asset(
//                       'assets/images/logo-big-icon.png',
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.04),
//                 Text(
//                   "Login".toUpperCase(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: orangeColor,
//                     fontSize: size.width * 0.08,
//                     fontFamily: 'Syne-Bold',
//                   ),
//                 ),
//                 Text(
//                   "Welcome, how can we help you?",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: size.width * 0.04,
//                     fontFamily: 'Syne-Regular',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.1),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
//                   child: TextFormField(
//                     controller: contactNumberController,
//                     cursorColor: orangeColor,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(15),
//                     ],
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Contact Number is required!';
//                       }
//                       return null;
//                     },
//                     style: TextStyle(
//                       color: blackColor,
//                       fontSize: 14,
//                       fontFamily: 'Inter-Regular',
//                     ),
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: filledColor,
//                       errorStyle: TextStyle(
//                         color: redColor,
//                         fontSize: 10,
//                         fontFamily: 'Inter-Bold',
//                       ),
//                       border: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(10),
//                         ),
//                         borderSide: BorderSide.none,
//                       ),
//                       enabledBorder: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(10),
//                         ),
//                         borderSide: BorderSide.none,
//                       ),
//                       focusedBorder: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(10),
//                         ),
//                         borderSide: BorderSide.none,
//                       ),
//                       focusedErrorBorder: const OutlineInputBorder(
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(10),
//                         ),
//                         borderSide: BorderSide.none,
//                       ),
//                       errorBorder: OutlineInputBorder(
//                         borderRadius: const BorderRadius.all(
//                           Radius.circular(10),
//                         ),
//                         borderSide: BorderSide(
//                           color: redColor,
//                           width: 1,
//                         ),
//                       ),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: screenWidth * 0.04,
//                         vertical: screenHeight * 0.02,
//                       ),
//                       hintText: "Contact Number",
//                       hintStyle: TextStyle(
//                         color: hintColor,
//                         fontSize: 12,
//                         fontFamily: 'Inter-Light',
//                       ),
//                       prefixIcon: GestureDetector(
//                         onTap: () async {
//                           final code =
//                               await countryPicker.showPicker(context: context);
//                           setState(() {
//                             countryCode = code;
//                           });
//                           debugPrint('countryName: ${countryCode!.name}');
//                           debugPrint('countryCode: ${countryCode!.code}');
//                           debugPrint('countryDialCode: ${countryCode!.dialCode}');
//                         },
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 20),
//                               child: Container(
//                                 child: countryCode != null
//                                     ? Image.asset(
//                                         countryCode!.flagUri,
//                                         package: countryCode!.flagImagePackage,
//                                         width: 25,
//                                         height: 20,
//                                       )
//                                     : SvgPicture.asset(
//                                         'assets/images/flag-icon.svg',
//                                       ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 10),
//                               child: Text(
//                                 countryCode?.dialCode ?? "+234",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: hintColor,
//                                   fontSize: 12,
//                                   fontFamily: 'Inter-Light',
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: size.width * 0.02),
//                             Text(
//                               '|',
//                               style: TextStyle(
//                                 color: hintColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Inter-SemiBold',
//                               ),
//                             ),
//                             SizedBox(width: size.width * 0.02),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.1),
//                 GestureDetector(
//                   onTap: () async {
//                     if (logInFormKey.currentState!.validate()) {
//                       setState(() {
//                         isLoading = true;
//                       });
//                       await getCurrentLocation();
//                       // navigateToVerifyPhoneSignUpScreen();
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => VerifyPhoneSignUpScreen(
//                             phoneNumber: countryCode!.dialCode +
//                                 contactNumberController.text,
//                             lat: currentLat,
//                             lng: currentLng,
//                           ),
//                         ),
//                       );
//                       setState(() {
//                         isLoading = false;
//                       });
//                     }
//                   },
//                   child: isLoading
//                       ? buttonGradientWithLoader("Please Wait...", context)
//                       : buttonGradient("LOGIN", context),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void navigateToVerifyPhoneSignUpScreen() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => VerifyPhoneSignUpScreen(
//           phoneNumber: countryCode!.dialCode + contactNumberController.text,
//           lat: currentLat,
//           lng: currentLng,
//         ),
//       ),
//     ).then((_) {
//       setState(() {
//         isLoading = false;
//       });
//     });
//   }
// }
//
// // // ignore_for_file: use_build_context_synchronously
// //
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:geocoding/geocoding.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:deliver_client/utils/colors.dart';
// // import 'package:deliver_client/widgets/buttons.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:fl_country_code_picker/fl_country_code_picker.dart';
// // import 'package:deliver_client/screens/signup/verify_phone_signup_screen.dart';
// //
// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});
// //
// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }
// //
// // class _LoginScreenState extends State<LoginScreen> {
// //   TextEditingController contactNumberController = TextEditingController();
// //   final GlobalKey<FormState> logInFormKey = GlobalKey<FormState>();
// //   final countryPicker = const FlCountryCodePicker();
// //   CountryCode? countryCode =
// //       const CountryCode(name: 'Nigeria', code: 'NG', dialCode: '+234');
// //
// //   bool status = false;
// //   String? currentLat;
// //   String? currentLng;
// //   bool isLoading = false;
// //   LatLng? currentLocation;
// //
// //   void locationPermission() async {
// //     PermissionStatus status = await Permission.location.request();
// //
// //     if (status.isGranted) {
// //       // Permission granted, navigate to the next screen
// //     } else if (status.isDenied) {
// //       // Permission denied, show a message and ask for permission again
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           backgroundColor: orangeColor,
// //           duration: const Duration(seconds: 2),
// //           content: Text(
// //             'Location permission is required to continue.',
// //             style: TextStyle(
// //               color: whiteColor,
// //               fontSize: 12,
// //               fontFamily: 'Syne-Regular',
// //             ),
// //           ),
// //         ),
// //       );
// //       PermissionStatus reRequestStatus = await Permission.location.request();
// //       if (reRequestStatus.isGranted) {
// //         // Permission granted after re-request, navigate to the next screen
// //       } else if (reRequestStatus.isPermanentlyDenied) {
// //         // Permission denied permanently, open app settings
// //         openAppSettings();
// //       }
// //     } else if (status.isPermanentlyDenied) {
// //       // Permission denied permanently, open app settings
// //       openAppSettings();
// //     }
// //   }
// //
// //   Future<void> getCurrentLocation() async {
// //     final Position position = await Geolocator.getCurrentPosition(
// //       desiredAccuracy: LocationAccuracy.best,
// //     );
// //
// //     final List<Placemark> placemarks =
// //         await placemarkFromCoordinates(position.latitude, position.longitude);
// //
// //     if (placemarks.isNotEmpty) {
// //       final Placemark currentPlace = placemarks.first;
// //       final String currentAddress =
// //           "${currentPlace.name}, ${currentPlace.locality}, ${currentPlace.country}";
// //
// //       setState(() {
// //         currentLocation = LatLng(position.latitude, position.longitude);
// //         currentLat = position.latitude.toString();
// //         currentLng = position.longitude.toString();
// //         debugPrint("currentLat: $currentLat");
// //         debugPrint("currentLng: $currentLng");
// //         debugPrint("currentPickupLocation: $currentAddress");
// //       });
// //     }
// //   }
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     locationPermission();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     var size = MediaQuery.of(context).size;
// //     return GestureDetector(
// //       onTap: () {
// //         FocusManager.instance.primaryFocus?.unfocus();
// //       },
// //       child: Scaffold(
// //         backgroundColor: bgColor,
// //         body: SingleChildScrollView(
// //           child: Form(
// //             key: logInFormKey,
// //             child: Column(
// //               children: [
// //                 SizedBox(height: size.height * 0.1),
// //                 Center(
// //                   child: Image.asset(
// //                     'assets/images/logo-big-icon.png',
// //                     width: 300,
// //                     height: 125,
// //                   ),
// //                 ),
// //                 SizedBox(height: size.height * 0.05),
// //                 Text(
// //                   "Login".toUpperCase(),
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     color: orangeColor,
// //                     fontSize: 30,
// //                     fontFamily: 'Syne-Bold',
// //                   ),
// //                 ),
// //                 Text(
// //                   "Welcome, how can we help you?",
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     color: blackColor,
// //                     fontSize: 16,
// //                     fontFamily: 'Syne-Regular',
// //                   ),
// //                 ),
// //                 SizedBox(height: size.height * 0.06),
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 40),
// //                   child: TextFormField(
// //                     controller: contactNumberController,
// //                     cursorColor: orangeColor,
// //                     keyboardType: TextInputType.number,
// //                     inputFormatters: [
// //                       FilteringTextInputFormatter.digitsOnly,
// //                       LengthLimitingTextInputFormatter(15),
// //                     ],
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'Contact Number is required!';
// //                       }
// //                       return null;
// //                     },
// //                     style: TextStyle(
// //                       color: blackColor,
// //                       fontSize: 14,
// //                       fontFamily: 'Inter-Regular',
// //                     ),
// //                     decoration: InputDecoration(
// //                       filled: true,
// //                       fillColor: filledColor,
// //                       errorStyle: TextStyle(
// //                         color: redColor,
// //                         fontSize: 10,
// //                         fontFamily: 'Inter-Bold',
// //                       ),
// //                       border: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       enabledBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       focusedBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       errorBorder: OutlineInputBorder(
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide(
// //                           color: redColor,
// //                           width: 1,
// //                         ),
// //                       ),
// //                       contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 20, vertical: 10),
// //                       hintText: "Contact Number",
// //                       hintStyle: TextStyle(
// //                         color: hintColor,
// //                         fontSize: 12,
// //                         fontFamily: 'Inter-Light',
// //                       ),
// //                       prefixIcon: GestureDetector(
// //                         onTap: () async {
// //                           final code =
// //                               await countryPicker.showPicker(context: context);
// //                           setState(() {
// //                             countryCode = code;
// //                           });
// //                           debugPrint('countryName: ${countryCode!.name}');
// //                           debugPrint('countryCode: ${countryCode!.code}');
// //                           debugPrint('countryDialCode: ${countryCode!.dialCode}');
// //                         },
// //                         child: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Padding(
// //                               padding: const EdgeInsets.only(left: 20),
// //                               child: Container(
// //                                 child: countryCode != null
// //                                     ? Image.asset(
// //                                         countryCode!.flagUri,
// //                                         package: countryCode!.flagImagePackage,
// //                                         width: 25,
// //                                         height: 20,
// //                                       )
// //                                     : SvgPicture.asset(
// //                                         'assets/images/flag-icon.svg',
// //                                       ),
// //                               ),
// //                             ),
// //                             Padding(
// //                               padding: const EdgeInsets.only(left: 10),
// //                               child: Text(
// //                                 countryCode?.dialCode ?? "+234",
// //                                 textAlign: TextAlign.center,
// //                                 style: TextStyle(
// //                                   color: hintColor,
// //                                   fontSize: 12,
// //                                   fontFamily: 'Inter-Light',
// //                                 ),
// //                               ),
// //                             ),
// //                             SizedBox(width: size.width * 0.02),
// //                             Text(
// //                               '|',
// //                               style: TextStyle(
// //                                 color: hintColor,
// //                                 fontSize: 12,
// //                                 fontFamily: 'Inter-SemiBold',
// //                               ),
// //                             ),
// //                             SizedBox(width: size.width * 0.02),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(height: size.height * 0.05),
// //                 GestureDetector(
// //                   onTap: () async {
// //                     if (logInFormKey.currentState!.validate()) {
// //                       setState(() {
// //                         isLoading = true;
// //                       });
// //                       await getCurrentLocation();
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (context) => VerifyPhoneSignUpScreen(
// //                             phoneNumber: countryCode!.dialCode +
// //                                 contactNumberController.text,
// //                             lat: currentLat,
// //                             lng: currentLng,
// //                           ),
// //                         ),
// //                       );
// //                       setState(() {
// //                         isLoading = false;
// //                       });
// //                     }
// //                   },
// //                   child: isLoading
// //                       ? buttonGradientWithLoader("Please Wait...", context)
// //                       : buttonGradient("LOGIN", context),
// //                 ),
// //                 SizedBox(height: size.height * 0.04),
// //                 SvgPicture.asset('assets/images/fingerprint-icon.svg'),
// //                 SizedBox(height: size.height * 0.04),
// //                 Container(
// //                   width: size.width,
// //                   decoration: BoxDecoration(
// //                     color: whiteColor,
// //                     border: Border.all(color: borderColor, width: 1),
// //                     borderRadius: const BorderRadius.only(
// //                       topLeft: Radius.circular(40),
// //                       topRight: Radius.circular(40),
// //                     ),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       SizedBox(height: size.height * 0.02),
// //                       const Text(
// //                         'OR',
// //                         textAlign: TextAlign.center,
// //                         style: TextStyle(
// //                           color: Color(0xFFA3A6AA),
// //                           fontSize: 18,
// //                           fontFamily: 'Syne-SemiBold',
// //                         ),
// //                       ),
// //                       SizedBox(height: size.height * 0.02),
// //                       GestureDetector(
// //                         onTap: () {},
// //                         child: SvgPicture.asset(
// //                           'assets/images/facebook-login-icon.svg',
// //                         ),
// //                       ),
// //                       SizedBox(height: size.height * 0.01),
// //                       GestureDetector(
// //                         onTap: () {},
// //                         child: SvgPicture.asset(
// //                           'assets/images/google-login-icon.svg',
// //                         ),
// //                       ),
// //                       SizedBox(height: size.height * 0.03),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
//
// // // ignore_for_file: use_build_context_synchronously
//
// // import 'dart:convert';
// // import 'package:flutter/gestures.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:geocoding/geocoding.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:deliver_client/utils/colors.dart';
// // import 'package:deliver_client/utils/baseurl.dart';
// // import 'package:flutter_switch/flutter_switch.dart';
// // import 'package:deliver_client/widgets/buttons.dart';
// // import 'package:deliver_client/models/login_model.dart';
// // import 'package:deliver_client/widgets/login_boxes.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:deliver_client/screens/signup/signup_screen.dart';
// // import 'package:deliver_client/screens/signup/verify_screen.dart';
// // import 'package:deliver_client/screens/home/home_page_screen.dart';
// // import 'package:fl_country_code_picker/fl_country_code_picker.dart';
// // import 'package:deliver_client/screens/login/login_profile_screen.dart';
// // import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// // import 'package:deliver_client/screens/login/forgot_password_screen.dart';
//
// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});
//
// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }
//
// // class _LoginScreenState extends State<LoginScreen> {
// //   TextEditingController emailController = TextEditingController();
// //   TextEditingController contactNumberController = TextEditingController();
// //   TextEditingController passwordController = TextEditingController();
// //   final GlobalKey<FormState> logInFormKey = GlobalKey<FormState>();
// //   final countryPicker = const FlCountryCodePicker();
// //   CountryCode? countryCode =
// //       const CountryCode(name: 'Nigeria', code: 'NG', dialCode: '+234');
//
// //   bool _obscure = true;
// //   bool status = false;
// //   String? currentLat;
// //   String? currentLng;
// //   bool isLoading = false;
// //   LatLng? currentLocation;
//
// //   sharedPrefs() async {
// //     SharedPreferences sharedPref = await SharedPreferences.getInstance();
// //     await sharedPref.setString(
// //         'userId', "${logInModel.data?.usersCustomersId.toString()}");
// //     await sharedPref.setString('email', "${logInModel.data?.email}");
// //     await sharedPref.setString('firstName', "${logInModel.data?.firstName}");
// //     await sharedPref.setString('lastName', "${logInModel.data?.lastName}");
// //     await sharedPref.setString('phoneNumber', "${logInModel.data?.phone}");
// //     debugPrint("sharedPref userId: ${logInModel.data!.usersCustomersId.toString()}");
// //     debugPrint("sharedPref email: ${logInModel.data!.email}");
// //     debugPrint("sharedPref firstName: ${logInModel.data!.firstName}");
// //     debugPrint("sharedPref lastName: ${logInModel.data!.lastName}");
// //     debugPrint("sharedPref phoneNumber: ${logInModel.data!.phone}");
// //   }
//
// //   LogInModel logInModel = LogInModel();
//
// //   userLogIn() async {
// //     try {
// //       String apiUrl = "$baseUrl/login_customers";
// //       // debugPrint("email: ${emailController.text}");
// //       debugPrint(
// //           "contactNumber: ${countryCode!.dialCode + contactNumberController.text}");
// //       debugPrint("password: ${passwordController.text}");
// //       final response = await http.post(
// //         Uri.parse(apiUrl),
// //         headers: {
// //           'Accept': 'application/json',
// //         },
// //         body: {
// //           "one_signal_id": "123",
// //           "phone": countryCode!.dialCode + contactNumberController.text,
// //           "password": passwordController.text,
// //           "latitude": currentLat,
// //           "longitude": currentLng
// //         },
// //       );
// //       final responseString = jsonDecode(response.body);
// //       debugPrint("response: $responseString");
// //       debugPrint("status: ${responseString['status']}");
// //       if (responseString["status"] == "success") {
// //         logInModel = logInModelFromJson(response.body);
// //         sharedPrefs();
// //         if (logInModel.data!.profilePic == null ||
// //             logInModel.data!.profilePic == "") {
// //           Navigator.of(context).pushAndRemoveUntil(
// //               MaterialPageRoute(
// //                 builder: (context) => LoginProfileScreen(
// //                   firstName: '${logInModel.data!.firstName}',
// //                   lastName: '${logInModel.data!.lastName}',
// //                   contactNumber: '${logInModel.data!.phone}',
// //                   email: '${logInModel.data!.email}',
// //                 ),
// //               ),
// //               (Route<dynamic> route) => false);
// //         } else {
// //           Navigator.of(context).pushAndRemoveUntil(
// //               MaterialPageRoute(builder: (context) => const HomePageScreen()),
// //               (Route<dynamic> route) => false);
// //           setState(() {
// //             isLoading = false;
// //           });
// //         }
// //       } else if (responseString["status"] == "error") {
// //         if (responseString["message"] == "Please verify your account.") {
// //           showDialog(
// //             context: context,
// //             barrierDismissible: false,
// //             builder: (context) => verifyYourself(context),
// //           );
// //         } else {
// //           final snackBar = SnackBar(
// //             elevation: 0,
// //             behavior: SnackBarBehavior.floating,
// //             dismissDirection: DismissDirection.horizontal,
// //             backgroundColor: transparentColor,
// //             content: AwesomeSnackbarContent(
// //               title: 'Oh Snap!',
// //               message: "${responseString["message"]}",
// //               contentType: ContentType.failure,
// //             ),
// //           );
// //           ScaffoldMessenger.of(context)
// //             ..hideCurrentSnackBar()
// //             ..showSnackBar(snackBar);
// //           setState(() {
// //             isLoading = false;
// //           });
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint('Something went wrong = ${e.toString()}');
// //       return null;
// //     }
// //   }
//
// //   void locationPermission() async {
// //     PermissionStatus status = await Permission.location.request();
//
// //     if (status.isGranted) {
// //       // Permission granted, navigate to the next screen
// //     } else if (status.isDenied) {
// //       // Permission denied, show a message and ask for permission again
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           backgroundColor: orangeColor,
// //           duration: const Duration(seconds: 2),
// //           content: Text(
// //             'Location permission is required to continue.',
// //             style: TextStyle(
// //               color: whiteColor,
// //               fontSize: 12,
// //               fontFamily: 'Syne-Regular',
// //             ),
// //           ),
// //         ),
// //       );
// //       PermissionStatus reRequestStatus = await Permission.location.request();
// //       if (reRequestStatus.isGranted) {
// //         // Permission granted after re-request, navigate to the next screen
// //       } else if (reRequestStatus.isPermanentlyDenied) {
// //         // Permission denied permanently, open app settings
// //         openAppSettings();
// //       }
// //     } else if (status.isPermanentlyDenied) {
// //       // Permission denied permanently, open app settings
// //       openAppSettings();
// //     }
// //   }
//
// //   Future<void> getCurrentLocation() async {
// //     final Position position = await Geolocator.getCurrentPosition(
// //       desiredAccuracy: LocationAccuracy.best,
// //     );
//
// //     final List<Placemark> placemarks =
// //         await placemarkFromCoordinates(position.latitude, position.longitude);
//
// //     if (placemarks.isNotEmpty) {
// //       final Placemark currentPlace = placemarks.first;
// //       final String currentAddress =
// //           "${currentPlace.name}, ${currentPlace.locality}, ${currentPlace.country}";
//
// //       setState(() {
// //         currentLocation = LatLng(position.latitude, position.longitude);
// //         currentLat = position.latitude.toString();
// //         currentLng = position.longitude.toString();
// //         debugPrint("currentLat: $currentLat");
// //         debugPrint("currentLng: $currentLng");
// //         debugPrint("currentPickupLocation: $currentAddress");
// //       });
// //     }
// //   }
//
// //   @override
// //   void initState() {
// //     super.initState();
// //     locationPermission();
// //   }
//
// //   @override
// //   Widget build(BuildContext context) {
// //     var size = MediaQuery.of(context).size;
// //     return GestureDetector(
// //       onTap: () {
// //         FocusManager.instance.primaryFocus?.unfocus();
// //       },
// //       child: Scaffold(
// //         backgroundColor: bgColor,
// //         body: SingleChildScrollView(
// //           child: Form(
// //             key: logInFormKey,
// //             child: Column(
// //               children: [
// //                 SizedBox(height: size.height * 0.04),
// //                 Center(
// //                   child: SvgPicture.asset('assets/images/logo-small-icon.svg'),
// //                 ),
// //                 SizedBox(height: size.height * 0.02),
// //                 Text(
// //                   "Login".toUpperCase(),
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     color: orangeColor,
// //                     fontSize: 30,
// //                     fontFamily: 'Syne-Bold',
// //                   ),
// //                 ),
// //                 Text(
// //                   "Welcome, how can we help you?",
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     color: blackColor,
// //                     fontSize: 16,
// //                     fontFamily: 'Syne-Regular',
// //                   ),
// //                 ),
// //                 SizedBox(height: size.height * 0.01),
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 38),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                     children: [
// //                       loginBox("assets/images/login-truck-icon.svg",
// //                           "Book a Van", context),
// //                       loginBox("assets/images/login-parcel-icon.svg",
// //                           "Deliver a Parcel", context),
// //                     ],
// //                   ),
// //                 ),
// //                 SizedBox(height: size.height * 0.02),
// //                 // Padding(
// //                 //   padding: const EdgeInsets.symmetric(horizontal: 40),
// //                 //   child: TextFormField(
// //                 //     controller: emailController,
// //                 //     cursorColor: orangeColor,
// //                 //     keyboardType: TextInputType.emailAddress,
// //                 //     validator: (value) {
// //                 //       if (value == null || value.isEmpty) {
// //                 //         return 'Email ID is required!';
// //                 //       }
// //                 //       return null;
// //                 //     },
// //                 //     style: TextStyle(
// //                 //       color: blackColor,
// //                 //       fontSize: 14,
// //                 //       fontFamily: 'Inter-Regular',
// //                 //     ),
// //                 //     decoration: InputDecoration(
// //                 //       filled: true,
// //                 //       fillColor: filledColor,
// //                 //       errorStyle: TextStyle(
// //                 //         color: redColor,
// //                 //         fontSize: 10,
// //                 //         fontFamily: 'Inter-Bold',
// //                 //       ),
// //                 //       border: const OutlineInputBorder(
// //                 //         borderRadius: BorderRadius.all(
// //                 //           Radius.circular(10),
// //                 //         ),
// //                 //         borderSide: BorderSide.none,
// //                 //       ),
// //                 //       enabledBorder: const OutlineInputBorder(
// //                 //         borderRadius: BorderRadius.all(
// //                 //           Radius.circular(10),
// //                 //         ),
// //                 //         borderSide: BorderSide.none,
// //                 //       ),
// //                 //       focusedBorder: const OutlineInputBorder(
// //                 //         borderRadius: BorderRadius.all(
// //                 //           Radius.circular(10),
// //                 //         ),
// //                 //         borderSide: BorderSide.none,
// //                 //       ),
// //                 //       focusedErrorBorder: const OutlineInputBorder(
// //                 //         borderRadius: BorderRadius.all(
// //                 //           Radius.circular(10),
// //                 //         ),
// //                 //         borderSide: BorderSide.none,
// //                 //       ),
// //                 //       errorBorder: OutlineInputBorder(
// //                 //         borderRadius: const BorderRadius.all(
// //                 //           Radius.circular(10),
// //                 //         ),
// //                 //         borderSide: BorderSide(
// //                 //           color: redColor,
// //                 //           width: 1,
// //                 //         ),
// //                 //       ),
// //                 //       contentPadding: const EdgeInsets.symmetric(
// //                 //           horizontal: 20, vertical: 10),
// //                 //       hintText: "Email ID",
// //                 //       hintStyle: TextStyle(
// //                 //         color: hintColor,
// //                 //         fontSize: 12,
// //                 //         fontFamily: 'Inter-Light',
// //                 //       ),
// //                 //     ),
// //                 //   ),
// //                 // ),
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 40),
// //                   child: TextFormField(
// //                     controller: contactNumberController,
// //                     cursorColor: orangeColor,
// //                     keyboardType: TextInputType.number,
// //                     inputFormatters: [
// //                       FilteringTextInputFormatter.digitsOnly,
// //                       LengthLimitingTextInputFormatter(15),
// //                     ],
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'Contact Number is required!';
// //                       }
// //                       return null;
// //                     },
// //                     style: TextStyle(
// //                       color: blackColor,
// //                       fontSize: 14,
// //                       fontFamily: 'Inter-Regular',
// //                     ),
// //                     decoration: InputDecoration(
// //                       filled: true,
// //                       fillColor: filledColor,
// //                       errorStyle: TextStyle(
// //                         color: redColor,
// //                         fontSize: 10,
// //                         fontFamily: 'Inter-Bold',
// //                       ),
// //                       border: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       enabledBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       focusedBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       errorBorder: OutlineInputBorder(
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide(
// //                           color: redColor,
// //                           width: 1,
// //                         ),
// //                       ),
// //                       contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 20, vertical: 10),
// //                       hintText: "Contact Number",
// //                       hintStyle: TextStyle(
// //                         color: hintColor,
// //                         fontSize: 12,
// //                         fontFamily: 'Inter-Light',
// //                       ),
// //                       prefixIcon: GestureDetector(
// //                         onTap: () async {
// //                           final code =
// //                               await countryPicker.showPicker(context: context);
// //                           setState(() {
// //                             countryCode = code;
// //                           });
// //                           debugPrint('countryName: ${countryCode!.name}');
// //                           debugPrint('countryCode: ${countryCode!.code}');
// //                           debugPrint('countryDialCode: ${countryCode!.dialCode}');
// //                         },
// //                         child: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             Padding(
// //                               padding: const EdgeInsets.only(left: 20),
// //                               child: Container(
// //                                 child: countryCode != null
// //                                     ? Image.asset(
// //                                         countryCode!.flagUri,
// //                                         package: countryCode!.flagImagePackage,
// //                                         width: 25,
// //                                         height: 20,
// //                                       )
// //                                     : SvgPicture.asset(
// //                                         'assets/images/flag-icon.svg',
// //                                       ),
// //                               ),
// //                             ),
// //                             Padding(
// //                               padding: const EdgeInsets.only(left: 10),
// //                               child: Text(
// //                                 countryCode?.dialCode ?? "+234",
// //                                 textAlign: TextAlign.center,
// //                                 style: TextStyle(
// //                                   color: hintColor,
// //                                   fontSize: 12,
// //                                   fontFamily: 'Inter-Light',
// //                                 ),
// //                               ),
// //                             ),
// //                             SizedBox(width: size.width * 0.02),
// //                             Text(
// //                               '|',
// //                               style: TextStyle(
// //                                 color: hintColor,
// //                                 fontSize: 12,
// //                                 fontFamily: 'Inter-SemiBold',
// //                               ),
// //                             ),
// //                             SizedBox(width: size.width * 0.02),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(height: size.height * 0.02),
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 40),
// //                   child: TextFormField(
// //                     controller: passwordController,
// //                     cursorColor: orangeColor,
// //                     obscureText: _obscure,
// //                     keyboardType: TextInputType.visiblePassword,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'Password is required!';
// //                       }
// //                       return null;
// //                     },
// //                     style: TextStyle(
// //                       color: blackColor,
// //                       fontSize: 14,
// //                       fontFamily: 'Inter-Regular',
// //                     ),
// //                     decoration: InputDecoration(
// //                       filled: true,
// //                       fillColor: filledColor,
// //                       errorStyle: TextStyle(
// //                         color: redColor,
// //                         fontSize: 10,
// //                         fontFamily: 'Inter-Bold',
// //                       ),
// //                       border: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       enabledBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       focusedBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       focusedErrorBorder: const OutlineInputBorder(
// //                         borderRadius: BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                       errorBorder: OutlineInputBorder(
// //                         borderRadius: const BorderRadius.all(
// //                           Radius.circular(10),
// //                         ),
// //                         borderSide: BorderSide(
// //                           color: redColor,
// //                           width: 1,
// //                         ),
// //                       ),
// //                       contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 20, vertical: 10),
// //                       hintText: "Password",
// //                       hintStyle: TextStyle(
// //                         color: hintColor,
// //                         fontSize: 12,
// //                         fontFamily: 'Inter-Light',
// //                       ),
// //                       suffixIcon: GestureDetector(
// //                         onTap: () {
// //                           setState(() {
// //                             _obscure = !_obscure;
// //                           });
// //                         },
// //                         child: _obscure
// //                             ? Container(
// //                                 color: transparentColor,
// //                                 child: SvgPicture.asset(
// //                                   'assets/images/show-password-icon.svg',
// //                                   width: 15,
// //                                   height: 15,
// //                                   fit: BoxFit.scaleDown,
// //                                 ),
// //                               )
// //                             : Container(
// //                                 color: transparentColor,
// //                                 child: SvgPicture.asset(
// //                                   'assets/images/hide-password-icon.svg',
// //                                   width: 15,
// //                                   height: 15,
// //                                   fit: BoxFit.scaleDown,
// //                                 ),
// //                               ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(height: size.height * 0.02),
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 40),
// //                   child: Row(
// //                     children: [
// //                       FlutterSwitch(
// //                         width: 35,
// //                         height: 20,
// //                         activeColor: blackColor,
// //                         inactiveColor: whiteColor,
// //                         activeToggleBorder:
// //                             Border.all(color: blackColor, width: 2),
// //                         inactiveToggleBorder:
// //                             Border.all(color: blackColor, width: 2),
// //                         inactiveSwitchBorder:
// //                             Border.all(color: blackColor, width: 2),
// //                         toggleSize: 12,
// //                         value: status,
// //                         borderRadius: 50,
// //                         onToggle: (val) {
// //                           setState(() {
// //                             status = val;
// //                           });
// //                         },
// //                       ),
// //                       SizedBox(width: size.width * 0.02),
// //                       Text(
// //                         'Remember me',
// //                         textAlign: TextAlign.left,
// //                         style: TextStyle(
// //                           color: blackColor,
// //                           fontSize: 12,
// //                           fontFamily: 'Syne-Regular',
// //                         ),
// //                       ),
// //                       const Spacer(),
// //                       GestureDetector(
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) =>
// //                                   const ForgotPasswordScreen(),
// //                             ),
// //                           );
// //                         },
// //                         child: Text(
// //                           'Forgot Password?',
// //                           textAlign: TextAlign.left,
// //                           style: TextStyle(
// //                             color: blackColor,
// //                             fontSize: 12,
// //                             fontFamily: 'Syne-Regular',
// //                             decoration: TextDecoration.underline,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 SizedBox(height: size.height * 0.02),
// //                 GestureDetector(
// //                   onTap: () async {
// //                     if (logInFormKey.currentState!.validate()) {
// //                       setState(() {
// //                         isLoading = true;
// //                       });
// //                       await getCurrentLocation();
// //                       await userLogIn();
// //                       setState(() {
// //                         isLoading = false;
// //                       });
// //                     }
// //                   },
// //                   child: isLoading
// //                       ? buttonGradientWithLoader("Please Wait...", context)
// //                       : buttonGradient("LOGIN", context),
// //                 ),
// //                 SizedBox(height: size.height * 0.02),
// //                 SvgPicture.asset('assets/images/fingerprint-icon.svg'),
// //                 SizedBox(height: size.height * 0.02),
// //                 Container(
// //                   width: size.width,
// //                   decoration: BoxDecoration(
// //                     color: whiteColor,
// //                     border: Border.all(color: borderColor, width: 1),
// //                     borderRadius: const BorderRadius.only(
// //                       topLeft: Radius.circular(40),
// //                       topRight: Radius.circular(40),
// //                     ),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       SizedBox(height: size.height * 0.02),
// //                       const Text(
// //                         'OR',
// //                         textAlign: TextAlign.center,
// //                         style: TextStyle(
// //                           color: Color(0xFFA3A6AA),
// //                           fontSize: 18,
// //                           fontFamily: 'Syne-SemiBold',
// //                         ),
// //                       ),
// //                       SizedBox(height: size.height * 0.02),
// //                       SvgPicture.asset('assets/images/facebook-login-icon.svg'),
// //                       SizedBox(height: size.height * 0.01),
// //                       GestureDetector(
// //                         onTap: () {},
// //                         child: SvgPicture.asset(
// //                             'assets/images/google-login-icon.svg'),
// //                       ),
// //                       SizedBox(height: size.height * 0.04),
// //                       RichText(
// //                         overflow: TextOverflow.clip,
// //                         textAlign: TextAlign.center,
// //                         text: TextSpan(
// //                           text: "Don't have an account? ",
// //                           style: TextStyle(
// //                             color: textHaveAccountColor,
// //                             fontSize: 12,
// //                             fontFamily: 'Syne-Regular',
// //                           ),
// //                           children: [
// //                             TextSpan(
// //                               recognizer: TapGestureRecognizer()
// //                                 ..onTap = () {
// //                                   // Handle the tap event, e.g., navigate to a new screen
// //                                   Navigator.push(
// //                                     context,
// //                                     MaterialPageRoute(
// //                                       builder: (context) =>
// //                                           const SignUpScreen(),
// //                                     ),
// //                                   );
// //                                 },
// //                               text: 'Register',
// //                               style: TextStyle(
// //                                 color: orangeColor,
// //                                 fontSize: 14,
// //                                 fontFamily: 'Syne-Bold',
// //                                 decoration: TextDecoration.underline,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       SizedBox(height: size.height * 0.02),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
//
// //   verifyYourself(BuildContext context) {
// //     var size = MediaQuery.of(context).size;
// //     return WillPopScope(
// //       onWillPop: () {
// //         return Future.value(false);
// //       },
// //       child: Dialog(
// //         backgroundColor: Colors.white,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(40),
// //         ),
// //         insetPadding: const EdgeInsets.only(left: 20, right: 20),
// //         child: SizedBox(
// //           height: size.height * 0.35,
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 20),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: [
// //                 GestureDetector(
// //                   onTap: () {
// //                     Navigator.pop(context);
// //                   },
// //                   child: Align(
// //                     alignment: Alignment.centerRight,
// //                     child: Padding(
// //                       padding: const EdgeInsets.only(top: 15),
// //                       child: SvgPicture.asset("assets/images/close-icon.svg"),
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(height: size.height * 0.005),
// //                 Text(
// //                   'Verify Yourself',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     color: orangeColor,
// //                     fontSize: 24,
// //                     fontFamily: 'Syne-Bold',
// //                   ),
// //                 ),
// //                 Text(
// //                   'Please verify yourself in order to\ncontinue to setup your account.',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     color: blackColor,
// //                     fontSize: 18,
// //                     fontFamily: 'Syne-Regular',
// //                   ),
// //                 ),
// //                 SizedBox(height: size.height * 0.02),
// //                 GestureDetector(
// //                   onTap: () {
// //                     Navigator.push(
// //                       context,
// //                       MaterialPageRoute(
// //                         builder: (context) => VerifyScreen(
// //                           email: emailController.text,
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                   child: buttonGradient("VERIFY", context),
// //                 ),
// //                 SizedBox(height: size.height * 0.02),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
