// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/widgets/buttons.dart';

// class PayStackScreen extends StatefulWidget {
//   const PayStackScreen({super.key});

//   @override
//   State<PayStackScreen> createState() => _PayStackScreenState();
// }

// class _PayStackScreenState extends State<PayStackScreen> {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   final GlobalKey<FormState> paymentViaWalletFormKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: transparentColor,
//       body: Column(
//         children: [
//           SizedBox(height: size.height * 0.03),
//           Text(
//             "Add a New Account",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: blackColor,
//               fontSize: 18,
//               fontFamily: 'Syne-Bold',
//             ),
//           ),
//           SizedBox(height: size.height * 0.03),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Row(
//               children: [
//                 SvgPicture.asset('assets/images/lock-icon.svg'),
//                 SizedBox(width: size.width * 0.02),
//                 Text(
//                   "Secure Payments",
//                   textAlign: TextAlign.left,
//                   style: TextStyle(
//                     color: orangeColor,
//                     fontSize: 12,
//                     fontFamily: 'Inter-Regular',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: size.height * 0.03),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: TextFormField(
//               controller: emailController,
//               cursorColor: orangeColor,
//               keyboardType: TextInputType.emailAddress,
//               // validator: (value) {
//               //   if (value == null || value.isEmpty) {
//               //     return 'Email field is required!';
//               //   }
//               //   return null;
//               // },
//               style: TextStyle(
//                 color: blackColor,
//                 fontSize: 14,
//                 fontFamily: 'Inter-Regular',
//               ),
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: filledColor,
//                 errorStyle: TextStyle(
//                   color: redColor,
//                   fontSize: 12,
//                   fontFamily: 'Inter-Bold',
//                 ),
//                 border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedErrorBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   borderSide: BorderSide.none,
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   borderSide: BorderSide(
//                     color: redColor,
//                     width: 1,
//                   ),
//                 ),
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 hintText: "Email",
//                 hintStyle: TextStyle(
//                   color: hintColor,
//                   fontSize: 12,
//                   fontFamily: 'Inter-Light',
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: size.height * 0.02),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: TextFormField(
//               controller: nameController,
//               cursorColor: orangeColor,
//               keyboardType: TextInputType.text,
//               // validator: (value) {
//               //   if (value == null || value.isEmpty) {
//               //     return 'Name field is required!';
//               //   }
//               //   return null;
//               // },
//               style: TextStyle(
//                 color: blackColor,
//                 fontSize: 14,
//                 fontFamily: 'Inter-Regular',
//               ),
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: filledColor,
//                 errorStyle: TextStyle(
//                   color: redColor,
//                   fontSize: 12,
//                   fontFamily: 'Inter-Bold',
//                 ),
//                 border: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   borderSide: BorderSide.none,
//                 ),
//                 enabledBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   borderSide: BorderSide.none,
//                 ),
//                 focusedErrorBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   borderSide: BorderSide.none,
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: const BorderRadius.all(
//                     Radius.circular(10),
//                   ),
//                   borderSide: BorderSide(
//                     color: redColor,
//                     width: 1,
//                   ),
//                 ),
//                 contentPadding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 hintText: "Name",
//                 hintStyle: TextStyle(
//                   color: hintColor,
//                   fontSize: 12,
//                   fontFamily: 'Inter-Light',
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(height: size.height * 0.1),
//           buttonTransparentGradient('SAVE', context),
//         ],
//       ),
//     );
//   }
// }
