// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_constructors, unused_local_variable

import 'dart:async';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/check_number_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/screens/login/login_profile_screen.dart';

class VerifyPhoneSignUpScreen extends StatefulWidget {
  final String? phoneNumber;
  const VerifyPhoneSignUpScreen({super.key, this.phoneNumber});

  @override
  State<VerifyPhoneSignUpScreen> createState() =>
      _VerifyPhoneSignUpScreenState();
}

class _VerifyPhoneSignUpScreenState extends State<VerifyPhoneSignUpScreen> {
  TextEditingController otpController = TextEditingController();

  bool isLoading = false;

  CheckNumberModel checkNumberModel = CheckNumberModel();

  checkNumber() async {
    try {
      String apiUrl = "$baseUrl/check_phone_exist_customers";
      print("contactNumber: ${widget.phoneNumber}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "phone": widget.phoneNumber,
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        checkNumberModel = checkNumberModelFromJson(responseString);
        print('checkNumberModel status: ${checkNumberModel.status}');
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
        print(
            "sharedPref userId: ${checkNumberModel.data!.usersCustomersId.toString()}");
        print("sharedPref email: ${checkNumberModel.data!.email}");
        print("sharedPref firstName: ${checkNumberModel.data!.firstName}");
        print("sharedPref lastName: ${checkNumberModel.data!.lastName}");
        print("sharedPref phoneNumber: ${checkNumberModel.data!.phone}");
        setState(() {});
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  String verifyId = '';

  Future<void> verifyPhoneNumber() async {
    if (widget.phoneNumber != null) {
      print("phoneNumber: ${widget.phoneNumber!}");
    }
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '${widget.phoneNumber}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) async {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        verifyId = verificationId;
        String smsCode = otpController.text;

        // Create a PhoneAuthCredential with the code
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: verificationId, smsCode: smsCode);

        // Sign the user in (or link) with the credential
        // await _auth.signInWithCredential(credential);
      },
      timeout: const Duration(seconds: 120),
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOTPCode() async {
    print("verificationId: $verifyId");
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verifyId,
      smsCode: otpController.text,
    );
    await auth.signInWithCredential(credential).then((value) async {
      print('User Login In Successful ${value.user}');
      await checkNumber();
      setState(() {
        isLoading = true;
      });
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
      setState(() {
        isLoading = false;
      });
    });
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
    verifyPhoneNumber();
    print("phoneNumber: ${widget.phoneNumber}");
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
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(
                    "Enter OTP Code",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 16,
                      fontFamily: 'Syne-SemiBold',
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "OTP valid for",
                      textAlign: TextAlign.left,
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
                    Container(
                      width: size.width * 0.2,
                      color: transparentColor,
                      child: Text(
                        getTimerText(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 16,
                          fontFamily: 'Inter-SemiBold',
                        ),
                      ),
                    ),
                  ],
                ),
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
                              verifyPhoneNumber();
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
              SizedBox(height: size.height * 0.03),
              GestureDetector(
                onTap: () async {
                  verifyOTPCode();
                  timer?.cancel();
                },
                child: isLoading
                    ? buttonGradientWithLoader("Pleasw Wait...", context)
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
