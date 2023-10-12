// ignore_for_file: avoid_print

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/models/get_reason_model.dart';

class ReportBoxes extends StatefulWidget {
  const ReportBoxes({super.key});

  @override
  State<ReportBoxes> createState() => _ReportBoxesState();
}

class _ReportBoxesState extends State<ReportBoxes> {
  bool isSelected1 = false;
  bool isSelected2 = false;
  bool isSelected3 = false;
  bool isSelected4 = false;
  String? selectedReasonId;

  bool isLoading = false;

  GetReasonModel getReasonModel = GetReasonModel();

  getReason() async {
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$baseUrl/get_bookings_reports_reasons";
      print("apiUrl: $apiUrl");
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getReasonModel = getReasonModelFromJson(responseString);
        print('getReasonModel status: ${getReasonModel.status}');
        print('getSupportAdminModel length: ${getReasonModel.data!.length}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getReason();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return isLoading
        ? Center(
            child: Container(
              width: 60,
              height: 60,
              color: transparentColor,
              child: Lottie.asset(
                'assets/images/loading-icon.json',
                fit: BoxFit.cover,
              ),
            ),
          )
        : getReasonModel.data != null
            ? Column(
                children: [
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: getReasonModel.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedReasonId = getReasonModel
                                .data![index].bookingsReportsReasonsId
                                .toString();
                            print(
                                "selectedReasonId: $selectedReasonId, ${getReasonModel.data![index].reason}");
                          });
                        },
                        child: Card(
                          color: whiteColor,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            color: transparentColor,
                            width: size.width,
                            height: size.height * 0.07,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.65,
                                    child: AutoSizeText(
                                      "${getReasonModel.data![index].reason}",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: drawerTextColor,
                                        fontSize: 16,
                                        fontFamily: 'Syne-Medium',
                                      ),
                                      minFontSize: 16,
                                      maxFontSize: 16,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (selectedReasonId ==
                                      getReasonModel
                                          .data![index].bookingsReportsReasonsId
                                          .toString())
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          // Deselect the item when the checkmark is tapped again
                                          selectedReasonId = null;
                                        });
                                      },
                                      child: SvgPicture.asset(
                                        'assets/images/round-checkmark-icon.svg',
                                        fit: BoxFit.scaleDown,
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     setState(() {
                  //       isSelected1 = false;
                  //       isSelected2 = true;
                  //       isSelected3 = false;
                  //       isSelected4 = false;
                  //     });
                  //   },
                  //   child: Card(
                  //     color: whiteColor,
                  //     elevation: 3,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Container(
                  //       color: transparentColor,
                  //       width: size.width,
                  //       height: size.height * 0.07,
                  //       child: Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 20),
                  //         child: Row(
                  //           children: [
                  //             Container(
                  //               color: transparentColor,
                  //               width: size.width * 0.65,
                  //               child: AutoSizeText(
                  //                 "title2",
                  //                 textAlign: TextAlign.left,
                  //                 style: TextStyle(
                  //                   color: drawerTextColor,
                  //                   fontSize: 16,
                  //                   fontFamily: 'Syne-Medium',
                  //                 ),
                  //                 minFontSize: 16,
                  //                 maxFontSize: 16,
                  //                 maxLines: 1,
                  //                 overflow: TextOverflow.ellipsis,
                  //               ),
                  //             ),
                  //             const Spacer(),
                  //             isSelected2 == true
                  //                 ? GestureDetector(
                  //                     onTap: () {
                  //                       setState(() {
                  //                         isSelected2 = false;
                  //                       });
                  //                     },
                  //                     child: SvgPicture.asset(
                  //                       'assets/images/round-checkmark-icon.svg',
                  //                       fit: BoxFit.scaleDown,
                  //                     ),
                  //                   )
                  //                 : const SizedBox(),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // GestureDetector(
                  //   onTap: () {
                  //     setState(() {
                  //       isSelected1 = false;
                  //       isSelected2 = false;
                  //       isSelected3 = true;
                  //       isSelected4 = false;
                  //     });
                  //   },
                  //   child: Card(
                  //     color: whiteColor,
                  //     elevation: 3,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Container(
                  //       color: transparentColor,
                  //       width: size.width,
                  //       height: size.height * 0.07,
                  //       child: Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 20),
                  //         child: Row(
                  //           children: [
                  //             Container(
                  //               color: transparentColor,
                  //               width: size.width * 0.65,
                  //               child: AutoSizeText(
                  //                 "title3",
                  //                 textAlign: TextAlign.left,
                  //                 style: TextStyle(
                  //                   color: drawerTextColor,
                  //                   fontSize: 16,
                  //                   fontFamily: 'Syne-Medium',
                  //                 ),
                  //                 minFontSize: 16,
                  //                 maxFontSize: 16,
                  //                 maxLines: 1,
                  //                 overflow: TextOverflow.ellipsis,
                  //               ),
                  //             ),
                  //             const Spacer(),
                  //             isSelected3 == true
                  //                 ? GestureDetector(
                  //                     onTap: () {
                  //                       setState(() {
                  //                         isSelected3 = false;
                  //                       });
                  //                     },
                  //                     child: SvgPicture.asset(
                  //                       'assets/images/round-checkmark-icon.svg',
                  //                       fit: BoxFit.scaleDown,
                  //                     ),
                  //                   )
                  //                 : const SizedBox(),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // GestureDetector(
                  //   onTap: () {
                  //     setState(() {
                  //       isSelected1 = false;
                  //       isSelected2 = false;
                  //       isSelected3 = false;
                  //       isSelected4 = true;
                  //     });
                  //   },
                  //   child: Card(
                  //     color: whiteColor,
                  //     elevation: 3,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Container(
                  //       color: transparentColor,
                  //       width: size.width,
                  //       height: size.height * 0.07,
                  //       child: Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 20),
                  //         child: Row(
                  //           children: [
                  //             Container(
                  //               color: transparentColor,
                  //               width: size.width * 0.65,
                  //               child: AutoSizeText(
                  //                 "title4",
                  //                 textAlign: TextAlign.left,
                  //                 style: TextStyle(
                  //                   color: drawerTextColor,
                  //                   fontSize: 16,
                  //                   fontFamily: 'Syne-Medium',
                  //                 ),
                  //                 minFontSize: 16,
                  //                 maxFontSize: 16,
                  //                 maxLines: 1,
                  //                 overflow: TextOverflow.ellipsis,
                  //               ),
                  //             ),
                  //             const Spacer(),
                  //             isSelected4 == true
                  //                 ? GestureDetector(
                  //                     onTap: () {
                  //                       setState(() {
                  //                         isSelected4 = false;
                  //                       });
                  //                     },
                  //                     child: SvgPicture.asset(
                  //                       'assets/images/round-checkmark-icon.svg',
                  //                       fit: BoxFit.scaleDown,
                  //                     ),
                  //                   )
                  //                 : const SizedBox(),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              )
            : Center(
                child: Text(
                  "No Reason Avalible",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textHaveAccountColor,
                    fontSize: 24,
                    fontFamily: 'Syne-SemiBold',
                  ),
                ),
              );
  }
}
