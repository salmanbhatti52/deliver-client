// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/models/notification_switch_model.dart';

String? userId;
String? notificationStatus = "Yes";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool switchStatus = true;

  checkSwitch() async {
    if (switchStatus == true) {
      notificationStatus = "Yes";
    } else {
      notificationStatus = "No";
    }

    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.setString('notificationStatus', "$notificationStatus");
    notificationSwitch();
  }

  NotificationSwitchModel notificationSwitchModel = NotificationSwitchModel();

  notificationSwitch() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/update_notification_switch_customers";
      print("apiUrl: $apiUrl");
      print("userId: $userId");
      print("notifications: $notificationStatus");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "users_customers_id": userId,
          "notifications": notificationStatus,
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        notificationSwitchModel =
            notificationSwitchModelFromJson(responseString);
        setState(() {});
        print(
            'notificationSwitchModel status: ${notificationSwitchModel.status}');
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  sharedPrefs() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    notificationStatus = sharedPref.getString('notificationStatus');
    print("notificationStatus in sharedPrefs is: $notificationStatus");
  }

  @override
  void initState() {
    super.initState();
    sharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomePageScreen(),
            ),
            (Route<dynamic> route) => false);
        return false;
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.03),
              Row(
                children: [
                  Text(
                    "Enable Notifications",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: drawerTextColor,
                      fontSize: 16,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  const Spacer(),
                  FlutterSwitch(
                    width: 35,
                    height: 20,
                    activeColor: blackColor,
                    inactiveColor: whiteColor,
                    activeToggleBorder: Border.all(color: blackColor, width: 2),
                    inactiveToggleBorder:
                        Border.all(color: blackColor, width: 2),
                    inactiveSwitchBorder:
                        Border.all(color: blackColor, width: 2),
                    toggleSize: 12,
                    value: notificationStatus == "Yes"
                        ? switchStatus = true
                        : false,
                    borderRadius: 50,
                    onToggle: (val) {
                      setState(() {
                        switchStatus = val;
                        checkSwitch();
                        print("switchStatus: $switchStatus");
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
