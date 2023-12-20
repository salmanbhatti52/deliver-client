// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:lottie/lottie.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  bool isLoading = false;
  bool isExpanded = false;
  bool isExpanded2 = false;

  String? termsText;
  String? privacyText;
  String? baseUrl = dotenv.env['BASE_URL'];

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

  getAllSystemData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$baseUrl/get_all_system_data";
      print("apiUrl: $apiUrl");
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getAllSystemDataModel = getAllSystemDataModelFromJson(responseString);
        print('getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        print(
            'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "terms_text") {
            termsText = "${getAllSystemDataModel.data?[i].description}";
            print("termsText: $termsText");
          }
          for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
            if (getAllSystemDataModel.data?[i].type == "privacy_text") {
              privacyText = "${getAllSystemDataModel.data?[i].description}";
              print("privacyText: $privacyText");
            }
          }
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getAllSystemData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePageScreen()),
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
            "Legal",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: blackColor,
              fontSize: 20,
              fontFamily: 'Syne-Bold',
            ),
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? Center(
                child: Container(
                  width: 100,
                  height: 100,
                  color: transparentColor,
                  child: Lottie.asset(
                    'assets/images/loading-icon.json',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : getAllSystemDataModel.data != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.02),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Container(
                                width: size.width,
                                height: isExpanded
                                    ? size.height * 0.6
                                    : size.height * 0.06,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  border: Border.all(
                                    color: borderColor.withOpacity(0.1),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: blackColor.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: isExpanded
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                  height: size.height * 0.02),
                                              Text(
                                                "Terms & Conditions",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: blackColor,
                                                  fontFamily: 'Syne-Bold',
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.02),
                                              Text(
                                                "$termsText",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: blackColor,
                                                  fontFamily: 'Syne-Regular',
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.02),
                                              Icon(
                                                Icons.keyboard_arrow_up_rounded,
                                                color:
                                                    blackColor.withOpacity(0.5),
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Terms & Conditions",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: blackColor,
                                                fontFamily: 'Syne-Medium',
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Icons
                                                  .keyboard_arrow_right_rounded,
                                              color:
                                                  blackColor.withOpacity(0.5),
                                            ),
                                          ],
                                        ),
                                      )),
                          ),
                          SizedBox(height: size.height * 0.02),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded2 = !isExpanded2;
                              });
                            },
                            child: Container(
                                width: size.width,
                                height: isExpanded2
                                    ? size.height * 0.6
                                    : size.height * 0.06,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  border: Border.all(
                                    color: borderColor.withOpacity(0.1),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: blackColor.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: isExpanded2
                                    ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                  height: size.height * 0.02),
                                              Text(
                                                "Privacy Policy",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: blackColor,
                                                  fontFamily: 'Syne-Bold',
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.02),
                                              Text(
                                                "$privacyText",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: blackColor,
                                                  fontFamily: 'Syne-Regular',
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.02),
                                              Icon(
                                                Icons.keyboard_arrow_up_rounded,
                                                color:
                                                    blackColor.withOpacity(0.5),
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Privacy Policy",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: blackColor,
                                                fontFamily: 'Syne-Medium',
                                              ),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              Icons
                                                  .keyboard_arrow_right_rounded,
                                              color:
                                                  blackColor.withOpacity(0.5),
                                            ),
                                          ],
                                        ),
                                      )),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      "Data Not Fetched Completely\nPlease Try Again",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textHaveAccountColor,
                        fontSize: 24,
                        fontFamily: 'Syne-SemiBold',
                      ),
                    ),
                  ),
      ),
    );
  }
}
