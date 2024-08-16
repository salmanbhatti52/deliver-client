// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_picker/image_picker.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:deliver_client/widgets/custom_snackbar.dart';
import 'package:deliver_client/models/create_profile_model.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/widgets/custom_snackbar_with_btn.dart';
import 'package:deliver_client/screens/first_time_location_and_address/first_save_location_screen.dart';

bool checkmark = false;
bool checkmark2 = false;

typedef OnAcceptCallback = void Function(bool value);

class LoginProfileScreen extends StatefulWidget {
  final String? contactNumber;

  const LoginProfileScreen({super.key, this.contactNumber});

  @override
  State<LoginProfileScreen> createState() => _LoginProfileScreenState();
}

class _LoginProfileScreenState extends State<LoginProfileScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> createProfileImageFormKey = GlobalKey<FormState>();
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode =
      const CountryCode(name: 'Nigeria', code: 'NG', dialCode: '+234');

  String? termsText;
  String? privacyText;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];

  void handleTermsCheckmarkState(bool newValue) {
    setState(() {
      checkmark = newValue;
    });
  }

  void handlePrivacyCheckmarkState(bool newValue) {
    setState(() {
      checkmark2 = newValue;
    });
  }

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
          if (getAllSystemDataModel.data?[i].type == "terms_text") {
            termsText = "${getAllSystemDataModel.data?[i].description}";
            debugPrint("termsText: $termsText");
          }
          for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
            if (getAllSystemDataModel.data?[i].type == "privacy_text") {
              privacyText = "${getAllSystemDataModel.data?[i].description}";
              debugPrint("privacyText: $privacyText");
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  CreateProfileModel createProfileModel = CreateProfileModel();
  var data;
  createProfile() async {
    try {
      String apiUrl = "$baseUrl/create_profile_customers";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("firstName: ${firstNameController.text}");
      debugPrint("lastName: ${lastNameController.text}");
      debugPrint("contactNumber: ${widget.contactNumber}");
      debugPrint("email: ${emailController.text}");
      debugPrint("profile_pic: $base64imgGallery");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "one_signal_id": "123",
          "first_name": firstNameController.text,
          "last_name": lastNameController.text,
          "phone": widget.contactNumber,
          "email": emailController.text,
          "account_type": "SignupWithApp",
          "profile_pic": base64imgGallery,
        },
      );
      final responseString = response.body;
      data = json.decode(responseString);
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        if (data['status'] == "success") {
          createProfileModel = createProfileModelFromJson(responseString);
          SharedPreferences sharedPref = await SharedPreferences.getInstance();
          await sharedPref.setString('userId',
              "${createProfileModel.data?.usersCustomersId.toString()}");
          await sharedPref.setString(
              'email', "${createProfileModel.data?.email}");
          await sharedPref.setString(
              'firstName', "${createProfileModel.data?.firstName}");
          await sharedPref.setString(
              'lastName', "${createProfileModel.data?.lastName}");
          await sharedPref.setString(
              'phoneNumber', "${createProfileModel.data?.phone}");
          await sharedPref.setString(
              'profilePic', "${createProfileModel.data?.profilePic}");
          debugPrint(
              "sharedPref userId: ${createProfileModel.data!.usersCustomersId.toString()}");
          debugPrint("sharedPref email: ${createProfileModel.data!.email}");
          debugPrint(
              "sharedPref firstName: ${createProfileModel.data!.firstName}");
          debugPrint(
              "sharedPref lastName: ${createProfileModel.data!.lastName}");
          debugPrint(
              "sharedPref phoneNumber: ${createProfileModel.data!.phone}");
          debugPrint(
              "sharedPref profilePic: ${createProfileModel.data!.profilePic}");
          debugPrint('createProfileModel status: ${createProfileModel.status}');
          setState(() {});
        } else if (data['status'] == "error") {
          createProfileModel = createProfileModelFromJson(responseString);
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  File? imagePathGallery;
  String? base64imgGallery;

  Future pickImageGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);
      if (xFile == null) {
        // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
        // const NavBar()), (Route<dynamic> route) => false);
      } else {
        Uint8List imageByte = await xFile.readAsBytes();
        base64imgGallery = base64.encode(imageByte);
        debugPrint("base64img $base64imgGallery");

        final imageTemporary = File(xFile.path);

        setState(() {
          imagePathGallery = imageTemporary;
          debugPrint("newImage $imagePathGallery");
          debugPrint("newImage64 $base64imgGallery");
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (BuildContext context) => SaveImageScreen(
          //           image: imagePath,
          //           image64: "$base64img",
          //         )));
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: ${e.toString()}');
    }
  }

  Future getStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      // Permission granted, navigate to the next screen
      pickImageGallery();
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Permission denied, show a message and provide information
      showStoragePermissionSnackBar();
    }
  }

  void showStoragePermissionSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBarWithBtn(
        message:
            "Photo Library permission is required\nto change profile picture.",
        buttonText: "Grant Permission",
        onPressed: () {
          openAppSettings();
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getAllSystemData();
    debugPrint('contactNumber: ${widget.contactNumber}');
  }

  @override
  Widget build(BuildContext context) {
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
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "Create Profile",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: blackColor,
              fontSize: 20,
              fontFamily: 'Syne-Bold',
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Form(
                key: createProfileImageFormKey,
                child: Column(
                  children: [
                    SizedBox(
                      width: size.width * 0.42,
                      height: size.height * 0.22,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: size.width * 0.4,
                              height: size.height * 0.2,
                              decoration: BoxDecoration(
                                color: transparentColor,
                              ),
                              child: imagePathGallery != null
                                  ? Image.file(
                                      imagePathGallery!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/user-profile.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // getStoragePermission();
                                pickImageGallery();
                              },
                              child: SvgPicture.asset(
                                'assets/images/camera-icon.svg',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: firstNameController,
                        cursorColor: orangeColor,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First Name is required!';
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          hintText: "First Name",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 12,
                            fontFamily: 'Inter-Light',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: lastNameController,
                        cursorColor: orangeColor,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last Name is required!';
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          hintText: "Last Name",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 12,
                            fontFamily: 'Inter-Light',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        controller: emailController,
                        cursorColor: orangeColor,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email ID is required!';
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          hintText: "Email ID",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 12,
                            fontFamily: 'Inter-Light',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => privacyDialog(
                                    context,
                                    '$privacyText',
                                    handlePrivacyCheckmarkState),
                              );
                              // setState(() {
                              //   checkmark2 = true;
                              // });
                            },
                            child: checkmark2 == true
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        checkmark2 = false;
                                      });
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/checkmark-icon.svg',
                                    ),
                                  )
                                : SvgPicture.asset(
                                    'assets/images/uncheckmark-icon.svg',
                                  ),
                          ),
                          SizedBox(width: size.width * 0.03),
                          RichText(
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              text: "I agree to the  ",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: 12,
                                fontFamily: 'Syne-Medium',
                              ),
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => privacyDialog(
                                            context,
                                            '$privacyText',
                                            handlePrivacyCheckmarkState),
                                      );
                                    },
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 12,
                                    fontFamily: 'Syne-Medium',
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(
                                  text: '.',
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 12,
                                    fontFamily: 'Syne-Medium',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => termsDialog(context,
                                    '$termsText', handleTermsCheckmarkState),
                              );
                              // setState(() {
                              //   checkmark = true;
                              // });
                            },
                            child: checkmark == true
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        checkmark = false;
                                      });
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/checkmark-icon.svg',
                                    ),
                                  )
                                : SvgPicture.asset(
                                    'assets/images/uncheckmark-icon.svg',
                                  ),
                          ),
                          SizedBox(width: size.width * 0.03),
                          RichText(
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              text: "I agree to the  ",
                              style: TextStyle(
                                color: blackColor,
                                fontSize: 12,
                                fontFamily: 'Syne-Medium',
                              ),
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => termsDialog(
                                            context,
                                            '$termsText',
                                            handleTermsCheckmarkState),
                                      );
                                    },
                                  text: 'Terms and Conditions',
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 12,
                                    fontFamily: 'Syne-Medium',
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(
                                  text: '.',
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 12,
                                    fontFamily: 'Syne-Medium',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.08),
                    GestureDetector(
                      onTap: () async {
                        if (createProfileImageFormKey.currentState!
                            .validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          if (base64imgGallery == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackBar(
                                message: "Please upload an image",
                                size: MediaQuery.of(context).size,
                              ),
                            );
                            setState(() {
                              isLoading = false;
                            });
                          } else if (!checkmark || !checkmark2) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackBar(
                                message:
                                    "Please accept our terms and conditions and privacy policy",
                                size: MediaQuery.of(context).size,
                              ),
                            );
                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            await createProfile();
                            if (createProfileModel.status == 'success') {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FirstSaveLocationScreen(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                              setState(() {
                                isLoading = false;
                              });
                            } else if (data['status'] == "error") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                CustomSnackBar(
                                  message:
                                      "Email already in use, please use another email",
                                  size: MediaQuery.of(context).size,
                                ),
                              );
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        }
                      },
                      child: isLoading
                          ? buttonGradientWithLoader("Please Wait...", context)
                          : buttonGradient("SAVE", context),
                    ),
                    SizedBox(height: size.height * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget termsDialog(
    BuildContext context, String? text, OnAcceptCallback onAccept) {
  var size = MediaQuery.of(context).size;
  return WillPopScope(
    onWillPop: () {
      return Future.value(false);
    },
    child: GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          insetPadding: const EdgeInsets.only(left: 20, right: 20),
          child: SizedBox(
            height: size.height * 0.8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(height: size.height * 0.04),
                  Text(
                    'Terms and Conditions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: orangeColor,
                      fontSize: 20,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Container(
                    width: size.width,
                    height: size.height * 0.6,
                    color: transparentColor,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Html(
                            data: "$text",
                            style: {
                              "html": Style(
                                color: blackColor,
                                fontSize: FontSize(15),
                                fontFamily: 'Syne-Medium',
                              ),
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: dialogButtonGradientSmall("Decline", context),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            checkmark = true;
                            debugPrint('checkmark: $checkmark');
                          });
                          onAccept(true);
                          Navigator.pop(context);
                        },
                        child: dialogButtonGradientSmall("Accept", context),
                      )
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

privacyDialog(BuildContext context, String? text, OnAcceptCallback onAccept) {
  var size = MediaQuery.of(context).size;
  return WillPopScope(
    onWillPop: () {
      return Future.value(false);
    },
    child: GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          insetPadding: const EdgeInsets.only(left: 20, right: 20),
          child: SizedBox(
            height: size.height * 0.8,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(height: size.height * 0.04),
                  Text(
                    'Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: orangeColor,
                      fontSize: 20,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Container(
                    width: size.width,
                    height: size.height * 0.6,
                    color: transparentColor,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Html(
                            data: "$text",
                            style: {
                              "html": Style(
                                color: blackColor,
                                fontSize: FontSize(15),
                                fontFamily: 'Syne-Medium',
                              ),
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: dialogButtonGradientSmall("Decline", context),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            checkmark2 = true;
                            debugPrint('checkmark2: $checkmark2');
                          });
                          onAccept(true);
                          Navigator.pop(context);
                        },
                        child: dialogButtonGradientSmall("Accept", context),
                      )
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// // ignore_for_file: use_build_context_synchronously
//
// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:deliver_client/models/profile_image_model.dart';
// import 'package:deliver_client/screens/first_time_location_and_address/first_save_location_screen.dart';
//
// String? userId;
//
// class LoginProfileScreen extends StatefulWidget {
//   final String? firstName;
//   final String? lastName;
//   final String? contactNumber;
//   final String? email;
//
//   const LoginProfileScreen(
//       {super.key,
//       this.firstName,
//       this.lastName,
//       this.contactNumber,
//       this.email});
//
//   @override
//   State<LoginProfileScreen> createState() => _LoginProfileScreenState();
// }
//
// class _LoginProfileScreenState extends State<LoginProfileScreen> {
//   final GlobalKey<FormState> logInPofileImageFormKey = GlobalKey<FormState>();
//   bool isLoading = false;
//
//   ProfileImageModel profileImageModel = ProfileImageModel();
//
//   profileImage() async {
//     try {
//       SharedPreferences sharedPref = await SharedPreferences.getInstance();
//       userId = sharedPref.getString('userId');
//       String apiUrl = "$baseUrl/update_profile_image_customers";
//       debugPrint("apiUrl: $apiUrl");
//       debugPrint("userId: $userId");
//       debugPrint("profile_pic: $base64imgGallery");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "users_customers_id": userId,
//           "profile_pic": base64imgGallery,
//         },
//       );
//       final responseString = response.body;
//       debugPrint("response: $responseString");
//       debugPrint("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         profileImageModel = profileImageModelFromJson(responseString);
//         debugPrint('profileImageModel status: ${profileImageModel.status}');
//         setState(() {});
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }
//
//   File? imagePathGallery;
//   String? base64imgGallery;
//
//   Future pickImageGallery() async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);
//       if (xFile == null) {
//         // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
//         // const NavBar()), (Route<dynamic> route) => false);
//       } else {
//         Uint8List imageByte = await xFile.readAsBytes();
//         base64imgGallery = base64.encode(imageByte);
//         debugPrint("base64img $base64imgGallery");
//
//         final imageTemporary = File(xFile.path);
//
//         setState(() {
//           imagePathGallery = imageTemporary;
//           debugPrint("newImage $imagePathGallery");
//           debugPrint("newImage64 $base64imgGallery");
//           // Navigator.push(
//           //     context,
//           //     MaterialPageRoute(
//           //         builder: (BuildContext context) => SaveImageScreen(
//           //           image: imagePath,
//           //           image64: "$base64img",
//           //         )));
//         });
//       }
//     } on PlatformException catch (e) {
//       debugPrint('Failed to pick image: ${e.toString()}');
//     }
//   }
//
//   Future getStoragePermission() async {
//     PermissionStatus status = await Permission.storage.request();
//
//     if (status.isGranted) {
//       // Permission granted, navigate to the next screen
//       pickImageGallery();
//     } else if (status.isDenied) {
//       // Permission denied, show a message and ask for permission again
//       openAppSettings();
//     } else if (status.isPermanentlyDenied) {
//       // Permission denied permanently, open app settings
//       openAppSettings();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     debugPrint('initState firstName: ${widget.firstName}');
//     debugPrint('initState lastName: ${widget.lastName}');
//     debugPrint('initState contactNumber: ${widget.contactNumber}');
//     debugPrint('initState email: ${widget.email}');
//   }
//
//   @override
//   Widget build(BuildContext context) {
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
//           automaticallyImplyLeading: false,
//           title: Text(
//             "Profile",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: blackColor,
//               fontSize: 20,
//               fontFamily: 'Syne-Bold',
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: SingleChildScrollView(
//               child: Form(
//                 key: logInPofileImageFormKey,
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: size.width * 0.42,
//                       height: size.height * 0.22,
//                       child: Stack(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Container(
//                               width: size.width * 0.4,
//                               height: size.height * 0.2,
//                               decoration: BoxDecoration(
//                                 color: transparentColor,
//                               ),
//                               child: imagePathGallery != null
//                                   ? Image.file(
//                                       imagePathGallery!,
//                                       fit: BoxFit.cover,
//                                     )
//                                   : Image.asset(
//                                       'assets/images/user-profile.png',
//                                       fit: BoxFit.cover,
//                                     ),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: GestureDetector(
//                               onTap: () {
//                                 // getStoragePermission();
//                                 pickImageGallery();
//                               },
//                               child: SvgPicture.asset(
//                                 'assets/images/camera-icon.svg',
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.01),
//                     Text(
//                       '${widget.firstName} ${widget.lastName}',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: drawerTextColor,
//                         fontSize: 17,
//                         fontFamily: 'Syne-Bold',
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.04),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Container(
//                         width: size.width,
//                         height: size.height * 0.06,
//                         decoration: BoxDecoration(
//                           color: filledColor,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 15, left: 20),
//                           child: Text(
//                             ' ${widget.firstName}',
//                             style: TextStyle(
//                               color: hintColor,
//                               fontSize: 12,
//                               fontFamily: 'Inter-Light',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Container(
//                         width: size.width,
//                         height: size.height * 0.06,
//                         decoration: BoxDecoration(
//                           color: filledColor,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 15, left: 20),
//                           child: Text(
//                             ' ${widget.lastName}',
//                             style: TextStyle(
//                               color: hintColor,
//                               fontSize: 12,
//                               fontFamily: 'Inter-Light',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Container(
//                         width: size.width,
//                         height: size.height * 0.06,
//                         decoration: BoxDecoration(
//                           color: filledColor,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 15, left: 20),
//                           child: Text(
//                             ' ${widget.contactNumber}',
//                             style: TextStyle(
//                               color: hintColor,
//                               fontSize: 12,
//                               fontFamily: 'Inter-Light',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Container(
//                         width: size.width,
//                         height: size.height * 0.06,
//                         decoration: BoxDecoration(
//                           color: filledColor,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 15, left: 20),
//                           child: Text(
//                             ' ${widget.email}',
//                             style: TextStyle(
//                               color: hintColor,
//                               fontSize: 12,
//                               fontFamily: 'Inter-Light',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.06),
//                     GestureDetector(
//                       onTap: () async {
//                         if (logInPofileImageFormKey.currentState!.validate()) {
//                           if (base64imgGallery == null) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 elevation: 0,
//                                 width: double.infinity,
//                                 behavior: SnackBarBehavior.floating,
//                                 backgroundColor: Colors.transparent,
//                                 duration: const Duration(seconds: 2),
//                                 content: Container(
//                                   padding: const EdgeInsets.all(15),
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       begin: Alignment.centerRight,
//                                       end: Alignment.centerLeft,
//                                       stops: const [0.1, 1.5],
//                                       colors: [
//                                         orangeColor,
//                                         yellowColor,
//                                       ],
//                                     ),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         blurRadius: 2,
//                                         spreadRadius: 2,
//                                         offset: const Offset(0, 3),
//                                         color: blackColor.withOpacity(0.2),
//                                       ),
//                                     ],
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(
//                                       width: 2,
//                                       color: borderColor,
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'Please Upload an Image',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: whiteColor,
//                                       fontFamily: 'Syne-Bold',
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                             setState(() {
//                               isLoading = false;
//                             });
//                           } else {
//                             setState(() {
//                               isLoading = true;
//                             });
//                             await profileImage();
//                             if (profileImageModel.status == 'success') {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       FirstSaveLocationScreen(),
//                                 ),
//                               );
//                               setState(() {
//                                 isLoading = false;
//                               });
//                             }
//                             if (profileImageModel.status != 'success') {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(
//                                   elevation: 0,
//                                   width: size.width,
//                                   behavior: SnackBarBehavior.floating,
//                                   backgroundColor: Colors.transparent,
//                                   duration: const Duration(seconds: 2),
//                                   content: Container(
//                                     padding: const EdgeInsets.all(15),
//                                     decoration: BoxDecoration(
//                                       gradient: LinearGradient(
//                                         begin: Alignment.centerRight,
//                                         end: Alignment.centerLeft,
//                                         stops: const [0.1, 1.5],
//                                         colors: [
//                                           orangeColor,
//                                           yellowColor,
//                                         ],
//                                       ),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           blurRadius: 2,
//                                           spreadRadius: 2,
//                                           offset: const Offset(0, 3),
//                                           color: blackColor.withOpacity(0.2),
//                                         ),
//                                       ],
//                                       borderRadius: BorderRadius.circular(10),
//                                       border: Border.all(
//                                         width: 2,
//                                         color: borderColor,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       'An error occurred while uploading the image.\nPlease try again.',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: whiteColor,
//                                         fontFamily: 'Syne-Bold',
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               );
//                               setState(() {
//                                 isLoading = false;
//                               });
//                             }
//                           }
//                         }
//                       },
//                       child: isLoading
//                           ? buttonGradientWithLoader("Please Wait...", context)
//                           : buttonGradient("SAVE", context),
//                     ),
//                     SizedBox(height: size.height * 0.1),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
