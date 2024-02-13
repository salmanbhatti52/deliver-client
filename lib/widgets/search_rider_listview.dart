// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  final Map? multipleData;
  final SearchRiderData? searchRider;

  const RidersList({
    super.key,
    this.singleData,
    this.multipleData,
    this.searchRider,
  });

  @override
  State<RidersList> createState() => _RidersListState();
}

class _RidersListState extends State<RidersList> {
  bool isLoading = false;
  bool isExpanded = false;
  double? distanceMeters;
  String? currentBookingId;
  String? distanceFormatted;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

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
        "vehicles_id": widget.singleData!.isNotEmpty
            ? widget.singleData!["vehicles_id"]
            : widget.multipleData!["vehicles_id"],
        "users_customers_id": userId,
        "bookings_types_id": widget.singleData!.isNotEmpty
            ? widget.singleData!["bookings_types_id"]
            : widget.multipleData!["bookings_types_id"],
        "delivery_type": widget.singleData!.isNotEmpty
            ? widget.singleData!["delivery_type"]
            : widget.multipleData!["delivery_type"],
        "bookings_destinations": [
          {
            "pickup_address": widget.singleData!.isNotEmpty
                ? widget.singleData!["pickup_address"]
                : widget.multipleData!["pickup_address0"],
            "pickup_latitude": widget.singleData!.isNotEmpty
                ? widget.singleData!["pickup_latitude"]
                : widget.multipleData!["pickup_latitude0"],
            "pickup_longitude": widget.singleData!.isNotEmpty
                ? widget.singleData!["pickup_longitude"]
                : widget.multipleData!["pickup_longitude0"],
            "destin_address": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_address"]
                : widget.multipleData!["destin_address0"],
            "destin_latitude": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_latitude"]
                : widget.multipleData!["destin_latitude0"],
            "destin_longitude": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_longitude"]
                : widget.multipleData!["destin_longitude0"],
            "destin_distance": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_distance"]
                : widget.multipleData!["destin_distance0"],
            "destin_time": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_time"]
                : widget.multipleData!["destin_time0"],
            "destin_delivery_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_delivery_charges"]
                : widget.multipleData!["destin_delivery_charges0"],
            "destin_vat_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_vat_charges"]
                : widget.multipleData!["destin_vat_charges0"],
            "destin_total_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_total_charges"]
                : widget.multipleData!["destin_total_charges0"],
            "destin_discount": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_discount"]
                : widget.multipleData!["destin_discount0"],
            "destin_discounted_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_discounted_charges"]
                : widget.multipleData!["destin_discounted_charges0"],
            "receiver_name": widget.singleData!.isNotEmpty
                ? widget.singleData!["receiver_name"]
                : widget.multipleData!["receiver_name0"],
            "receiver_phone": widget.singleData!.isNotEmpty
                ? widget.singleData!["receiver_phone"]
                : widget.multipleData!["receiver_phone0"],
          },
          if (widget.multipleData!["pickup_address1"] != null &&
              widget.multipleData!["pickup_address1"].isNotEmpty)
            {
              "pickup_address": widget.multipleData!["pickup_address1"],
              "pickup_latitude": widget.multipleData!["pickup_latitude1"],
              "pickup_longitude": widget.multipleData!["pickup_longitude1"],
              "destin_address": widget.multipleData!["destin_address1"],
              "destin_latitude": widget.multipleData!["destin_latitude1"],
              "destin_longitude": widget.multipleData!["destin_longitude1"],
              "destin_distance": widget.multipleData!["destin_distance1"],
              "destin_time": widget.multipleData!["destin_time1"],
              "destin_delivery_charges":
                  widget.multipleData!["destin_delivery_charges1"],
              "destin_vat_charges": widget.multipleData!["destin_vat_charges1"],
              "destin_total_charges":
                  widget.multipleData!["destin_total_charges1"],
              "destin_discount": widget.multipleData!["destin_discount1"],
              "destin_discounted_charges":
                  widget.multipleData!["destin_discounted_charges1"],
              "receiver_name": widget.multipleData!["receiver_name1"],
              "receiver_phone": widget.multipleData!["receiver_phone1"],
            },
          if (widget.multipleData!["pickup_address2"] != null &&
              widget.multipleData!["pickup_address2"].isNotEmpty)
            {
              "pickup_address": widget.multipleData!["pickup_address2"],
              "pickup_latitude": widget.multipleData!["pickup_latitude2"]
                  ["latitude"],
              "pickup_longitude": widget.multipleData!["pickup_longitude2"]
                  ["longitude"],
              "destin_address": widget.multipleData!["destin_address2"],
              "destin_latitude": widget.multipleData!["destin_latitude2"]
                  ["latitude"],
              "destin_longitude": widget.multipleData!["destin_longitude2"]
                  ["longitude"],
              "destin_distance": widget.multipleData!["destin_distance2"],
              "destin_time": widget.multipleData!["destin_time2"],
              "destin_delivery_charges":
                  widget.multipleData!["destin_delivery_charges2"],
              "destin_vat_charges": widget.multipleData!["destin_vat_charges2"],
              "destin_total_charges":
                  widget.multipleData!["destin_total_charges2"],
              "destin_discount": widget.multipleData!["destin_discount2"],
              "destin_discounted_charges":
                  widget.multipleData!["destin_discounted_charges2"],
              "receiver_name": widget.multipleData!["receiver_name2"],
              "receiver_phone": widget.multipleData!["receiver_phone2"],
            },
          if (widget.multipleData!["pickup_address3"] != null &&
              widget.multipleData!["pickup_address3"].isNotEmpty)
            {
              "pickup_address": widget.multipleData!["pickup_address3"],
              "pickup_latitude": widget.multipleData!["pickup_latitude3"]
                  ["latitude"],
              "pickup_longitude": widget.multipleData!["pickup_longitude3"]
                  ["longitude"],
              "destin_address": widget.multipleData!["destin_address3"],
              "destin_latitude": widget.multipleData!["destin_latitude3"]
                  ["latitude"],
              "destin_longitude": widget.multipleData!["destin_longitude3"]
                  ["longitude"],
              "destin_distance": widget.multipleData!["destin_distance3"],
              "destin_time": widget.multipleData!["destin_time3"],
              "destin_delivery_charges":
                  widget.multipleData!["destin_delivery_charges3"],
              "destin_vat_charges": widget.multipleData!["destin_vat_charges3"],
              "destin_total_charges":
                  widget.multipleData!["destin_total_charges3"],
              "destin_discount": widget.multipleData!["destin_discount3"],
              "destin_discounted_charges":
                  widget.multipleData!["destin_discounted_charges3"],
              "receiver_name": widget.multipleData!["receiver_name3"],
              "receiver_phone": widget.multipleData!["receiver_phone3"],
            },
          if (widget.multipleData!["pickup_address4"] != null &&
              widget.multipleData!["pickup_address4"].isNotEmpty)
            {
              "pickup_address": widget.multipleData!["pickup_address4"],
              "pickup_latitude": widget.multipleData!["pickup_latitude4"]
                  ["latitude"],
              "pickup_longitude": widget.multipleData!["pickup_longitude4"]
                  ["longitude"],
              "destin_address": widget.multipleData!["destin_address4"],
              "destin_latitude": widget.multipleData!["destin_latitude4"]
                  ["latitude"],
              "destin_longitude": widget.multipleData!["destin_longitude4"]
                  ["longitude"],
              "destin_distance": widget.multipleData!["destin_distance4"],
              "destin_time": widget.multipleData!["destin_time4"],
              "destin_delivery_charges":
                  widget.multipleData!["destin_delivery_charges4"],
              "destin_vat_charges": widget.multipleData!["destin_vat_charges4"],
              "destin_total_charges":
                  widget.multipleData!["destin_total_charges4"],
              "destin_discount": widget.multipleData!["destin_discount4"],
              "destin_discounted_charges":
                  widget.multipleData!["destin_discounted_charges4"],
              "receiver_name": widget.multipleData!["receiver_name4"],
              "receiver_phone": widget.multipleData!["receiver_phone4"],
            },
        ],
        "total_delivery_charges": widget.singleData!.isNotEmpty
            ? widget.singleData!["destin_total_charges"]
            : widget.multipleData!["destin_total_charges"],
        "total_vat_charges": widget.singleData!.isNotEmpty
            ? widget.singleData!["total_vat_charges"]
            : widget.multipleData!["total_vat_charges"],
        "total_charges": widget.singleData!.isNotEmpty
            ? widget.singleData!["total_charges"]
            : widget.multipleData!["total_charges"],
        "total_discount": widget.singleData!.isNotEmpty
            ? widget.singleData!["total_discount"]
            : widget.multipleData!["total_discount"],
        "total_discounted_charges": widget.singleData!.isNotEmpty
            ? widget.singleData!["total_discounted_charges"]
            : widget.multipleData!["total_discounted_charges"],
        "payment_gateways_id": widget.singleData!.isNotEmpty
            ? widget.singleData!["payment_gateways_id"]
            : widget.multipleData!["payment_gateways_id"],
        "payment_by": widget.singleData!.isNotEmpty
            ? widget.singleData!["payment_by"]
            : widget.multipleData!["payment_by"],
        "payment_status": "Unpaid"
      };
      String apiUrl = "$baseUrl/send_request_booking";
      print("apiUrl: $apiUrl");
      print("requestData: $requestData");
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
        "vehicles_id": widget.singleData!.isNotEmpty
            ? widget.singleData!["vehicles_id"]
            : widget.multipleData!["vehicles_id"],
        "users_customers_id": userId,
        "bookings_types_id": widget.singleData!.isNotEmpty
            ? widget.singleData!["bookings_types_id"]
            : widget.multipleData!["bookings_types_id"],
        "delivery_type": widget.singleData!.isNotEmpty
            ? widget.singleData!["delivery_type"]
            : widget.multipleData!["delivery_type"],
        "bookings_destinations": [
          {
            "pickup_address": widget.singleData!.isNotEmpty
                ? widget.singleData!["pickup_address"]
                : widget.multipleData!["pickup_address0"],
            "pickup_latitude": widget.singleData!.isNotEmpty
                ? widget.singleData!["pickup_latitude"]
                : widget.multipleData!["pickup_latitude0"],
            "pickup_longitude": widget.singleData!.isNotEmpty
                ? widget.singleData!["pickup_longitude"]
                : widget.multipleData!["pickup_longitude0"],
            "destin_address": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_address"]
                : widget.multipleData!["destin_address0"],
            "destin_latitude": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_latitude"]
                : widget.multipleData!["destin_latitude0"],
            "destin_longitude": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_longitude"]
                : widget.multipleData!["destin_longitude0"],
            "destin_distance": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_distance"]
                : widget.multipleData!["destin_distance0"],
            "destin_time": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_time"]
                : widget.multipleData!["destin_time0"],
            "destin_delivery_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_delivery_charges"]
                : widget.multipleData!["destin_delivery_charges0"],
            "destin_vat_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_vat_charges"]
                : widget.multipleData!["destin_vat_charges0"],
            "destin_total_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_total_charges"]
                : widget.multipleData!["destin_total_charges0"],
            "destin_discount": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_discount"]
                : widget.multipleData!["destin_discount0"],
            "destin_discounted_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["destin_discounted_charges"]
                : widget.multipleData!["destin_discounted_charges0"],
            "receiver_name": widget.singleData!.isNotEmpty
                ? widget.singleData!["receiver_name"]
                : widget.multipleData!["receiver_name0"],
            "receiver_phone": widget.singleData!.isNotEmpty
                ? widget.singleData!["receiver_phone"]
                : widget.multipleData!["receiver_phone0"],
          },
          if (widget.multipleData!["pickup_address1"] != null &&
              widget.multipleData!["pickup_address1"].isNotEmpty)
            {
              "pickup_address": widget.multipleData!["pickup_address1"],
              "pickup_latitude": widget.multipleData!["pickup_latitude1"],
              "pickup_longitude": widget.multipleData!["pickup_longitude1"],
              "destin_address": widget.multipleData!["destin_address1"],
              "destin_latitude": widget.multipleData!["destin_latitude1"],
              "destin_longitude": widget.multipleData!["destin_longitude1"],
              "destin_distance": widget.multipleData!["destin_distance1"],
              "destin_time": widget.multipleData!["destin_time1"],
              "destin_delivery_charges":
                  widget.multipleData!["destin_delivery_charges1"],
              "destin_vat_charges": widget.multipleData!["destin_vat_charges1"],
              "destin_total_charges":
                  widget.multipleData!["destin_total_charges1"],
              "destin_discount": widget.multipleData!["destin_discount1"],
              "destin_discounted_charges":
                  widget.multipleData!["destin_discounted_charges1"],
              "receiver_name": widget.multipleData!["receiver_name1"],
              "receiver_phone": widget.multipleData!["receiver_phone1"],
            },
          if (widget.multipleData!["pickup_address2"] != null &&
              widget.multipleData!["pickup_address2"].isNotEmpty)
            {
              "pickup_address": widget.multipleData!["pickup_address2"],
              "pickup_latitude": widget.multipleData!["pickup_latitude2"]
                  ["latitude"],
              "pickup_longitude": widget.multipleData!["pickup_longitude2"]
                  ["longitude"],
              "destin_address": widget.multipleData!["destin_address2"],
              "destin_latitude": widget.multipleData!["destin_latitude2"]
                  ["latitude"],
              "destin_longitude": widget.multipleData!["destin_longitude2"]
                  ["longitude"],
              "destin_distance": widget.multipleData!["destin_distance2"],
              "destin_time": widget.multipleData!["destin_time2"],
              "destin_delivery_charges":
                  widget.multipleData!["destin_delivery_charges2"],
              "destin_vat_charges": widget.multipleData!["destin_vat_charges2"],
              "destin_total_charges":
                  widget.multipleData!["destin_total_charges2"],
              "destin_discount": widget.multipleData!["destin_discount2"],
              "destin_discounted_charges":
                  widget.multipleData!["destin_discounted_charges2"],
              "receiver_name": widget.multipleData!["receiver_name2"],
              "receiver_phone": widget.multipleData!["receiver_phone2"],
            },
          if (widget.multipleData!["pickup_address3"] != null &&
              widget.multipleData!["pickup_address3"].isNotEmpty)
            {
              "pickup_address": widget.multipleData!["pickup_address3"],
              "pickup_latitude": widget.multipleData!["pickup_latitude3"]
                  ["latitude"],
              "pickup_longitude": widget.multipleData!["pickup_longitude3"]
                  ["longitude"],
              "destin_address": widget.multipleData!["destin_address3"],
              "destin_latitude": widget.multipleData!["destin_latitude3"]
                  ["latitude"],
              "destin_longitude": widget.multipleData!["destin_longitude3"]
                  ["longitude"],
              "destin_distance": widget.multipleData!["destin_distance3"],
              "destin_time": widget.multipleData!["destin_time3"],
              "destin_delivery_charges":
                  widget.multipleData!["destin_delivery_charges3"],
              "destin_vat_charges": widget.multipleData!["destin_vat_charges3"],
              "destin_total_charges":
                  widget.multipleData!["destin_total_charges3"],
              "destin_discount": widget.multipleData!["destin_discount3"],
              "destin_discounted_charges":
                  widget.multipleData!["destin_discounted_charges3"],
              "receiver_name": widget.multipleData!["receiver_name3"],
              "receiver_phone": widget.multipleData!["receiver_phone3"],
            },
          if (widget.multipleData!["pickup_address4"] != null &&
              widget.multipleData!["pickup_address4"].isNotEmpty)
            {
              "pickup_address": widget.multipleData!["pickup_address4"],
              "pickup_latitude": widget.multipleData!["pickup_latitude4"]
                  ["latitude"],
              "pickup_longitude": widget.multipleData!["pickup_longitude4"]
                  ["longitude"],
              "destin_address": widget.multipleData!["destin_address4"],
              "destin_latitude": widget.multipleData!["destin_latitude4"]
                  ["latitude"],
              "destin_longitude": widget.multipleData!["destin_longitude4"]
                  ["longitude"],
              "destin_distance": widget.multipleData!["destin_distance4"],
              "destin_time": widget.multipleData!["destin_time4"],
              "destin_delivery_charges":
                  widget.multipleData!["destin_delivery_charges4"],
              "destin_vat_charges": widget.multipleData!["destin_vat_charges4"],
              "destin_total_charges":
                  widget.multipleData!["destin_total_charges4"],
              "destin_discount": widget.multipleData!["destin_discount4"],
              "destin_discounted_charges":
                  widget.multipleData!["destin_discounted_charges4"],
              "receiver_name": widget.multipleData!["receiver_name4"],
              "receiver_phone": widget.multipleData!["receiver_phone4"],
            },
        ],
        "delivery_date": widget.singleData!.isNotEmpty
            ? widget.singleData!["delivery_date"]
            : widget.multipleData!["delivery_date"],
        "delivery_time": widget.singleData!.isNotEmpty
            ? widget.singleData!["delivery_time"]
            : widget.multipleData!["delivery_time"],
        "total_delivery_charges": widget.singleData!.isNotEmpty
            ? widget.singleData!["destin_total_charges"]
            : widget.multipleData!["destin_total_charges"],
        "total_vat_charges": widget.singleData!.isNotEmpty
            ? widget.singleData!["total_vat_charges"]
            : widget.multipleData!["total_vat_charges"],
        "total_charges": widget.singleData!.isNotEmpty
            ? widget.singleData!["total_charges"]
            : widget.multipleData!["total_charges"],
        "total_discount": widget.singleData!.isNotEmpty
            ? widget.singleData!["total_discount"]
            : widget.multipleData!["total_discount"],
        "total_discounted_charges": widget.singleData!.isNotEmpty
            ? widget.singleData!["total_discounted_charges"]
            : widget.multipleData!["total_discounted_charges"],
        "payment_gateways_id": widget.singleData!.isNotEmpty
            ? widget.singleData!["payment_gateways_id"]
            : widget.multipleData!["payment_gateways_id"],
        "payment_by": widget.singleData!.isNotEmpty
            ? widget.singleData!["payment_by"]
            : widget.multipleData!["payment_by"],
        "payment_status": "Unpaid"
      };
      String apiUrl = "$baseUrl/send_request_booking_scheduled";
      print("apiUrl: $apiUrl");
      print("requestData: $requestData");
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

  calculateDistance() {
    distanceKm = double.parse("${widget.searchRider?.distance}");
    print('distanceKm: $distanceKm');

    if (distanceKm! > 10.00) {
      distanceKm = null; // Set distanceKm to null or another sentinel value
    } else {
      distanceMeters = distanceKm! * 1000;
      distanceFormatted = distanceMeters!.toStringAsFixed(0);
      print('distanceFormatted: $distanceFormatted');
    }
  }

  @override
  initState() {
    super.initState();
    calculateDistance();
    print('singleData: ${widget.singleData}');
    print('multipleData: ${widget.multipleData}');
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
                      if (widget.singleData?["type"] == "booking" ||
                          widget.multipleData?["type"] == "booking") {
                        print("booking");
                        calculateDistance();
                        await createBooking();
                        if (createBookingModel.data != null) {
                          if (createBookingModel.status == 'success') {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DriverFoundScreen(
                                  bookingId: createBookingModel.data?.bookingsId
                                      .toString(),
                                  fleetId:
                                      "${widget.searchRider?.usersFleetId}",
                                  currentBookingId: currentBookingId,
                                  passCode: createBookingModel
                                      .data
                                      ?.bookingsFleet?[0]
                                      .bookingsDestinations
                                      ?.passcode,
                                  distance: distanceKm,
                                  singleData: widget.singleData,
                                  multipleData: widget.multipleData,
                                  riderData: widget.searchRider,
                                  bookingDestinationId: createBookingModel.data
                                      ?.bookingsFleet?[0].bookingsDestinationsId
                                      .toString(),
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
                      } else {
                        print("schedule");
                        calculateDistance();
                        await scheduleBooking();
                        if (scheduleBookingModel.status == 'success') {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const HomePageScreen()));
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
