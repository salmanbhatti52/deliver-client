// // ignore_for_file: use_build_context_synchronously

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/models/send_otp_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:deliver_client/models/update_email_model.dart';
// import 'package:deliver_client/models/update_password_model.dart';
// import 'package:deliver_client/screens/home/home_page_screen.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// import 'package:deliver_client/screens/home/drawer/profile/update_email_otp_screen.dart';

// String? userId;

// class ProfileSettingScreen extends StatefulWidget {
//   final String? firstName;
//   final String? lastName;
//   final String? image;
//   const ProfileSettingScreen(
//       {super.key, this.firstName, this.lastName, this.image});

//   @override
//   State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
// }

// class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
//   TextEditingController oldpasswordController = TextEditingController();
//   TextEditingController newpasswordController = TextEditingController();
//   TextEditingController confirmPasswordController = TextEditingController();
//   TextEditingController currentEmailController = TextEditingController();
//   TextEditingController newEmailController = TextEditingController();
//   final GlobalKey<FormState> passwordSettingFormKey = GlobalKey<FormState>();
//   final GlobalKey<FormState> emailSettingFormKey = GlobalKey<FormState>();

//   bool _obscure = true;
//   bool _obscure2 = true;
//   bool _obscure3 = true;

//   bool isLoadingEmail = false;
//   bool isLoadingPassword = false;

//   UpdatePasswordModel updatePasswordModel = UpdatePasswordModel();

//   updatePassword() async {
//     try {
//       SharedPreferences sharedPref = await SharedPreferences.getInstance();
//       userId = sharedPref.getString('userId');
//       String apiUrl = "$baseUrl/update_password_customers";
//       debugPrint("apiUrl: $apiUrl");
//       debugPrint("userId: $userId");
//       debugPrint("oldPassword: ${oldpasswordController.text}");
//       debugPrint("newPassword: ${newpasswordController.text}");
//       debugPrint("confirmPassword: ${confirmPasswordController.text}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "users_customers_id": userId,
//           "current_password": oldpasswordController.text,
//           "password": newpasswordController.text,
//           "confirm_password": confirmPasswordController.text,
//         },
//       );
//       final responseString = jsonDecode(response.body);
//       debugPrint("response: $responseString");
//       debugPrint("status: ${responseString['status']}");
//       if (responseString["status"] == "success") {
//         updatePasswordModel = updatePasswordModelFromJson(response.body);
//         Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const HomePageScreen()),
//             (Route<dynamic> route) => false);
//         setState(() {
//           isLoadingPassword = false;
//         });
//       } else if (responseString["status"] == "error") {
//         final snackBar = SnackBar(
//           elevation: 0,
//           behavior: SnackBarBehavior.floating,
//           dismissDirection: DismissDirection.horizontal,
//           backgroundColor: transparentColor,
//           content: AwesomeSnackbarContent(
//             title: 'Oh Snap!',
//             message: "${responseString["message"]}",
//             contentType: ContentType.failure,
//           ),
//         );
//         ScaffoldMessenger.of(context)
//           ..hideCurrentSnackBar()
//           ..showSnackBar(snackBar);
//         setState(() {
//           isLoadingPassword = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   UpdateEmailModel updateEmailModel = UpdateEmailModel();

//   updateEmail() async {
//     try {
//       SharedPreferences sharedPref = await SharedPreferences.getInstance();
//       userId = sharedPref.getString('userId');
//       String apiUrl = "$baseUrl/update_email_customers";
//       debugPrint("apiUrl: $apiUrl");
//       debugPrint("userId: $userId");
//       debugPrint("currentEmail: ${currentEmailController.text}");
//       debugPrint("newEmail: ${newEmailController.text}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "users_customers_id": userId,
//           "current_email": currentEmailController.text,
//           "new_email": newEmailController.text
//         },
//       );
//       final responseString = response.body;
//       debugPrint("response: $responseString");
//       debugPrint("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         updateEmailModel = updateEmailModelFromJson(responseString);
//         setState(() {});
//         debugPrint('updateEmailModel status: ${updateEmailModel.status}');
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   SendOtpModel sendOtpModel = SendOtpModel();

//   sendOtp() async {
//     try {
//       String apiUrl = "$baseUrl/verify_email_customers";
//       debugPrint("apiUrl: $apiUrl");
//       debugPrint("email: ${newEmailController.text}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "email": newEmailController.text,
//         },
//       );
//       final responseString = response.body;
//       debugPrint("response: $responseString");
//       debugPrint("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         sendOtpModel = sendOtpModelFromJson(responseString);
//         setState(() {});
//         debugPrint('sendOtpModel status: ${sendOtpModel.status}');
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     debugPrint("firstName: ${widget.firstName}");
//     debugPrint("lastName: ${widget.lastName}");
//     debugPrint("imageUrl: ${widget.image}");
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
//                 key: passwordSettingFormKey,
//                 child: Column(
//                   children: [
//                     SizedBox(height: size.height * 0.03),
//                     SizedBox(
//                       width: size.width * 0.40,
//                       height: size.height * 0.20,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Container(
//                           width: size.width * 0.4,
//                           height: size.height * 0.2,
//                           decoration: BoxDecoration(
//                             color: transparentColor,
//                           ),
//                           child: FadeInImage(
//                             placeholder: const AssetImage(
//                               "assets/images/user-profile.png",
//                             ),
//                             image: NetworkImage(
//                               '$imageUrl${widget.image}',
//                             ),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
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
//                     SizedBox(height: size.height * 0.04),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Change Password',
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                           color: drawerTextColor,
//                           fontSize: 16,
//                           fontFamily: 'Syne-Bold',
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.03),
//                     TextFormField(
//                       controller: oldpasswordController,
//                       cursorColor: orangeColor,
//                       obscureText: _obscure,
//                       keyboardType: TextInputType.visiblePassword,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Old Password is required!';
//                         }
//                         return null;
//                       },
//                       style: TextStyle(
//                         color: blackColor,
//                         fontSize: 14,
//                         fontFamily: 'Inter-Regular',
//                       ),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: filledColor,
//                         errorStyle: TextStyle(
//                           color: redColor,
//                           fontSize: 10,
//                           fontFamily: 'Inter-Bold',
//                         ),
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         errorBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide(
//                             color: redColor,
//                             width: 1,
//                           ),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 10),
//                         hintText: "Old Password",
//                         hintStyle: TextStyle(
//                           color: hintColor,
//                           fontSize: 12,
//                           fontFamily: 'Inter-Light',
//                         ),
//                         suffixIcon: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _obscure = !_obscure;
//                             });
//                           },
//                           child: _obscure
//                               ? Container(
//                                   color: transparentColor,
//                                   child: SvgPicture.asset(
//                                     'assets/images/show-password-icon.svg',
//                                     width: 15,
//                                     height: 15,
//                                     fit: BoxFit.scaleDown,
//                                   ),
//                                 )
//                               : Container(
//                                   color: transparentColor,
//                                   child: SvgPicture.asset(
//                                     'assets/images/hide-password-icon.svg',
//                                     width: 15,
//                                     height: 15,
//                                     fit: BoxFit.scaleDown,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     TextFormField(
//                       controller: newpasswordController,
//                       cursorColor: orangeColor,
//                       obscureText: _obscure2,
//                       keyboardType: TextInputType.visiblePassword,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'New Password is required!';
//                         }
//                         return null;
//                       },
//                       style: TextStyle(
//                         color: blackColor,
//                         fontSize: 14,
//                         fontFamily: 'Inter-Regular',
//                       ),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: filledColor,
//                         errorStyle: TextStyle(
//                           color: redColor,
//                           fontSize: 10,
//                           fontFamily: 'Inter-Bold',
//                         ),
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         errorBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide(
//                             color: redColor,
//                             width: 1,
//                           ),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 10),
//                         hintText: "New Password",
//                         hintStyle: TextStyle(
//                           color: hintColor,
//                           fontSize: 12,
//                           fontFamily: 'Inter-Light',
//                         ),
//                         suffixIcon: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _obscure2 = !_obscure2;
//                             });
//                           },
//                           child: _obscure2
//                               ? Container(
//                                   color: transparentColor,
//                                   child: SvgPicture.asset(
//                                     'assets/images/show-password-icon.svg',
//                                     width: 15,
//                                     height: 15,
//                                     fit: BoxFit.scaleDown,
//                                   ),
//                                 )
//                               : Container(
//                                   color: transparentColor,
//                                   child: SvgPicture.asset(
//                                     'assets/images/hide-password-icon.svg',
//                                     width: 15,
//                                     height: 15,
//                                     fit: BoxFit.scaleDown,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.02),
//                     TextFormField(
//                       controller: confirmPasswordController,
//                       cursorColor: orangeColor,
//                       obscureText: _obscure3,
//                       keyboardType: TextInputType.visiblePassword,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Confirm Password is required!';
//                         }
//                         return null;
//                       },
//                       style: TextStyle(
//                         color: blackColor,
//                         fontSize: 14,
//                         fontFamily: 'Inter-Regular',
//                       ),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: filledColor,
//                         errorStyle: TextStyle(
//                           color: redColor,
//                           fontSize: 10,
//                           fontFamily: 'Inter-Bold',
//                         ),
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         errorBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide(
//                             color: redColor,
//                             width: 1,
//                           ),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 10),
//                         hintText: "Confirm Password",
//                         hintStyle: TextStyle(
//                           color: hintColor,
//                           fontSize: 12,
//                           fontFamily: 'Inter-Light',
//                         ),
//                         suffixIcon: GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               _obscure3 = !_obscure3;
//                             });
//                           },
//                           child: _obscure3
//                               ? Container(
//                                   color: transparentColor,
//                                   child: SvgPicture.asset(
//                                     'assets/images/show-password-icon.svg',
//                                     width: 15,
//                                     height: 15,
//                                     fit: BoxFit.scaleDown,
//                                   ),
//                                 )
//                               : Container(
//                                   color: transparentColor,
//                                   child: SvgPicture.asset(
//                                     'assets/images/hide-password-icon.svg',
//                                     width: 15,
//                                     height: 15,
//                                     fit: BoxFit.scaleDown,
//                                   ),
//                                 ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.03),
//                     GestureDetector(
//                       onTap: () async {
//                         if (passwordSettingFormKey.currentState!.validate()) {
//                           setState(() {
//                             isLoadingPassword = true;
//                           });
//                           await updatePassword();
//                           setState(() {
//                             isLoadingPassword = false;
//                           });
//                         }
//                       },
//                       child: isLoadingPassword
//                           ? buttonGradientWithLoader("Please Wait...", context)
//                           : buttonGradient("UPDATE", context),
//                     ),
//                     SizedBox(height: size.height * 0.04),
//                     Form(
//                       key: emailSettingFormKey,
//                       child: Column(
//                         children: [
//                           Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               'Change Email',
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: drawerTextColor,
//                                 fontSize: 16,
//                                 fontFamily: 'Syne-Bold',
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: size.height * 0.03),
//                           TextFormField(
//                             controller: currentEmailController,
//                             cursorColor: orangeColor,
//                             keyboardType: TextInputType.emailAddress,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Current Email is required!';
//                               }
//                               return null;
//                             },
//                             style: TextStyle(
//                               color: blackColor,
//                               fontSize: 14,
//                               fontFamily: 'Inter-Regular',
//                             ),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: filledColor,
//                               errorStyle: TextStyle(
//                                 color: redColor,
//                                 fontSize: 10,
//                                 fontFamily: 'Inter-Bold',
//                               ),
//                               border: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               enabledBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               focusedBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               focusedErrorBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               errorBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide(
//                                   color: redColor,
//                                   width: 1,
//                                 ),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 10),
//                               hintText: "Enter Current Email",
//                               hintStyle: TextStyle(
//                                 color: hintColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Inter-Light',
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: size.height * 0.02),
//                           TextFormField(
//                             controller: newEmailController,
//                             cursorColor: orangeColor,
//                             keyboardType: TextInputType.emailAddress,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'New Email is required!';
//                               }
//                               return null;
//                             },
//                             style: TextStyle(
//                               color: blackColor,
//                               fontSize: 14,
//                               fontFamily: 'Inter-Regular',
//                             ),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: filledColor,
//                               errorStyle: TextStyle(
//                                 color: redColor,
//                                 fontSize: 10,
//                                 fontFamily: 'Inter-Bold',
//                               ),
//                               border: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               enabledBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               focusedBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               focusedErrorBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               errorBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide(
//                                   color: redColor,
//                                   width: 1,
//                                 ),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 10),
//                               hintText: "Enter New Email",
//                               hintStyle: TextStyle(
//                                 color: hintColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Inter-Light',
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: size.height * 0.03),
//                           GestureDetector(
//                             onTap: () async {
//                               if (emailSettingFormKey.currentState!
//                                   .validate()) {
//                                 setState(() {
//                                   isLoadingEmail = true;
//                                 });
//                                 await updateEmail();
//                                 if (updateEmailModel.status == "success") {
//                                   await sendOtp();
//                                   final snackBar = SnackBar(
//                                     elevation: 0,
//                                     behavior: SnackBarBehavior.floating,
//                                     dismissDirection:
//                                         DismissDirection.horizontal,
//                                     backgroundColor: transparentColor,
//                                     content: AwesomeSnackbarContent(
//                                       title: 'Hi There!',
//                                       message: "${sendOtpModel.message}",
//                                       contentType: ContentType.help,
//                                     ),
//                                   );
//                                   ScaffoldMessenger.of(context)
//                                     ..hideCurrentSnackBar()
//                                     ..showSnackBar(snackBar);
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           UpdateEmailOtpScreen(
//                                         email: newEmailController.text,
//                                       ),
//                                     ),
//                                   );
//                                   setState(() {
//                                     isLoadingEmail = false;
//                                   });
//                                 } else if (updateEmailModel.status == "error") {
//                                   final snackBar = SnackBar(
//                                     elevation: 0,
//                                     behavior: SnackBarBehavior.floating,
//                                     dismissDirection:
//                                         DismissDirection.horizontal,
//                                     backgroundColor: transparentColor,
//                                     content: AwesomeSnackbarContent(
//                                       title: 'Oh Snap!',
//                                       message: "${updateEmailModel.message}",
//                                       contentType: ContentType.failure,
//                                     ),
//                                   );
//                                   ScaffoldMessenger.of(context)
//                                     ..hideCurrentSnackBar()
//                                     ..showSnackBar(snackBar);
//                                   setState(() {
//                                     isLoadingEmail = false;
//                                   });
//                                 }
//                                 setState(() {
//                                   isLoadingEmail = false;
//                                 });
//                               }
//                             },
//                             child: isLoadingEmail
//                                 ? buttonGradientWithLoader(
//                                     "Please Wait...", context)
//                                 : buttonGradient("UPDATE", context),
//                           ),
//                         ],
//                       ),
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
