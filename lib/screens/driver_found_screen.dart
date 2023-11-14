// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:deliver_client/screens/chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/models/cancel_booking_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/screens/booking_accepted_screen.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/models/update_booking_status_model.dart';

String? userId;

class DriverFoundScreen extends StatefulWidget {
  final String? bookingId;
  final String? fleetId;
  final String? passCode;
  final String? currentBookingId;
  final double? distance;
  final Map? singleData;
  final Map? multipleData;
  final SearchRiderData? riderData;
  final String? bookingDestinationId;

  const DriverFoundScreen({
    super.key,
    this.bookingId,
    this.fleetId,
    this.passCode,
    this.currentBookingId,
    this.distance,
    this.singleData,
    this.multipleData,
    this.riderData,
    this.bookingDestinationId,
  });

  @override
  State<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends State<DriverFoundScreen> {
  bool isLoading = false;

  String? currencyUnit;
  String? distanceUnit;
  Timer? timer;
  String? lat;
  String? lng;
  double? riderLat;
  double? riderLng;
  int currentIndex = 0;
  GoogleMapController? mapController;
  BitmapDescriptor? customMarkerIcon;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];
  ScrollController scrollController = ScrollController();


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

  CancelBookingModel cancelBookingModel = CancelBookingModel();

  cancelBooking() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/cancel_booking";
      print("apiUrl: $apiUrl");
      print("bookings_id: ${widget.bookingId}");
      print("users_fleet_id: ${widget.fleetId}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "bookings_id": widget.bookingId,
          "users_customers_id": userId,
          "users_fleet_id": widget.fleetId,
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        cancelBookingModel = cancelBookingModelFromJson(responseString);
        setState(() {});
        print('cancelBookingModel status: ${cancelBookingModel.status}');
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();

  updateBookingStatus() async {
    try {
      String apiUrl = "$baseUrl/get_updated_status_booking";
      print("apiUrl: $apiUrl");
      print("currentBookingId: ${widget.currentBookingId}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "bookings_id": widget.currentBookingId,
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        updateBookingStatusModel =
            updateBookingStatusModelFromJson(responseString);
        print(
            'updateBookingStatusModel status: ${updateBookingStatusModel.status}');
        if (updateBookingStatusModel.data?.status == "Accepted" ||
            updateBookingStatusModel.data?.status == "Ongoing") {
          timer?.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingAcceptedScreen(
                distance: widget.distance,
                singleData: widget.singleData,
                passCode: widget.passCode,
                riderData: widget.riderData!,
                currentBookingId: widget.currentBookingId,
                bookingDestinationId: widget.bookingDestinationId,
              ),
            ),
          );
        }
        setState(() {});
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  Future<void> loadCustomMarker() async {
    final ByteData bytes = await rootBundle.load(
      'assets/images/rider-marker-icon.png',
    );
    final Uint8List list = bytes.buffer.asUint8List();

    customMarkerIcon = BitmapDescriptor.fromBytes(list);

    setState(() {});
  }

  void showPasscodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var size = MediaQuery.of(context).size;
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: StatefulBuilder(
            builder: (context, setState) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              insetPadding: const EdgeInsets.only(left: 20, right: 20),
              child: SizedBox(
                height: size.height * 0.36,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Passcode',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: orangeColor,
                          fontSize: 24,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        'Share your passcode with the receiver\nto ensure a secure and safe delivery.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 16,
                          fontFamily: 'Syne-Regular',
                        ),
                      ),
                      Text(
                        '${widget.passCode}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 24,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                      SizedBox(height: size.height * 0.002),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: dialogButtonTransparentGradientSmall(
                              "Cancel",
                              context,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              sharePasscode("${widget.passCode}");
                            },
                            child: dialogButtonGradientSmall("Share", context),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void sharePasscode(String passcode) {
    Share.share('Your passcode is: $passcode');
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      updateBookingStatus();
    });
  }

  @override
  void initState() {
    super.initState();
    print("passCode: ${widget.passCode}");
    Future.delayed(Duration.zero, () {
      showPasscodeDialog();
    });
    getAllSystemData();
    loadCustomMarker();
    lat = "${widget.riderData!.latitude}";
    lng = "${widget.riderData!.longitude}";
    riderLat = double.parse(lat!);
    riderLng = double.parse(lng!);
    print("riderLat: $riderLat");
    print("riderLng: $riderLng");
    print("currentBookingId: ${widget.currentBookingId}");
    print("bookingDestinationId;: ${widget.bookingDestinationId}");
    startTimer();
    scrollController.addListener(() {
      setState(() {
        // Update the current index based on the scroll position
        currentIndex = (scrollController.offset / MediaQuery.of(context).size.width).round();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: isLoading
            ? Center(
                child: Container(
                  width: 100,
                  height: 100,
                  color: transparentColor,
                  child: lottie.Lottie.asset(
                    'assets/images/loading-icon.json',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : widget.riderData != null
                ? Stack(
                    children: [
                      Container(
                        color: transparentColor,
                        width: size.width,
                        height: size.height * 1,
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            mapController = controller;
                          },
                          mapType: MapType.normal,
                          myLocationEnabled: false,
                          zoomControlsEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              riderLat != null ? riderLat! : 0.0,
                              riderLng != null ? riderLng! : 0.0,
                            ),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId("riderMarker"),
                              position: LatLng(
                                riderLat != null ? riderLat! : 0.0,
                                riderLng != null ? riderLng! : 0.0,
                              ),
                              icon: customMarkerIcon ??
                                  BitmapDescriptor.defaultMarker,
                            ),
                          },
                        ),
                      ),
                      Positioned(
                        top: 45,
                        left: 0,
                        right: 0,
                        child: Text(
                          "Driver Found",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 20,
                            fontFamily: 'Syne-Bold',
                          ),
                        ),
                      ),
                      // Positioned(
                      //   top: 160,
                      //   left: 50,
                      //   child: SpeechBalloon(
                      //     nipLocation: NipLocation.bottom,
                      //     nipHeight: 12,
                      //     borderColor: borderColor,
                      //     width: size.width * 0.45,
                      //     height: size.height * 0.1,
                      //     borderRadius: 10,
                      //     offset: const Offset(10, 0),
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8),
                      //       child: Column(
                      //         children: [
                      //           Row(
                      //             mainAxisAlignment: MainAxisAlignment.start,
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               ClipRRect(
                      //                 borderRadius: BorderRadius.circular(100),
                      //                 child: Container(
                      //                   color: transparentColor,
                      //                   width: 35,
                      //                   height: 35,
                      //                   child: FadeInImage(
                      //                     placeholder: const AssetImage(
                      //                       "assets/images/user-profile.png",
                      //                     ),
                      //                     image: NetworkImage(
                      //                       '$imageUrl${widget.riderData!.profilePic}',
                      //                     ),
                      //                     fit: BoxFit.cover,
                      //                   ),
                      //                 ),
                      //               ),
                      //               SizedBox(width: size.width * 0.01),
                      //               Column(
                      //                 mainAxisAlignment: MainAxisAlignment.start,
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Text(
                      //                     "${widget.riderData!.firstName} ${widget.riderData!.lastName}",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       color: blackColor,
                      //                       fontSize: 12,
                      //                       fontFamily: 'Inter-Regular',
                      //                     ),
                      //                   ),
                      //                   Row(
                      //                     children: [
                      //                       SvgPicture.asset(
                      //                         'assets/images/orange-location-icon.svg',
                      //                       ),
                      //                       SizedBox(width: size.width * 0.005),
                      //                       Text(
                      //                         "${widget.riderData!.address}",
                      //                         textAlign: TextAlign.center,
                      //                         style: TextStyle(
                      //                           color: textHaveAccountColor,
                      //                           fontSize: 10,
                      //                           fontFamily: 'Inter-Regular',
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ],
                      //               ),
                      //             ],
                      //           ),
                      //           statusButtonSmall(
                      //               "Pending", redStatusButtonColor, context),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Positioned(
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          child: Container(
                            width: size.width,
                            height: widget.singleData!.isNotEmpty ? size.height * 0.46 : size.height * 0.48,
                            decoration: BoxDecoration(
                              color: whiteColor,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.04),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Driver Found",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 22,
                                          fontFamily: 'Syne-Bold',
                                        ),
                                      ),
                                      statusButtonSmall("Pending",
                                          redStatusButtonColor, context),
                                      // Text(
                                      //   "5min",
                                      //   textAlign: TextAlign.left,
                                      //   style: TextStyle(
                                      //     color: textHaveAccountColor,
                                      //     fontSize: 16,
                                      //     fontFamily: 'Inter-Regular',
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
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
                                      SizedBox(width: size.width * 0.03),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              maxFontSize: 16,
                                              minFontSize: 12,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.003),
                                          Stack(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/star-with-container-icon.svg',
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 1.5, left: 24),
                                                child: Text(
                                                  "${widget.riderData!.bookingsRatings}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Regular',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.003),
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.45,
                                            child: AutoSizeText(
                                              "${widget.riderData!.usersFleetVehicles!.color} ${widget.riderData!.usersFleetVehicles!.model} (${widget.riderData!.usersFleetVehicles!.vehicleRegistrationNo})",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: textHaveAccountColor,
                                                fontSize: 14,
                                                fontFamily: 'Syne-Regular',
                                              ),
                                              minFontSize: 14,
                                              maxFontSize: 14,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              timer?.cancel();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                    callbackFunction:
                                                        startTimer,
                                                    riderId: widget
                                                        .riderData!.usersFleetId
                                                        .toString(),
                                                    name:
                                                        "${widget.riderData!.firstName} ${widget.riderData!.lastName}",
                                                    image: widget
                                                        .riderData!.profilePic,
                                                    phone:
                                                        widget.riderData!.phone,
                                                    address: widget
                                                        .riderData!.address,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: SvgPicture.asset(
                                              'assets/images/message-icon.svg',
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.02),
                                          GestureDetector(
                                            onTap: () {
                                              makePhoneCall(
                                                  "${widget.riderData!.phone}");
                                              // timer?.cancel();
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         CallScreen(
                                              //       name:
                                              //           "${widget.riderData!.firstName} ${widget.riderData!.lastName}",
                                              //       image: widget
                                              //           .riderData!.profilePic,
                                              //     ),
                                              //   ),
                                              // );
                                            },
                                            child: SvgPicture.asset(
                                              'assets/images/call-icon.svg',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  widget.singleData!.isNotEmpty ?
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Tooltip(
                                        message:
                                        "${widget.singleData?["destin_address"]}",
                                        child: Text(
                                          "${widget.singleData?["destin_address"]}",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: blackColor,
                                            fontSize: 16,
                                            fontFamily: 'Syne-Bold',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.03),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/black-location-icon.svg',
                                              ),
                                              SizedBox(height: size.height * 0.01),
                                              Tooltip(
                                                message:
                                                "${widget.distance} $distanceUnit",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.18,
                                                  child: AutoSizeText(
                                                    "${widget.distance} $distanceUnit",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: drawerTextColor,
                                                      fontSize: 16,
                                                      fontFamily: 'Inter-Regular',
                                                    ),
                                                    maxFontSize: 16,
                                                    minFontSize: 12,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/black-clock-icon.svg',
                                              ),
                                              SizedBox(height: size.height * 0.01),
                                              Tooltip(
                                                message:
                                                "${widget.singleData?["destin_time"]}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.38,
                                                  child: AutoSizeText(
                                                    "${widget.singleData?["destin_time"]}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: drawerTextColor,
                                                      fontSize: 16,
                                                      fontFamily: 'Inter-Regular',
                                                    ),
                                                    maxFontSize: 16,
                                                    minFontSize: 12,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/black-naira-icon.svg',
                                              ),
                                              SizedBox(height: size.height * 0.01),
                                              Tooltip(
                                                message:
                                                "$currencyUnit${widget.singleData?["total_charges"]}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.2,
                                                  child: AutoSizeText(
                                                    "$currencyUnit${widget.singleData?["total_charges"]}",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: drawerTextColor,
                                                      fontSize: 16,
                                                      fontFamily: 'Inter-Regular',
                                                    ),
                                                    maxFontSize: 16,
                                                    minFontSize: 12,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ): Container(
                                    color: transparentColor,
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.86,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Tooltip(
                                                  message:
                                                  "${widget.multipleData?["destin_address0"]}",
                                                  child: Text(
                                                    "${widget.multipleData?["destin_address0"]}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 16,
                                                      fontFamily: 'Syne-Bold',
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(height: size.height * 0.03),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-location-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "${widget.distance} $distanceUnit",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.18,
                                                            child: AutoSizeText(
                                                              "${widget.distance} $distanceUnit",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-clock-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "${widget.multipleData?["destin_time0"]}",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.38,
                                                            child: AutoSizeText(
                                                              "${widget.multipleData?["destin_time0"]}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-naira-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.2,
                                                            child: AutoSizeText(
                                                              "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.04),
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.85,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Tooltip(
                                                  message:
                                                  "${widget.multipleData?["destin_address1"]}",
                                                  child: Text(
                                                    "${widget.multipleData?["destin_address1"]}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 16,
                                                      fontFamily: 'Syne-Bold',
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(height: size.height * 0.03),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-location-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "${widget.distance} $distanceUnit",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.18,
                                                            child: AutoSizeText(
                                                              "${widget.distance} $distanceUnit",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-clock-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "${widget.multipleData?["destin_time1"]}",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.38,
                                                            child: AutoSizeText(
                                                              "${widget.multipleData?["destin_time1"]}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-naira-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.2,
                                                            child: AutoSizeText(
                                                              "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // if (widget.multipleData!["destin_address2"] != null &&
                                          //     widget.multipleData!["destin_address2"].isNotEmpty)
                                          SizedBox(width: size.width * 0.04),
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.85,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Tooltip(
                                                  message:
                                                  "${widget.multipleData?["destin_address2"]}",
                                                  child: Text(
                                                    "${widget.multipleData?["destin_address2"]}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 16,
                                                      fontFamily: 'Syne-Bold',
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(height: size.height * 0.03),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-location-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "${widget.distance} $distanceUnit",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.18,
                                                            child: AutoSizeText(
                                                              "${widget.distance} $distanceUnit",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-clock-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "${widget.multipleData?["destin_time2"]}",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.38,
                                                            child: AutoSizeText(
                                                              "${widget.multipleData?["destin_time2"]}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-naira-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.2,
                                                            child: AutoSizeText(
                                                              "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // if (widget.multipleData!["destin_address3"] != null &&
                                          //     widget.multipleData!["destin_address3"].isNotEmpty)
                                          SizedBox(width: size.width * 0.04),
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.85,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Tooltip(
                                                  message:
                                                  "${widget.multipleData?["destin_address3"]}",
                                                  child: Text(
                                                    "${widget.multipleData?["destin_address3"]}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 16,
                                                      fontFamily: 'Syne-Bold',
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(height: size.height * 0.03),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-location-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "${widget.distance} $distanceUnit",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.18,
                                                            child: AutoSizeText(
                                                              "${widget.distance} $distanceUnit",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-clock-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "${widget.multipleData?["destin_time3"]}",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.38,
                                                            child: AutoSizeText(
                                                              "${widget.multipleData?["destin_time3"]}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-naira-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.2,
                                                            child: AutoSizeText(
                                                              "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // if (widget.multipleData!["destin_address4"] != null &&
                                          //     widget.multipleData!["destin_address4"].isNotEmpty)
                                          SizedBox(width: size.width * 0.04),
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.85,
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Tooltip(
                                                  message:
                                                  "${widget.multipleData?["destin_address4"]}",
                                                  child: Text(
                                                    "${widget.multipleData?["destin_address4"]}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 16,
                                                      fontFamily: 'Syne-Bold',
                                                    ),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                SizedBox(height: size.height * 0.03),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-location-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "${widget.distance} $distanceUnit",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.18,
                                                            child: AutoSizeText(
                                                              "${widget.distance} $distanceUnit",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-clock-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "${widget.multipleData?["destin_time4"]}",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.38,
                                                            child: AutoSizeText(
                                                              "${widget.multipleData?["destin_time4"]}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/black-naira-icon.svg',
                                                        ),
                                                        SizedBox(height: size.height * 0.01),
                                                        Tooltip(
                                                          message:
                                                          "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                          child: Container(
                                                            color: transparentColor,
                                                            width: size.width * 0.2,
                                                            child: AutoSizeText(
                                                              "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                color: drawerTextColor,
                                                                fontSize: 16,
                                                                fontFamily: 'Inter-Regular',
                                                              ),
                                                              maxFontSize: 16,
                                                              minFontSize: 12,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
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
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: currentIndex == 0 ? orangeColor : dotsColor,
                                        ),
                                      ),
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: currentIndex == 1 ? orangeColor : dotsColor,
                                        ),
                                      ),
                                      if (widget.multipleData!["destin_address2"] != null &&
                                          widget.multipleData!["destin_address2"].isNotEmpty)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: currentIndex == 2 ? orangeColor : dotsColor,
                                        ),
                                      ),
                                      if (widget.multipleData!["destin_address3"] != null &&
                                          widget.multipleData!["destin_address3"].isNotEmpty)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: currentIndex == 3 ? orangeColor : dotsColor,
                                        ),
                                      ),
                                      if (widget.multipleData!["destin_address4"] != null &&
                                          widget.multipleData!["destin_address4"].isNotEmpty)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: currentIndex == 4 ? orangeColor : dotsColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) =>
                                            cancelRide(context),
                                      );
                                    },
                                    child: buttonTransparent("CANCEL", context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   top: 40,
                      //   left: 20,
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       Navigator.pop(context);
                      //     },
                      //     child: SvgPicture.asset(
                      //       'assets/images/back-icon.svg',
                      //       fit: BoxFit.scaleDown,
                      //     ),
                      //   ),
                      // ),
                      Positioned(
                        top: 40,
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                            showPasscodeDialog();
                          },
                          child: SvgPicture.asset(
                            'assets/images/share-icon.svg',
                            fit: BoxFit.scaleDown,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
      ),
    );
  }

  cancelRide(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          insetPadding: const EdgeInsets.only(left: 20, right: 20),
          child: SizedBox(
            height: size.height * 0.3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  Text(
                    'Cancel Ride',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: orangeColor,
                      fontSize: 24,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  Text(
                    'Are you sure, you want\nto cancel this ride?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 18,
                      fontFamily: 'Syne-Regular',
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child:
                            dialogButtonTransparentGradientSmall("No", context),
                      ),
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            isLoading = true;
                          });
                          await cancelBooking();
                          if (cancelBookingModel.status == "success") {
                            timer?.cancel();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const HomePageScreen()),
                                (Route<dynamic> route) => false);
                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            Fluttertoast.showToast(
                              msg: "You have already cancelled this booking.",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 2,
                              backgroundColor: toastColor,
                              textColor: whiteColor,
                              fontSize: 12,
                            );
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                        child: isLoading
                            ? dialogButtonGradientSmallWithLoader(
                                "Please wait...", context)
                            : dialogButtonGradientSmall("Yes", context),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
