// // ignore_for_file: avoid_print, use_build_context_synchronously

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/models/forgot_password_model.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// import 'package:deliver_client/screens/login/verify_otp_password_screen.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   TextEditingController emailController = TextEditingController();
//   final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
//   bool isLoading = false;

//   ForgotPasswordModel forgotPasswordModel = ForgotPasswordModel();

//   forgotPassword() async {
//     try {
//       String apiUrl = "$baseUrl/forgot_password_customers";
//       print("apiUrl: $apiUrl");
//       print("email: ${emailController.text}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "email": emailController.text,
//         },
//       );
//       final responseString = jsonDecode(response.body);
//       print("response: $responseString");
//       print("status: ${responseString['status']}");
//       if (responseString["status"] == "success") {
//         forgotPasswordModel = forgotPasswordModelFromJson(response.body);
//         final snackBar = SnackBar(
//           elevation: 0,
//           behavior: SnackBarBehavior.floating,
//           dismissDirection: DismissDirection.horizontal,
//           backgroundColor: transparentColor,
//           content: AwesomeSnackbarContent(
//             title: 'Hi There!',
//             message: "${forgotPasswordModel.message}",
//             contentType: ContentType.help,
//           ),
//         );
//         ScaffoldMessenger.of(context)
//           ..hideCurrentSnackBar()
//           ..showSnackBar(snackBar);
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => VerifyOTPPasswordScreen(
//               email: emailController.text,
//             ),
//           ),
//         );
//         setState(() {
//           isLoading = false;
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
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
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
//             key: forgotPasswordFormKey,
//             child: Column(
//               children: [
//                 SizedBox(height: size.height * 0.08),
//                 Center(
//                   child: SvgPicture.asset(
//                     'assets/images/logo-big-icon.svg',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.06),
//                 Text(
//                   "Forgot\nPassword?".toUpperCase(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: orangeColor,
//                     fontSize: 30,
//                     fontFamily: 'Syne-SemiBold',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   "Enter your account email.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 16,
//                     fontFamily: 'Syne-Regular',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.1),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: TextFormField(
//                     controller: emailController,
//                     cursorColor: orangeColor,
//                     keyboardType: TextInputType.emailAddress,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Email ID is required!';
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
//                       hintText: "Email ID",
//                       hintStyle: TextStyle(
//                         color: hintColor,
//                         fontSize: 12,
//                         fontFamily: 'Inter-Light',
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.08),
//                 GestureDetector(
//                   onTap: () async {
//                     if (forgotPasswordFormKey.currentState!.validate()) {
//                       setState(() {
//                         isLoading = true;
//                       });
//                       await forgotPassword();
//                       setState(() {
//                         isLoading = false;
//                       });
//                     }
//                   },
//                   child: isLoading
//                       ? buttonGradientWithLoader("Please Wait...", context)
//                       : buttonGradient("NEXT", context),
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
