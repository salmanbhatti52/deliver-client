import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/screens/login/login_screen.dart';

String? firstName;
String? lastName;

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  sharedPrefs() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    firstName = sharedPref.getString('firstName');
    lastName = sharedPref.getString('lastName');
    debugPrint('sharedPrefs firstName: $firstName');
    debugPrint('sharedPrefs lastName: $lastName');
    setState(() {});
  }

  removeDataFormSharedPreferences() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.clear();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    sharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
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
        title: Text(
          "Settings",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blackColor,
            fontSize: 20,
            fontFamily: 'Syne-Bold',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.03),
              Text(
                'Hi there! $firstName $lastName',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: orangeColor,
                  fontSize: 20,
                  fontFamily: 'Syne-SemiBold',
                ),
              ),
              SizedBox(height: size.height * 0.11),
              SvgPicture.asset(
                'assets/images/delete-account-icon.svg',
                width: 300,
                height: 300,
              ),
              SizedBox(height: size.height * 0.16),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => dialog(context),
                  );
                },
                child: buttonGradient('Delete Account', context),
              ),
              SizedBox(height: size.height * 0.02),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: buttonTransparentGradient('Go Back', context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dialog(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Dialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        insetPadding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
          height: size.height * 0.35,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Are you sure you want to delete your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      color: orangeColor,
                      fontFamily: 'Syne-Bold'),
                ),
                Text(
                  'If you delete your account then you will lose all your data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 16,
                    fontFamily: 'Syne-Regular',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child:
                          dialogButtonTransparentGradientSmall('No', context),
                    ),
                    SizedBox(width: size.width * 0.03),
                    GestureDetector(
                      onTap: () async {
                        removeDataFormSharedPreferences();
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            elevation: 0,
                            width: size.width,
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
                              child: Text(
                                'Delete account request has been sent to admin your account will be deleted in 24 hour.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: whiteColor,
                                  fontFamily: 'Syne-Bold',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: dialogButtonGradientSmall('Yes', context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
