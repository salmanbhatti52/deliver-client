// // ignore_for_file: avoid_print, use_build_context_synchronously

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/models/signup_model.dart';
// import 'package:deliver_client/screens/login/login_screen.dart';
// import 'package:fl_country_code_picker/fl_country_code_picker.dart';
// import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
// import 'package:deliver_client/screens/signup/verify_phone_signup_screen.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   TextEditingController firstNameController = TextEditingController();
//   TextEditingController lastNameController = TextEditingController();
//   TextEditingController contactNumberController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController confirmPasswordController = TextEditingController();
//   final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
//   final countryPicker = const FlCountryCodePicker();
//   CountryCode? countryCode =
//       const CountryCode(name: 'Nigeria', code: 'NG', dialCode: '+234');

//   bool _obscure = true;
//   bool _obscure2 = true;
//   bool status = false;
//   bool checkmark = false;
//   bool isLoading = false;

//   SignUpModel signUpModel = SignUpModel();

//   userSignUp() async {
//     try {
//       String apiUrl = "$baseUrl/signup_customers";
//       print("apiUrl: $apiUrl");
//       print("firstName: ${firstNameController.text}");
//       print("lastName: ${lastNameController.text}");
//       print(
//           "contactNumber: ${countryCode!.dialCode + contactNumberController.text}");
//       print("email: ${emailController.text}");
//       print("password: ${passwordController.text}");
//       print("confirmPassword: ${confirmPasswordController.text}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "one_signal_id": "123",
//           "first_name": firstNameController.text,
//           "last_name": lastNameController.text,
//           "phone": countryCode!.dialCode + contactNumberController.text,
//           "email": emailController.text,
//           "password": passwordController.text,
//           "confirm_password": confirmPasswordController.text,
//           "account_type": "SignupWithApp"
//         },
//       );
//       final responseString = response.body;
//       print("response: $responseString");
//       print("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         signUpModel = signUpModelFromJson(responseString);
//         setState(() {});
//         print('signUpModel status: ${signUpModel.status}');
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
//         body: SingleChildScrollView(
//           child: Form(
//             key: signUpFormKey,
//             child: Column(
//               children: [
//                 SizedBox(height: size.height * 0.04),
//                 Center(
//                   child: SvgPicture.asset('assets/images/logo-small-icon.svg'),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Text(
//                   "Register".toUpperCase(),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: orangeColor,
//                     fontSize: 30,
//                     fontFamily: 'Syne-Bold',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: TextFormField(
//                     controller: firstNameController,
//                     cursorColor: orangeColor,
//                     keyboardType: TextInputType.text,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'First Name is required!';
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
//                       hintText: "First Name",
//                       hintStyle: TextStyle(
//                         color: hintColor,
//                         fontSize: 12,
//                         fontFamily: 'Inter-Light',
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: TextFormField(
//                     controller: lastNameController,
//                     cursorColor: orangeColor,
//                     keyboardType: TextInputType.text,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Last Name is required!';
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
//                       hintText: "Last Name",
//                       hintStyle: TextStyle(
//                         color: hintColor,
//                         fontSize: 12,
//                         fontFamily: 'Inter-Light',
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: TextFormField(
//                     controller: contactNumberController,
//                     cursorColor: orangeColor,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(15),
//                     ],
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Contact Number is required!';
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
//                       hintText: "Contact Number",
//                       hintStyle: TextStyle(
//                         color: hintColor,
//                         fontSize: 12,
//                         fontFamily: 'Inter-Light',
//                       ),
//                       prefixIcon: GestureDetector(
//                         onTap: () async {
//                           final code =
//                               await countryPicker.showPicker(context: context);
//                           setState(() {
//                             countryCode = code;
//                           });
//                           print('countryName: ${countryCode!.name}');
//                           print('countryCode: ${countryCode!.code}');
//                           print('countryDialCode: ${countryCode!.dialCode}');
//                         },
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.only(left: 20),
//                               child: Container(
//                                 child: countryCode != null
//                                     ? Image.asset(
//                                         countryCode!.flagUri,
//                                         package: countryCode!.flagImagePackage,
//                                         width: 25,
//                                         height: 20,
//                                       )
//                                     : SvgPicture.asset(
//                                         'assets/images/flag-icon.svg',
//                                       ),
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.only(left: 10),
//                               child: Text(
//                                 countryCode?.dialCode ?? "+234",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: hintColor,
//                                   fontSize: 12,
//                                   fontFamily: 'Inter-Light',
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: size.width * 0.02),
//                             Text(
//                               '|',
//                               style: TextStyle(
//                                 color: hintColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Inter-SemiBold',
//                               ),
//                             ),
//                             SizedBox(width: size.width * 0.02),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.02),
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
//                 SizedBox(height: size.height * 0.02),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: TextFormField(
//                     controller: passwordController,
//                     cursorColor: orangeColor,
//                     obscureText: _obscure,
//                     keyboardType: TextInputType.visiblePassword,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Password is required!';
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
//                       hintText: "Password",
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
//                         return 'Confirm Password is required!';
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
//                 SizedBox(height: size.height * 0.02),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: Row(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             checkmark = true;
//                           });
//                         },
//                         child: checkmark == true
//                             ? GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     checkmark = false;
//                                   });
//                                 },
//                                 child: SvgPicture.asset(
//                                   'assets/images/checkmark-icon.svg',
//                                 ),
//                               )
//                             : SvgPicture.asset(
//                                 'assets/images/uncheckmark-icon.svg',
//                               ),
//                       ),
//                       SizedBox(width: size.width * 0.03),
//                       RichText(
//                         overflow: TextOverflow.clip,
//                         textAlign: TextAlign.left,
//                         text: TextSpan(
//                           text: "I agree to the  ",
//                           style: TextStyle(
//                             color: blackColor,
//                             fontSize: 12,
//                             fontFamily: 'Syne-Medium',
//                           ),
//                           children: [
//                             TextSpan(
//                               text: 'Terms and Conditions',
//                               style: TextStyle(
//                                 color: blackColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Syne-Medium',
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                             TextSpan(
//                               text: ' and\n',
//                               style: TextStyle(
//                                 color: blackColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Syne-Medium',
//                               ),
//                             ),
//                             TextSpan(
//                               text: 'Privacy Policy',
//                               style: TextStyle(
//                                 color: blackColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Syne-Medium',
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                             TextSpan(
//                               text: '.',
//                               style: TextStyle(
//                                 color: blackColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Syne-Medium',
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.05),
//                 GestureDetector(
//                   onTap: () async {
//                     if (signUpFormKey.currentState!.validate()) {
//                       setState(() {
//                         isLoading = true;
//                       });
//                       if (checkmark == true) {
//                         await userSignUp();
//                         if (signUpModel.status == 'success') {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => VerifyPhoneSignUpScreen(
//                                 phoneNumber: countryCode!.dialCode +
//                                     contactNumberController.text,
//                               ),
//                             ),
//                           );

//                           setState(() {
//                             isLoading = false;
//                           });
//                         }
//                         if (signUpModel.status != 'success') {
//                           final snackBar = SnackBar(
//                             elevation: 0,
//                             behavior: SnackBarBehavior.floating,
//                             dismissDirection: DismissDirection.horizontal,
//                             backgroundColor: transparentColor,
//                             content: AwesomeSnackbarContent(
//                               title: 'Oh Snap!',
//                               message: "${signUpModel.message}",
//                               contentType: ContentType.failure,
//                             ),
//                           );
//                           ScaffoldMessenger.of(context)
//                             ..hideCurrentSnackBar()
//                             ..showSnackBar(snackBar);
//                           setState(() {
//                             isLoading = false;
//                           });
//                         }
//                       } else {
//                         final snackBar = SnackBar(
//                           elevation: 0,
//                           behavior: SnackBarBehavior.floating,
//                           dismissDirection: DismissDirection.horizontal,
//                           backgroundColor: transparentColor,
//                           content: AwesomeSnackbarContent(
//                             title: 'Oh Snap!',
//                             message:
//                                 "Please read and accept the terms and conditions and privacy policy",
//                             contentType: ContentType.warning,
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
//                       : buttonGradient("REGISTER", context),
//                 ),
//                 SizedBox(height: size.height * 0.02),
//                 Container(
//                   width: size.width,
//                   decoration: BoxDecoration(
//                     color: whiteColor,
//                     border: Border.all(color: borderColor, width: 1),
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(40),
//                       topRight: Radius.circular(40),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       SizedBox(height: size.height * 0.02),
//                       const Text(
//                         'OR',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Color(0xFFA3A6AA),
//                           fontSize: 18,
//                           fontFamily: 'Syne-SemiBold',
//                         ),
//                       ),
//                       SizedBox(height: size.height * 0.02),
//                       SvgPicture.asset(
//                         'assets/images/facebook-signup-icon.svg',
//                       ),
//                       SizedBox(height: size.height * 0.01),
//                       SvgPicture.asset(
//                         'assets/images/google-signup-icon.svg',
//                       ),
//                       SizedBox(height: size.height * 0.04),
//                       RichText(
//                         overflow: TextOverflow.clip,
//                         textAlign: TextAlign.center,
//                         text: TextSpan(
//                           text: "Have an account already? ",
//                           style: TextStyle(
//                             color: textHaveAccountColor,
//                             fontSize: 12,
//                             fontFamily: 'Syne-Regular',
//                           ),
//                           children: [
//                             TextSpan(
//                               recognizer: TapGestureRecognizer()
//                                 ..onTap = () {
//                                   // Handle the tap event, e.g., navigate to a new screen
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => const LoginScreen(),
//                                     ),
//                                   );
//                                 },
//                               text: 'Login',
//                               style: TextStyle(
//                                 color: orangeColor,
//                                 fontSize: 14,
//                                 fontFamily: 'Syne-Bold',
//                                 decoration: TextDecoration.underline,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: size.height * 0.02),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
