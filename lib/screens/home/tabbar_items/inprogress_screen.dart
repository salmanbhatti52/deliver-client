// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:deliver_client/screens/report_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:deliver_client/screens/payment/amount_to_pay_screen.dart';

class InProgressHomeScreen extends StatefulWidget {
  final Map? singleData;
  final String? passCode;
  final Map? multipleData;
  final String? currentBookingId;
  final SearchRiderData? riderData;
  final String? bookingDestinationId;

  const InProgressHomeScreen({
    super.key,
    this.singleData,
    this.passCode,
    this.multipleData,
    this.currentBookingId,
    this.riderData,
    this.bookingDestinationId,
  });

  @override
  State<InProgressHomeScreen> createState() => _InProgressHomeScreenState();
}

class _InProgressHomeScreenState extends State<InProgressHomeScreen> {
  bool isLoading = false;
  String? distanceUnit;
  Timer? timer;
  String? latDest;
  String? lngDest;
  String? latRider;
  String? lngRider;
  double? destLat;
  double? destLng;
  double? riderLat;
  double? riderLng;
  GoogleMapController? mapController;
  BitmapDescriptor? customMarkerIcon;
  BitmapDescriptor? customDestMarkerIcon;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? mapsKey = dotenv.env['MAPS_KEY'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

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
        setState(() {});
        updateBookingStatusModel =
            updateBookingStatusModelFromJson(responseString);
        print(
            'updateBookingStatusModel status: ${updateBookingStatusModel.status}');
        if (updateBookingStatusModel.data?.status == "Completed") {
          timer?.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AmountToPayScreen(
                riderData: widget.riderData!,
                singleData: widget.singleData,
                multipleData: widget.multipleData,
                currentBookingId: widget.currentBookingId,
                bookingDestinationId: widget.bookingDestinationId,
              ),
            ),
          );
        } else {
          // timer?.cancel();
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => HomePageScreen(
          //       index: 1,
          //       passCode: widget.passCode,
          //       singleData: widget.singleData,
          //       multipleData: widget.multipleData,
          //       riderData: widget.riderData!,
          //       currentBookingId: widget.currentBookingId,
          //       bookingDestinationId: widget.bookingDestinationId,
          //     ),
          //   ),
          // );
        }
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  getLocationSingle() {
    if (widget.singleData!.isNotEmpty) {
      latDest = "${widget.singleData!['destin_latitude']}";
      lngDest = "${widget.singleData!['destin_longitude']}";
      destLat = double.parse(latDest!);
      destLng = double.parse(lngDest!);
      print("destLat: $destLat");
      print("destLng: $destLng");
      latRider = "${widget.riderData!.latitude}";
      lngRider = "${widget.riderData!.longitude}";
      riderLat = double.parse(latRider!);
      riderLng = double.parse(lngRider!);
      print("riderLat: $riderLat");
      print("riderLng: $riderLng");
    } else {
      print("No LatLng Data");
    }
  }

  getLocationMultiple() {
    if (widget.multipleData!.isNotEmpty) {
      latDest = "${widget.multipleData!['destin_latitude0']}";
      lngDest = "${widget.multipleData!['destin_longitude0']}";
      destLat = double.parse(latDest!);
      destLng = double.parse(lngDest!);
      print("destLat: $destLat");
      print("destLng: $destLng");
      latRider = "${widget.riderData!.latitude}";
      lngRider = "${widget.riderData!.longitude}";
      riderLat = double.parse(latRider!);
      riderLng = double.parse(lngRider!);
      print("riderLat: $riderLat");
      print("riderLng: $riderLng");
    } else {
      print("No LatLng Data");
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

  Future<void> loadCustomDestMarker() async {
    final ByteData bytes = await rootBundle.load(
      'assets/images/custom-dest-icon.png',
    );
    final Uint8List list = bytes.buffer.asUint8List();
    customDestMarkerIcon = BitmapDescriptor.fromBytes(list);
    setState(() {});
  }

  List<LatLng> polylineCoordinates = [];

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    if (riderLat != null &&
        riderLng != null &&
        destLat != null &&
        destLng != null) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "$mapsKey",
        PointLatLng(riderLat!, riderLng!),
        PointLatLng(destLat!, destLng!),
      );
      if (result.points.isNotEmpty) {
        print("polylineCoordinates: $polylineCoordinates");
        for (var point in result.points) {
          polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          );
        }
        setState(() {});
      }
    } else {
      print("No Polyline Data");
    }
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      updateBookingStatus();
    });
  }

  @override
  initState() {
    super.initState();
    getAllSystemData();
    loadCustomMarker();
    if (widget.singleData!.isNotEmpty) {
      // getPolyPoints();
      getLocationSingle();
      loadCustomDestMarker();
    } else {
      getLocationMultiple();
      print("Multiple data so no polyline will be shown!");
      print("Multiple data so no custom marker will be shown!");
    }
    startTimer();
  }

  @override
  dispose() {
    timer?.cancel();
    super.dispose();
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
                child: lottie.Lottie.asset(
                  'assets/images/loading-icon.json',
                  fit: BoxFit.cover,
                ),
              ),
            )
          : widget.singleData != null
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
                            markerId: const MarkerId('destMarker'),
                            position: LatLng(
                              destLat != null ? destLat! : 0.0,
                              destLng != null ? destLng! : 0.0,
                            ),
                            icon: customDestMarkerIcon ??
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
                                      widget.singleData!.isNotEmpty
                                          ? Column(
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
                                                SizedBox(
                                                    height:
                                                        size.height * 0.005),
                                                Tooltip(
                                                  message:
                                                      "${widget.singleData!['destin_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.79,
                                                    child: Text(
                                                      "${widget.singleData!['destin_address']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Destination Addresses",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: size.height * 0.01),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "1.",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.02),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 2.5),
                                                      child: Tooltip(
                                                        message:
                                                            "${widget.multipleData!['destin_address0']}",
                                                        child: Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.75,
                                                          child: Text(
                                                            "${widget.multipleData!['destin_address0']}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                    height: size.height * 0.01),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "2.",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            size.width * 0.02),
                                                    Tooltip(
                                                      message:
                                                          "${widget.multipleData!['destin_address1']}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.75,
                                                        child: Text(
                                                          "${widget.multipleData!['destin_address1']}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (widget.multipleData![
                                                            "destin_address2"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address2"]
                                                        .isNotEmpty)
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                if (widget.multipleData![
                                                            "destin_address2"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address2"]
                                                        .isNotEmpty)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "3.",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: size.width *
                                                              0.02),
                                                      Tooltip(
                                                        message:
                                                            "${widget.multipleData!['destin_address2']}",
                                                        child: Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.75,
                                                          child: Text(
                                                            "${widget.multipleData!['destin_address2']}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if (widget.multipleData![
                                                            "destin_address3"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address3"]
                                                        .isNotEmpty)
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                if (widget.multipleData![
                                                            "destin_address3"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address3"]
                                                        .isNotEmpty)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "4.",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: size.width *
                                                              0.02),
                                                      Tooltip(
                                                        message:
                                                            "${widget.multipleData!['destin_address3']}",
                                                        child: Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.75,
                                                          child: Text(
                                                            "${widget.multipleData!['destin_address3']}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if (widget.multipleData![
                                                            "destin_address4"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address4"]
                                                        .isNotEmpty)
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.01),
                                                if (widget.multipleData![
                                                            "destin_address4"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address4"]
                                                        .isNotEmpty)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "5.",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          width: size.width *
                                                              0.02),
                                                      Tooltip(
                                                        message:
                                                            "${widget.multipleData!['destin_address4']}",
                                                        child: Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.75,
                                                          child: Text(
                                                            "${widget.multipleData!['destin_address4']}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
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
                                          widget.singleData!.isNotEmpty
                                              ? Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.25,
                                                  child: Text(
                                                    "${widget.singleData!['destin_distance']} $distanceUnit",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    SizedBox(
                                                        height: size.height *
                                                            0.005),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "1.",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 2.5),
                                                          child: Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.25,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_distance0']} $distanceUnit",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "2.",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.25,
                                                          child: Text(
                                                            "${widget.multipleData!['destin_distance1']} $distanceUnit",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (widget.multipleData![
                                                                "destin_address2"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address2"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address2"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address2"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "3.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.25,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_distance2']} $distanceUnit",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (widget.multipleData![
                                                                "destin_address3"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address3"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address3"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address3"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "4.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.25,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_distance3']} $distanceUnit",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (widget.multipleData![
                                                                "destin_address4"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address4"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address4"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address4"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "5.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.25,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_distance4']} $distanceUnit",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
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
                                          widget.singleData!.isNotEmpty
                                              ? Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.25,
                                                  child: Text(
                                                    "${widget.singleData!['destin_time']}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    SizedBox(
                                                        height: size.height *
                                                            0.005),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "1.",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 2.5),
                                                          child: Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.4,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_time0']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "2.",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.4,
                                                          child: Text(
                                                            "${widget.multipleData!['destin_time1']}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (widget.multipleData![
                                                                "destin_address2"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address2"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address2"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address2"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "3.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.4,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_time2']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (widget.multipleData![
                                                                "destin_address3"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address3"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address3"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address3"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "4.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.4,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_time3']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (widget.multipleData![
                                                                "destin_address4"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address4"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address4"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address4"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "5.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.4,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_time4']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                      SizedBox(width: size.width * 0.08),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/passcode-icon.svg',
                                          ),
                                          SizedBox(width: size.width * 0.02),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Text(
                                                  "Passcode",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Regular',
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.005),
                                              Text(
                                                "${widget.passCode}",
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
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         const AmountToPayEditScreen(),
                                          //   ),
                                          // );
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
                                                      width: widget.singleData!
                                                              .isNotEmpty
                                                          ? size.width * 0.3
                                                          : size.width * 0.4,
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
                                              widget.singleData!.isNotEmpty
                                                  ? Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/small-grey-arrival-time-icon.svg',
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.01),
                                                        Tooltip(
                                                          message:
                                                              "ETA ${widget.singleData!['destin_time']}",
                                                          child: Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.23,
                                                            child: Text(
                                                              "ETA ${widget.singleData!['destin_time']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    textHaveAccountColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Syne-Regular',
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox(
                                                      width: size.width * 0.16),
                                              SizedBox(
                                                  width: size.width * 0.02),
                                              GestureDetector(
                                                onTap: () {
                                                  timer?.cancel();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReportScreen(
                                                        callbackFunction:
                                                            startTimer,
                                                        riderData:
                                                            widget.riderData,
                                                        currentBookingId: widget
                                                            .currentBookingId,
                                                        bookingDestinationId: widget
                                                            .bookingDestinationId,
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
                                  widget.singleData!.isNotEmpty
                                      ? Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Pickup",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
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
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Destination",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
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
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Pickup 1",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.multipleData!['pickup_address0']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.61,
                                                    child: Text(
                                                      "${widget.multipleData!['pickup_address0']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Destination 1",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.multipleData!['destin_address0']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.53,
                                                    child: Text(
                                                      "${widget.multipleData!['destin_address0']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Pickup 2",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.multipleData!['pickup_address1']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.61,
                                                    child: Text(
                                                      "${widget.multipleData!['pickup_address1']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Destination 2",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.multipleData!['destin_address1']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.53,
                                                    child: Text(
                                                      "${widget.multipleData!['destin_address1']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Pickup 3",
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
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['pickup_address2']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.61,
                                                      child: Text(
                                                        "${widget.multipleData!['pickup_address2']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Destination 3",
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
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['destin_address2']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.53,
                                                      child: Text(
                                                        "${widget.multipleData!['destin_address2']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Pickup 4",
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
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['pickup_address3']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.61,
                                                      child: Text(
                                                        "${widget.multipleData!['pickup_address3']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Destination 4",
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
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['destin_address3']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.53,
                                                      child: Text(
                                                        "${widget.multipleData!['destin_address3']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Pickup 5",
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
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['pickup_address4']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.61,
                                                      child: Text(
                                                        "${widget.multipleData!['pickup_address4']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Destination 5",
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
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['destin_address4']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.53,
                                                      child: Text(
                                                        "${widget.multipleData!['destin_address4']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
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
                                  widget.singleData!.isNotEmpty
                                      ? const SizedBox()
                                      : SizedBox(height: size.height * 0.12),
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
                      lottie.Lottie.asset('assets/images/no-data-icon.json'),
                      SizedBox(height: size.height * 0.04),
                      Text(
                        "No Ride In Progress",
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
