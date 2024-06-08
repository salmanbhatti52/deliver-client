import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/tabbar_ride_history.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

class RideHistoryScreen extends StatefulWidget {
  final int? index;
  final Map? singleData;
  final Map? multipleData;
  final String? passCode;
  final String? currentBookingId;
  final UpdateBookingStatusModel? riderData;
  final String? bookingDestinationId;
  const RideHistoryScreen({
    super.key,
    this.index,
    this.singleData,
    this.multipleData,
    this.passCode,
    this.currentBookingId,
    this.riderData,
    this.bookingDestinationId,});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePageScreen()),
            (Route<dynamic> route) => false);
        return false;
      },
      child: Scaffold(
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
            "Ride History",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: blackColor,
              fontSize: 20,
              fontFamily: 'Syne-Bold',
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.03),
                TabbarRideHistory(
                  singleData: widget.singleData,
                  passCode: widget.passCode,
                  multipleData: widget.multipleData,
                  currentBookingId: widget.currentBookingId,
                  riderData: widget.riderData,
                  bookingDestinationId: widget.bookingDestinationId,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
