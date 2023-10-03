// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/cancel_booking_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/models/get_scheduled_booking_model.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart'
    as systemdata;

String? userId;

class ScheduledRideDetailScreen extends StatefulWidget {
  final Datum? getScheduledBookingModel;
  const ScheduledRideDetailScreen({super.key, this.getScheduledBookingModel});

  @override
  State<ScheduledRideDetailScreen> createState() =>
      _ScheduledRideDetailScreenState();
}

class _ScheduledRideDetailScreenState extends State<ScheduledRideDetailScreen> {
  String? currencyUnit;
  String? distanceUnit;
  bool isLoading = false;

  systemdata.GetAllSystemDataModel getAllSystemDataModel =
      systemdata.GetAllSystemDataModel();

  getAllSystemData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$baseUrl/get_all_system_data";
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
        getAllSystemDataModel =
            systemdata.getAllSystemDataModelFromJson(responseString);
        print('getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        print(
            'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "system_currency") {
            currencyUnit = "${getAllSystemDataModel.data?[i].description}";
            print("currencyUnit: $currencyUnit");
          }
          if (getAllSystemDataModel.data?[i].type == "distance_unit") {
            distanceUnit = "${getAllSystemDataModel.data?[i].description}";
            print("distanceUnit: $distanceUnit");
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  CancelBookingModel cancelBookingModel = CancelBookingModel();

  cancelBooking() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/cancel_booking";
      print("apiUrl: $apiUrl");
      // print("bookings_id: ${widget.bookingId}");
      // print("users_fleet_id: ${widget.fleetId}");
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
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        cancelBookingModel = cancelBookingModelFromJson(responseString);
        setState(() {});
        print('cancelBookingModel status: ${cancelBookingModel.status}');
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getAllSystemData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: SvgPicture.asset(
              'assets/images/back-icon.svg',
              width: 22,
              height: 22,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
        title: Text(
          "Scheduled Rides",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blackColor,
            fontSize: 20,
            fontFamily: 'Syne-Bold',
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
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
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.02),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Text(
                          "12 min ago",
                          // "${widget.completedRideModel?.rideCompleted}",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: sheetBarrierColor,
                            fontSize: 14,
                            fontFamily: 'Inter-Medium',
                          ),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
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
                                              '$imageUrl${widget.getScheduledBookingModel?.bookingsFleet?[0].usersFleet?.profilePic}',
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
                                            width: size.width * 0.45,
                                            child: AutoSizeText(
                                              "${widget.getScheduledBookingModel?.bookingsFleet?[0].usersFleet?.firstName} ${widget.getScheduledBookingModel?.bookingsFleet?[0].usersFleet?.lastName}",
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
                                                '${widget.getScheduledBookingModel?.bookingsFleet?[0].usersFleetVehicles?.color} ',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 12,
                                                  fontFamily: 'Inter-Regular',
                                                ),
                                              ),
                                              Text(
                                                '${widget.getScheduledBookingModel?.bookingsFleet?[0].usersFleetVehicles?.model}',
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
                                            '${widget.getScheduledBookingModel?.bookingsFleet?[0].usersFleetVehicles?.vehicleRegistrationNo}',
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
                                  SizedBox(height: size.height * 0.03),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/date-picker-icon.svg',
                                        width: 15,
                                        height: 15,
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text(
                                        'Scheduled Date:',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text(
                                        '${widget.getScheduledBookingModel?.deliveryDate}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Regular',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/time-picker-icon.svg',
                                        width: 15,
                                        height: 15,
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text(
                                        'Scheduled Time:',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text(
                                        '${widget.getScheduledBookingModel?.deliveryTime}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Regular',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/orange-location-big-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.04),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pickup',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 14,
                                              fontFamily: 'Syne-Regular',
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Tooltip(
                                            message:
                                                "${widget.getScheduledBookingModel?.pickupAddress}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.6,
                                              child: AutoSizeText(
                                                "${widget.getScheduledBookingModel?.pickupAddress}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                                minFontSize: 14,
                                                maxFontSize: 14,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Divider(
                                    thickness: 1,
                                    color: dividerColor,
                                    indent: 30,
                                    endIndent: 30,
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/send-small-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.04),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Dropoff',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 14,
                                              fontFamily: 'Syne-Regular',
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Tooltip(
                                            message:
                                                "${widget.getScheduledBookingModel?.bookingsFleet?[0].bookingsDestinations?.destinAddress}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.6,
                                              child: AutoSizeText(
                                                "${widget.getScheduledBookingModel?.bookingsFleet?[0].bookingsDestinations?.destinAddress}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                                minFontSize: 14,
                                                maxFontSize: 14,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/grey-location-icon.svg',
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Tooltip(
                                            message:
                                                "${widget.getScheduledBookingModel?.bookingsFleet?[0].bookingsDestinations?.destinDistance} $distanceUnit",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.18,
                                              child: AutoSizeText(
                                                "${widget.getScheduledBookingModel?.bookingsFleet?[0].bookingsDestinations?.destinDistance} $distanceUnit",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Regular',
                                                ),
                                                maxFontSize: 14,
                                                minFontSize: 12,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/grey-clock-icon.svg',
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Tooltip(
                                            message:
                                                "${widget.getScheduledBookingModel?.bookingsFleet?[0].bookingsDestinations?.destinTime}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.38,
                                              child: AutoSizeText(
                                                "${widget.getScheduledBookingModel?.bookingsFleet?[0].bookingsDestinations?.destinTime}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Regular',
                                                ),
                                                maxFontSize: 14,
                                                minFontSize: 12,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/grey-dollar-icon.svg',
                                            colorFilter: ColorFilter.mode(
                                                const Color(0xFF292D32)
                                                    .withOpacity(0.4),
                                                BlendMode.srcIn),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Tooltip(
                                            message:
                                                "$currencyUnit${widget.getScheduledBookingModel?.totalCharges}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.2,
                                              child: AutoSizeText(
                                                "$currencyUnit${widget.getScheduledBookingModel?.totalCharges}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Regular',
                                                ),
                                                maxFontSize: 14,
                                                minFontSize: 12,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) =>
                                            cancelRide(context),
                                      );
                                    },
                                    child: buttonGradient("Cancel", context),
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
                                  '${widget.getScheduledBookingModel?.bookingsFleet?[0].usersFleet?.bookingsRatings}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 12,
                                    fontFamily: 'Inter-Regular',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
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
                            Fluttertoast.showToast(
                              msg: "You have already cancelled this booking.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: toastColor,
                              textColor: whiteColor,
                              fontSize: 12,
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
