// ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/screens/search_riders_screen.dart';

// class PayViaBankScreen extends StatefulWidget {
//   final Map? singleData;
//   const PayViaBankScreen({super.key, this.singleData});

//   @override
//   State<PayViaBankScreen> createState() => _PayViaBankScreenState();
// }

// class _PayViaBankScreenState extends State<PayViaBankScreen> {
//   TextEditingController accountHolderNameController = TextEditingController();
//   TextEditingController accountNumberController = TextEditingController();
//   TextEditingController bankController = TextEditingController();
//   TextEditingController routingNumberController = TextEditingController();
//   final GlobalKey<FormState> paymentViaBankFormKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     print("mapData: ${widget.singleData}");
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
//             "Payment Through Bank",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: blackColor,
//               fontSize: 18,
//               fontFamily: 'Syne-Bold',
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(height: size.height * 0.03),
//                 Card(
//                   color: whiteColor,
//                   elevation: 5,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: size.height * 0.02),
//                             Text(
//                               "Account Holder Name",
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: blackColor,
//                                 fontSize: 18,
//                                 fontFamily: 'Syne-Bold',
//                               ),
//                             ),
//                             SizedBox(height: size.height * 0.01),
//                             Text(
//                               "2348-XXXX-XXXX-XXX3",
//                               textAlign: TextAlign.left,
//                               style: TextStyle(
//                                 color: textHaveAccountColor,
//                                 fontSize: 16,
//                                 fontFamily: 'Inter-Regular',
//                               ),
//                             ),
//                             SizedBox(height: size.height * 0.02),
//                           ],
//                         ),
//                         SvgPicture.asset('assets/images/delete-icon.svg'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.03),
//                 Text(
//                   "Add a New Account",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 18,
//                     fontFamily: 'Syne-Bold',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.03),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     children: [
//                       SvgPicture.asset('assets/images/lock-icon.svg'),
//                       SizedBox(width: size.width * 0.02),
//                       Text(
//                         "Secure Payments",
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                           color: orangeColor,
//                           fontSize: 12,
//                           fontFamily: 'Inter-Regular',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.03),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: TextFormField(
//                     controller: accountHolderNameController,
//                     cursorColor: orangeColor,
//                     keyboardType: TextInputType.text,
//                     // validator: (value) {
//                     //   if (value == null || value.isEmpty) {
//                     //     return 'Account Holder Name field is required!';
//                     //   }
//                     //   return null;
//                     // },
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
//                         fontSize: 12,
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
//                       hintText: "Account Holder Name",
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
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: TextFormField(
//                     controller: accountNumberController,
//                     cursorColor: orangeColor,
//                     keyboardType: TextInputType.text,
//                     // validator: (value) {
//                     //   if (value == null || value.isEmpty) {
//                     //     return 'Account Number field is required!';
//                     //   }
//                     //   return null;
//                     // },
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
//                         fontSize: 12,
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
//                       hintText: "Account Number",
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
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         color: transparentColor,
//                         width: size.width * 0.38,
//                         child: TextFormField(
//                           controller: bankController,
//                           cursorColor: orangeColor,
//                           keyboardType: TextInputType.text,
//                           // validator: (value) {
//                           //   if (value == null || value.isEmpty) {
//                           //     return 'Bank field is required!';
//                           //   }
//                           //   return null;
//                           // },
//                           style: TextStyle(
//                             color: blackColor,
//                             fontSize: 14,
//                             fontFamily: 'Inter-Regular',
//                           ),
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: filledColor,
//                             errorStyle: TextStyle(
//                               color: redColor,
//                               fontSize: 12,
//                               fontFamily: 'Inter-Bold',
//                             ),
//                             border: const OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             enabledBorder: const OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: const OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedErrorBorder: const OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             errorBorder: OutlineInputBorder(
//                               borderRadius: const BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               borderSide: BorderSide(
//                                 color: redColor,
//                                 width: 1,
//                               ),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 10),
//                             hintText: "Bank",
//                             hintStyle: TextStyle(
//                               color: hintColor,
//                               fontSize: 12,
//                               fontFamily: 'Inter-Light',
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         color: transparentColor,
//                         width: size.width * 0.38,
//                         child: TextFormField(
//                           controller: routingNumberController,
//                           cursorColor: orangeColor,
//                           keyboardType: TextInputType.text,
//                           // validator: (value) {
//                           //   if (value == null || value.isEmpty) {
//                           //     return 'Routing Number field is required!';
//                           //   }
//                           //   return null;
//                           // },
//                           style: TextStyle(
//                             color: blackColor,
//                             fontSize: 14,
//                             fontFamily: 'Inter-Regular',
//                           ),
//                           decoration: InputDecoration(
//                             filled: true,
//                             fillColor: filledColor,
//                             errorStyle: TextStyle(
//                               color: redColor,
//                               fontSize: 12,
//                               fontFamily: 'Inter-Bold',
//                             ),
//                             border: const OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             enabledBorder: const OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedBorder: const OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             focusedErrorBorder: const OutlineInputBorder(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               borderSide: BorderSide.none,
//                             ),
//                             errorBorder: OutlineInputBorder(
//                               borderRadius: const BorderRadius.all(
//                                 Radius.circular(10),
//                               ),
//                               borderSide: BorderSide(
//                                 color: redColor,
//                                 width: 1,
//                               ),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 10),
//                             hintText: "Routing Number",
//                             hintStyle: TextStyle(
//                               color: hintColor,
//                               fontSize: 12,
//                               fontFamily: 'Inter-Light',
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.1),
//                 buttonTransparentGradient('SAVE', context),
//                 SizedBox(height: size.height * 0.135),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => SearchRidersScreen(
//                           singleData: widget.singleData,
//                         ),
//                       ),
//                     );
//                   },
//                   child: buttonGradient('NEXT', context),
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
