// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
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
  @override
  void initState() {
    super.initState();
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
                      "12 min ago",
                      // '${widget.cancelledRideModel?.rideCancelled}',
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
                                  child: FadeInImage(
                                    placeholder: const AssetImage(
                                      "assets/images/user-profile.png",
                                    ),
                                    image: NetworkImage(
                                      '$imageUrl${widget.cancelledRideModel?.bookingsFleet?[0].usersFleet?.profilePic}',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
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
                              SizedBox(width: size.width * 0.04),
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
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.6,
                                    child: AutoSizeText(
                                      "${widget.cancelledRideModel?.pickupAddress}",
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
