// ignore_for_file: avoid_print

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/cancelled_ride_model.dart';
import 'package:deliver_client/screens/home/drawer/ride_history/ride_history_details/cancelled_details_screen.dart';

String? userId;

class CancelledList extends StatefulWidget {
  const CancelledList({super.key});

  @override
  State<CancelledList> createState() => _CancelledListState();
}

class _CancelledListState extends State<CancelledList> {
  bool isLoading = false;

  CancelledRideModel cancelledRideModel = CancelledRideModel();

  cancelledRide() async {
    try {
      setState(() {
        isLoading = true;
      });
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/get_bookings_cancelled_customers";
      print("apiUrl: $apiUrl");
      print("userId: $userId");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "users_customers_id": userId,
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        cancelledRideModel = cancelledRideModelFromJson(responseString);
        print('cancelledRideModel status: ${cancelledRideModel.status}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      setState(() {
        isLoading = false;
      });
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    cancelledRide();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return isLoading
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
        : cancelledRideModel.data != null
            ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: cancelledRideModel.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "12 min ago",
                        // '${cancelledRideModel.data![index].rideCancelled}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: sheetBarrierColor,
                          fontSize: 14,
                          fontFamily: 'Inter-Medium',
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
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 10,
                          ),
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
                                              '$imageUrl${cancelledRideModel.data![index].bookingsFleet?[0].usersFleet?.profilePic}',
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
                                            width: size.width * 0.44,
                                            child: AutoSizeText(
                                              '${cancelledRideModel.data![index].bookingsFleet?[0].usersFleet?.firstName} ${cancelledRideModel.data![index].bookingsFleet?[0].usersFleet?.lastName}',
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
                                                '${cancelledRideModel.data![index].bookingsFleet?[0].usersFleetVehicles?.color} ',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 12,
                                                  fontFamily: 'Inter-Regular',
                                                ),
                                              ),
                                              Text(
                                                '${cancelledRideModel.data![index].bookingsFleet?[0].usersFleetVehicles?.model}',
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
                                            '${cancelledRideModel.data![index].bookingsFleet?[0].usersFleetVehicles?.vehicleRegistrationNo}',
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
                                  SizedBox(height: size.height * 0.02),
                                ],
                              ),
                              Positioned(
                                bottom: 15,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RideHistoryCancelledDetailsScreen(
                                          cancelledRideModel:
                                              cancelledRideModel.data?[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: detailButtonGradientSmall(
                                      'See detail', context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
                  );
                },
              )
            : Padding(
                padding: const EdgeInsets.only(top: 180),
                child: Column(
                  children: [
                    Lottie.asset('assets/images/no-data-icon.json'),
                    SizedBox(height: size.height * 0.04),
                    Text(
                      "No Ride is Cancelled",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textHaveAccountColor,
                        fontSize: 24,
                        fontFamily: 'Syne-SemiBold',
                      ),
                    ),
                  ],
                ),
              );
  }
}
