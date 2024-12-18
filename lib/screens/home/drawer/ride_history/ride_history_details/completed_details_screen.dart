// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
  DateTime? timeAdded;
  String? currencyUnit;
  String? distanceUnit;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  system_data.GetAllSystemDataModel getAllSystemDataModel =
      system_data.GetAllSystemDataModel();
  String? deliverType;
  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();
  Map<String, dynamic>? jsonResponse;
  updateBookingStatus() async {
    // try {
    String apiUrl = "$baseUrl/get_updated_status_booking";
    debugPrint("apiUrl: $apiUrl");
    debugPrint(
        "currentBookingId: ${widget.completedRideModel!.bookingsFleet![0].bookingsId}");
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        "bookings_id":
            "${widget.completedRideModel!.bookingsFleet![0].bookingsId}",
      },
    );
    final responseString = response.body;
    debugPrint("response: $responseString");
    debugPrint("statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      updateBookingStatusModel =
          updateBookingStatusModelFromJson(responseString);
      debugPrint(
          'updateBookingStatusModel status: ${updateBookingStatusModel.status}');
      jsonResponse = jsonDecode(response.body);
    }
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  getAllSystemData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$baseUrl/get_all_system_data";
      debugPrint("apiUrl: $apiUrl");
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getAllSystemDataModel =
            system_data.getAllSystemDataModelFromJson(responseString);
        await updateBookingStatus();
        debugPrint(
            'getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        debugPrint(
            'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "system_currency") {
            currencyUnit = "${getAllSystemDataModel.data?[i].description}";
            debugPrint("currencyUnit: $currencyUnit");
          }
          if (getAllSystemDataModel.data?[i].type == "distance_unit") {
            distanceUnit = "${getAllSystemDataModel.data?[i].description}";
            debugPrint("distanceUnit: $distanceUnit");
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

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

  int _currentPage = 0;
  final _controller = PageController();

  @override
  void initState() {
    super.initState();
    getAllSystemData();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page!.round();
      });
    });
    print(
        "completedRideModel Delivery Type: ${widget.completedRideModel!.deliveryType}");

    print(
        "completedRideModel: ${widget.completedRideModel!.bookingsFleet![0].bookingsId}");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    timeAdded = DateTime.parse("${widget.completedRideModel?.dateModified}");
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
                  Expanded(
                    child: Container(
                      color: transparentColor,
                      // height: size.height * 0.78,
                      child: PageView.builder(
                          controller: _controller,
                          itemCount: updateBookingStatusModel
                              .data!.bookingsFleet!.length,
                          onPageChanged: (int page) {
                            setState(() {
                              _currentPage = page;
                            });
                          }, // replace with your actual item count
                          itemBuilder: (context, index) {
                            return Column(
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
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                                height: size.height * 0.02),
                                            Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: 60,
                                                    height: 65,
                                                    child: widget.completedRideModel?.bookingsFleet?[index].usersFleet?.profilePic != null
                                                        ? FadeInImage(
                                                      placeholder: const AssetImage("assets/images/user-profile.png"),
                                                      image: NetworkImage(
                                                        '$imageUrl${widget.completedRideModel?.bookingsFleet?[index].usersFleet?.profilePic}',
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                        : Image.asset(
                                                      "assets/images/user-profile.png", // Asset fallback image
                                                      fit: BoxFit.cover,
                                                    ),
                                                    // child: FadeInImage(
                                                    //   placeholder:
                                                    //       const AssetImage(
                                                    //     "assets/images/user-profile.png",
                                                    //   ),
                                                    //   image: NetworkImage(
                                                    //     '$imageUrl${widget.completedRideModel?.bookingsFleet?[index].usersFleet?.profilePic}',
                                                    //   ),
                                                    //   fit: BoxFit.cover,
                                                    // ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.45,
                                                      child: AutoSizeText(
                                                        "${widget.completedRideModel?.bookingsFleet?[index].usersFleet?.firstName} ${widget.completedRideModel?.bookingsFleet?[index].usersFleet?.lastName}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color:
                                                              drawerTextColor,
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'Syne-Bold',
                                                        ),
                                                        minFontSize: 16,
                                                        maxFontSize: 16,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${widget.completedRideModel?.bookingsFleet?[index].usersFleetVehicles?.color} ',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color:
                                                                textHaveAccountColor,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                'Inter-Regular',
                                                          ),
                                                        ),
                                                        Text(
                                                          '${widget.completedRideModel?.bookingsFleet?[index].usersFleetVehicles?.model}',
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color:
                                                                textHaveAccountColor,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                'Inter-Regular',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height: size.height *
                                                            0.005),
                                                    Text(
                                                      '${widget.completedRideModel?.bookingsFleet?[index].usersFleetVehicles?.vehicleRegistrationNo}',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            textHaveAccountColor,
                                                        fontSize: 12,
                                                        fontFamily:
                                                            'Inter-Regular',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.03),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/orange-location-big-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Pickup',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            textHaveAccountColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Syne-Regular',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "${widget.completedRideModel?.bookingsFleet?[index].bookingsDestinations?.pickupAddress}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.65,
                                                        child: AutoSizeText(
                                                          "${widget.completedRideModel?.bookingsFleet?[index].bookingsDestinations?.pickupAddress}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                          minFontSize: 14,
                                                          maxFontSize: 14,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Divider(
                                              thickness: 1,
                                              color: dividerColor,
                                              indent: 30,
                                              endIndent: 30,
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/send-small-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Dropoff',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color:
                                                            textHaveAccountColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Syne-Regular',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "${widget.completedRideModel?.bookingsFleet?[index].bookingsDestinations?.destinAddress}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.65,
                                                        child: AutoSizeText(
                                                          "${widget.completedRideModel?.bookingsFleet?[index].bookingsDestinations?.destinAddress}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                          minFontSize: 14,
                                                          maxFontSize: 14,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.03),
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
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "${widget.completedRideModel?.bookingsFleet?[index].bookingsDestinations?.destinDistance} $distanceUnit",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.18,
                                                        child: AutoSizeText(
                                                          "${widget.completedRideModel?.bookingsFleet?[index].bookingsDestinations?.destinDistance} $distanceUnit",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                textHaveAccountColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Regular',
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
                                                Column(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/images/grey-clock-icon.svg',
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "${widget.completedRideModel?.bookingsFleet?[index].bookingsDestinations?.destinTime}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.38,
                                                        child: AutoSizeText(
                                                          "${widget.completedRideModel?.bookingsFleet?[index].bookingsDestinations?.destinTime}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                textHaveAccountColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Regular',
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
                                                Column(
                                                  children: [
                                                    Text(
                                                      "$currencyUnit",
                                                      style: TextStyle(
                                                        color:
                                                            textHaveAccountColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Regular',
                                                      ),
                                                    ),
                                                    // SvgPicture.asset(
                                                    //   'assets/images/grey-dollar-icon.svg',
                                                    //   colorFilter:
                                                    //       ColorFilter.mode(
                                                    //           const Color(
                                                    //                   0xFF292D32)
                                                    //               .withOpacity(
                                                    //                   0.4),
                                                    //           BlendMode.srcIn),
                                                    // ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "$currencyUnit${widget.completedRideModel?.totalCharges}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width: size.width * 0.2,
                                                        child: AutoSizeText(
                                                          "$currencyUnit${widget.completedRideModel?.totalCharges}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                textHaveAccountColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Regular',
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
                                              ],
                                            ),
                                            // SizedBox(height: size.height * 0.03),
                                            // GestureDetector(
                                            //   onTap: () {
                                            //     showDialog(
                                            //       context: context,
                                            //       barrierDismissible: false,
                                            //        barrierColor: sheetBarrierColor,
                                            //       builder: (context) =>
                                            //           rebookRide(context),
                                            //     );
                                            //   },
                                            //   child: buttonGradient("REBOOK", context),
                                            // ),
                                            SizedBox(
                                                height: size.height * 0.02),
                                          ],
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 0,
                                          child: SvgPicture.asset(
                                            'assets/images/star-with-container-icon.svg',
                                            width: 45,
                                          ),
                                        ),
                                        Positioned(
                                          top: 11.5,
                                          right: 7,
                                          child: Text(
                                            '${widget.completedRideModel?.bookingsFleet?[index].usersFleet?.bookingsRatings}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: blackColor,
                                              fontSize: 12,
                                              fontFamily: 'Inter-Regular',
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 31,
                                          right: 0,
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: 36,
                                                height: 36,
                                                child: SvgPicture.asset(
                                                  'assets/images/dt.svg',
                                                  fit: BoxFit.scaleDown,
                                                  color: orangeColor,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                widget.completedRideModel!
                                                    .deliveryType!,
                                                style: GoogleFonts.syne(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: grey,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                      updateBookingStatusModel.data!
                                          .bookingsFleet!.length, (index) {
                                    return Container(
                                      margin: const EdgeInsets.all(2.0),
                                      width: 10.0,
                                      height: 10.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentPage == index
                                            ? Colors.orange
                                            : Colors.grey,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
                ],
              ),
            ),
      // : Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 20),
      //     child: SingleChildScrollView(
      //       child: Column(
      //         children: [
      //           SizedBox(height: size.height * 0.02),
      //           Container(
      //             color: transparentColor,
      //             // height: size.height * 0.98,
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 Padding(
      //                   padding: const EdgeInsets.only(left: 5),
      //                   child: Text(
      //                     formatTimeDifference(timeAdded!),
      //                     textAlign: TextAlign.left,
      //                     style: TextStyle(
      //                       color: sheetBarrierColor,
      //                       fontSize: 14,
      //                       fontFamily: 'Inter-Medium',
      //                     ),
      //                   ),
      //                 ),
      //                 SizedBox(height: size.height * 0.02),
      //                 Card(
      //                   color: whiteColor,
      //                   elevation: 5,
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                   ),
      //                   child: Padding(
      //                     padding: const EdgeInsets.symmetric(
      //                         horizontal: 10, vertical: 5),
      //                     child: Stack(
      //                       children: [
      //                         SingleChildScrollView(
      //                           child: SizedBox(
      //                             height: size.height * 0.8,
      //                             child: SingleChildScrollView(
      //                               child: Column(
      //                                 crossAxisAlignment:
      //                                     CrossAxisAlignment.start,
      //                                 children: [
      //                                   SizedBox(
      //                                       height: size.height * 0.02),
      //                                   Row(
      //                                     children: [
      //                                       ClipRRect(
      //                                         borderRadius:
      //                                             BorderRadius.circular(
      //                                                 10),
      //                                         child: Container(
      //                                           color: transparentColor,
      //                                           width: 60,
      //                                           height: 65,
      //                                           child: FadeInImage(
      //                                             placeholder:
      //                                                 const AssetImage(
      //                                               "assets/images/user-profile.png",
      //                                             ),
      //                                             image: NetworkImage(
      //                                               '$imageUrl${widget.completedRideModel?.bookingsFleet?[0].usersFleet?.profilePic}',
      //                                             ),
      //                                             fit: BoxFit.cover,
      //                                           ),
      //                                         ),
      //                                       ),
      //                                       SizedBox(
      //                                           width:
      //                                               size.width * 0.02),
      //                                       Column(
      //                                         crossAxisAlignment:
      //                                             CrossAxisAlignment
      //                                                 .start,
      //                                         children: [
      //                                           Container(
      //                                             color:
      //                                                 transparentColor,
      //                                             width:
      //                                                 size.width * 0.45,
      //                                             child: AutoSizeText(
      //                                               "${widget.completedRideModel?.bookingsFleet?[0].usersFleet?.firstName} ${widget.completedRideModel?.bookingsFleet?[0].usersFleet?.lastName}",
      //                                               textAlign:
      //                                                   TextAlign.left,
      //                                               style: TextStyle(
      //                                                 color:
      //                                                     drawerTextColor,
      //                                                 fontSize: 16,
      //                                                 fontFamily:
      //                                                     'Syne-Bold',
      //                                               ),
      //                                               minFontSize: 16,
      //                                               maxFontSize: 16,
      //                                               maxLines: 1,
      //                                               overflow:
      //                                                   TextOverflow
      //                                                       .ellipsis,
      //                                             ),
      //                                           ),
      //                                           SizedBox(
      //                                               height:
      //                                                   size.height *
      //                                                       0.01),
      //                                           Row(
      //                                             children: [
      //                                               Text(
      //                                                 '${widget.completedRideModel?.bookingsFleet?[0].usersFleetVehicles?.color} ',
      //                                                 textAlign:
      //                                                     TextAlign
      //                                                         .left,
      //                                                 style: TextStyle(
      //                                                   color:
      //                                                       textHaveAccountColor,
      //                                                   fontSize: 12,
      //                                                   fontFamily:
      //                                                       'Inter-Regular',
      //                                                 ),
      //                                               ),
      //                                               Text(
      //                                                 '${widget.completedRideModel?.bookingsFleet?[0].usersFleetVehicles?.model}',
      //                                                 textAlign:
      //                                                     TextAlign
      //                                                         .left,
      //                                                 style: TextStyle(
      //                                                   color:
      //                                                       textHaveAccountColor,
      //                                                   fontSize: 12,
      //                                                   fontFamily:
      //                                                       'Inter-Regular',
      //                                                 ),
      //                                               ),
      //                                             ],
      //                                           ),
      //                                           SizedBox(
      //                                               height:
      //                                                   size.height *
      //                                                       0.005),
      //                                           Text(
      //                                             '${widget.completedRideModel?.bookingsFleet?[0].usersFleetVehicles?.vehicleRegistrationNo}',
      //                                             textAlign:
      //                                                 TextAlign.left,
      //                                             style: TextStyle(
      //                                               color:
      //                                                   textHaveAccountColor,
      //                                               fontSize: 12,
      //                                               fontFamily:
      //                                                   'Inter-Regular',
      //                                             ),
      //                                           ),
      //                                         ],
      //                                       ),
      //                                     ],
      //                                   ),
      //                                   SizedBox(
      //                                       height: size.height * 0.03),
      //                                   // SizedBox(
      //                                   //   height: size.height * 0.45,
      //                                   //   child: Column(
      //                                   //     children: [
      //                                   //       Row(
      //                                   //         crossAxisAlignment:
      //                                   //             CrossAxisAlignment
      //                                   //                 .start,
      //                                   //         children: [
      //                                   //           SvgPicture.asset(
      //                                   //             'assets/images/orange-location-big-icon.svg',
      //                                   //           ),
      //                                   //           SizedBox(
      //                                   //               width:
      //                                   //                   size.width *
      //                                   //                       0.02),
      //                                   //           Column(
      //                                   //             crossAxisAlignment:
      //                                   //                 CrossAxisAlignment
      //                                   //                     .start,
      //                                   //             children: [
      //                                   //               Text(
      //                                   //                 'Pickup',
      //                                   //                 textAlign:
      //                                   //                     TextAlign
      //                                   //                         .left,
      //                                   //                 style:
      //                                   //                     TextStyle(
      //                                   //                   color:
      //                                   //                       textHaveAccountColor,
      //                                   //                   fontSize: 14,
      //                                   //                   fontFamily:
      //                                   //                       'Syne-Regular',
      //                                   //                 ),
      //                                   //               ),
      //                                   //               SizedBox(
      //                                   //                   height:
      //                                   //                       size.height *
      //                                   //                           0.01),
      //                                   //               Tooltip(
      //                                   //                 message:
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.pickupAddress}",
      //                                   //                 child:
      //                                   //                     Container(
      //                                   //                   color:
      //                                   //                       transparentColor,
      //                                   //                   width:
      //                                   //                       size.width *
      //                                   //                           0.65,
      //                                   //                   child:
      //                                   //                       AutoSizeText(
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.pickupAddress}",
      //                                   //                     textAlign:
      //                                   //                         TextAlign
      //                                   //                             .left,
      //                                   //                     style:
      //                                   //                         TextStyle(
      //                                   //                       color:
      //                                   //                           blackColor,
      //                                   //                       fontSize:
      //                                   //                           14,
      //                                   //                       fontFamily:
      //                                   //                           'Inter-Medium',
      //                                   //                     ),
      //                                   //                     minFontSize:
      //                                   //                         14,
      //                                   //                     maxFontSize:
      //                                   //                         14,
      //                                   //                     maxLines: 1,
      //                                   //                     overflow:
      //                                   //                         TextOverflow
      //                                   //                             .ellipsis,
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ),
      //                                   //             ],
      //                                   //           ),
      //                                   //         ],
      //                                   //       ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       Divider(
      //                                   //         thickness: 1,
      //                                   //         color: dividerColor,
      //                                   //         indent: 30,
      //                                   //         endIndent: 30,
      //                                   //       ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       Row(
      //                                   //         crossAxisAlignment:
      //                                   //             CrossAxisAlignment
      //                                   //                 .start,
      //                                   //         children: [
      //                                   //           SvgPicture.asset(
      //                                   //             'assets/images/send-small-icon.svg',
      //                                   //           ),
      //                                   //           SizedBox(
      //                                   //               width:
      //                                   //                   size.width *
      //                                   //                       0.02),
      //                                   //           Column(
      //                                   //             crossAxisAlignment:
      //                                   //                 CrossAxisAlignment
      //                                   //                     .start,
      //                                   //             children: [
      //                                   //               Text(
      //                                   //                 'Dropoff',
      //                                   //                 textAlign:
      //                                   //                     TextAlign
      //                                   //                         .left,
      //                                   //                 style:
      //                                   //                     TextStyle(
      //                                   //                   color:
      //                                   //                       textHaveAccountColor,
      //                                   //                   fontSize: 14,
      //                                   //                   fontFamily:
      //                                   //                       'Syne-Regular',
      //                                   //                 ),
      //                                   //               ),
      //                                   //               SizedBox(
      //                                   //                   height:
      //                                   //                       size.height *
      //                                   //                           0.01),
      //                                   //               Tooltip(
      //                                   //                 message:
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinAddress}",
      //                                   //                 child:
      //                                   //                     Container(
      //                                   //                   color:
      //                                   //                       transparentColor,
      //                                   //                   width:
      //                                   //                       size.width *
      //                                   //                           0.65,
      //                                   //                   child:
      //                                   //                       AutoSizeText(
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinAddress}",
      //                                   //                     textAlign:
      //                                   //                         TextAlign
      //                                   //                             .left,
      //                                   //                     style:
      //                                   //                         TextStyle(
      //                                   //                       color:
      //                                   //                           blackColor,
      //                                   //                       fontSize:
      //                                   //                           14,
      //                                   //                       fontFamily:
      //                                   //                           'Inter-Medium',
      //                                   //                     ),
      //                                   //                     minFontSize:
      //                                   //                         14,
      //                                   //                     maxFontSize:
      //                                   //                         14,
      //                                   //                     maxLines: 1,
      //                                   //                     overflow:
      //                                   //                         TextOverflow
      //                                   //                             .ellipsis,
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ),
      //                                   //             ],
      //                                   //           ),
      //                                   //         ],
      //                                   //       ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       Divider(
      //                                   //         thickness: 1,
      //                                   //         color: dividerColor,
      //                                   //         indent: 30,
      //                                   //         endIndent: 30,
      //                                   //       ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       Row(
      //                                   //         crossAxisAlignment:
      //                                   //             CrossAxisAlignment
      //                                   //                 .start,
      //                                   //         children: [
      //                                   //           SvgPicture.asset(
      //                                   //             'assets/images/orange-location-big-icon.svg',
      //                                   //           ),
      //                                   //           SizedBox(
      //                                   //               width:
      //                                   //                   size.width *
      //                                   //                       0.02),
      //                                   //           Column(
      //                                   //             crossAxisAlignment:
      //                                   //                 CrossAxisAlignment
      //                                   //                     .start,
      //                                   //             children: [
      //                                   //               Text(
      //                                   //                 'Pickup',
      //                                   //                 textAlign:
      //                                   //                     TextAlign
      //                                   //                         .left,
      //                                   //                 style:
      //                                   //                     TextStyle(
      //                                   //                   color:
      //                                   //                       textHaveAccountColor,
      //                                   //                   fontSize: 14,
      //                                   //                   fontFamily:
      //                                   //                       'Syne-Regular',
      //                                   //                 ),
      //                                   //               ),
      //                                   //               SizedBox(
      //                                   //                   height:
      //                                   //                       size.height *
      //                                   //                           0.01),
      //                                   //               Tooltip(
      //                                   //                 message:
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[1].bookingsDestinations?.pickupAddress}",
      //                                   //                 child:
      //                                   //                     Container(
      //                                   //                   color:
      //                                   //                       transparentColor,
      //                                   //                   width:
      //                                   //                       size.width *
      //                                   //                           0.65,
      //                                   //                   child:
      //                                   //                       AutoSizeText(
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[1].bookingsDestinations?.pickupAddress}",
      //                                   //                     textAlign:
      //                                   //                         TextAlign
      //                                   //                             .left,
      //                                   //                     style:
      //                                   //                         TextStyle(
      //                                   //                       color:
      //                                   //                           blackColor,
      //                                   //                       fontSize:
      //                                   //                           14,
      //                                   //                       fontFamily:
      //                                   //                           'Inter-Medium',
      //                                   //                     ),
      //                                   //                     minFontSize:
      //                                   //                         14,
      //                                   //                     maxFontSize:
      //                                   //                         14,
      //                                   //                     maxLines: 1,
      //                                   //                     overflow:
      //                                   //                         TextOverflow
      //                                   //                             .ellipsis,
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ),
      //                                   //             ],
      //                                   //           ),
      //                                   //         ],
      //                                   //       ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       Divider(
      //                                   //         thickness: 1,
      //                                   //         color: dividerColor,
      //                                   //         indent: 30,
      //                                   //         endIndent: 30,
      //                                   //       ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       Row(
      //                                   //         crossAxisAlignment:
      //                                   //             CrossAxisAlignment
      //                                   //                 .start,
      //                                   //         children: [
      //                                   //           SvgPicture.asset(
      //                                   //             'assets/images/send-small-icon.svg',
      //                                   //           ),
      //                                   //           SizedBox(
      //                                   //               width:
      //                                   //                   size.width *
      //                                   //                       0.02),
      //                                   //           Column(
      //                                   //             crossAxisAlignment:
      //                                   //                 CrossAxisAlignment
      //                                   //                     .start,
      //                                   //             children: [
      //                                   //               Text(
      //                                   //                 'Dropoff',
      //                                   //                 textAlign:
      //                                   //                     TextAlign
      //                                   //                         .left,
      //                                   //                 style:
      //                                   //                     TextStyle(
      //                                   //                   color:
      //                                   //                       textHaveAccountColor,
      //                                   //                   fontSize: 14,
      //                                   //                   fontFamily:
      //                                   //                       'Syne-Regular',
      //                                   //                 ),
      //                                   //               ),
      //                                   //               SizedBox(
      //                                   //                   height:
      //                                   //                       size.height *
      //                                   //                           0.01),
      //                                   //               Tooltip(
      //                                   //                 message:
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[1].bookingsDestinations?.destinAddress}",
      //                                   //                 child:
      //                                   //                     Container(
      //                                   //                   color:
      //                                   //                       transparentColor,
      //                                   //                   width:
      //                                   //                       size.width *
      //                                   //                           0.65,
      //                                   //                   child:
      //                                   //                       AutoSizeText(
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[1].bookingsDestinations?.destinAddress}",
      //                                   //                     textAlign:
      //                                   //                         TextAlign
      //                                   //                             .left,
      //                                   //                     style:
      //                                   //                         TextStyle(
      //                                   //                       color:
      //                                   //                           blackColor,
      //                                   //                       fontSize:
      //                                   //                           14,
      //                                   //                       fontFamily:
      //                                   //                           'Inter-Medium',
      //                                   //                     ),
      //                                   //                     minFontSize:
      //                                   //                         14,
      //                                   //                     maxFontSize:
      //                                   //                         14,
      //                                   //                     maxLines: 1,
      //                                   //                     overflow:
      //                                   //                         TextOverflow
      //                                   //                             .ellipsis,
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ),
      //                                   //             ],
      //                                   //           ),
      //                                   //         ],
      //                                   //       ),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               2 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][2]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         SizedBox(
      //                                   //             height:
      //                                   //                 size.height *
      //                                   //                     0.01),
      //                                   //       Divider(
      //                                   //         thickness: 1,
      //                                   //         color: dividerColor,
      //                                   //         indent: 30,
      //                                   //         endIndent: 30,
      //                                   //       ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               2 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][2]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         // pickup index 2
      //                                   //         Row(
      //                                   //           crossAxisAlignment:
      //                                   //               CrossAxisAlignment
      //                                   //                   .start,
      //                                   //           children: [
      //                                   //             SvgPicture.asset(
      //                                   //               'assets/images/orange-location-big-icon.svg',
      //                                   //             ),
      //                                   //             SizedBox(
      //                                   //                 width:
      //                                   //                     size.width *
      //                                   //                         0.02),
      //                                   //             Column(
      //                                   //               crossAxisAlignment:
      //                                   //                   CrossAxisAlignment
      //                                   //                       .start,
      //                                   //               children: [
      //                                   //                 Text(
      //                                   //                   'Pickup',
      //                                   //                   textAlign:
      //                                   //                       TextAlign
      //                                   //                           .left,
      //                                   //                   style:
      //                                   //                       TextStyle(
      //                                   //                     color:
      //                                   //                         textHaveAccountColor,
      //                                   //                     fontSize:
      //                                   //                         14,
      //                                   //                     fontFamily:
      //                                   //                         'Syne-Regular',
      //                                   //                   ),
      //                                   //                 ),
      //                                   //                 SizedBox(
      //                                   //                     height: size
      //                                   //                             .height *
      //                                   //                         0.01),
      //                                   //                 Tooltip(
      //                                   //                   message:
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[2].bookingsDestinations?.pickupAddress}",
      //                                   //                   child:
      //                                   //                       Container(
      //                                   //                     color:
      //                                   //                         transparentColor,
      //                                   //                     width: size
      //                                   //                             .width *
      //                                   //                         0.65,
      //                                   //                     child:
      //                                   //                         AutoSizeText(
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[2].bookingsDestinations?.pickupAddress}",
      //                                   //                       textAlign:
      //                                   //                           TextAlign
      //                                   //                               .left,
      //                                   //                       style:
      //                                   //                           TextStyle(
      //                                   //                         color:
      //                                   //                             blackColor,
      //                                   //                         fontSize:
      //                                   //                             14,
      //                                   //                         fontFamily:
      //                                   //                             'Inter-Medium',
      //                                   //                       ),
      //                                   //                       minFontSize:
      //                                   //                           14,
      //                                   //                       maxFontSize:
      //                                   //                           14,
      //                                   //                       maxLines:
      //                                   //                           1,
      //                                   //                       overflow:
      //                                   //                           TextOverflow
      //                                   //                               .ellipsis,
      //                                   //                     ),
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ],
      //                                   //             ),
      //                                   //           ],
      //                                   //         ),
      //                                   //       // SizedBox(
      //                                   //       //     height:
      //                                   //       //         size.height * 0.01),
      //                                   //       // if (jsonResponse!['data'][
      //                                   //       //                 'bookings_fleet']
      //                                   //       //             .length >
      //                                   //       //         2 &&
      //                                   //       //     jsonResponse!['data'][
      //                                   //       //                     'bookings_fleet'][2]
      //                                   //       //                 [
      //                                   //       //                 'bookings_destinations']
      //                                   //       //             [
      //                                   //       //             'destin_address'] !=
      //                                   //       //         null)
      //                                   //       // Divider(
      //                                   //       //   thickness: 1,
      //                                   //       //   color: dividerColor,
      //                                   //       //   indent: 30,
      //                                   //       //   endIndent: 30,
      //                                   //       // ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               2 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][2]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         Row(
      //                                   //           crossAxisAlignment:
      //                                   //               CrossAxisAlignment
      //                                   //                   .start,
      //                                   //           children: [
      //                                   //             SvgPicture.asset(
      //                                   //               'assets/images/send-small-icon.svg',
      //                                   //             ),
      //                                   //             SizedBox(
      //                                   //                 width:
      //                                   //                     size.width *
      //                                   //                         0.02),
      //                                   //             Column(
      //                                   //               crossAxisAlignment:
      //                                   //                   CrossAxisAlignment
      //                                   //                       .start,
      //                                   //               children: [
      //                                   //                 Text(
      //                                   //                   'Dropoff',
      //                                   //                   textAlign:
      //                                   //                       TextAlign
      //                                   //                           .left,
      //                                   //                   style:
      //                                   //                       TextStyle(
      //                                   //                     color:
      //                                   //                         textHaveAccountColor,
      //                                   //                     fontSize:
      //                                   //                         14,
      //                                   //                     fontFamily:
      //                                   //                         'Syne-Regular',
      //                                   //                   ),
      //                                   //                 ),
      //                                   //                 SizedBox(
      //                                   //                     height: size
      //                                   //                             .height *
      //                                   //                         0.01),
      //                                   //                 Tooltip(
      //                                   //                   message:
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[2].bookingsDestinations?.destinAddress}",
      //                                   //                   child:
      //                                   //                       Container(
      //                                   //                     color:
      //                                   //                         transparentColor,
      //                                   //                     width: size
      //                                   //                             .width *
      //                                   //                         0.65,
      //                                   //                     child:
      //                                   //                         AutoSizeText(
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[2].bookingsDestinations?.destinAddress}",
      //                                   //                       textAlign:
      //                                   //                           TextAlign
      //                                   //                               .left,
      //                                   //                       style:
      //                                   //                           TextStyle(
      //                                   //                         color:
      //                                   //                             blackColor,
      //                                   //                         fontSize:
      //                                   //                             14,
      //                                   //                         fontFamily:
      //                                   //                             'Inter-Medium',
      //                                   //                       ),
      //                                   //                       minFontSize:
      //                                   //                           14,
      //                                   //                       maxFontSize:
      //                                   //                           14,
      //                                   //                       maxLines:
      //                                   //                           1,
      //                                   //                       overflow:
      //                                   //                           TextOverflow
      //                                   //                               .ellipsis,
      //                                   //                     ),
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ],
      //                                   //             ),
      //                                   //           ],
      //                                   //         ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               3 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][3]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         SizedBox(
      //                                   //             height:
      //                                   //                 size.height *
      //                                   //                     0.01),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               3 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][3]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         Row(
      //                                   //           crossAxisAlignment:
      //                                   //               CrossAxisAlignment
      //                                   //                   .start,
      //                                   //           children: [
      //                                   //             SvgPicture.asset(
      //                                   //               'assets/images/orange-location-big-icon.svg',
      //                                   //             ),
      //                                   //             SizedBox(
      //                                   //                 width:
      //                                   //                     size.width *
      //                                   //                         0.02),
      //                                   //             Column(
      //                                   //               crossAxisAlignment:
      //                                   //                   CrossAxisAlignment
      //                                   //                       .start,
      //                                   //               children: [
      //                                   //                 Text(
      //                                   //                   'Pickup',
      //                                   //                   textAlign:
      //                                   //                       TextAlign
      //                                   //                           .left,
      //                                   //                   style:
      //                                   //                       TextStyle(
      //                                   //                     color:
      //                                   //                         textHaveAccountColor,
      //                                   //                     fontSize:
      //                                   //                         14,
      //                                   //                     fontFamily:
      //                                   //                         'Syne-Regular',
      //                                   //                   ),
      //                                   //                 ),
      //                                   //                 SizedBox(
      //                                   //                     height: size
      //                                   //                             .height *
      //                                   //                         0.01),
      //                                   //                 Tooltip(
      //                                   //                   message:
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[3].bookingsDestinations?.pickupAddress}",
      //                                   //                   child:
      //                                   //                       Container(
      //                                   //                     color:
      //                                   //                         transparentColor,
      //                                   //                     width: size
      //                                   //                             .width *
      //                                   //                         0.65,
      //                                   //                     child:
      //                                   //                         AutoSizeText(
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[3].bookingsDestinations?.pickupAddress}",
      //                                   //                       textAlign:
      //                                   //                           TextAlign
      //                                   //                               .left,
      //                                   //                       style:
      //                                   //                           TextStyle(
      //                                   //                         color:
      //                                   //                             blackColor,
      //                                   //                         fontSize:
      //                                   //                             14,
      //                                   //                         fontFamily:
      //                                   //                             'Inter-Medium',
      //                                   //                       ),
      //                                   //                       minFontSize:
      //                                   //                           14,
      //                                   //                       maxFontSize:
      //                                   //                           14,
      //                                   //                       maxLines:
      //                                   //                           1,
      //                                   //                       overflow:
      //                                   //                           TextOverflow
      //                                   //                               .ellipsis,
      //                                   //                     ),
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ],
      //                                   //             ),
      //                                   //           ],
      //                                   //         ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               3 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][3]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         Divider(
      //                                   //           thickness: 1,
      //                                   //           color: dividerColor,
      //                                   //           indent: 30,
      //                                   //           endIndent: 30,
      //                                   //         ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               3 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][3]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         Row(
      //                                   //           crossAxisAlignment:
      //                                   //               CrossAxisAlignment
      //                                   //                   .start,
      //                                   //           children: [
      //                                   //             SvgPicture.asset(
      //                                   //               'assets/images/send-small-icon.svg',
      //                                   //             ),
      //                                   //             SizedBox(
      //                                   //                 width:
      //                                   //                     size.width *
      //                                   //                         0.02),
      //                                   //             Column(
      //                                   //               crossAxisAlignment:
      //                                   //                   CrossAxisAlignment
      //                                   //                       .start,
      //                                   //               children: [
      //                                   //                 Text(
      //                                   //                   'Dropoff',
      //                                   //                   textAlign:
      //                                   //                       TextAlign
      //                                   //                           .left,
      //                                   //                   style:
      //                                   //                       TextStyle(
      //                                   //                     color:
      //                                   //                         textHaveAccountColor,
      //                                   //                     fontSize:
      //                                   //                         14,
      //                                   //                     fontFamily:
      //                                   //                         'Syne-Regular',
      //                                   //                   ),
      //                                   //                 ),
      //                                   //                 SizedBox(
      //                                   //                     height: size
      //                                   //                             .height *
      //                                   //                         0.01),
      //                                   //                 Tooltip(
      //                                   //                   message:
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[3].bookingsDestinations?.destinAddress}",
      //                                   //                   child:
      //                                   //                       Container(
      //                                   //                     color:
      //                                   //                         transparentColor,
      //                                   //                     width: size
      //                                   //                             .width *
      //                                   //                         0.65,
      //                                   //                     child:
      //                                   //                         AutoSizeText(
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[3].bookingsDestinations?.destinAddress}",
      //                                   //                       textAlign:
      //                                   //                           TextAlign
      //                                   //                               .left,
      //                                   //                       style:
      //                                   //                           TextStyle(
      //                                   //                         color:
      //                                   //                             blackColor,
      //                                   //                         fontSize:
      //                                   //                             14,
      //                                   //                         fontFamily:
      //                                   //                             'Inter-Medium',
      //                                   //                       ),
      //                                   //                       minFontSize:
      //                                   //                           14,
      //                                   //                       maxFontSize:
      //                                   //                           14,
      //                                   //                       maxLines:
      //                                   //                           1,
      //                                   //                       overflow:
      //                                   //                           TextOverflow
      //                                   //                               .ellipsis,
      //                                   //                     ),
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ],
      //                                   //             ),
      //                                   //           ],
      //                                   //         ),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               4 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][4]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         SizedBox(
      //                                   //             height:
      //                                   //                 size.height *
      //                                   //                     0.01),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               4 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][4]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         Row(
      //                                   //           crossAxisAlignment:
      //                                   //               CrossAxisAlignment
      //                                   //                   .start,
      //                                   //           children: [
      //                                   //             SvgPicture.asset(
      //                                   //               'assets/images/orange-location-big-icon.svg',
      //                                   //             ),
      //                                   //             SizedBox(
      //                                   //                 width:
      //                                   //                     size.width *
      //                                   //                         0.02),
      //                                   //             Column(
      //                                   //               crossAxisAlignment:
      //                                   //                   CrossAxisAlignment
      //                                   //                       .start,
      //                                   //               children: [
      //                                   //                 Text(
      //                                   //                   'Pickup',
      //                                   //                   textAlign:
      //                                   //                       TextAlign
      //                                   //                           .left,
      //                                   //                   style:
      //                                   //                       TextStyle(
      //                                   //                     color:
      //                                   //                         textHaveAccountColor,
      //                                   //                     fontSize:
      //                                   //                         14,
      //                                   //                     fontFamily:
      //                                   //                         'Syne-Regular',
      //                                   //                   ),
      //                                   //                 ),
      //                                   //                 SizedBox(
      //                                   //                     height: size
      //                                   //                             .height *
      //                                   //                         0.01),
      //                                   //                 Tooltip(
      //                                   //                   message:
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[4].bookingsDestinations?.pickupAddress}",
      //                                   //                   child:
      //                                   //                       Container(
      //                                   //                     color:
      //                                   //                         transparentColor,
      //                                   //                     width: size
      //                                   //                             .width *
      //                                   //                         0.65,
      //                                   //                     child:
      //                                   //                         AutoSizeText(
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[4].bookingsDestinations?.pickupAddress}",
      //                                   //                       textAlign:
      //                                   //                           TextAlign
      //                                   //                               .left,
      //                                   //                       style:
      //                                   //                           TextStyle(
      //                                   //                         color:
      //                                   //                             blackColor,
      //                                   //                         fontSize:
      //                                   //                             14,
      //                                   //                         fontFamily:
      //                                   //                             'Inter-Medium',
      //                                   //                       ),
      //                                   //                       minFontSize:
      //                                   //                           14,
      //                                   //                       maxFontSize:
      //                                   //                           14,
      //                                   //                       maxLines:
      //                                   //                           1,
      //                                   //                       overflow:
      //                                   //                           TextOverflow
      //                                   //                               .ellipsis,
      //                                   //                     ),
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ],
      //                                   //             ),
      //                                   //           ],
      //                                   //         ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               4 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][4]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         Divider(
      //                                   //           thickness: 1,
      //                                   //           color: dividerColor,
      //                                   //           indent: 30,
      //                                   //           endIndent: 30,
      //                                   //         ),
      //                                   //       SizedBox(
      //                                   //           height: size.height *
      //                                   //               0.01),
      //                                   //       if (jsonResponse!['data'][
      //                                   //                       'bookings_fleet']
      //                                   //                   .length >
      //                                   //               4 &&
      //                                   //           jsonResponse!['data'][
      //                                   //                           'bookings_fleet'][4]
      //                                   //                       [
      //                                   //                       'bookings_destinations']
      //                                   //                   [
      //                                   //                   'destin_address'] !=
      //                                   //               null)
      //                                   //         Row(
      //                                   //           crossAxisAlignment:
      //                                   //               CrossAxisAlignment
      //                                   //                   .start,
      //                                   //           children: [
      //                                   //             SvgPicture.asset(
      //                                   //               'assets/images/send-small-icon.svg',
      //                                   //             ),
      //                                   //             SizedBox(
      //                                   //                 width:
      //                                   //                     size.width *
      //                                   //                         0.02),
      //                                   //             Column(
      //                                   //               crossAxisAlignment:
      //                                   //                   CrossAxisAlignment
      //                                   //                       .start,
      //                                   //               children: [
      //                                   //                 Text(
      //                                   //                   'Dropoff',
      //                                   //                   textAlign:
      //                                   //                       TextAlign
      //                                   //                           .left,
      //                                   //                   style:
      //                                   //                       TextStyle(
      //                                   //                     color:
      //                                   //                         textHaveAccountColor,
      //                                   //                     fontSize:
      //                                   //                         14,
      //                                   //                     fontFamily:
      //                                   //                         'Syne-Regular',
      //                                   //                   ),
      //                                   //                 ),
      //                                   //                 SizedBox(
      //                                   //                     height: size
      //                                   //                             .height *
      //                                   //                         0.01),
      //                                   //                 Tooltip(
      //                                   //                   message:
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[4].bookingsDestinations?.destinAddress}",
      //                                   //                   child:
      //                                   //                       Container(
      //                                   //                     color:
      //                                   //                         transparentColor,
      //                                   //                     width: size
      //                                   //                             .width *
      //                                   //                         0.65,
      //                                   //                     child:
      //                                   //                         AutoSizeText(
      //                                   //                       "${widget.completedRideModel?.bookingsFleet?[4].bookingsDestinations?.destinAddress}",
      //                                   //                       textAlign:
      //                                   //                           TextAlign
      //                                   //                               .left,
      //                                   //                       style:
      //                                   //                           TextStyle(
      //                                   //                         color:
      //                                   //                             blackColor,
      //                                   //                         fontSize:
      //                                   //                             14,
      //                                   //                         fontFamily:
      //                                   //                             'Inter-Medium',
      //                                   //                       ),
      //                                   //                       minFontSize:
      //                                   //                           14,
      //                                   //                       maxFontSize:
      //                                   //                           14,
      //                                   //                       maxLines:
      //                                   //                           1,
      //                                   //                       overflow:
      //                                   //                           TextOverflow
      //                                   //                               .ellipsis,
      //                                   //                     ),
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ],
      //                                   //             ),
      //                                   //           ],
      //                                   //         ),
      //                                   //       Row(
      //                                   //         mainAxisAlignment:
      //                                   //             MainAxisAlignment
      //                                   //                 .spaceEvenly,
      //                                   //         children: [
      //                                   //           Column(
      //                                   //             children: [
      //                                   //               SvgPicture.asset(
      //                                   //                 'assets/images/grey-location-icon.svg',
      //                                   //               ),
      //                                   //               SizedBox(
      //                                   //                   height:
      //                                   //                       size.height *
      //                                   //                           0.01),
      //                                   //               Tooltip(
      //                                   //                 message:
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinDistance} $distanceUnit",
      //                                   //                 child:
      //                                   //                     Container(
      //                                   //                   color:
      //                                   //                       transparentColor,
      //                                   //                   width:
      //                                   //                       size.width *
      //                                   //                           0.18,
      //                                   //                   child:
      //                                   //                       AutoSizeText(
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinDistance} $distanceUnit",
      //                                   //                     textAlign:
      //                                   //                         TextAlign
      //                                   //                             .center,
      //                                   //                     style:
      //                                   //                         TextStyle(
      //                                   //                       color:
      //                                   //                           textHaveAccountColor,
      //                                   //                       fontSize:
      //                                   //                           14,
      //                                   //                       fontFamily:
      //                                   //                           'Inter-Regular',
      //                                   //                     ),
      //                                   //                     maxFontSize:
      //                                   //                         14,
      //                                   //                     minFontSize:
      //                                   //                         12,
      //                                   //                     maxLines: 1,
      //                                   //                     overflow:
      //                                   //                         TextOverflow
      //                                   //                             .ellipsis,
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ),
      //                                   //             ],
      //                                   //           ),
      //                                   //           Column(
      //                                   //             children: [
      //                                   //               SvgPicture.asset(
      //                                   //                 'assets/images/grey-clock-icon.svg',
      //                                   //               ),
      //                                   //               SizedBox(
      //                                   //                   height:
      //                                   //                       size.height *
      //                                   //                           0.01),
      //                                   //               Tooltip(
      //                                   //                 message:
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinTime}",
      //                                   //                 child:
      //                                   //                     Container(
      //                                   //                   color:
      //                                   //                       transparentColor,
      //                                   //                   width:
      //                                   //                       size.width *
      //                                   //                           0.38,
      //                                   //                   child:
      //                                   //                       AutoSizeText(
      //                                   //                     "${widget.completedRideModel?.bookingsFleet?[0].bookingsDestinations?.destinTime}",
      //                                   //                     textAlign:
      //                                   //                         TextAlign
      //                                   //                             .center,
      //                                   //                     style:
      //                                   //                         TextStyle(
      //                                   //                       color:
      //                                   //                           textHaveAccountColor,
      //                                   //                       fontSize:
      //                                   //                           14,
      //                                   //                       fontFamily:
      //                                   //                           'Inter-Regular',
      //                                   //                     ),
      //                                   //                     maxFontSize:
      //                                   //                         14,
      //                                   //                     minFontSize:
      //                                   //                         12,
      //                                   //                     maxLines: 1,
      //                                   //                     overflow:
      //                                   //                         TextOverflow
      //                                   //                             .ellipsis,
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ),
      //                                   //             ],
      //                                   //           ),
      //                                   //           Column(
      //                                   //             children: [
      //                                   //               SvgPicture.asset(
      //                                   //                 'assets/images/grey-dollar-icon.svg',
      //                                   //                 colorFilter: ColorFilter.mode(
      //                                   //                     const Color(
      //                                   //                             0xFF292D32)
      //                                   //                         .withOpacity(
      //                                   //                             0.4),
      //                                   //                     BlendMode
      //                                   //                         .srcIn),
      //                                   //               ),
      //                                   //               SizedBox(
      //                                   //                   height:
      //                                   //                       size.height *
      //                                   //                           0.01),
      //                                   //               Tooltip(
      //                                   //                 message:
      //                                   //                     "$currencyUnit${widget.completedRideModel?.totalCharges}",
      //                                   //                 child:
      //                                   //                     Container(
      //                                   //                   color:
      //                                   //                       transparentColor,
      //                                   //                   width:
      //                                   //                       size.width *
      //                                   //                           0.2,
      //                                   //                   child:
      //                                   //                       AutoSizeText(
      //                                   //                     "$currencyUnit${widget.completedRideModel?.totalCharges}",
      //                                   //                     textAlign:
      //                                   //                         TextAlign
      //                                   //                             .center,
      //                                   //                     style:
      //                                   //                         TextStyle(
      //                                   //                       color:
      //                                   //                           textHaveAccountColor,
      //                                   //                       fontSize:
      //                                   //                           14,
      //                                   //                       fontFamily:
      //                                   //                           'Inter-Regular',
      //                                   //                     ),
      //                                   //                     maxFontSize:
      //                                   //                         14,
      //                                   //                     minFontSize:
      //                                   //                         12,
      //                                   //                     maxLines: 1,
      //                                   //                     overflow:
      //                                   //                         TextOverflow
      //                                   //                             .ellipsis,
      //                                   //                   ),
      //                                   //                 ),
      //                                   //               ),
      //                                   //             ],
      //                                   //           ),
      //                                   //         ],
      //                                   //       ),
      //                                   //     ],
      //                                   //   ),
      //                                   // ),
      //                                   // SizedBox(
      //                                   //     height: size.height * 0.3),

      //                                   // SizedBox(height: size.height * 0.03),
      //                                   // GestureDetector(
      //                                   //   onTap: () {
      //                                   //     showDialog(
      //                                   //       context: context,
      //                                   //       barrierDismissible: false,
      //                                   //       // barrierColor: sheetBarrierColor,
      //                                   //       builder: (context) =>
      //                                   //           rebookRide(context),
      //                                   //     );
      //                                   //   },
      //                                   //   child: buttonGradient("REBOOK", context),
      //                                   // ),
      //                                   // SizedBox(
      //                                   //     height: size.height * 0.02),
      //                                 ],
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                         Positioned(
      //                           top: 10,
      //                           right: 0,
      //                           child: SvgPicture.asset(
      //                             'assets/images/star-with-container-icon.svg',
      //                             width: 45,
      //                           ),
      //                         ),
      //                         Positioned(
      //                           top: 11.5,
      //                           right: 7,
      //                           child: Text(
      //                             '${widget.completedRideModel?.bookingsFleet?[0].usersFleet?.bookingsRatings}',
      //                             textAlign: TextAlign.center,
      //                             style: TextStyle(
      //                               color: blackColor,
      //                               fontSize: 12,
      //                               fontFamily: 'Inter-Regular',
      //                             ),
      //                           ),
      //                         ),
      //                         Positioned(
      //                           top: 31,
      //                           right: 0,
      //                           child: Column(
      //                             children: [
      //                               SizedBox(
      //                                 width: 36,
      //                                 height: 36,
      //                                 child: SvgPicture.asset(
      //                                   'assets/images/dt.svg',
      //                                   fit: BoxFit.scaleDown,
      //                                   color: orangeColor,
      //                                 ),
      //                               ),
      //                               const SizedBox(
      //                                 height: 5,
      //                               ),
      //                               Text(
      //                                 widget.completedRideModel!
      //                                     .deliveryType!,
      //                                 style: GoogleFonts.syne(
      //                                   fontSize: 12,
      //                                   fontWeight: FontWeight.w400,
      //                                   color: grey,
      //                                 ),
      //                               )
      //                             ],
      //                           ),
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 ),
      //                 SizedBox(height: size.height * 0.02),
      //               ],
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
    );
  }
}

// Widget rebookRide(BuildContext context) {
//   var size = MediaQuery.of(context).size;
//   return GestureDetector(
//     onTap: () {
//       FocusManager.instance.primaryFocus?.unfocus();
//     },
//     child: WillPopScope(
//       onWillPop: () {
//         return Future.value(false);
//       },
//       child: Dialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(40),
//         ),
//         insetPadding: const EdgeInsets.only(left: 20, right: 20),
//         child: SizedBox(
//           height: size.height * 0.45,
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: Padding(
//                       padding: const EdgeInsets.only(top: 15),
//                       child: SvgPicture.asset("assets/images/close-icon.svg"),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 SvgPicture.asset('assets/images/hourglass-icon.svg'),
//                 SizedBox(height: size.height * 0.03),
//                 Text(
//                   'Time up',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: orangeColor,
//                     fontSize: 20,
//                     fontFamily: 'Syne-Bold',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.01),
//                 Text(
//                   'You can not rebook this ride after 5\nmins of completing the ride.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 18,
//                     fontFamily: 'Syne-Regular',
//                   ),
//                 ),
//                 SizedBox(height: size.height * 0.03),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }
