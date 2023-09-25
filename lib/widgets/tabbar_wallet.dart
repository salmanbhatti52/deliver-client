// import 'package:flutter/material.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/screens/payment/tabbar_wallet_items/paypal_screen.dart';
// import 'package:deliver_client/screens/payment/tabbar_wallet_items/paystack_screen.dart';
// import 'package:deliver_client/screens/payment/tabbar_wallet_items/flutterwave_screen.dart';

// class TabbarWallet extends StatefulWidget {
//   const TabbarWallet({super.key});

//   @override
//   State<TabbarWallet> createState() => _TabbarWalletState();
// }

// class _TabbarWalletState extends State<TabbarWallet>
//     with TickerProviderStateMixin {
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     TabController tabController = TabController(length: 3, vsync: this);
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 10),
//           child: Container(
//               width: size.width,
//               height: size.height * 0.06,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   color: borderColor,
//                   width: 1,
//                 ),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
//                 child: TabBar(
//                   controller: tabController,
//                   indicator: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.centerRight,
//                       end: Alignment.centerLeft,
//                       stops: const [0.1, 1.5],
//                       colors: [
//                         orangeColor,
//                         yellowColor,
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   isScrollable: true,
//                   labelPadding: const EdgeInsets.symmetric(horizontal: 18),
//                   labelColor: whiteColor,
//                   labelStyle: TextStyle(
//                     color: whiteColor,
//                     fontSize: 14,
//                     fontFamily: 'Syne-Medium',
//                   ),
//                   unselectedLabelColor: const Color(0xFF929292),
//                   unselectedLabelStyle: const TextStyle(
//                     color: Color(0xFF929292),
//                     fontSize: 14,
//                     fontFamily: 'Syne-Regular',
//                   ),
//                   tabs: const [
//                     Tab(text: "FlutterWave"),
//                     Tab(text: "PayPal"),
//                     Tab(text: "PayStack"),
//                   ],
//                 ),
//               )),
//         ),
//         Container(
//           color: transparentColor,
//           width: double.maxFinite,
//           height: size.height * 0.5,
//           child: TabBarView(
//             controller: tabController,
//             children: const [
//               FlutterWaveScreen(),
//               PayPalScreen(),
//               PayStackScreen(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
