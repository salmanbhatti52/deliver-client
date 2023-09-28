// ignore_for_file: avoid_print

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/screens/report_screen.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/screens/payment/amount_to_pay_edit_screen.dart';

class InProgressHomeScreen extends StatefulWidget {
  final Map? singleData;
  final String? currentBookingId;
  final SearchRiderData? riderData;
  const InProgressHomeScreen({
    super.key,
    this.singleData,
    this.currentBookingId,
    this.riderData,
  });

  @override
  State<InProgressHomeScreen> createState() => _InProgressHomeScreenState();
}

class _InProgressHomeScreenState extends State<InProgressHomeScreen> {
  bool isLoading = false;
  String? distanceUnit;

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

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
        getAllSystemDataModel = getAllSystemDataModelFromJson(responseString);
        print('getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        print(
            'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
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
  initState() {
    super.initState();
    getAllSystemData();
    isLoading = true;
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: transparentColor,
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
          : widget.singleData != null
              ? Stack(
                  children: [
                    Image.asset(
                      'assets/images/tracking-location-background.png',
                      width: size.width,
                      height: size.height,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        child: Container(
                          width: size.width,
                          height: size.height * 0.51,
                          decoration: BoxDecoration(
                            color: whiteColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.04),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/small-black-send-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.03),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Destination Address",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter-Regular',
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          Tooltip(
                                            message:
                                                "${widget.singleData!['destin_address']}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.7,
                                              child: Text(
                                                "${widget.singleData!['destin_address']}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/orange-distance-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              "Estimated Distance to Destination",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: textHaveAccountColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter-Regular',
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          Text(
                                            "${widget.singleData!['destin_distance']} $distanceUnit",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: blackColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter-Medium',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/arrival-time-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              "Estimated Time of Arrival",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: textHaveAccountColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter-Regular',
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          Text(
                                            "${widget.singleData!['destin_time']}",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: blackColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter-Medium',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const AmountToPayEditScreen(),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            color: transparentColor,
                                            width: 55,
                                            height: 55,
                                            child: FadeInImage(
                                              placeholder: const AssetImage(
                                                "assets/images/user-profile.png",
                                              ),
                                              image: NetworkImage(
                                                '$imageUrl${widget.riderData!.profilePic}',
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.03),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                color: transparentColor,
                                                width: size.width * 0.45,
                                                child: AutoSizeText(
                                                  "${widget.riderData!.firstName} ${widget.riderData!.lastName}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: drawerTextColor,
                                                    fontSize: 16,
                                                    fontFamily: 'Syne-SemiBold',
                                                  ),
                                                  minFontSize: 16,
                                                  maxFontSize: 16,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(width: size.width * 0.1),
                                              Stack(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/star-with-container-icon.svg',
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 1.5, left: 24),
                                                    child: Text(
                                                      "${widget.riderData!.bookingsRatings}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Regular',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.62,
                                            child: AutoSizeText(
                                              "${widget.riderData!.usersFleetVehicles!.color} ${widget.riderData!.usersFleetVehicles!.model} (${widget.riderData!.usersFleetVehicles!.vehicleRegistrationNo})",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: textHaveAccountColor,
                                                fontSize: 14,
                                                fontFamily: 'Syne-Regular',
                                              ),
                                              maxFontSize: 14,
                                              minFontSize: 12,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.002),
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-grey-location-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.01),
                                                  Tooltip(
                                                    message:
                                                        "${widget.riderData!.address}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.3,
                                                      child: AutoSizeText(
                                                        "${widget.riderData!.address}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color:
                                                              textHaveAccountColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Syne-Regular',
                                                        ),
                                                        maxFontSize: 14,
                                                        minFontSize: 12,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.01),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-grey-arrival-time-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.01),
                                                  Tooltip(
                                                    message:
                                                        "ETA ${widget.singleData!['destin_time']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.23,
                                                      child: Text(
                                                        "ETA ${widget.singleData!['destin_time']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color:
                                                              textHaveAccountColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Syne-Regular',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.02),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReportScreen(
                                                        riderData:
                                                            widget.riderData,
                                                        currentBookingId: widget
                                                            .currentBookingId,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: SvgPicture.asset(
                                                  'assets/images/report-icon.svg',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/small-white-send-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.03),
                                      Text(
                                        "Pickup",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Tooltip(
                                        message:
                                            "${widget.singleData!['pickup_address']}",
                                        child: Container(
                                          color: transparentColor,
                                          width: size.width * 0.6,
                                          child: Text(
                                            "${widget.singleData!['pickup_address']}",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: blackColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter-Medium',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/small-white-send-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.03),
                                      Text(
                                        "Destination",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Tooltip(
                                        message:
                                            "${widget.singleData!['destin_address']}",
                                        child: Container(
                                          color: transparentColor,
                                          width: size.width * 0.53,
                                          child: Text(
                                            "${widget.singleData!['destin_address']}",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: blackColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter-Medium',
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 180),
                  child: Column(
                    children: [
                      Lottie.asset('assets/images/no-data-icon.json'),
                      SizedBox(height: size.height * 0.04),
                      Text(
                        "No Ride Inprogress",
                        textAlign: TextAlign.center,
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
}
