// ignore_for_file: avoid_print

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/completed_ride_model.dart';
import 'package:deliver_client/screens/home/drawer/ride_history/ride_history_details/completed_details_screen.dart';

String? userId;

class CompletedList extends StatefulWidget {
  const CompletedList({super.key});

  @override
  State<CompletedList> createState() => _CompletedListState();
}

class _CompletedListState extends State<CompletedList> {
  DateTime? timeAdded;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  CompletedRideModel completedRideModel = CompletedRideModel();

  completedRide() async {
    try {
      setState(() {
        isLoading = true;
      });
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/get_bookings_completed_customers";
      print("apiUrl: $apiUrl");
      print("userId: $userId");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "users_customers_id": userId,
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        completedRideModel = completedRideModelFromJson(responseString);
        print('completedRideModel status: ${completedRideModel.status}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      setState(() {
        isLoading = false;
      });
      return null;
    }
  }

  String formatTimeDifference(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays >= 365) {
      int years = (difference.inDays / 365).floor();
      return "${years == 1 ? '1 year' : '$years years'} ago";
    } else if (difference.inDays >= 30) {
      int months = (difference.inDays / 30).floor();
      return "${months == 1 ? '1 month' : '$months months'} ago";
    } else if (difference.inDays >= 7) {
      int weeks = (difference.inDays / 7).floor();
      return "${weeks == 1 ? '1 week' : '$weeks weeks'} ago";
    } else if (difference.inDays > 0) {
      return "${difference.inDays == 1 ? '1 day' : '${difference.inDays} days'} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours == 1 ? '1 hour' : '${difference.inHours} hours'} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes == 1 ? '1 minute' : '${difference.inMinutes} mins'} ago";
    } else {
      return "Just now";
    }
  }

  @override
  void initState() {
    super.initState();
    completedRide();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return isLoading
        ? Center(
            child: Container(
              width: 100,
              height: 100,
              color: transparentColor,
              child: Lottie.asset(
                'assets/images/loading-icon.json',
                fit: BoxFit.cover,
              ),
            ),
          )
        : completedRideModel.data != null
            ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: completedRideModel.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  int reverseIndex =
                      completedRideModel.data!.length - 1 - index;
                  timeAdded = DateTime.parse(
                      "${completedRideModel.data![reverseIndex].dateModified}");
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatTimeDifference(timeAdded!),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: sheetBarrierColor,
                          fontSize: 14,
                          fontFamily: 'Inter-Medium',
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Card(
                        color: whiteColor,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 10,
                            bottom: 15,
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          color: transparentColor,
                                          width: 60,
                                          height: 65,
                                          child: FadeInImage(
                                            placeholder: const AssetImage(
                                              "assets/images/user-profile.png",
                                            ),
                                            image: NetworkImage(
                                              '$imageUrl${completedRideModel.data![reverseIndex].bookingsFleet?[0].usersFleet?.profilePic}',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.44,
                                            child: AutoSizeText(
                                              '${completedRideModel.data![reverseIndex].bookingsFleet?[0].usersFleet?.firstName} ${completedRideModel.data![reverseIndex].bookingsFleet?[0].usersFleet?.lastName}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: drawerTextColor,
                                                fontSize: 16,
                                                fontFamily: 'Syne-Bold',
                                              ),
                                              minFontSize: 16,
                                              maxFontSize: 16,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Row(
                                            children: [
                                              Text(
                                                '${completedRideModel.data![reverseIndex].bookingsFleet?[0].usersFleetVehicles?.color} ',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 12,
                                                  fontFamily: 'Inter-Regular',
                                                ),
                                              ),
                                              Text(
                                                '${completedRideModel.data![reverseIndex].bookingsFleet?[0].usersFleetVehicles?.model}',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 12,
                                                  fontFamily: 'Inter-Regular',
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          Text(
                                            '${completedRideModel.data![reverseIndex].bookingsFleet?[0].usersFleetVehicles?.vehicleRegistrationNo}',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 12,
                                              fontFamily: 'Inter-Regular',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.54,
                                    child: AutoSizeText(
                                      'You Completed a ride\n${formatTimeDifference(timeAdded!)} ago with this captain',
                                      // 'You Completed a ride\n${completedRideModel.data![reverseIndex].rideCompleted} with this captain',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: textHaveAccountColor,
                                        fontSize: 14,
                                        fontFamily: 'Inter-Regular',
                                      ),
                                      minFontSize: 14,
                                      maxFontSize: 14,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                ],
                              ),
                              Positioned(
                                top: 18,
                                right: 0,
                                child: SvgPicture.asset(
                                  'assets/images/star-with-container-icon.svg',
                                  width: 45,
                                ),
                              ),
                              Positioned(
                                top: 19,
                                right: 7,
                                child: Text(
                                  '${completedRideModel.data![reverseIndex].bookingsFleet?[0].usersFleet?.bookingsRatings}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 12,
                                    fontFamily: 'Inter-Regular',
                                  ),
                                ),
                              ),
                              // Positioned(
                              //   bottom: 55,
                              //   right: 0,
                              //   child: GestureDetector(
                              //     onTap: () {
                              //       showDialog(
                              //         context: context,
                              //         barrierDismissible: false,
                              //         // barrierColor: sheetBarrierColor,
                              //         builder: (context) => rebookRide(context),
                              //       );
                              //     },
                              //     child: detailButtonTransparentGradientSmall(
                              //         'Rebook', context),
                              //   ),
                              // ),
                              Positioned(
                                bottom: 18,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RideHistoryCompletedDetailsScreen(
                                          completedRideModel: completedRideModel
                                              .data?[reverseIndex],
                                        ),
                                      ),
                                    );
                                  },
                                  child: detailButtonGradientSmall(
                                      'See detail', context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
                  );
                },
              )
            : Padding(
                padding: const EdgeInsets.only(top: 180),
                child: Center(
                  child: Column(
                    children: [
                      Lottie.asset('assets/images/no-data-icon.json'),
                      SizedBox(height: size.height * 0.04),
                      Text(
                        "No Ride is Completed",
                        style: TextStyle(
                          color: textHaveAccountColor,
                          fontSize: 24,
                          fontFamily: 'Syne-SemiBold',
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }
}

// Widget rebookRide(BuildContext context) {
//   var size = MediaQuery.of(context).size;
//   return GestureDetector(
//     onTap: () {
//       FocusManager.instance.primaryFocus?.unfocus();
//     },
//     child: WillPopScope(
//       onWillPop: () {
//         return Future.value(false);
//       },
//       child: Dialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(40),
//         ),
//         insetPadding: const EdgeInsets.only(left: 20, right: 20),
//         child: SizedBox(
//           height: size.height * 0.45,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 15),
//                       child: SvgPicture.asset("assets/images/close-icon.svg"),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 SvgPicture.asset('assets/images/hourglass-icon.svg'),
//                 SizedBox(height: size.height * 0.03),
//                 Text(
//                   'Time up',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: orangeColor,
//                     fontSize: 20,
//                     fontFamily: 'Syne-Bold',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   'You can not rebook this ride after 5\nmins of completing the ride.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 18,
//                     fontFamily: 'Syne-Regular',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.03),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }
