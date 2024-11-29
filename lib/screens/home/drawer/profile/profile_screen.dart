// ignore_for_file: avoid_print

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/get_profile_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/screens/home/drawer/profile/edit_profile_screen.dart';

String? userId;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  GetProfileModel getProfileModel = GetProfileModel();

  getProfile() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/get_profile_customers";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("userId: $userId");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "users_customers_id": userId,
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getProfileModel = getProfileModelFromJson(responseString);
        setState(() {});
        debugPrint('getProfileModel status: ${getProfileModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getProfile();
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
      child: GestureDetector(
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
              "Profile",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackColor,
                fontSize: 20,
                fontFamily: 'Syne-Bold',
              ),
            ),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () {
                  if (getProfileModel.data != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(
                          firstName: getProfileModel.data!.firstName,
                          lastName: getProfileModel.data!.lastName,
                          image: getProfileModel.data!.profilePic,
                        ),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: SvgPicture.asset(
                    'assets/images/edit-profile-icon.svg',
                  ),
                ),
              ),
            ],
          ),
          body: getProfileModel.data != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: transparentColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: getProfileModel.data!.profilePic != null &&
                                    getProfileModel.data!.profilePic!.isNotEmpty
                                    ? FadeInImage(
                                  placeholder: const AssetImage("assets/images/user-profile.png"),
                                  image: NetworkImage(
                                    '$imageUrl${getProfileModel.data!.profilePic}',
                                  ),
                                  fit: BoxFit.cover,
                                )
                                    : Image.asset(
                                  "assets/images/user-profile.png", // Asset fallback image
                                  fit: BoxFit.cover,
                                ),
                                // child: FadeInImage(
                                //   placeholder: const AssetImage(
                                //     "assets/images/user-profile.png",
                                //   ),
                                //   image: NetworkImage(
                                //     '$imageUrl${getProfileModel.data!.profilePic}',
                                //   ),
                                //   fit: BoxFit.cover,
                                // ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Text(
                          '${getProfileModel.data!.firstName} ${getProfileModel.data!.lastName}',
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
                          child: Container(
                            width: size.width,
                            decoration: BoxDecoration(
                              color: filledColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 17, left: 20, bottom: 17),
                              child: Text(
                                '${getProfileModel.data!.firstName}',
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 20),
                        //   child: TextFormField(
                        //     readOnly: true,
                        //     decoration: InputDecoration(
                        //       filled: true,
                        //       fillColor: filledColor,
                        //       errorStyle: TextStyle(
                        //         color: redColor,
                        //         fontSize: 10,
                        //         fontFamily: 'Inter-Bold',
                        //       ),
                        //       border: const OutlineInputBorder(
                        //         borderRadius: BorderRadius.all(
                        //           Radius.circular(10),
                        //         ),
                        //         borderSide: BorderSide.none,
                        //       ),
                        //       enabledBorder: const OutlineInputBorder(
                        //         borderRadius: BorderRadius.all(
                        //           Radius.circular(10),
                        //         ),
                        //         borderSide: BorderSide.none,
                        //       ),
                        //       focusedBorder: const OutlineInputBorder(
                        //         borderRadius: BorderRadius.all(
                        //           Radius.circular(10),
                        //         ),
                        //         borderSide: BorderSide.none,
                        //       ),
                        //       focusedErrorBorder: const OutlineInputBorder(
                        //         borderRadius: BorderRadius.all(
                        //           Radius.circular(10),
                        //         ),
                        //         borderSide: BorderSide.none,
                        //       ),
                        //       errorBorder: OutlineInputBorder(
                        //         borderRadius: const BorderRadius.all(
                        //           Radius.circular(10),
                        //         ),
                        //         borderSide: BorderSide(
                        //           color: redColor,
                        //           width: 1,
                        //         ),
                        //       ),
                        //       contentPadding: const EdgeInsets.symmetric(
                        //           horizontal: 20, vertical: 10),
                        //       hintText: "${getProfileModel.data!.firstName}",
                        //       hintStyle: TextStyle(
                        //         color: hintColor,
                        //         fontSize: 12,
                        //         fontFamily: 'Inter-Light',
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: size.height * 0.02),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: size.width,
                            decoration: BoxDecoration(
                              color: filledColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 17, left: 20, bottom: 17),
                              child: Text(
                                '${getProfileModel.data!.lastName}',
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: size.width,
                            decoration: BoxDecoration(
                              color: filledColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 17, left: 20, bottom: 17),
                              child: Text(
                                '${getProfileModel.data!.phone}',
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: size.width,
                            decoration: BoxDecoration(
                              color: filledColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 17, left: 20, bottom: 17),
                              child: Text(
                                '${getProfileModel.data!.email}',
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    color: transparentColor,
                    child: Lottie.asset(
                      'assets/images/loading-icon.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// // ignore_for_file: avoid_print

// import 'package:lottie/lottie.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:deliver_client/models/get_profile_model.dart';
// import 'package:deliver_client/screens/home/home_page_screen.dart';
// import 'package:deliver_client/screens/home/drawer/profile/edit_profile_screen.dart';
// import 'package:deliver_client/screens/home/drawer/profile/profile_setting_screen.dart';

// String? userId;

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   bool isLoading = false;

//   GetProfileModel getProfileModel = GetProfileModel();

//   getProfile() async {
//     try {
//       SharedPreferences sharedPref = await SharedPreferences.getInstance();
//       userId = sharedPref.getString('userId');
//       String apiUrl = "$baseUrl/get_profile_customers";
//       debugPrint("apiUrl: $apiUrl");
//       debugPrint("userId: $userId");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "users_customers_id": userId,
//         },
//       );
//       final responseString = response.body;
//       debugPrint("response: $responseString");
//       debugPrint("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         getProfileModel = getProfileModelFromJson(responseString);
//         setState(() {});
//         debugPrint('getProfileModel status: ${getProfileModel.status}');
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getProfile();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const HomePageScreen()),
//             (Route<dynamic> route) => false);
//         return false;
//       },
//       child: GestureDetector(
//         onTap: () {
//           FocusManager.instance.primaryFocus?.unfocus();
//         },
//         child: Scaffold(
//           backgroundColor: bgColor,
//           appBar: AppBar(
//             backgroundColor: bgColor,
//             elevation: 0,
//             scrolledUnderElevation: 0,
//             leading: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 20),
//                 child: SvgPicture.asset(
//                   'assets/images/back-icon.svg',
//                   width: 22,
//                   height: 22,
//                   fit: BoxFit.scaleDown,
//                 ),
//               ),
//             ),
//             title: Text(
//               "Profile",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: blackColor,
//                 fontSize: 20,
//                 fontFamily: 'Syne-Bold',
//               ),
//             ),
//             centerTitle: true,
//             actions: [
//               GestureDetector(
//                 onTap: () {
//                   if (getProfileModel.data != null) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ProfileSettingScreen(
//                           firstName: getProfileModel.data?.firstName,
//                           lastName: getProfileModel.data?.lastName,
//                           image: getProfileModel.data?.profilePic,
//                         ),
//                       ),
//                     );
//                   }
//                 },
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 20),
//                   child: SvgPicture.asset(
//                     'assets/images/setting-profile-icon.svg',
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           body: getProfileModel.data != null
//               ? Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Container(
//                           color: transparentColor,
//                           width: size.width,
//                           height: size.height * 0.23,
//                           child: Stack(
//                             children: [
//                               Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(top: 20),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(10),
//                                     child: Container(
//                                       width: size.width * 0.4,
//                                       height: size.height * 0.2,
//                                       decoration: BoxDecoration(
//                                         color: transparentColor,
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: FadeInImage(
//                                         placeholder: const AssetImage(
//                                           "assets/images/user-profile.png",
//                                         ),
//                                         image: NetworkImage(
//                                           '$imageUrl${getProfileModel.data!.profilePic}',
//                                         ),
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 right: 0,
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     if (getProfileModel.data != null) {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               EditProfileScreen(
//                                             firstName:
//                                                 getProfileModel.data!.firstName,
//                                             lastName:
//                                                 getProfileModel.data!.lastName,
//                                             image: getProfileModel
//                                                 .data!.profilePic,
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                   },
//                                   child: SvgPicture.asset(
//                                     'assets/images/edit-profile-icon.svg',
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                         Text(
//                           '${getProfileModel.data!.firstName} ${getProfileModel.data!.lastName}',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: drawerTextColor,
//                             fontSize: 17,
//                             fontFamily: 'Syne-Bold',
//                           ),
//                         ),
//                         SizedBox(height: size.height * 0.04),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Container(
//                             width: size.width,
//                             height: size.height * 0.06,
//                             decoration: BoxDecoration(
//                               color: filledColor,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 15, left: 20),
//                               child: Text(
//                                 '${getProfileModel.data!.firstName}',
//                                 style: TextStyle(
//                                   color: hintColor,
//                                   fontSize: 12,
//                                   fontFamily: 'Inter-Light',
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Container(
//                             width: size.width,
//                             height: size.height * 0.06,
//                             decoration: BoxDecoration(
//                               color: filledColor,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 15, left: 20),
//                               child: Text(
//                                 '${getProfileModel.data!.lastName}',
//                                 style: TextStyle(
//                                   color: hintColor,
//                                   fontSize: 12,
//                                   fontFamily: 'Inter-Light',
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Container(
//                             width: size.width,
//                             height: size.height * 0.06,
//                             decoration: BoxDecoration(
//                               color: filledColor,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 15, left: 20),
//                               child: Text(
//                                 '${getProfileModel.data!.phone}',
//                                 style: TextStyle(
//                                   color: hintColor,
//                                   fontSize: 12,
//                                   fontFamily: 'Inter-Light',
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Container(
//                             width: size.width,
//                             height: size.height * 0.06,
//                             decoration: BoxDecoration(
//                               color: filledColor,
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.only(top: 15, left: 20),
//                               child: Text(
//                                 '${getProfileModel.data!.email}',
//                                 style: TextStyle(
//                                   color: hintColor,
//                                   fontSize: 12,
//                                   fontFamily: 'Inter-Light',
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                       ],
//                     ),
//                   ),
//                 )
//               : Center(
//                   child: Container(
//                     width: 100,
//                     height: 100,
//                     color: transparentColor,
//                     child: Lottie.asset(
//                       'assets/images/loading-icon.json',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }
