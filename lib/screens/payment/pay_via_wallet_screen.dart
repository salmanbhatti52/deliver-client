// // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/widgets/tabbar_wallet.dart';
// import 'package:deliver_client/screens/search_riders_screen.dart';

// class PayViaWalletScreen extends StatefulWidget {
//   final Map? singleData;
//   const PayViaWalletScreen({super.key, this.singleData});

//   @override
//   State<PayViaWalletScreen> createState() => _PayViaWalletScreenState();
// }

// class _PayViaWalletScreenState extends State<PayViaWalletScreen> {
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
//             "Payment Through Wallet",
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
//                               "PayPal",
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
//                 SizedBox(height: size.height * 0.04),
//                 const TabbarWallet(),
//                 SizedBox(height: size.height * 0.07),
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
