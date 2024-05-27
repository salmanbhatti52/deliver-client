// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:deliver_client/screens/payment/receiptScreenMultiple.dart';
import 'package:deliver_client/screens/payment/receiptScreenSingle.dart';
import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/screens/rate_driver_screen.dart';

String? userEmail;

class AmountPaidScreen extends StatefulWidget {
  final Map? singleData;
  final Map? multipleData;
  final String? currentBookingId;
  final SearchRiderData? riderData;
  final String? bookingDestinationId;

  const AmountPaidScreen({
    super.key,
    this.riderData,
    this.singleData,
    this.multipleData,
    this.currentBookingId,
    this.bookingDestinationId,
  });

  @override
  State<AmountPaidScreen> createState() => _AmountPaidScreenState();
}

class _AmountPaidScreenState extends State<AmountPaidScreen> {
  String? latDest;
  String? lngDest;
  double? destLat;
  double? destLng;
  GoogleMapController? mapController;
  BitmapDescriptor? customMarkerIcon;

  getLocationSingle() {
    if (widget.singleData!.isNotEmpty) {
      latDest = "${widget.singleData!['destin_latitude']}";
      lngDest = "${widget.singleData!['destin_longitude']}";
      destLat = double.parse(latDest!);
      destLng = double.parse(lngDest!);
      debugPrint("destLat: $destLat");
      debugPrint("destLng: $destLng");
    } else {
      debugPrint("No LatLng Data");
    }
  }

  String? baseUrl = dotenv.env['BASE_URL'];
  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();
  String? responseString1;
  updateBookingStatus() async {
    // print(
    // " Passssssssssss ${updateBookingStatusModel.data!.bookingsFleet![0].bookingsDestinations!.passCode}");
    // try {
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
    responseString1 = response.body;

    debugPrint("response zain: $responseString1");
    debugPrint("statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      updateBookingStatusModel =
          updateBookingStatusModelFromJson(responseString1!);
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      debugPrint(
          'updateBookingStatusModel status: ${updateBookingStatusModel.status}');

      if (mounted) {
        setState(() {});
      }
    }
    // }
    //  catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  getLocationMultiple() {
    if (widget.multipleData!.isNotEmpty) {
      latDest = "${widget.multipleData!['destin_latitude0']}";
      lngDest = "${widget.multipleData!['destin_longitude0']}";
      destLat = double.parse(latDest!);
      destLng = double.parse(lngDest!);
      debugPrint("destLat: $destLat");
      debugPrint("destLng: $destLng");
    } else {
      debugPrint("No LatLng Data");
    }
  }

  Future<void> loadCustomMarker() async {
    final ByteData bytes = await rootBundle.load(
      'assets/images/custom-dest-icon.png',
    );
    final Uint8List list = bytes.buffer.asUint8List();
    customMarkerIcon = BitmapDescriptor.fromBytes(list);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    updateBookingStatus();
    if (widget.singleData!.isNotEmpty) {
      getLocationSingle();
    } else {
      getLocationMultiple();
    }
    loadCustomMarker();
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
        body: Stack(
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
                    destLat != null ? destLat! : 0.0,
                    destLng != null ? destLng! : 0.0,
                  ),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('destMarker'),
                    position: LatLng(
                      destLat != null ? destLat! : 0.0,
                      destLng != null ? destLng! : 0.0,
                    ),
                    icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
                  ),
                },
              ),
            ),
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Text(
                "Arrived at Destination",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blackColor,
                  fontSize: 18,
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
                  height: size.height * 0.36,
                  decoration: BoxDecoration(
                    color: whiteColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.04),
                          Text(
                            "Amount Paid",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 22,
                              fontFamily: 'Syne-Bold',
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          RichText(
                            overflow: TextOverflow.clip,
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '₦',
                                  style: TextStyle(
                                    color: orangeColor,
                                    fontSize: 26,
                                    fontFamily: 'Inter-Regular',
                                  ),
                                ),
                                TextSpan(
                                  text: widget.singleData!.isNotEmpty
                                      ? widget.singleData!['total_charges']
                                      : widget.multipleData!['total_charges'],
                                  style: TextStyle(
                                    color: orangeColor,
                                    fontSize: 26,
                                    fontFamily: 'Inter-Bold',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.04),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Payment Status",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 18,
                                      fontFamily: 'Syne-Medium',
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.12),
                                  Text(
                                    "Paid",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: orangeColor,
                                      fontSize: 18,
                                      fontFamily: 'Syne-Medium',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              Row(
                                children: [
                                  Text(
                                    "Payment Method",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 18,
                                      fontFamily: 'Syne-Medium',
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.085),
                                  widget.singleData!.isNotEmpty
                                      ? Text(
                                          widget.singleData![
                                                      "payment_gateways_id"] ==
                                                  '1'
                                              ? "Cash"
                                              : "Card",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: orangeColor,
                                            fontSize: 18,
                                            fontFamily: 'Syne-Medium',
                                          ),
                                        )
                                      : Text(
                                          widget.multipleData![
                                                      "payment_gateways_id"] ==
                                                  '1'
                                              ? "Cash"
                                              : "Card",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: orangeColor,
                                            fontSize: 18,
                                            fontFamily: 'Syne-Medium',
                                          ),
                                        ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.04),
                          GestureDetector(
                            onTap: () {
                              if (widget.multipleData!.isEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReceiptScreenSingle(
                                      singleData: widget.singleData,
                                      riderData: widget.riderData!,
                                      currentBookingId: widget.currentBookingId,
                                      bookingDestinationId:
                                          widget.bookingDestinationId,
                                      date: updateBookingStatusModel
                                          .data!.dateModified,
                                      paymentType: updateBookingStatusModel
                                          .data!.paymentGateways!.name,
                                      ridername:
                                          "${widget.riderData!.firstName} "
                                          " ${widget.riderData!.lastName}",
                                    ),
                                  ),
                                );
                              } else if (widget.multipleData != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReceiptScreenMultiple(
                                      multipleData: widget.multipleData,
                                      riderData: widget.riderData!,
                                      currentBookingId: widget.currentBookingId,
                                      bookingDestinationId:
                                          widget.bookingDestinationId,
                                      date: updateBookingStatusModel
                                          .data!.dateModified,
                                      paymentType: updateBookingStatusModel
                                          .data!.paymentGateways!.name,
                                      ridername:
                                          "${widget.riderData!.firstName} "
                                          " ${widget.riderData!.lastName}",
                                    ),
                                  ),
                                );
                              }
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => RateDriverScreen(
                              //       riderData: widget.riderData!,
                              //       currentBookingId: widget.currentBookingId,
                              //       bookingDestinationId:
                              //           widget.bookingDestinationId,
                              //     ),
                              //   ),
                              // );
                            },
                            child: buttonGradient("NEXT", context),
                          ),
                        ],
                      ),
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
          ],
        ),
      ),
    );
  }
}
