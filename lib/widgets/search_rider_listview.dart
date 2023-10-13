// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:speech_balloon/speech_balloon.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/models/create_booking_model.dart';
import 'package:deliver_client/screens/driver_found_screen.dart';
import 'package:deliver_client/models/schedule_booking_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

String? userId;
double? distanceKm = 0.0;

class RidersList extends StatefulWidget {
  final Map? singleData;
  final SearchRiderData? searchRider;

  const RidersList({
    super.key,
    this.singleData,
    this.searchRider,
  });

  @override
  State<RidersList> createState() => _RidersListState();
}

class _RidersListState extends State<RidersList> {
  bool isLoading = false;
  bool isExpanded = false;
  String? currentBookingId;
  double? distanceMeters;
  String? distanceFormatted;

  CreateBookingModel createBookingModel = CreateBookingModel();

  createBooking() async {
    try {
      setState(() {
        isLoading = true;
      });
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      final Map<String, dynamic> requestData = {
        "users_fleet_id": widget.searchRider?.usersFleetId,
        "vehicles_id": widget.singleData?["vehicles_id"],
        "users_customers_id": userId,
        "bookings_types_id": widget.singleData?["bookings_types_id"],
        "delivery_type": widget.singleData?["delivery_type"],
        "pickup_address": widget.singleData?["pickup_address"],
        "pickup_latitude": widget.singleData?["pickup_latitude"],
        "pickup_longitude": widget.singleData?["pickup_longitude"],
        "bookings_destinations": [
          {
            "destin_address": widget.singleData?["destin_address"],
            "destin_latitude": widget.singleData?["destin_latitude"],
            "destin_longitude": widget.singleData?["destin_longitude"],
            "destin_distance": widget.singleData?["destin_distance"],
            "destin_time": widget.singleData?["destin_time"],
            "destin_delivery_charges":
                widget.singleData?["destin_delivery_charges"],
            "destin_vat_charges": widget.singleData?["destin_vat_charges"],
            "destin_total_charges": widget.singleData?["destin_total_charges"],
            "destin_discount": widget.singleData?["destin_discount"],
            "destin_discounted_charges":
                widget.singleData?["destin_discounted_charges"],
            "receiver_name": widget.singleData?["receiver_name"],
            "receiver_phone": widget.singleData?["receiver_phone"],
          }
        ],
        "total_delivery_charges": widget.singleData?["destin_total_charges"],
        "total_vat_charges": widget.singleData?["total_vat_charges"],
        "total_charges": widget.singleData?["total_charges"],
        "total_discount": widget.singleData?["total_discount"],
        "total_discounted_charges":
            widget.singleData?["total_discounted_charges"],
        "payment_gateways_id": widget.singleData?["payment_gateways_id"],
        "payment_by": widget.singleData?["payment_gateways_id"] == "1"
            ? "Receiver"
            : "Sender",
        "payment_status": "Unpaid"
      };
      String apiUrl = "$baseUrl/send_request_booking";
      print("apiUrl: $apiUrl");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        createBookingModel = createBookingModelFromJson(responseString);
        print('createBookingModel status: ${createBookingModel.status}');
        currentBookingId = createBookingModel.data?.bookingsId.toString();
        print('currentBookingId: $currentBookingId');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  ScheduleBookingModel scheduleBookingModel = ScheduleBookingModel();

  scheduleBooking() async {
    try {
      setState(() {
        isLoading = true;
      });
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      final Map<String, dynamic> requestData = {
        "users_fleet_id": widget.searchRider?.usersFleetId,
        "vehicles_id": widget.singleData?["vehicles_id"],
        "users_customers_id": userId,
        "bookings_types_id": widget.singleData?["bookings_types_id"],
        "delivery_type": widget.singleData?["delivery_type"],
        "pickup_address": widget.singleData?["pickup_address"],
        "pickup_latitude": widget.singleData?["pickup_latitude"],
        "pickup_longitude": widget.singleData?["pickup_longitude"],
        "bookings_destinations": [
          {
            "destin_address": widget.singleData?["destin_address"],
            "destin_latitude": widget.singleData?["destin_latitude"],
            "destin_longitude": widget.singleData?["destin_longitude"],
            "destin_distance": widget.singleData?["destin_distance"],
            "destin_time": widget.singleData?["destin_time"],
            "destin_delivery_charges":
                widget.singleData?["destin_delivery_charges"],
            "destin_vat_charges": widget.singleData?["destin_vat_charges"],
            "destin_total_charges": widget.singleData?["destin_total_charges"],
            "destin_discount": widget.singleData?["destin_discount"],
            "destin_discounted_charges":
                widget.singleData?["destin_discounted_charges"],
            "receiver_name": widget.singleData?["receiver_name"],
            "receiver_phone": widget.singleData?["receiver_phone"],
          }
        ],
        "delivery_date": widget.singleData?["delivery_date"],
        "delivery_time": widget.singleData?["delivery_time"],
        "total_delivery_charges": widget.singleData?["destin_total_charges"],
        "total_vat_charges": widget.singleData?["total_vat_charges"],
        "total_charges": widget.singleData?["total_charges"],
        "total_discount": widget.singleData?["total_discount"],
        "total_discounted_charges":
            widget.singleData?["total_discounted_charges"],
        "payment_gateways_id": widget.singleData?["payment_gateways_id"],
        "payment_by": widget.singleData?["payment_gateways_id"] == "1"
            ? "Receiver"
            : "Sender",
        "payment_status": "Unpaid"
      };
      String apiUrl = "$baseUrl/send_request_scheduled_booking";
      print("apiUrl: $apiUrl");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestData),
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        scheduleBookingModel = scheduleBookingModelFromJson(responseString);
        print('scheduleBookingModel status: ${scheduleBookingModel.status}');
        currentBookingId = scheduleBookingModel.data?.bookingsId.toString();
        print('currentBookingId: $currentBookingId');
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
  initState() {
    super.initState();
    distanceKm = double.parse("${widget.searchRider?.distance}");
    print('distanceKm: $distanceKm');
    if (distanceKm! <= 10.00) {
      distanceMeters = distanceKm! * 100;
      distanceFormatted = distanceMeters!.toStringAsFixed(0);
      print('distanceFormatted: $distanceFormatted');
    }
    print('singleData: ${widget.singleData}');
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: isExpanded
          ? SpeechBalloon(
              nipLocation: NipLocation.bottom,
              nipHeight: 0,
              borderColor: borderColor,
              width: size.width * 0.35,
              height: size.height * 0.1,
              borderRadius: 10,
              offset: const Offset(10, 0),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          color: transparentColor,
                          width: 35,
                          height: 35,
                          child: FadeInImage(
                            placeholder: const AssetImage(
                              "assets/images/user-profile.png",
                            ),
                            image: NetworkImage(
                              '$imageUrl${widget.searchRider?.profilePic}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Image.asset(
                        //   'assets/images/user-profile.png',
                        //   width: 35,
                        //   height: 35,
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.searchRider?.firstName}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 12,
                              fontFamily: 'Inter-Regular',
                            ),
                          ),
                          Text(
                            "Drive  $distanceFormatted m",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textHaveAccountColor,
                              fontSize: 10,
                              fontFamily: 'Inter-Regular',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.005),
                  GestureDetector(
                    onTap: () async {
                      if (widget.singleData?["type"] == "booking") {
                        print("booking");
                        await createBooking();
                        if (createBookingModel.data != null) {
                          if (createBookingModel.status == 'success') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverFoundScreen(
                                  bookingId: createBookingModel.data?.bookingsId.toString(),
                                  fleetId: "${widget.searchRider?.usersFleetId}",
                                  currentBookingId: currentBookingId,
                                  passCode: createBookingModel.data?.bookingsFleet?[0].bookingsDestinations?.passcode,
                                  distance: distanceKm,
                                  singleData: widget.singleData,
                                  riderData: widget.searchRider,
                                ),
                              ),
                            );
                          } else {
                            Fluttertoast.showToast(
                              msg: "Please try again.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: toastColor,
                              textColor: whiteColor,
                              fontSize: 12,
                            );
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg: "Please try again.",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 2,
                            backgroundColor: toastColor,
                            textColor: whiteColor,
                            fontSize: 12,
                          );
                        }
                      } else if (widget.singleData?["type"] == "schedule") {
                        print("schedule");
                        await scheduleBooking();
                        if (scheduleBookingModel.status == 'success') {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const HomePageScreen()));
                        } else {
                          print("error");
                        }
                      }
                    },
                    child: isLoading
                        ? statusGradientButtonSmallWithLoader(
                            "Please wait...",
                            context,
                          )
                        : statusGradientButtonSmall(
                            "Send Request",
                            greenStatusButtonColor,
                            context,
                          ),
                  ),
                ],
              ),
            )
          : SpeechBalloon(
              nipLocation: NipLocation.bottom,
              borderColor: borderColor,
              width: size.width * 0.12,
              height: size.height * 0.055,
              borderRadius: 100,
              offset: const Offset(0, -1.5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: FadeInImage(
                  placeholder: const AssetImage(
                    "assets/images/user-profile.png",
                  ),
                  image: NetworkImage(
                    '$imageUrl${widget.searchRider?.profilePic}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }
}
