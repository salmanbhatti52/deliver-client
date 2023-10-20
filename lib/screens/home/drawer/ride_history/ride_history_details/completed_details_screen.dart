// ignore_for_file: avoid_print

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/models/completed_ride_model.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart'
    as system_data;

class RideHistoryCompletedDetailsScreen extends StatefulWidget {
  final Datum? completedRideModel;

  const RideHistoryCompletedDetailsScreen({
    super.key,
    this.completedRideModel,
  });

  @override
  State<RideHistoryCompletedDetailsScreen> createState() =>
      _RideHistoryCompletedDetailsScreenState();
}

class _RideHistoryCompletedDetailsScreenState
    extends State<RideHistoryCompletedDetailsScreen> {
  String? currencyUnit;
  String? distanceUnit;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  system_data.GetAllSystemDataModel getAllSystemDataModel =
      system_data.GetAllSystemDataModel();

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
            system_data.getAllSystemDataModelFromJson(responseString);
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            color: transparentColor,
                                            width: 60,
                                            height: 65,
                                            child: FadeInImage(
                                              placeholder: const AssetImage(
                                                "assets/images/user-profile.png",
                                              ),
                                              image: NetworkImage(
                                                '$imageUrl${widget.completedRideModel?.bookingsFleet?[0].usersFleet?.profilePic}',
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
                                                "${widget.completedRideModel?.bookingsFleet?[0].usersFleet?.firstName} ${widget.completedRideModel?.bookingsFleet?[0].usersFleet?.lastName}",
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
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              children: [
                                                Text(
                                                  '${widget.completedRideModel?.bookingsFleet?[0].usersFleetVehicles?.vehicleRegistrationNo}} ',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 12,
                                                    fontFamily: 'Inter-Regular',
                                                  ),
                                                ),
                                                Text(
                                                  '${widget.completedRideModel?.bookingsFleet?[0].usersFleetVehicles?.vehicleRegistrationNo}}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 12,
                                                    fontFamily: 'Inter-Regular',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.005),
                                            Text(
                                              '${widget.completedRideModel?.bookingsFleet?[0].usersFleetVehicles?.vehicleRegistrationNo}}',
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
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Container(
                                              color: transparentColor,
                                              width: size.width * 0.6,
                                              child: AutoSizeText(
                                                "${widget.completedRideModel?.pickupAddress}",
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
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Container(
                                              color: transparentColor,
                                              width: size.width * 0.6,
                                              child: AutoSizeText(
                                                "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinAddress}",
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
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Tooltip(
                                              message:
                                                  "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinDistance} $distanceUnit",
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.18,
                                                child: AutoSizeText(
                                                  "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinDistance} $distanceUnit",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Regular',
                                                  ),
                                                  maxFontSize: 14,
                                                  minFontSize: 12,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Tooltip(
                                              message:
                                                  "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinTime}",
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.38,
                                                child: AutoSizeText(
                                                  "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinTime}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Regular',
                                                  ),
                                                  maxFontSize: 14,
                                                  minFontSize: 12,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Tooltip(
                                              message:
                                                  "$currencyUnit${widget.completedRideModel?.totalCharges}",
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.2,
                                                child: AutoSizeText(
                                                  "$currencyUnit${widget.completedRideModel?.totalCharges}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Regular',
                                                  ),
                                                  maxFontSize: 14,
                                                  minFontSize: 12,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                          // barrierColor: sheetBarrierColor,
                                          builder: (context) =>
                                              rebookRide(context),
                                        );
                                      },
                                      child: buttonGradient("REBOOK", context),
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
                                    '${widget.completedRideModel?.bookingsFleet?[0].usersFleet?.bookingsRatings}',
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
                  ),
                ],
              ),
            ),
    );
  }
}

Widget rebookRide(BuildContext context) {
  var size = MediaQuery.of(context).size;
  return GestureDetector(
    onTap: () {
      FocusManager.instance.primaryFocus?.unfocus();
    },
    child: WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        insetPadding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
          height: size.height * 0.45,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                SvgPicture.asset('assets/images/hourglass-icon.svg'),
                SizedBox(height: size.height * 0.03),
                Text(
                  'Time up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: orangeColor,
                    fontSize: 20,
                    fontFamily: 'Syne-Bold',
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'You can not rebook this ride after 5\nmins of completing the ride.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 18,
                    fontFamily: 'Syne-Regular',
                  ),
                ),
                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
