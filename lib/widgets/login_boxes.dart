// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';

// Widget loginBox(image, titleText, context) {
//   return Stack(
//     children: [
//       Container(
//         color: transparentColor,
//         width: MediaQuery.of(context).size.width * 0.38,
//         height: MediaQuery.of(context).size.height * 0.12,
//       ),
//       Positioned(
//         bottom: 0,
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.38,
//           height: MediaQuery.of(context).size.height * 0.1,
//           decoration: BoxDecoration(
//             color: orangeColor,
//             borderRadius: BorderRadius.circular(15),
//           ),
//         ),
//       ),
//       Positioned(
//         top: 60,
//         left: 0,
//         right: 0,
//         child: Text(
//           titleText,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: whiteColor,
//             fontSize: 14,
//             fontFamily: 'Syne-Bold',
//           ),
//         ),
//       ),
//       Positioned(
//         left: 0,
//         right: 0,
//         child: SvgPicture.asset(image),
//       ),
//     ],
//   );
// }
