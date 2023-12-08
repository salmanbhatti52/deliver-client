// // ignore_for_file: avoid_print, use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/screens/login/login_screen.dart';
// import 'package:deliver_client/models/reset_password_model.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

// class CreateNewPasswordScreen extends StatefulWidget {
//   final String? email;
//   final String? otp;
//   const CreateNewPasswordScreen({super.key, this.email, this.otp});

//   @override
//   State<CreateNewPasswordScreen> createState() =>
//       _CreateNewPasswordScreenState();
// }

// class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
//   TextEditingController newpasswordController = TextEditingController();
//   TextEditingController confirmPasswordController = TextEditingController();
//   final GlobalKey<FormState> createNewPasswordFormKey = GlobalKey<FormState>();

//   bool _obscure = true;
//   bool _obscure2 = true;
//   bool isLoading = false;

//   ResetPasswordModel resetPasswordModel = ResetPasswordModel();

//   resetPassword() async {
//     try {
//       String apiUrl = "$baseUrl/reset_password_customers";
//       print("apiUrl: $apiUrl");
//       print("email: ${widget.email}");
//       print("otp: ${widget.otp}");
//       print("password: ${newpasswordController.text}");
//       print("confirmPassword: ${confirmPasswordController.text}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "email": widget.email,
//           "otp": widget.otp,
//           "password": newpasswordController.text,
//           "confirm_password": confirmPasswordController.text,
//         },
//       );
//       final responseString = response.body;
//       print("response: $responseString");
//       print("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         resetPasswordModel = resetPasswordModelFromJson(responseString);
//         setState(() {});
//         print('resetPasswordModel status: ${resetPasswordModel.status}');
//       }
//     } catch (e) {
//       print('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     print("initState Email: ${widget.email}");
//     print("initState OTP: ${widget.otp}");
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
//         ),
//         body: SingleChildScrollView(
//           child: Form(
//             key: createNewPasswordFormKey,
//             child: Column(
//               children: [
//                 SizedBox(height: size.height * 0.08),
//                 Center(
//                   child: Image.asset(
//                     'assets/images/logo-big-icon.png',
//                     width: 300,
//                     height: 125,
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.06),
//                 Text(
//                   "New\nPassword?".toUpperCase(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: orangeColor,
//                     fontSize: 30,
//                     fontFamily: 'Syne-SemiBold',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   "Enter new password",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 16,
//                     fontFamily: 'Syne-Regular',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.04),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: TextFormField(
//                     controller: newpasswordController,
//                     cursorColor: orangeColor,
//                     obscureText: _obscure,
//                     keyboardType: TextInputType.visiblePassword,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'New Password field is required!';
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
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10),
//                       hintText: "New Password",
//                       hintStyle: TextStyle(
//                         color: hintColor,
//                         fontSize: 12,
//                         fontFamily: 'Inter-Light',
//                       ),
//                       suffixIcon: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _obscure = !_obscure;
//                           });
//                         },
//                         child: _obscure
//                             ? Container(
//                                 color: transparentColor,
//                                 child: SvgPicture.asset(
//                                   'assets/images/show-password-icon.svg',
//                                   width: 15,
//                                   height: 15,
//                                   fit: BoxFit.scaleDown,
//                                 ),
//                               )
//                             : Container(
//                                 color: transparentColor,
//                                 child: SvgPicture.asset(
//                                   'assets/images/hide-password-icon.svg',
//                                   width: 15,
//                                   height: 15,
//                                   fit: BoxFit.scaleDown,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: TextFormField(
//                     controller: confirmPasswordController,
//                     cursorColor: orangeColor,
//                     obscureText: _obscure2,
//                     keyboardType: TextInputType.visiblePassword,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Confirm Password field is required!';
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
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10),
//                       hintText: "Confirm Password",
//                       hintStyle: TextStyle(
//                         color: hintColor,
//                         fontSize: 12,
//                         fontFamily: 'Inter-Light',
//                       ),
//                       suffixIcon: GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _obscure2 = !_obscure2;
//                           });
//                         },
//                         child: _obscure2
//                             ? Container(
//                                 color: transparentColor,
//                                 child: SvgPicture.asset(
//                                   'assets/images/show-password-icon.svg',
//                                   width: 15,
//                                   height: 15,
//                                   fit: BoxFit.scaleDown,
//                                 ),
//                               )
//                             : Container(
//                                 color: transparentColor,
//                                 child: SvgPicture.asset(
//                                   'assets/images/hide-password-icon.svg',
//                                   width: 15,
//                                   height: 15,
//                                   fit: BoxFit.scaleDown,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.06),
//                 GestureDetector(
//                   onTap: () async {
//                     if (createNewPasswordFormKey.currentState!.validate()) {
//                       setState(() {
//                         isLoading = true;
//                       });
//                       await resetPassword();
//                       if (resetPasswordModel.status == 'success') {
//                         final snackBar = SnackBar(
//                           elevation: 0,
//                           behavior: SnackBarBehavior.floating,
//                           dismissDirection: DismissDirection.horizontal,
//                           backgroundColor: transparentColor,
//                           content: AwesomeSnackbarContent(
//                             title: 'Hi There!',
//                             message: "${resetPasswordModel.message}",
//                             contentType: ContentType.success,
//                           ),
//                         );
//                         ScaffoldMessenger.of(context)
//                           ..hideCurrentSnackBar()
//                           ..showSnackBar(snackBar);
//                         Navigator.of(context).pushAndRemoveUntil(
//                             MaterialPageRoute(
//                                 builder: (context) => const LoginScreen()),
//                             (Route<dynamic> route) => false);
//                         setState(() {
//                           isLoading = false;
//                         });
//                       }
//                       if (resetPasswordModel.status != 'success') {
//                         final snackBar = SnackBar(
//                           elevation: 0,
//                           behavior: SnackBarBehavior.floating,
//                           dismissDirection: DismissDirection.horizontal,
//                           backgroundColor: transparentColor,
//                           content: AwesomeSnackbarContent(
//                             title: 'Oh Snap!',
//                             message: "${resetPasswordModel.message}",
//                             contentType: ContentType.failure,
//                           ),
//                         );
//                         ScaffoldMessenger.of(context)
//                           ..hideCurrentSnackBar()
//                           ..showSnackBar(snackBar);
//                         setState(() {
//                           isLoading = false;
//                         });
//                       }
//                     }
//                   },
//                   child: isLoading
//                       ? buttonGradientWithLoader("Please Wait...", context)
//                       : buttonGradient("RESET", context),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
