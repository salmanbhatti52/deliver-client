// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:deliver_client/screens/chat_screen.dart';
import 'package:deliver_client/screens/call_screen.dart';
import 'package:deliver_client/screens/arriving_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';

class BookingAcceptedScreen extends StatefulWidget {
  final double? distance;
  final Map? singleData;
  final SearchRiderData? riderData;
  const BookingAcceptedScreen({
    super.key,
    this.distance,
    this.singleData,
    this.riderData,
  });

  @override
  State<BookingAcceptedScreen> createState() => _BookingAcceptedScreenState();
}

class _BookingAcceptedScreenState extends State<BookingAcceptedScreen> {
  bool isLoading = false;

  String? currencyUnit;
  String? distanceUnit;
  String? lat;
  String? lng;
  double? riderLat;
  double? riderLng;
  GoogleMapController? mapController;
  BitmapDescriptor? customMarkerIcon;

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

  Future<void> loadCustomMarker() async {
    final ByteData bytes = await rootBundle.load(
      'assets/images/rider-marker-icon.png',
    );
    final Uint8List list = bytes.buffer.asUint8List();

    customMarkerIcon = BitmapDescriptor.fromBytes(list);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getAllSystemData();
    loadCustomMarker();
    lat = "${widget.riderData!.latitude}";
    lng = "${widget.riderData!.longitude}";
    riderLat = double.parse(lat!);
    riderLng = double.parse(lng!);
    print("riderLat: $riderLat");
    print("riderLng: $riderLng");
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
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
                    // Image.asset(
                    //   'assets/images/booking_accepted-location-background.png',
                    //   fit: BoxFit.cover,
                    // ),
                    Positioned(
                      top: 45,
                      left: 0,
                      right: 0,
                      child: Text(
                        "Booking Accepted",
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
                    //                 child: Image.asset(
                    //                   'assets/images/user-profile.png',
                    //                   width: 35,
                    //                   height: 35,
                    //                   fit: BoxFit.cover,
                    //                 ),
                    //               ),
                    //               SizedBox(width: size.width * 0.01),
                    //               Column(
                    //                 mainAxisAlignment: MainAxisAlignment.start,
                    //                 crossAxisAlignment: CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     "Jannie",
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
                    //                           'assets/images/orange-location-icon.svg'),
                    //                       SizedBox(width: size.width * 0.005),
                    //                       Text(
                    //                         "Mexicali CT 13a",
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
                    //               "Accepted", greenStatusButtonColor, context),
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
                          height: size.height * 0.46,
                          decoration: BoxDecoration(
                            color: whiteColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: size.height * 0.04),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Booking Accepted",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 22,
                                        fontFamily: 'Syne-Bold',
                                      ),
                                    ),
                                    statusButtonSmall("Accepted",
                                        greenStatusButtonColor, context),
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
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(
                                                  riderId: widget
                                                      .riderData!.usersFleetId
                                                      .toString(),
                                                  name:
                                                      "${widget.riderData!.firstName} ${widget.riderData!.lastName}",
                                                  address:
                                                      widget.riderData!.address,
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
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CallScreen(
                                                  name:
                                                      "${widget.riderData!.firstName} ${widget.riderData!.lastName}",
                                                  image: widget
                                                      .riderData!.profilePic,
                                                ),
                                              ),
                                            );
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
                                SizedBox(height: size.height * 0.03),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ArrivingScreen(
                                          distance: widget.distance,
                                          singleData: widget.singleData,
                                          riderData: widget.riderData!,
                                        ),
                                      ),
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
                    Positioned(
                      top: 40,
                      left: 20,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SvgPicture.asset(
                          'assets/images/back-icon.svg',
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: GestureDetector(
                        onTap: () {},
                        child: SvgPicture.asset(
                          'assets/images/share-icon.svg',
                          fit: BoxFit.scaleDown,
                        ),
                      ),
                    ),
                  ],
                )
              : null,
    );
  }
}
