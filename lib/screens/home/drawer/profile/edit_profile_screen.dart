// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/edit_profile_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

String? userId;

class EditProfileScreen extends StatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? image;

  const EditProfileScreen(
      {super.key, this.firstName, this.lastName, this.image});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  final GlobalKey<FormState> editProfileFormKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  EditProfileModel editProfileModel = EditProfileModel();

  editProfile() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/update_profile_customers";
      print("apiUrl: $apiUrl");
      print("userId: $userId");
      print("firstName: ${firstNameController.text}");
      print("lastName: ${lastNameController.text}");
      print("profilePic: $base64imgGallery");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "users_customers_id": userId,
          "first_name": firstNameController.text,
          "last_name": lastNameController.text,
          if (base64imgGallery != null) "profile_pic": base64imgGallery,
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        editProfileModel = editProfileModelFromJson(responseString);
        setState(() {});
        print('editProfileModel status: ${editProfileModel.status}');
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

  // Future getStoragePermission() async {
  //   PermissionStatus status = await Permission.storage.request();
  //
  //   if (status.isGranted) {
  //     // Permission granted, navigate to the next screen
  //   } else if (status.isDenied) {
  //     // Permission denied, show a message and ask for permission again
  //   } else if (status.isPermanentlyDenied) {
  //     // Permission denied permanently, open app settings
  //     openAppSettings();
  //   }
  // }

  void getStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      // Permission granted, navigate to the next screen
    } else if (status.isDenied || status.isPermanentlyDenied) {
      // Permission denied, show a message and provide information
      showStoragePermissionSnackBar();
    }
  }

  void showStoragePermissionSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: orangeColor,
        duration: const Duration(seconds: 5),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photo Library permission is required\nto change profile picture.',
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
    );
  }

  @override
  void initState() {
    super.initState();
    getStoragePermission();
    print("firstName: ${widget.firstName}");
    print("lastName: ${widget.lastName}");
    print("imageUrl: ${widget.image}");
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
            "Edit Profile",
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
                key: editProfileFormKey,
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.03),
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
                                  : FadeInImage(
                                      placeholder: const AssetImage(
                                        "assets/images/user-profile.png",
                                      ),
                                      image: NetworkImage(
                                        '$imageUrl${widget.image}',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
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
                    SizedBox(height: size.height * 0.02),
                    Text(
                      '${widget.firstName} ${widget.lastName}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: drawerTextColor,
                        fontSize: 17,
                        fontFamily: 'Syne-Bold',
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
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
                    SizedBox(height: size.height * 0.25),
                    GestureDetector(
                      onTap: () async {
                        if (editProfileFormKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          await editProfile();
                          if (editProfileModel.status == 'success') {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const HomePageScreen()),
                                (Route<dynamic> route) => false);
                            setState(() {
                              isLoading = false;
                            });
                          }
                          if (editProfileModel.status != 'success') {
                            final snackBar = SnackBar(
                              elevation: 0,
                              behavior: SnackBarBehavior.floating,
                              dismissDirection: DismissDirection.horizontal,
                              backgroundColor: transparentColor,
                              content: AwesomeSnackbarContent(
                                title: 'Oh Snap!',
                                message:
                                    "An error occurred while uploading your image.\nPlease try again.",
                                messageFontSize: 12,
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
                      },
                      child: isLoading
                          ? buttonGradientWithLoader("Please Wait...", context)
                          : buttonGradient("SAVE", context),
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
// import 'package:deliver_client/models/edit_profile_model.dart';
// import 'package:deliver_client/screens/home/home_page_screen.dart';
// import 'package:fl_country_code_picker/fl_country_code_picker.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// String? userId;

// class EditProfileScreen extends StatefulWidget {
//   final String? firstName;
//   final String? lastName;
//   final String? image;
//   const EditProfileScreen(
//       {super.key, this.firstName, this.lastName, this.image});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   TextEditingController firstNameController = TextEditingController();
//   TextEditingController lastNameController = TextEditingController();
//   TextEditingController contactNumberController = TextEditingController();
//   final GlobalKey<FormState> editProfileFormKey = GlobalKey<FormState>();
//   final countryPicker = const FlCountryCodePicker();
//   CountryCode? countryCode =
//       const CountryCode(name: 'Nigeria', code: 'NG', dialCode: '+234');

//   bool isLoading = false;

//   EditProfileModel editProfileModel = EditProfileModel();

//   editProfile() async {
//     try {
//       SharedPreferences sharedPref = await SharedPreferences.getInstance();
//       userId = sharedPref.getString('userId');
//       String apiUrl = "$baseUrl/update_profile_customers";
//       print("apiUrl: $apiUrl");
//       print("userId: $userId");
//       print("firstName: ${firstNameController.text}");
//       print("lastName: ${lastNameController.text}");
//       print(
//           "contactNumber: ${countryCode!.dialCode + contactNumberController.text}");
//       print("profilePic: $base64imgGallery");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "users_customers_id": userId,
//           "first_name": firstNameController.text,
//           "last_name": lastNameController.text,
//           "phone": countryCode!.dialCode + contactNumberController.text,
//           if (base64imgGallery != null) "profile_pic": base64imgGallery,
//         },
//       );
//       final responseString = response.body;
//       print("response: $responseString");
//       print("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         editProfileModel = editProfileModelFromJson(responseString);
//         setState(() {});
//         print('editProfileModel status: ${editProfileModel.status}');
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
//     } else if (status.isDenied) {
//       // Permission denied, show a message and ask for permission again
//     } else if (status.isPermanentlyDenied) {
//       // Permission denied permanently, open app settings
//       openAppSettings();
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getStoragePermission();
//     print("firstName: ${widget.firstName}");
//     print("lastName: ${widget.lastName}");
//     print("imageUrl: ${widget.image}");
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
//           leading: GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
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
//           title: Text(
//             "Edit Profile",
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
//                 key: editProfileFormKey,
//                 child: Column(
//                   children: [
//                     SizedBox(height: size.height * 0.03),
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
//                                   : FadeInImage(
//                                       placeholder: const AssetImage(
//                                         "assets/images/user-profile.png",
//                                       ),
//                                       image: NetworkImage(
//                                         '$imageUrl${widget.image}',
//                                       ),
//                                       fit: BoxFit.cover,
//                                     ),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: GestureDetector(
//                               onTap: () {
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
//                     SizedBox(height: size.height * 0.02),
//                     Text(
//                       '${widget.firstName} ${widget.lastName}',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: drawerTextColor,
//                         fontSize: 17,
//                         fontFamily: 'Syne-Bold',
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: TextFormField(
//                         controller: firstNameController,
//                         cursorColor: orangeColor,
//                         keyboardType: TextInputType.text,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'First Name is required!';
//                           }
//                           return null;
//                         },
//                         style: TextStyle(
//                           color: blackColor,
//                           fontSize: 14,
//                           fontFamily: 'Inter-Regular',
//                         ),
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: filledColor,
//                           errorStyle: TextStyle(
//                             color: redColor,
//                             fontSize: 10,
//                             fontFamily: 'Inter-Bold',
//                           ),
//                           border: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedErrorBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderRadius: const BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide(
//                               color: redColor,
//                               width: 1,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 10),
//                           hintText: "First Name",
//                           hintStyle: TextStyle(
//                             color: hintColor,
//                             fontSize: 12,
//                             fontFamily: 'Inter-Light',
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: TextFormField(
//                         controller: lastNameController,
//                         cursorColor: orangeColor,
//                         keyboardType: TextInputType.text,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Last Name is required!';
//                           }
//                           return null;
//                         },
//                         style: TextStyle(
//                           color: blackColor,
//                           fontSize: 14,
//                           fontFamily: 'Inter-Regular',
//                         ),
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: filledColor,
//                           errorStyle: TextStyle(
//                             color: redColor,
//                             fontSize: 10,
//                             fontFamily: 'Inter-Bold',
//                           ),
//                           border: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedErrorBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderRadius: const BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide(
//                               color: redColor,
//                               width: 1,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 10),
//                           hintText: "Last Name",
//                           hintStyle: TextStyle(
//                             color: hintColor,
//                             fontSize: 12,
//                             fontFamily: 'Inter-Light',
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: TextFormField(
//                         controller: contactNumberController,
//                         cursorColor: orangeColor,
//                         keyboardType: TextInputType.number,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                           LengthLimitingTextInputFormatter(15),
//                         ],
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Contact Number is required!';
//                           }
//                           return null;
//                         },
//                         style: TextStyle(
//                           color: blackColor,
//                           fontSize: 14,
//                           fontFamily: 'Inter-Regular',
//                         ),
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: filledColor,
//                           errorStyle: TextStyle(
//                             color: redColor,
//                             fontSize: 10,
//                             fontFamily: 'Inter-Bold',
//                           ),
//                           border: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           enabledBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           focusedErrorBorder: const OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide.none,
//                           ),
//                           errorBorder: OutlineInputBorder(
//                             borderRadius: const BorderRadius.all(
//                               Radius.circular(10),
//                             ),
//                             borderSide: BorderSide(
//                               color: redColor,
//                               width: 1,
//                             ),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 20, vertical: 10),
//                           hintText: "Contact Number",
//                           hintStyle: TextStyle(
//                             color: hintColor,
//                             fontSize: 12,
//                             fontFamily: 'Inter-Light',
//                           ),
//                           prefixIcon: GestureDetector(
//                             onTap: () async {
//                               final code = await countryPicker.showPicker(
//                                   context: context);
//                               setState(() {
//                                 countryCode = code;
//                               });
//                               print('countryName: ${countryCode!.name}');
//                               print('countryCode: ${countryCode!.code}');
//                               print(
//                                   'countryDialCode: ${countryCode!.dialCode}');
//                             },
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 20),
//                                   child: Container(
//                                     child: countryCode != null
//                                         ? Image.asset(
//                                             countryCode!.flagUri,
//                                             package:
//                                                 countryCode!.flagImagePackage,
//                                             width: 25,
//                                             height: 20,
//                                           )
//                                         : SvgPicture.asset(
//                                             'assets/images/flag-icon.svg',
//                                           ),
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.only(left: 10),
//                                   child: Text(
//                                     countryCode?.dialCode ?? "+234",
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       color: hintColor,
//                                       fontSize: 12,
//                                       fontFamily: 'Inter-Light',
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(width: size.width * 0.02),
//                                 Text(
//                                   '|',
//                                   style: TextStyle(
//                                     color: hintColor,
//                                     fontSize: 12,
//                                     fontFamily: 'Inter-SemiBold',
//                                   ),
//                                 ),
//                                 SizedBox(width: size.width * 0.02),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.2),
//                     GestureDetector(
//                       onTap: () async {
//                         if (editProfileFormKey.currentState!.validate()) {
//                           setState(() {
//                             isLoading = true;
//                           });
//                           await editProfile();
//                           if (editProfileModel.status == 'success') {
//                             Navigator.of(context).pushAndRemoveUntil(
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                         const HomePageScreen()),
//                                 (Route<dynamic> route) => false);
//                             setState(() {
//                               isLoading = false;
//                             });
//                           }
//                           if (editProfileModel.status != 'success') {
//                             final snackBar = SnackBar(
//                               elevation: 0,
//                               behavior: SnackBarBehavior.floating,
//                               dismissDirection: DismissDirection.horizontal,
//                               backgroundColor: transparentColor,
//                               content: AwesomeSnackbarContent(
//                                 title: 'Oh Snap!',
//                                 message:
//                                     "An error occurred while uploading your image.\nPlease try again.",
//                                 messageFontSize: 12,
//                                 contentType: ContentType.failure,
//                               ),
//                             );
//                             ScaffoldMessenger.of(context)
//                               ..hideCurrentSnackBar()
//                               ..showSnackBar(snackBar);
//                             setState(() {
//                               isLoading = false;
//                             });
//                           }
//                         }
//                       },
//                       child: isLoading
//                           ? buttonGradientWithLoader("Please Wait...", context)
//                           : buttonGradient("SAVE", context),
//                     ),
//                     SizedBox(height: size.height * 0.02),
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
