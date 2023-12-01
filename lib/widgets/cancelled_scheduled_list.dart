// import 'package:flutter/material.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:deliver_client/widgets/buttons.dart';
//
// class CancelledScheduledList extends StatefulWidget {
//   const CancelledScheduledList({super.key});
//
//   @override
//   State<CancelledScheduledList> createState() => _CancelledScheduledListState();
// }
//
// class _CancelledScheduledListState extends State<CancelledScheduledList> {
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return ListView.builder(
//       physics: const BouncingScrollPhysics(),
//       shrinkWrap: true,
//       scrollDirection: Axis.vertical,
//       itemCount: 2,
//       itemBuilder: (BuildContext context, int index) {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "12 min ago",
//               textAlign: TextAlign.left,
//               style: TextStyle(
//                 color: sheetBarrierColor,
//                 fontSize: 14,
//                 fontFamily: 'Inter-Medium',
//               ),
//             ),
//             SizedBox(height: size.height * 0.02),
//             Card(
//               color: whiteColor,
//               elevation: 5,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                   left: 15,
//                   right: 10,
//                 ),
//                 child: Stack(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(height: size.height * 0.02),
//                         Row(
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(10),
//                               child: Container(
//                                 color: transparentColor,
//                                 width: 60,
//                                 height: 65,
//                                 child: Image.asset(
//                                   'assets/images/user-profile.png',
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: size.width * 0.02),
//                             Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   color: transparentColor,
//                                   width: size.width * 0.44,
//                                   child: AutoSizeText(
//                                     'Captain Jannie',
//                                     textAlign: TextAlign.left,
//                                     style: TextStyle(
//                                       color: drawerTextColor,
//                                       fontSize: 16,
//                                       fontFamily: 'Syne-Bold',
//                                     ),
//                                     minFontSize: 16,
//                                     maxFontSize: 16,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 SizedBox(height: size.height * 0.01),
//                                 Row(
//                                   children: [
//                                     Text(
//                                       'Yellow ',
//                                       textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                         color: textHaveAccountColor,
//                                         fontSize: 12,
//                                         fontFamily: 'Inter-Regular',
//                                       ),
//                                     ),
//                                     Text(
//                                       'Toyota',
//                                       textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                         color: textHaveAccountColor,
//                                         fontSize: 12,
//                                         fontFamily: 'Inter-Regular',
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: size.height * 0.005),
//                                 Text(
//                                   '(NHN-5638)',
//                                   textAlign: TextAlign.left,
//                                   style: TextStyle(
//                                     color: textHaveAccountColor,
//                                     fontSize: 12,
//                                     fontFamily: 'Inter-Regular',
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: size.height * 0.02),
//                       ],
//                     ),
//                     Positioned(
//                       bottom: 15,
//                       right: 0,
//                       child: GestureDetector(
//                         onTap: () {
//                           // Navigator.push(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //     builder: (context) =>
//                           //         RideHistoryCancelledDetailsScreen(
//                           //           cancelledRideModel:
//                           //           cancelledRideModel.data?[index],
//                           //         ),
//                           //   ),
//                           // );
//                         },
//                         child: detailButtonGradientSmall(
//                             'See detail', context),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: size.height * 0.02),
//           ],
//         );
//       },
//     );
//   }
// }
