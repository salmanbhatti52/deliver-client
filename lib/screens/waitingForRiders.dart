// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:deliver_client/screens/booking_accepted_screen.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();
  String? responseString1;

  @override
  void initState() {
    super.initState();
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
      updateBookingStatusModel = updateBookingStatusModelFromJson(response.body);
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
              'No rider accepted your ride request.',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            actions: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const HomePageScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
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
