// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:deliver_client/screens/chat_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/models/update_booking_status_model.dart';

class ArrivingScreen extends StatefulWidget {
  final double? distance;
  final Map? singleData;
  final String? passCode;
  final Map? multipleData;
  final String? currentBookingId;
  final SearchRiderData? riderData;
  final String? bookingDestinationId;

  const ArrivingScreen({
    super.key,
    this.distance,
    this.singleData,
    this.passCode,
    this.multipleData,
    this.currentBookingId,
    this.riderData,
    this.bookingDestinationId,
  });

  @override
  State<ArrivingScreen> createState() => _ArrivingScreenState();
}

class _ArrivingScreenState extends State<ArrivingScreen> {
  bool isLoading = false;

  String? lat;
  String? lng;
  Timer? timer;
  String? latPickup;
  String? lngPickup;
  String? latRider;
  String? lngRider;
  double? pickupLat;
  double? pickupLng;
  double? riderLat;
  double? riderLng;
  String? currencyUnit;
  String? distanceUnit;
  int currentIndex = 0;
  GoogleMapController? mapController;
  BitmapDescriptor? customMarkerIcon;
  BitmapDescriptor? customPickupMarkerIcon;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? mapsKey = dotenv.env['MAPS_KEY'];
  String? imageUrl = dotenv.env['IMAGE_URL'];
  ScrollController scrollController = ScrollController();

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

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
        getAllSystemDataModel = getAllSystemDataModelFromJson(responseString);
        debugPrint('getAllSystemDataModel status: ${getAllSystemDataModel.status}');
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

  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();

  updateBookingStatus() async {
    try {
      String apiUrl = "$baseUrl/get_updated_status_booking";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("currentBookingId: ${widget.currentBookingId}");
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
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        updateBookingStatusModel =
            updateBookingStatusModelFromJson(responseString);
        debugPrint(
            'updateBookingStatusModel status: ${updateBookingStatusModel.status}');
        if (updateBookingStatusModel.data?.bookingsFleet?[0]
                .bookingsDestinations?.bookingsDestinationsStatus?.name ==
            "Start Ride") {
          timer?.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePageScreen(
                index: 1,
                singleData: widget.singleData,
                multipleData: widget.multipleData,
                passCode: widget.passCode,
                currentBookingId: widget.currentBookingId,
                riderData: widget.riderData!,
                bookingDestinationId: widget.bookingDestinationId,
              ),
            ),
          );
        } else {
          // timer?.cancel();
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => ArrivingScreen(
          //       distance: widget.distance,
          //       passCode: widget.passCode,
          //       singleData: widget.singleData,
          //       riderData: widget.riderData!,
          //       currentBookingId: widget.currentBookingId,
          //       bookingDestinationId: widget.bookingDestinationId,
          //     ),
          //   ),
          // );
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  getLocationSingle() {
    if (widget.singleData!.isNotEmpty) {
      latPickup = " ${widget.singleData!['pickup_latitude']}";
      lngPickup = "${widget.singleData!['pickup_longitude']}";
      pickupLat = double.parse(latPickup!);
      pickupLng = double.parse(lngPickup!);
      debugPrint("pickupLat: $pickupLat");
      debugPrint("pickupLng: $pickupLng");
      latRider = "${widget.riderData!.latitude}";
      lngRider = "${widget.riderData!.longitude}";
      riderLat = double.parse(latRider!);
      riderLng = double.parse(lngRider!);
      debugPrint("riderLat: $riderLat");
      debugPrint("riderLng: $riderLng");
    } else {
      debugPrint("No LatLng Data");
    }
  }

  getLocationMultiple() {
    if (widget.multipleData!.isNotEmpty) {
      latPickup = " ${widget.multipleData!['pickup_latitude0']}";
      lngPickup = "${widget.multipleData!['pickup_longitude0']}";
      pickupLat = double.parse(latPickup!);
      pickupLng = double.parse(lngPickup!);
      debugPrint("pickupLat: $pickupLat");
      debugPrint("pickupLng: $pickupLng");
      latRider = "${widget.riderData!.latitude}";
      lngRider = "${widget.riderData!.longitude}";
      riderLat = double.parse(latRider!);
      riderLng = double.parse(lngRider!);
      debugPrint("riderLat: $riderLat");
      debugPrint("riderLng: $riderLng");
    } else {
      debugPrint("No LatLng Data");
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

  Future<void> loadCustomPickupMarker() async {
    final ByteData bytes = await rootBundle.load(
      'assets/images/custom-pickup-icon.png',
    );
    final Uint8List list = bytes.buffer.asUint8List();
    customPickupMarkerIcon = BitmapDescriptor.fromBytes(list);
    setState(() {});
  }

  List<LatLng> polylineCoordinates = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    if (riderLat != null &&
        riderLng != null &&
        pickupLat != null &&
        pickupLng != null) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "$mapsKey",
        PointLatLng(riderLat!, riderLng!),
        PointLatLng(pickupLat!, pickupLng!),
      );
      if (result.points.isNotEmpty) {
        debugPrint("polylineCoordinates: $polylineCoordinates");
        for (var point in result.points) {
          polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          );
        }
        setState(() {});
      }
    } else {
      debugPrint("No Polyline Data");
    }
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
                height: size.height * 0.4,
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
                      SizedBox(height: size.height * 0.01),
                      Text(
                        '${widget.passCode}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 24,
                          fontFamily: 'Syne-SemiBold',
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
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
                              showPasscodeDialog();
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
    getAllSystemData();
    loadCustomMarker();
    // getPolyPoints();
    if (widget.singleData != null) {
      // getPolyPoints();
      getLocationSingle();
      loadCustomPickupMarker();
    } else {
      getLocationMultiple();
      debugPrint("Multiple data so no polyline will be shown!");
      debugPrint("Multiple data so no custom marker will be shown!");
    }
    startTimer();
    scrollController.addListener(() {
      setState(() {
        // Update the current index based on the scroll position
        currentIndex =
            (scrollController.offset / MediaQuery.of(context).size.width)
                .round();
      });
    });
  }

  @override
  dispose() {
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
                            Marker(
                              markerId: const MarkerId('pickupMarker'),
                              position: LatLng(
                                pickupLat != null ? pickupLat! : 0.0,
                                pickupLng != null ? pickupLng! : 0.0,
                              ),
                              icon: customPickupMarkerIcon ??
                                  BitmapDescriptor.defaultMarker,
                            ),
                          },
                          // polylines: {
                          //   Polyline(
                          //     polylineId: const PolylineId("polyline"),
                          //     points: polylineCoordinates,
                          //     color: orangeColor,
                          //     geodesic: true,
                          //     patterns: [
                          //       PatternItem.dash(40),
                          //       PatternItem.gap(10),
                          //     ],
                          //     width: 6,
                          //   ),
                          // },
                        ),
                      ),
                      Positioned(
                        top: 45,
                        left: 0,
                        right: 0,
                        child: Text(
                          "Arriving",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 20,
                            fontFamily: 'Syne-Bold',
                          ),
                        ),
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
                            height: widget.singleData!.isNotEmpty
                                ? size.height * 0.46
                                : size.height * 0.48,
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
                                        "Arriving",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 22,
                                          fontFamily: 'Syne-Bold',
                                        ),
                                      ),
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
                                                    address: widget
                                                        .riderData!.address,
                                                    phone:
                                                        widget.riderData!.phone,
                                                    image: widget
                                                        .riderData!.profilePic,
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
                                  widget.singleData!.isNotEmpty
                                      ? Column(
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
                                            SizedBox(
                                                height: size.height * 0.03),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/images/black-location-icon.svg',
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "${widget.distance} $distanceUnit",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.18,
                                                        child: AutoSizeText(
                                                          "${widget.distance} $distanceUnit",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                drawerTextColor,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Inter-Regular',
                                                          ),
                                                          maxFontSize: 16,
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
                                                      'assets/images/black-clock-icon.svg',
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "${widget.singleData?["destin_time"]}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.38,
                                                        child: AutoSizeText(
                                                          "${widget.singleData?["destin_time"]}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                drawerTextColor,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Inter-Regular',
                                                          ),
                                                          maxFontSize: 16,
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
                                                      'assets/images/black-naira-icon.svg',
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "$currencyUnit${widget.singleData?["total_charges"]}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width: size.width * 0.2,
                                                        child: AutoSizeText(
                                                          "$currencyUnit${widget.singleData?["total_charges"]}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                drawerTextColor,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Inter-Regular',
                                                          ),
                                                          maxFontSize: 16,
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
                                          ],
                                        )
                                      : Container(
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Tooltip(
                                                        message:
                                                            "${widget.multipleData?["destin_address0"]}",
                                                        child: Text(
                                                          "${widget.multipleData?["destin_address0"]}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Syne-Bold',
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: size.height *
                                                              0.03),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/black-location-icon.svg',
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "${widget.distance} $distanceUnit",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.18,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "${widget.distance} $distanceUnit",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "${widget.multipleData?["destin_time0"]}",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.38,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "${widget.multipleData?["destin_time0"]}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                                SizedBox(
                                                    width: size.width * 0.04),
                                                Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.85,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Tooltip(
                                                        message:
                                                            "${widget.multipleData?["destin_address1"]}",
                                                        child: Text(
                                                          "${widget.multipleData?["destin_address1"]}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Syne-Bold',
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: size.height *
                                                              0.03),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/black-location-icon.svg',
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "${widget.distance} $distanceUnit",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.18,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "${widget.distance} $distanceUnit",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "${widget.multipleData?["destin_time1"]}",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.38,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "${widget.multipleData?["destin_time1"]}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                                SizedBox(
                                                    width: size.width * 0.04),
                                                if (widget.multipleData![
                                                            "destin_address2"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address2"]
                                                        .isNotEmpty)
                                                  Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.85,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Tooltip(
                                                          message:
                                                              "${widget.multipleData?["destin_address2"]}",
                                                          child: Text(
                                                            "${widget.multipleData?["destin_address2"]}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Syne-Bold',
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                size.height *
                                                                    0.03),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-location-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.distance} $distanceUnit",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.18,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.distance} $distanceUnit",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-clock-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.multipleData?["destin_time2"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.38,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.multipleData?["destin_time2"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-naira-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width:
                                                                        size.width *
                                                                            0.2,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
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
                                                SizedBox(
                                                    width: size.width * 0.04),
                                                if (widget.multipleData![
                                                            "destin_address3"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address3"]
                                                        .isNotEmpty)
                                                  Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.85,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Tooltip(
                                                          message:
                                                              "${widget.multipleData?["destin_address3"]}",
                                                          child: Text(
                                                            "${widget.multipleData?["destin_address3"]}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Syne-Bold',
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                size.height *
                                                                    0.03),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-location-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.distance} $distanceUnit",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.18,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.distance} $distanceUnit",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-clock-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.multipleData?["destin_time3"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.38,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.multipleData?["destin_time3"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-naira-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width:
                                                                        size.width *
                                                                            0.2,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
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
                                                SizedBox(
                                                    width: size.width * 0.04),
                                                if (widget.multipleData![
                                                            "destin_address4"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address4"]
                                                        .isNotEmpty)
                                                  Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.85,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Tooltip(
                                                          message:
                                                              "${widget.multipleData?["destin_address4"]}",
                                                          child: Text(
                                                            "${widget.multipleData?["destin_address4"]}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Syne-Bold',
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                size.height *
                                                                    0.03),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-location-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.distance} $distanceUnit",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.18,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.distance} $distanceUnit",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-clock-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.multipleData?["destin_time4"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.38,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.multipleData?["destin_time4"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-naira-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width:
                                                                        size.width *
                                                                            0.2,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
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
                                  widget.singleData != null
                                      ? SizedBox(height: size.height * 0.01)
                                      : SizedBox(height: size.height * 0.02),
                                  if (widget.multipleData != null &&
                                      widget.multipleData!.isNotEmpty)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: currentIndex == 0
                                                ? orangeColor
                                                : dotsColor,
                                          ),
                                        ),
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: currentIndex == 1
                                                ? orangeColor
                                                : dotsColor,
                                          ),
                                        ),
                                        if (widget.multipleData![
                                                    "destin_address2"] !=
                                                null &&
                                            widget
                                                .multipleData![
                                                    "destin_address2"]
                                                .isNotEmpty)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 1),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: currentIndex == 2
                                                  ? orangeColor
                                                  : dotsColor,
                                            ),
                                          ),
                                        if (widget.multipleData![
                                                    "destin_address3"] !=
                                                null &&
                                            widget
                                                .multipleData![
                                                    "destin_address3"]
                                                .isNotEmpty)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 1),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: currentIndex == 3
                                                  ? orangeColor
                                                  : dotsColor,
                                            ),
                                          ),
                                        if (widget.multipleData![
                                                    "destin_address4"] !=
                                                null &&
                                            widget
                                                .multipleData![
                                                    "destin_address4"]
                                                .isNotEmpty)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 1),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: currentIndex == 4
                                                  ? orangeColor
                                                  : dotsColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  SizedBox(height: size.height * 0.02),
                                  buttonTransparent("CANCEL", context),
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
}
