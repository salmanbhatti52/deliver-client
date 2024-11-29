// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/models/cancelled_ride_model.dart';

class RideHistoryCancelledDetailsScreen extends StatefulWidget {
  final Datum? cancelledRideModel;

  const RideHistoryCancelledDetailsScreen({
    super.key,
    this.cancelledRideModel,
  });

  @override
  State<RideHistoryCancelledDetailsScreen> createState() =>
      _RideHistoryCancelledDetailsScreenState();
}

class _RideHistoryCancelledDetailsScreenState
    extends State<RideHistoryCancelledDetailsScreen> {
  DateTime? timeAdded;
  String? imageUrl = dotenv.env['IMAGE_URL'];

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
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    timeAdded = DateTime.parse("${widget.cancelledRideModel?.dateModified}");
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
        child: Column(
          children: [
            SizedBox(height: size.height * 0.02),
            Container(
              color: transparentColor,
              height: size.height * 0.78,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      formatTimeDifference(timeAdded!),
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
                      child: Column(
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
                                  child: widget.cancelledRideModel?.bookingsFleet?[0].usersFleet?.profilePic != null
                                      ? FadeInImage(
                                    placeholder: const AssetImage("assets/images/user-profile.png"),
                                    image: NetworkImage(
                                      '$imageUrl${widget.cancelledRideModel?.bookingsFleet?[0].usersFleet?.profilePic}',
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                      : Image.asset(
                                    "assets/images/user-profile.png", // Asset fallback image
                                    fit: BoxFit.cover,
                                  ),
                                  // child: FadeInImage(
                                  //   placeholder: const AssetImage(
                                  //     "assets/images/user-profile.png",
                                  //   ),
                                  //   image: NetworkImage(
                                  //     '$imageUrl${widget.cancelledRideModel?.bookingsFleet?[0].usersFleet?.profilePic}',
                                  //   ),
                                  //   fit: BoxFit.cover,
                                  // ),
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.6,
                                    child: AutoSizeText(
                                      '${widget.cancelledRideModel?.bookingsFleet?[0].usersFleet?.firstName} ${widget.cancelledRideModel?.bookingsFleet?[0].usersFleet?.lastName}',
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
                                        '${widget.cancelledRideModel?.bookingsFleet?[0].usersFleetVehicles?.color} ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 12,
                                          fontFamily: 'Inter-Regular',
                                        ),
                                      ),
                                      Text(
                                        '${widget.cancelledRideModel?.bookingsFleet?[0].usersFleetVehicles?.model}',
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
                                    '${widget.cancelledRideModel?.bookingsFleet?[0].usersFleetVehicles?.vehicleRegistrationNo}',
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/images/orange-location-big-icon.svg',
                              ),
                              SizedBox(width: size.width * 0.02),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        "${widget.cancelledRideModel?.bookingsFleet?[0].bookingsDestinations?.pickupAddress}",
                                    child: Container(
                                      color: transparentColor,
                                      width: size.width * 0.7,
                                      child: AutoSizeText(
                                        "${widget.cancelledRideModel?.bookingsFleet?[0].bookingsDestinations?.pickupAddress}",
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
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
