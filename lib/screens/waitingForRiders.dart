// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:deliver_client/models/create_booking_model.dart';
import 'package:deliver_client/screens/booking_accepted_screen.dart';
import 'package:deliver_client/screens/chat_screen.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/screens/search_riders_screen.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:deliver_client/widgets/remove_coma.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaitingForRiders extends StatefulWidget {
  final double? distance;
  final Map? singleData;
  final Map? multipleData;
  final String? passCode;
  final String? currentBookingId;
  // final SearchRiderData? riderData;
  final String? bookingDestinationId;
  const WaitingForRiders(
      {super.key,
      this.distance,
      this.singleData,
      this.multipleData,
      this.passCode,
      this.currentBookingId,
      // this.riderData,
      this.bookingDestinationId});

  @override
  State<WaitingForRiders> createState() => _WaitingForRidersState();
}

class _WaitingForRidersState extends State<WaitingForRiders> {
  Timer? timer;
  Timer? timeoutTimer;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  String? currentBookingId;
  bool isLoading = false;
  List<Map<String, String>>? bookingsFleet;
  CreateBookingModel createBookingModel = CreateBookingModel();
  Future<void> createBooking() async {
    // try {
    setState(() {
      isLoading = true;
    });
    // SharedPreferences sharedPref = await SharedPreferences.getInstance();
    // final userId = sharedPref.getString('userId');
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('userId');
    print("userIdddddddddddddddddddddddddddd: $userId");
    final Map<String, dynamic> requestData = {
      // "users_fleet_id": searchRider?.usersFleetId,
      "bookings_fleet": bookingsFleet,
      "users_customers_id": userId.toString(),
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
              ? removeCommaFromString(
                  widget.singleData!["destin_delivery_charges"])
              : removeCommaFromString(
                  widget.multipleData!["destin_delivery_charges0"]),
          "destin_vat_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_vat_charges"]
              : widget.multipleData!["destin_vat_charges0"],
          "destin_total_charges": widget.singleData!.isNotEmpty
              ? removeCommaFromString(
                  widget.singleData!["destin_total_charges"])
              : removeCommaFromString(
                  widget.multipleData!["destin_total_charges0"]),
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
          "svc_running_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["svc_running_charges0"]
              : widget.multipleData!["svc_running_charges0"],
          if (widget.singleData!.isNotEmpty &&
              widget.singleData!["tollgate_charges0"] != null)
            "tollgate_charges": widget.singleData!["tollgate_charges0"],
          if (widget.singleData!.isEmpty &&
              widget.multipleData!["tollgate_charges0"] != null)
            "tollgate_charges": widget.multipleData!["tollgate_charges0"],
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
            "destin_delivery_charges": removeCommaFromString(
                widget.multipleData!["destin_delivery_charges1"]),
            "destin_vat_charges": widget.multipleData!["destin_vat_charges1"],
            "destin_total_charges": removeCommaFromString(
                widget.multipleData!["destin_total_charges1"]),
            "destin_discount":
                removeCommaFromString(widget.multipleData!["destin_discount1"]),
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges1"],
            "receiver_name": widget.multipleData!["receiver_name1"],
            "receiver_phone": widget.multipleData!["receiver_phone1"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? removeCommaFromString(
                    widget.singleData!["svc_running_charges1"])
                : removeCommaFromString(
                    widget.multipleData!["svc_running_charges1"]),
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges1"] != null)
              "tollgate_charges": removeCommaFromString(
                  widget.singleData!["tollgate_charges1"]),
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges1"] != null)
              "tollgate_charges": removeCommaFromString(
                  widget.multipleData!["tollgate_charges1"]),
          },
        if (widget.multipleData!["pickup_address2"] != null &&
            widget.multipleData!["pickup_address2"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address2"],
            "pickup_latitude": widget.multipleData!["pickup_latitude2"],
            "pickup_longitude": widget.multipleData!["pickup_longitude2"],
            "destin_address": widget.multipleData!["destin_address2"],
            "destin_latitude": widget.multipleData!["destin_latitude2"],
            "destin_longitude": widget.multipleData!["destin_longitude2"],
            "destin_distance": widget.multipleData!["destin_distance2"],
            "destin_time": widget.multipleData!["destin_time2"],
            "destin_delivery_charges": removeCommaFromString(
                widget.multipleData!["destin_delivery_charges2"]),
            "destin_vat_charges": widget.multipleData!["destin_vat_charges2"],
            "destin_total_charges": removeCommaFromString(
                widget.multipleData!["destin_total_charges2"]),
            "destin_discount":
                removeCommaFromString(widget.multipleData!["destin_discount2"]),
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges2"],
            "receiver_name": widget.multipleData!["receiver_name2"],
            "receiver_phone": widget.multipleData!["receiver_phone2"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges2"]
                : widget.multipleData!["svc_running_charges2"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges2"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges2"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges2"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges2"],
          },
        if (widget.multipleData!["pickup_address3"] != null &&
            widget.multipleData!["pickup_address3"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address3"],
            "pickup_latitude": widget.multipleData!["pickup_latitude3"],
            "pickup_longitude": widget.multipleData!["pickup_longitude3"],
            "destin_address": widget.multipleData!["destin_address3"],
            "destin_latitude": widget.multipleData!["destin_latitude3"],
            "destin_longitude": widget.multipleData!["destin_longitude3"],
            "destin_distance": widget.multipleData!["destin_distance3"],
            "destin_time": widget.multipleData!["destin_time3"],
            "destin_delivery_charges": removeCommaFromString(
                widget.multipleData!["destin_delivery_charges3"]),
            "destin_vat_charges": widget.multipleData!["destin_vat_charges3"],
            "destin_total_charges": removeCommaFromString(
                widget.multipleData!["destin_total_charges3"]),
            "destin_discount":
                removeCommaFromString(widget.multipleData!["destin_discount3"]),
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges3"],
            "receiver_name": widget.multipleData!["receiver_name3"],
            "receiver_phone": widget.multipleData!["receiver_phone3"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges3"]
                : widget.multipleData!["svc_running_charges3"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges3"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges3"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges3"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges3"],
          },
        if (widget.multipleData!["pickup_address4"] != null &&
            widget.multipleData!["pickup_address4"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address4"],
            "pickup_latitude": widget.multipleData!["pickup_latitude4"],
            "pickup_longitude": widget.multipleData!["pickup_longitude4"],
            "destin_address": widget.multipleData!["destin_address4"],
            "destin_latitude": widget.multipleData!["destin_latitude4"],
            "destin_longitude": widget.multipleData!["destin_longitude4"],
            "destin_distance": widget.multipleData!["destin_distance4"],
            "destin_time": widget.multipleData!["destin_time4"],
            "destin_delivery_charges": removeCommaFromString(
                widget.multipleData!["destin_delivery_charges4"]),
            "destin_vat_charges": widget.multipleData!["destin_vat_charges4"],
            "destin_total_charges": removeCommaFromString(
                widget.multipleData!["destin_total_charges4"]),
            "destin_discount": widget.multipleData!["destin_discount4"],
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges4"],
            "receiver_name": widget.multipleData!["receiver_name4"],
            "receiver_phone": widget.multipleData!["receiver_phone4"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges4"]
                : widget.multipleData!["svc_running_charges4"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges4"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges4"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges4"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges4"],
          },
      ],
      "service_running": widget.singleData!.isNotEmpty
          ? widget.singleData!["service_running"]
          : widget.multipleData!["service_running"],
      "total_svc_running_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_svc_running_charges"]
          : widget.multipleData!["total_svc_running_charges"],
      if (widget.singleData!.isNotEmpty &&
          widget.singleData!["tollgate_charges"] != null)
        "tollgate_charges": widget.singleData!["tollgate_charges"],
      if (widget.singleData!.isEmpty &&
          widget.multipleData!["tollgate_charges"] != null)
        "tollgate_charges": widget.multipleData!["tollgate_charges"],
      "delivery_date": widget.singleData!.isNotEmpty
          ? widget.singleData!["delivery_date"]
          : widget.multipleData!["delivery_date"],
      "delivery_time": widget.singleData!.isNotEmpty
          ? widget.singleData!["delivery_time"]
          : widget.multipleData!["delivery_time"],
      "total_delivery_charges": widget.singleData!.isNotEmpty
          ? removeCommaFromString(
              widget.singleData!["destin_total_charges"].toString())
          : removeCommaFromString(
              widget.multipleData!["destin_total_charges"].toString()),
      "total_vat_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_vat_charges"]
          : widget.multipleData!["total_vat_charges"],
      "total_charges": widget.singleData!.isNotEmpty
          ? removeCommaFromString(widget.singleData!["total_charges"])
          : removeCommaFromString(widget.multipleData!["total_charges"]),
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
    debugPrint("apiUrl: $apiUrl");
    debugPrint("requestData: $requestData");
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );
    final responseString = response.body;
    debugPrint("response: $responseString");
    debugPrint("statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      createBookingModel = createBookingModelFromJson(responseString);
      debugPrint('createBookingModel status: ${createBookingModel.status}');
      currentBookingId = createBookingModel.data?.bookingsId.toString();
      debugPrint('currentBookingId: $currentBookingId');
      setState(() {
        isLoading = false;
      });
    }
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();
  String? responseString1;

  bool systemSettings = false;
  String? round;

  Future<String?> fetchSystemSettingsDescription28() async {
    const String apiUrl = 'https://deliverbygfl.com/api/get_all_system_data';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        final Map<String, dynamic> data = json.decode(response.body);

        // Find the setting with system_settings_id equal to 396
        final setting396 = data['data'].firstWhere(
            (setting) => setting['system_settings_id'] == 396,
            orElse: () => null);

        if (setting396 != null) {
          // Extract and return the description if setting 28 exists
          round = setting396['description'];

          return round;
        } else {
          throw Exception('System setting with ID 396 not found');
        }
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to fetch system settings');
      }
    } catch (e) {
      // Catch any exception that might occur during the process
      print('Error fetching system settings: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSystemSettingsDescription28();
    startTimer();
    startTimeoutTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> updateBookingStatus() async {
    String apiUrl = "$baseUrl/get_updated_status_booking";
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        "bookings_id": widget.currentBookingId,
      },
    );

    if (response.statusCode == 200) {
      updateBookingStatusModel =
          updateBookingStatusModelFromJson(response.body);
      if (updateBookingStatusModel.data!.status == "Accepted") {
        timer!.cancel();
        timeoutTimer!.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookingAcceptedScreen(
              distance: widget.distance,
              singleData: widget.singleData,
              multipleData: widget.multipleData,
              passCode: widget.passCode,
              riderData: updateBookingStatusModel,
              currentBookingId: widget.currentBookingId,
              bookingDestinationId: widget.bookingDestinationId,
            ),
          ),
        );
      }
    }
  }

  void handleButtonTap() async {
    int? roundInt = int.tryParse(round ?? '0'); // Convert round to int

    if (tapCount < (roundInt ?? 0)) {
      // Check if tapCount is less than roundInt
      tapCount++; // Increment tap count
      Navigator.pop(context); // Close the bottom sheet

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => SearchRidersScreen(
      //       singleData: widget.singleData,
      //       multipleData: widget.multipleData,
      //     ),
      //   ),
      // );
    } else {
      CustomToast.showToast(
          message: "You have reached the maximum search LIMIT");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot search riders at this time.'),
        ),
      );
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      updateBookingStatus();
    });
  }

  void startTimeoutTimer() {
    timeoutTimer = Timer(const Duration(seconds: 45), () {
      timer!.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Ride Request',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            content: const Text(
              'No rider in your area. Please try again',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            actions: <Widget>[
              InkWell(
                onTap: () {
                  print("tapCount on Ride Request: $tapCount");
                  int? roundInt = int.tryParse(round!);
                  print("roundInt: $roundInt");
                  if (tapCount < roundInt!) {
                    tapCount++;
                    print("tapCount: $tapCount");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchRidersScreen(
                          singleData: widget.singleData,
                          multipleData: widget.multipleData,
                        ),
                      ),
                    );
                  } else {
                    print("tapCount on else: $tapCount");
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomePageScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                    CustomToast.showToast(
                        message: "You have reached the maximum search LIMIT");
                  }
                  // handleButtonTap();

                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(
                  //     builder: (context) => const HomePageScreen(),
                  //   ),
                  //   (Route<dynamic> route) => false,
                  // );
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.refresh,
                    color: Colors.green,
                    size: 30,
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            "Waiting for Riders",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: blackColor,
              fontSize: 20,
              fontFamily: 'Syne-Bold',
            ),
          ),
        ),
        actions: [
          InkWell(
            onTap: () async {},
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(
                Icons.refresh,
                color: blackColor,
                size: 22,
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SpinKitFadingCube(
                color: Colors.orange,
                size: 50.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
