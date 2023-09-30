// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:deliver_client/models/create_profile_model.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:deliver_client/screens/first_time_location_and_address/first_save_location_screen.dart';

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
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode =
      const CountryCode(name: 'Nigeria', code: 'NG', dialCode: '+234');

  final GlobalKey<FormState> createPofileImageFormKey = GlobalKey<FormState>();
  bool isLoading = false;

  CreateProfileModel createProfileModel = CreateProfileModel();

  createProfile() async {
    try {
      String apiUrl = "$baseUrl/create_profile_customers";
      print("apiUrl: $apiUrl");
      print("firstName: ${firstNameController.text}");
      print("lastName: ${lastNameController.text}");
      print("contactNumber: ${widget.contactNumber}");
      print("email: ${emailController.text}");
      print("profile_pic: $base64imgGallery");
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
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
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
        print(
            "sharedPref userId: ${createProfileModel.data!.usersCustomersId.toString()}");
        print("sharedPref email: ${createProfileModel.data!.email}");
        print("sharedPref firstName: ${createProfileModel.data!.firstName}");
        print("sharedPref lastName: ${createProfileModel.data!.lastName}");
        print('createProfileModel status: ${createProfileModel.status}');
        setState(() {});
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
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
        print("base64img $base64imgGallery");

        final imageTemporary = File(xFile.path);

        setState(() {
          imagePathGallery = imageTemporary;
          print("newImage $imagePathGallery");
          print("newImage64 $base64imgGallery");
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
      print('Failed to pick image: ${e.toString()}');
    }
  }

  Future getStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      // Permission granted, navigate to the next screen
      pickImageGallery();
    } else if (status.isDenied) {
      // Permission denied, show a message and ask for permission again
      openAppSettings();
    } else if (status.isPermanentlyDenied) {
      // Permission denied permanently, open app settings
      openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    print('contactNumber: ${widget.contactNumber}');
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
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
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
                key: createPofileImageFormKey,
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
                    SizedBox(height: size.height * 0.08),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        if (createPofileImageFormKey.currentState!.validate()) {
                          if (base64imgGallery == null) {
                            final snackBar = SnackBar(
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              dismissDirection: DismissDirection.horizontal,
                              backgroundColor: transparentColor,
                              content: AwesomeSnackbarContent(
                                title: 'Oh Snap!',
                                message: "Please Upload an Image",
                                contentType: ContentType.help,
                              ),
                            );
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(snackBar);
                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            await createProfile();

                            if (createProfileModel.status == 'success') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FirstSaveLocationScreen(),
                                ),
                              );
                              setState(() {
                                isLoading = false;
                              });
                            }
                            if (createProfileModel.status != 'success') {
                              final snackBar = SnackBar(
                                elevation: 0,
                                behavior: SnackBarBehavior.floating,
                                dismissDirection: DismissDirection.horizontal,
                                backgroundColor: transparentColor,
                                content: AwesomeSnackbarContent(
                                  title: 'Oh Snap!',
                                  message: "Email already exists.",
                                  contentType: ContentType.failure,
                                ),
                              );
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(snackBar);
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


// // ignore_for_file: avoid_print, use_build_context_synchronously

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
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// import 'package:deliver_client/screens/first_time_location_and_address/first_save_location_screen.dart';

// String? userId;

// class LoginProfileScreen extends StatefulWidget {
//   final String? firstName;
//   final String? lastName;
//   final String? contactNumber;
//   final String? email;
//   const LoginProfileScreen(
//       {super.key,
//       this.firstName,
//       this.lastName,
//       this.contactNumber,
//       this.email});

//   @override
//   State<LoginProfileScreen> createState() => _LoginProfileScreenState();
// }

// class _LoginProfileScreenState extends State<LoginProfileScreen> {
//   final GlobalKey<FormState> logInPofileImageFormKey = GlobalKey<FormState>();
//   bool isLoading = false;

//   ProfileImageModel profileImageModel = ProfileImageModel();

//   profileImage() async {
//     try {
//       SharedPreferences sharedPref = await SharedPreferences.getInstance();
//       userId = sharedPref.getString('userId');
//       String apiUrl = "$baseUrl/update_profile_image_customers";
//       print("apiUrl: $apiUrl");
//       print("userId: $userId");
//       print("profile_pic: $base64imgGallery");
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
//       print("response: $responseString");
//       print("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         profileImageModel = profileImageModelFromJson(responseString);
//         print('profileImageModel status: ${profileImageModel.status}');
//         setState(() {});
//       }
//     } catch (e) {
//       print('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   File? imagePathGallery;
//   String? base64imgGallery;
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
//         print("base64img $base64imgGallery");

//         final imageTemporary = File(xFile.path);

//         setState(() {
//           imagePathGallery = imageTemporary;
//           print("newImage $imagePathGallery");
//           print("newImage64 $base64imgGallery");
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
//       print('Failed to pick image: ${e.toString()}');
//     }
//   }

//   Future getStoragePermission() async {
//     PermissionStatus status = await Permission.storage.request();

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

//   @override
//   void initState() {
//     super.initState();
//     print('initState firstName: ${widget.firstName}');
//     print('initState lastName: ${widget.lastName}');
//     print('initState contactNumber: ${widget.contactNumber}');
//     print('initState email: ${widget.email}');
//   }

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
//                             final snackBar = SnackBar(
//                               elevation: 0,
//                               behavior: SnackBarBehavior.floating,
//                               dismissDirection: DismissDirection.horizontal,
//                               backgroundColor: transparentColor,
//                               content: AwesomeSnackbarContent(
//                                 title: 'Oh Snap!',
//                                 message: "Please Upload an Image",
//                                 contentType: ContentType.help,
//                                 // change contentType to ContentType.success,
//                                 // ContentType.warning or ContentType.help for variants
//                               ),
//                             );
//                             ScaffoldMessenger.of(context)
//                               ..hideCurrentSnackBar()
//                               ..showSnackBar(snackBar);
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
//                               final snackBar = SnackBar(
//                                 elevation: 0,
//                                 behavior: SnackBarBehavior.floating,
//                                 dismissDirection: DismissDirection.horizontal,
//                                 backgroundColor: transparentColor,
//                                 content: AwesomeSnackbarContent(
//                                   title: 'Oh Snap!',
//                                   message:
//                                       "An error occurred while uploading the image.\nPlease try again.",
//                                   contentType: ContentType.failure,
//                                   // change contentType to ContentType.success,
//                                   // ContentType.warning or ContentType.help for variants
//                                 ),
//                               );
//                               ScaffoldMessenger.of(context)
//                                 ..hideCurrentSnackBar()
//                                 ..showSnackBar(snackBar);
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
