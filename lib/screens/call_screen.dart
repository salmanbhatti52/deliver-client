// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
//
// class CallScreen extends StatefulWidget {
//   final String? name;
//   final String? image;
//   const CallScreen({super.key, this.name, this.image});
//
//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }
//
// // class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
// // late final AnimationController lottieController;
// // int duration = 5;
//
// // @override
// // void initState() {
// //   super.initState();
// //   lottieController = AnimationController(
// //     vsync: this,
// //     duration: Duration(seconds: duration),
// //   );
// //   lottieController.repeat();
// // }
//
// // @override
// // void dispose() {
// //   lottieController.dispose();
// //   super.dispose();
// // }
//
// class _CallScreenState extends State<CallScreen> {
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         backgroundColor: bgColor,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         leading: Padding(
//           padding: const EdgeInsets.only(left: 20),
//           child: GestureDetector(
//             onTap: () {
//               Navigator.pop(context);
//             },
//             child: SvgPicture.asset(
//               'assets/images/back-icon.svg',
//               width: 22,
//               height: 22,
//               fit: BoxFit.scaleDown,
//             ),
//           ),
//         ),
//         title: Text(
//           "Call",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: blackColor,
//             fontSize: 20,
//             fontFamily: 'Syne-Bold',
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: size.height * 0.08),
//               Container(
//                 width: size.width,
//                 height: size.height * 0.38,
//                 color: transparentColor,
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       left: 0,
//                       right: 0,
//                       child: SvgPicture.asset(
//                         'assets/images/call-background.svg',
//                       ),
//                     ),
//                     // Center(
//                     //   child:
//                     //   Lottie.asset(
//                     //     'assets/images/call-background.json',
//                     //     controller: lottieController,
//                     //   ),
//                     // ),
//                     Positioned(
//                       top: 35,
//                       left: 79,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(100),
//                         child: Container(
//                           width: 170,
//                           height: 170,
//                           decoration: BoxDecoration(
//                             color: transparentColor,
//                             shape: BoxShape.circle,
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
//                   ],
//                 ),
//               ),
//               SizedBox(height: size.height * 0.04),
//               Text(
//                 "${widget.name}",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: blackColor,
//                   fontSize: 28,
//                   fontFamily: 'Syne-SemiBold',
//                 ),
//               ),
//               SizedBox(height: size.height * 0.02),
//               Text(
//                 "01:23 minutes",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: supportTextColor,
//                   fontSize: 16,
//                   fontFamily: 'Inter-Medium',
//                 ),
//               ),
//               SizedBox(height: size.height * 0.1),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SvgPicture.asset('assets/images/call-cancel-icon.svg'),
//                   SizedBox(width: size.width * 0.02),
//                   SvgPicture.asset('assets/images/call-video-icon.svg'),
//                   SizedBox(width: size.width * 0.02),
//                   SvgPicture.asset('assets/images/call-specker-icon.svg'),
//                 ],
//               ),
//               SizedBox(height: size.height * 0.02),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
