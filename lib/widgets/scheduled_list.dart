// ignore_for_file: use_build_context_synchronously

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/cancel_booking_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/models/get_scheduled_booking_model.dart';
import 'package:deliver_client/screens/home/drawer/scheduled_ride/scheduled_ride_details/scheduled_ride_details_screen.dart';

String? userId;

class ScheduledList extends StatefulWidget {
  const ScheduledList({super.key});

  @override
  State<ScheduledList> createState() => _ScheduledListState();
}

class _ScheduledListState extends State<ScheduledList> {
  DateTime? timeAdded;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  GetScheduledBookingModel getScheduledBookingModel =
      GetScheduledBookingModel();

  getScheduledBooking() async {
    try {
      setState(() {
        isLoading = true;
      });
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/get_bookings_scheduled_customers";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("userId: $userId");
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
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getScheduledBookingModel =
            getScheduledBookingModelFromJson(responseString);
        debugPrint(
            'getScheduledBookingModel status: ${getScheduledBookingModel.status}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      setState(() {
        isLoading = false;
      });
      return null;
    }
  }

  CancelBookingModel cancelBookingModel = CancelBookingModel();

  cancelBooking() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/cancel_booking";
      debugPrint("apiUrl: $apiUrl");
      // debugPrint("bookings_id: ${widget.bookingId}");
      // debugPrint("users_fleet_id: ${widget.fleetId}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          // "bookings_id": widget.bookingId,
          "users_customers_id": userId,
          // "users_fleet_id": widget.fleetId,
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        cancelBookingModel = cancelBookingModelFromJson(responseString);
        setState(() {});
        debugPrint('cancelBookingModel status: ${cancelBookingModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
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
    getScheduledBooking();
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
        : getScheduledBookingModel.data != null
            ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: getScheduledBookingModel.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  int reverseIndex =
                      getScheduledBookingModel.data!.length - 1 - index;
                  if (getScheduledBookingModel
                          .data![reverseIndex].dateModified !=
                      null) {
                    timeAdded = DateTime.parse(
                        "${getScheduledBookingModel.data![reverseIndex].dateModified}");
                  } else {
                    // Handle the situation when dateModified is null
                    // For example, you can use the current date and time as a default value
                    timeAdded = DateTime.now();
                  }
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
                                              '$imageUrl${getScheduledBookingModel.data?[reverseIndex].bookingsFleet?[0].usersFleet?.profilePic}',
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
                                              '${getScheduledBookingModel.data?[reverseIndex].bookingsFleet?[0].usersFleet?.firstName} ${getScheduledBookingModel.data?[reverseIndex].bookingsFleet?[0].usersFleet?.lastName}',
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
                                                '${getScheduledBookingModel.data?[reverseIndex].bookingsFleet?[0].usersFleetVehicles?.color} ',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 12,
                                                  fontFamily: 'Inter-Regular',
                                                ),
                                              ),
                                              Text(
                                                '${getScheduledBookingModel.data?[reverseIndex].bookingsFleet?[0].usersFleetVehicles?.model}',
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
                                            '(${getScheduledBookingModel.data?[reverseIndex].bookingsFleet?[0].usersFleetVehicles?.vehicleRegistrationNo})',
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
                                      'You Scheduled a ride\n${formatTimeDifference(timeAdded!)} with this captain',
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
                                  '${getScheduledBookingModel.data?[reverseIndex].bookingsFleet?[0].usersFleet?.bookingsRatings}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 12,
                                    fontFamily: 'Inter-Regular',
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 52,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => cancelRide(context),
                                    );
                                  },
                                  child: detailButtonTransparentGradientSmall(
                                      'Cancel', context),
                                ),
                              ),
                              Positioned(
                                bottom: 13,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ScheduledRideDetailScreen(
                                          getScheduledBookingModel:
                                              getScheduledBookingModel
                                                  .data?[reverseIndex],
                                        ),
                                      ),
                                    );
                                  },
                                  child: detailButtonGradientSmall(
                                    'See detail',
                                    context,
                                  ),
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
                        "No Ride is Scheduled",
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

  cancelRide(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          insetPadding: const EdgeInsets.only(left: 20, right: 20),
          child: SizedBox(
            height: size.height * 0.3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SvgPicture.asset("assets/images/close-icon.svg"),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Cancel Ride',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: orangeColor,
                      fontSize: 24,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  Text(
                    'Are you sure, you want\nto cancel this ride?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 18,
                      fontFamily: 'Syne-Regular',
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child:
                            dialogButtonTransparentGradientSmall("No", context),
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await cancelBooking();
                          if (cancelBookingModel.status == "success") {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const HomePageScreen()),
                                (Route<dynamic> route) => false);
                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            CustomToast.showToast(
                              fontSize: 12,
                              message:
                                  "You have already cancelled this booking.",
                            );
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                        child: isLoading
                            ? dialogButtonGradientSmallWithLoader(
                                "Please wait...", context)
                            : dialogButtonGradientSmall("Yes", context),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
