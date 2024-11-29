// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:deliver_client/screens/payment/amount_to_pay_From_IP.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart'
    show
        Clipboard,
        ClipboardData,
        SystemChrome,
        SystemUiOverlayStyle,
        rootBundle;
import 'package:deliver_client/screens/report_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/models/update_booking_status_model.dart';

class InProgressDetailedScreen extends StatefulWidget {
  final Map? singleData;
  final String? passCode;
  final Map? multipleData;
  final String? currentBookingId;
  final UpdateBookingStatusModel? riderData;
  final String? bookingDestinationId;

  const InProgressDetailedScreen({
    super.key,
    this.singleData,
    this.passCode,
    this.multipleData,
    this.currentBookingId,
    this.riderData,
    this.bookingDestinationId,
  });

  @override
  State<InProgressDetailedScreen> createState() =>
      _InProgressDetailedScreenState();
}

class _InProgressDetailedScreenState extends State<InProgressDetailedScreen> {
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
        await updateBookingStatus();
        debugPrint(
            'getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
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

  List<bool>? isValidIndex;
  String? passcode0;
  String? passcode1;
  String? passcode2;
  String? passcode3;
  String? passcode4;
  String? deliverType;
  bool systemSettings = false;
  String? trackingPrefix;

  Future<String?> fetchSystemSettingsDescription28() async {
    const String apiUrl = 'https://deliverbygfl.com/api/get_all_system_data';
    setState(() {
      systemSettings = true;
    });
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        final Map<String, dynamic> data = json.decode(response.body);

        // Find the setting with system_settings_id equal to 26
        final setting395 = data['data'].firstWhere(
            (setting) => setting['system_settings_id'] == 395,
            orElse: () => null);
        setState(() {
          systemSettings = false;
        });
        if (setting395 != null) {
          // Extract and return the description if setting 28 exists
          trackingPrefix = setting395['description'];

          return trackingPrefix;
        } else {
          throw Exception('System setting with ID 40 not found');
        }
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to fetch system settings');
      }
    } catch (e) {
      // Catch any exception that might occur during the process
      print('Error fetching system settings: $e');
      return null;
    }
  }

  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();
  Map<String, dynamic>? jsonResponse;
  updateBookingStatus() async {
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
    final responseString = response.body;
    debugPrint("response: $responseString");
    debugPrint("statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      updateBookingStatusModel =
          updateBookingStatusModelFromJson(responseString);
      debugPrint(
          'updateBookingStatusModel status: ${updateBookingStatusModel.status}');
      jsonResponse = jsonDecode(response.body);
      isValidIndex = List.generate(
          5,
          (index) =>
              jsonResponse!['data']['bookings_fleet'].length > index &&
              jsonResponse!['data']['bookings_fleet'][index]
                      ['bookings_destinations'] !=
                  null);
      print("jsonResponse: Dataaaa ${jsonResponse!['data']['bookings_fleet']}");

      // Access the passcode
      deliverType = jsonResponse!['data']['delivery_type'] ?? "";
      print("Delivery Type: $deliverType");
      passcode0 = jsonResponse!['data']['bookings_fleet'][0]
              ['bookings_destinations']['passcode'] ??
          "";
      print("Passcode0: $passcode0");
      if (jsonResponse!['data']['bookings_fleet'].length > 1) {
        passcode1 = jsonResponse!['data']['bookings_fleet'][1]
                ['bookings_destinations']['passcode'] ??
            "";
        print("Passcode1: $passcode1");
      }
      if (jsonResponse!['data']['bookings_fleet'].length > 2) {
        passcode2 = jsonResponse!['data']['bookings_fleet'][2]
                ['bookings_destinations']['passcode'] ??
            "";
        print("Passcode2: $passcode2");
      }
      if (jsonResponse!['data']['bookings_fleet'].length > 3) {
        passcode3 = jsonResponse!['data']['bookings_fleet'][3]
                ['bookings_destinations']['passcode'] ??
            "";
        print("Passcode3: $passcode3");
      }
      if (jsonResponse!['data']['bookings_fleet'].length > 4) {
        passcode4 = jsonResponse!['data']['bookings_fleet'][4]
                ['bookings_destinations']['passcode'] ??
            "";
        print("Passcode4: $passcode4");
      }
      CustomToast.showToast(
          message: "${updateBookingStatusModel.data?.status}");
      if (mounted) {
        setState(() {});
      }
      if (updateBookingStatusModel.data?.status == "Completed") {
        timer?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AmountToPayFromInProgress(
              riderData: jsonResponse!['data']['bookings_fleet'][0]
                  ['users_fleet'],
              singleData: jsonResponse!['data']['bookings_fleet'][0]
                  ['bookings_destinations'],
              multipleData: jsonResponse!['data'],
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
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  getLocationSingle() {
    if (widget.singleData!.isNotEmpty) {
      latDest = "${widget.singleData!['destin_latitude']}";
      lngDest = "${widget.singleData!['destin_longitude']}";
      destLat = double.parse(latDest!);
      destLng = double.parse(lngDest!);
      debugPrint("destLat: $destLat");
      debugPrint("destLng: $destLng");
      latRider =
          "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.latitude}";
      lngRider =
          "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.longitude}";
      riderLat = double.parse(latRider!);
      riderLng = double.parse(lngRider!);
      debugPrint("riderLat: $riderLat");
      debugPrint("riderLng: $riderLng");
    } else {
      debugPrint("No LatLng Data");
    }
  }

  getLocationMultiple() {
    if (widget.multipleData?.isNotEmpty ?? false) {
      latDest = "${widget.multipleData!['destin_latitude0']}";
      lngDest = "${widget.multipleData!['destin_longitude0']}";
      destLat = double.parse(latDest!);
      destLng = double.parse(lngDest!);
      debugPrint("destLat: $destLat");
      debugPrint("destLng: $destLng");
      latRider =
          "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.latitude}";
      lngRider =
          "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.longitude}";
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

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.currentBookingId != null &&
          widget.currentBookingId!.isNotEmpty) {
        updateBookingStatus();
      }
    });
  }

  @override
  initState() {
    super.initState();
    getAllSystemData();
    loadCustomMarker();
    updateBookingStatus();
    fetchSystemSettingsDescription28();
    print("Single Data: ${widget.singleData}");
    print("Multiple Data: ${widget.multipleData}");
    if (widget.singleData?.isNotEmpty ?? false) {
      // getPolyPoints();
      getLocationSingle();
      loadCustomDestMarker();
    } else {
      getLocationMultiple();
      debugPrint("Multiple data so no polyline will be shown!");
      debugPrint("Multiple data so no custom marker will be shown!");
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Set status bar color
      statusBarIconBrightness: Brightness.dark, // Set status bar icon color
    ));
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: SvgPicture.asset(
            'assets/images/back-icon.svg',
            fit: BoxFit.scaleDown,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "In Progress",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blackColor,
            fontSize: 20,
            fontFamily: 'Syne-Bold',
          ),
        ),
      ),
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
          : jsonResponse!['data']['bookings_fleet'][0]
                      ['bookings_destinations'] !=
                  null
              ? Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      child: Container(
                        width: size.width,
                        // height: size.height * 0.1,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/small-black-send-icon.svg',
                                    ),
                                    SizedBox(width: size.width * 0.03),
                                    // widget.singleData!.isNotEmpty
                                    if (deliverType != null &&
                                        deliverType == "Single")
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
                                                "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_address']}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.79,
                                              child: Text(
                                                "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_address']}",
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
                                      )
                                    else if (deliverType != null &&
                                        deliverType == "Multiple")
                                      Column(
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
                                          SizedBox(height: size.height * 0.01),
                                          Row(
                                            children: [
                                              Text(
                                                "1.",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.02),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 2.5),
                                                child: Tooltip(
                                                  message:
                                                      "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.75,
                                                    child: Text(
                                                      "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_address']}",
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
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: "$passcode0"));
                                              CustomToast.showToast(
                                                fontSize: 12,
                                                message:
                                                    "$passcode0 copied to clipboard",
                                              );
                                            },
                                            child: Tooltip(
                                              message: "$passcode0",
                                              child: Text(
                                                "                                               Passcode ${passcode0 ?? '--'}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: orangeColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Row(
                                            children: [
                                              Text(
                                                "2.",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.02),
                                              Tooltip(
                                                message:
                                                    "${jsonResponse!['data']['bookings_fleet'][1]['bookings_destinations']['destin_address']}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.75,
                                                  child: Text(
                                                    "${jsonResponse!['data']['bookings_fleet'][1]['bookings_destinations']['destin_address']}",
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
                                          SizedBox(height: size.height * 0.01),
                                          GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(
                                                  text: "$passcode1"));
                                              CustomToast.showToast(
                                                fontSize: 12,
                                                message:
                                                    "$passcode1 copied to clipboard",
                                              );
                                            },
                                            child: Tooltip(
                                              message: "$passcode1",
                                              child: Text(
                                                "                                               Passcode ${passcode1 ?? '--'}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: orangeColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),

                                          if (jsonResponse!['data'][
                                                          'bookings_fleet']
                                                      .length >
                                                  2 &&
                                              jsonResponse!['data'][
                                                              'bookings_fleet'][2]
                                                          [
                                                          'bookings_destinations']
                                                      ['destin_address'] !=
                                                  null)
                                            SizedBox(
                                                height: size.height * 0.01),
                                          if (jsonResponse!['data'][
                                                          'bookings_fleet']
                                                      .length >
                                                  2 &&
                                              jsonResponse!['data'][
                                                              'bookings_fleet'][2]
                                                          [
                                                          'bookings_destinations']
                                                      ['destin_address'] !=
                                                  null)
                                            Row(
                                              children: [
                                                Text(
                                                  "3.",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${jsonResponse!['data']['bookings_fleet'][2]['bookings_destinations']['destin_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.75,
                                                    child: Text(
                                                      "${jsonResponse!['data']['bookings_fleet'][2]['bookings_destinations']['destin_address']}",
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
                                          SizedBox(height: size.height * 0.01),
                                          if (jsonResponse!['data'][
                                                          'bookings_fleet']
                                                      .length >
                                                  2 &&
                                              jsonResponse!['data'][
                                                              'bookings_fleet'][2]
                                                          [
                                                          'bookings_destinations']
                                                      ['destin_address'] !=
                                                  null)
                                            // if (jsonResponse!['data']
                                            //                 ['bookings_fleet'][2]
                                            //             ['bookings_destinations']
                                            //         ['destin_address'] !=
                                            //     null)
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: "$passcode2"));
                                                CustomToast.showToast(
                                                  fontSize: 12,
                                                  message:
                                                      "$passcode2 copied to clipboard",
                                                );
                                              },
                                              child: Tooltip(
                                                message: "$passcode2",
                                                child: Text(
                                                  "                                               Passcode ${passcode2 ?? '--'}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: orangeColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          // SizedBox(
                                          //     height: size.height * 0.01),
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet']
                                                      .length >
                                                  3 &&
                                              jsonResponse!['data']
                                                          ['bookings_fleet'][3]
                                                      ['bookings_destinations']
                                                  ['destin_address'] &&
                                              isValidIndex![3])
                                            SizedBox(
                                                height: size.height * 0.01),
                                          if (jsonResponse!['data'][
                                                          'bookings_fleet']
                                                      .length >
                                                  3 &&
                                              jsonResponse!['data'][
                                                              'bookings_fleet'][3]
                                                          [
                                                          'bookings_destinations']
                                                      ['destin_address'] !=
                                                  null &&
                                              isValidIndex![3])
                                            Row(
                                              children: [
                                                Text(
                                                  "4.",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${jsonResponse!['data']['bookings_fleet'][3]['bookings_destinations']['destin_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.75,
                                                    child: Text(
                                                      "${jsonResponse!['data']['bookings_fleet'][3]['bookings_destinations']['destin_address']}",
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
                                          SizedBox(height: size.height * 0.01),
                                          if (jsonResponse!['data'][
                                                          'bookings_fleet']
                                                      .length >
                                                  3 &&
                                              jsonResponse!['data'][
                                                              'bookings_fleet'][3]
                                                          [
                                                          'bookings_destinations']
                                                      ['destin_address'] !=
                                                  null &&
                                              isValidIndex![3])
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: "$passcode3"));
                                                CustomToast.showToast(
                                                  fontSize: 12,
                                                  message:
                                                      "$passcode3 copied to clipboard",
                                                );
                                              },
                                              child: Tooltip(
                                                message: "$passcode3",
                                                child: Text(
                                                  "                                               Passcode ${passcode3 ?? '--'}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: orangeColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          if (jsonResponse!['data'][
                                                          'bookings_fleet']
                                                      .length >
                                                  4 &&
                                              jsonResponse!['data'][
                                                              'bookings_fleet'][4]
                                                          [
                                                          'bookings_destinations']
                                                      ['destin_address'] !=
                                                  null &&
                                              isValidIndex![4])
                                            SizedBox(
                                                height: size.height * 0.01),
                                          if (jsonResponse!['data'][
                                                          'bookings_fleet']
                                                      .length >
                                                  4 &&
                                              jsonResponse!['data'][
                                                              'bookings_fleet'][4]
                                                          [
                                                          'bookings_destinations']
                                                      ['destin_address'] !=
                                                  null &&
                                              isValidIndex![4])
                                            Row(
                                              children: [
                                                Text(
                                                  "5.",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${jsonResponse!['data']['bookings_fleet'][4]['bookings_destinations']['destin_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.75,
                                                    child: Text(
                                                      "${jsonResponse!['data']['bookings_fleet'][4]['bookings_destinations']['destin_address']}",
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
                                          SizedBox(height: size.height * 0.01),
                                          if (jsonResponse!['data'][
                                                          'bookings_fleet']
                                                      .length >
                                                  4 &&
                                              jsonResponse!['data'][
                                                              'bookings_fleet'][4]
                                                          [
                                                          'bookings_destinations']
                                                      ['destin_address'] !=
                                                  null &&
                                              isValidIndex![4])
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: "$passcode4"));
                                                CustomToast.showToast(
                                                  fontSize: 12,
                                                  message:
                                                      "$passcode4 copied to clipboard",
                                                );
                                              },
                                              child: Tooltip(
                                                message: "$passcode4",
                                                child: Text(
                                                  "                                               Passcode ${passcode4 ?? '--'}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: orangeColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            "Tracking Number",
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter-Regular',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: size.width * 0.04),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(
                                                  text:
                                                      "$trackingPrefix${updateBookingStatusModel.data!.bookingsId}"));
                                            },
                                            child: Text(
                                              "$trackingPrefix${updateBookingStatusModel.data!.bookingsId}",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: blackColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter-Regular',
                                              ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        jsonResponse!['data']['bookings_fleet']
                                                        [0] !=
                                                    null &&
                                                jsonResponse!['data']
                                                        ['delivery_type'] ==
                                                    "Single"
                                            ? Container(
                                                color: transparentColor,
                                                width: size.width * 0.25,
                                                child: Text(
                                                  "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_distance']} $distanceUnit",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                ),
                                              )
                                            : Column(
                                                children: [
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.005),
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
                                                          width:
                                                              size.width * 0.25,
                                                          child: Text(
                                                            "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_distance']} $distanceUnit",
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
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.25,
                                                        child: Text(
                                                          "${jsonResponse!['data']['bookings_fleet'][1]['bookings_destinations']['destin_distance']} $distanceUnit",
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
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          2 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][2]
                                                                  [
                                                                  'bookings_destinations']
                                                              [
                                                              'destin_address'] !=
                                                          null)
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          2 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][2]
                                                                  [
                                                                  'bookings_destinations']
                                                              [
                                                              'destin_address'] !=
                                                          null)
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
                                                        Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.25,
                                                          child: Text(
                                                            "${jsonResponse!['data']['bookings_fleet'][2]['bookings_destinations']['destin_distance']} $distanceUnit",
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
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          3 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][3]
                                                                  [
                                                                  'bookings_destinations']
                                                              [
                                                              'destin_address'] !=
                                                          null)
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          3 &&
                                                      jsonResponse!['data']
                                                                      ['bookings_fleet'][3]
                                                                  ['bookings_destinations']
                                                              [
                                                              'destin_address'] !=
                                                          null)
                                                    if (jsonResponse!['data']
                                                                    ['bookings_fleet'][3]
                                                                ['bookings_destinations']
                                                            ['destin_distance'] !=
                                                        null)
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
                                                              "${jsonResponse!['data']['bookings_fleet'][3]['bookings_destinations']['destin_distance']} $distanceUnit",
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
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          4 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][4]
                                                                  [
                                                                  'bookings_destinations']
                                                              [
                                                              'destin_address'] !=
                                                          null)
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          4 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][4]
                                                                  [
                                                                  'bookings_destinations']
                                                              [
                                                              'destin_address'] !=
                                                          null)
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
                                                        Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.25,
                                                          child: Text(
                                                            "${jsonResponse!['data']['bookings_fleet'][4]['bookings_destinations']['destin_distance']} $distanceUnit",
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
                                                ],
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        jsonResponse!['data']['bookings_fleet']
                                                            [0][
                                                        'bookings_destinations'] !=
                                                    null &&
                                                jsonResponse!['data']
                                                        ['delivery_type'] ==
                                                    "Single"
                                            ? Container(
                                                color: transparentColor,
                                                width: size.width * 0.25,
                                                child: Text(
                                                  "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_time']}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                ),
                                              )
                                            : Column(
                                                children: [
                                                  SizedBox(
                                                      height:
                                                          size.height * 0.005),
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
                                                          width:
                                                              size.width * 0.4,
                                                          child: Text(
                                                            "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_time']}",
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
                                                        color: transparentColor,
                                                        width: size.width * 0.4,
                                                        child: Text(
                                                          "${jsonResponse!['data']['bookings_fleet'][1]['bookings_destinations']['destin_time']}",
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
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          2 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][2]
                                                                  [
                                                                  'bookings_destinations']
                                                              [
                                                              'destin_address'] !=
                                                          null)
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          2 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][2]
                                                                  [
                                                                  'bookings_destinations']
                                                              [
                                                              'destin_address'] !=
                                                          null)
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
                                                        Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.4,
                                                          child: Text(
                                                            "${jsonResponse!['data']['bookings_fleet'][2]['bookings_destinations']['destin_time']}",
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
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          3 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][3]
                                                                  [
                                                                  'bookings_destinations']
                                                              [
                                                              'destin_address'] !=
                                                          null)
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          3 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][3]
                                                                  [
                                                                  'bookings_destinations']
                                                              [
                                                              'destin_address'] !=
                                                          null)
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
                                                        Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.4,
                                                          child: Text(
                                                            "${jsonResponse!['data']['bookings_fleet'][3]['bookings_destinations']['destin_time']}",
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
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          4 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][4]
                                                                  [
                                                                  'bookings_destinations']
                                                              ['destin_time'] !=
                                                          null)
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                  if (jsonResponse!['data'][
                                                                  'bookings_fleet']
                                                              .length >
                                                          4 &&
                                                      jsonResponse!['data'][
                                                                      'bookings_fleet'][4]
                                                                  [
                                                                  'bookings_destinations']
                                                              ['destin_time'] !=
                                                          null)
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
                                                        Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.4,
                                                          child: Text(
                                                            "${jsonResponse!['data']['bookings_fleet'][4]['bookings_destinations']['destin_time']}",
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
                                              padding:
                                                  const EdgeInsets.only(top: 2),
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
                                              "$passcode0",
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
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          color: transparentColor,
                                          width: 55,
                                          height: 55,
                                          child: jsonResponse!['data']['bookings_fleet'][0]['users_fleet']['profile_pic'] != null &&
                                              jsonResponse!['data']['bookings_fleet'][0]['users_fleet']['profile_pic']!.isNotEmpty
                                              ? FadeInImage(
                                            placeholder: const AssetImage("assets/images/user-profile.png"),
                                            image: NetworkImage(
                                              '$imageUrl${jsonResponse!['data']['bookings_fleet'][0]['users_fleet']['profile_pic']}',
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                              : Image.asset(
                                            "assets/images/user-profile.png", // Asset fallback image
                                            fit: BoxFit.cover,
                                          ),
                                          // child: FadeInImage(
                                          //   placeholder: const AssetImage(
                                          //     "assets/images/user-profile.png",
                                          //   ),
                                          //   image: NetworkImage(
                                          //     '$imageUrl${jsonResponse!['data']['bookings_fleet'][0]['users_fleet']['profile_pic']}',
                                          //   ),
                                          //   fit: BoxFit.cover,
                                          // ),
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
                                                "${jsonResponse!['data']['bookings_fleet'][0]['users_fleet']['first_name']} ${jsonResponse!['data']['bookings_fleet'][0]['users_fleet']['last_name']}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: drawerTextColor,
                                                  fontSize: 16,
                                                  fontFamily: 'Syne-SemiBold',
                                                ),
                                                minFontSize: 16,
                                                maxFontSize: 16,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                                    "${jsonResponse!['data']['bookings_fleet'][0]['users_fleet']['bookings_ratings']}",
                                                    textAlign: TextAlign.center,
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
                                        // Container(
                                        //   color: transparentColor,
                                        //   width: size.width * 0.62,
                                        //   child: AutoSizeText(
                                        //     "${widget.riderData!.usersFleetVehicles!.color} ${widget.riderData!.usersFleetVehicles!.model} (${widget.riderData!.usersFleetVehicles!.vehicleRegistrationNo})",
                                        //     textAlign: TextAlign.left,
                                        //     style: TextStyle(
                                        //       color: textHaveAccountColor,
                                        //       fontSize: 14,
                                        //       fontFamily: 'Syne-Regular',
                                        //     ),
                                        //     maxFontSize: 14,
                                        //     minFontSize: 12,
                                        //     maxLines: 1,
                                        //     overflow: TextOverflow.ellipsis,
                                        //   ),
                                        // ),
                                        // SizedBox(height: size.height * 0.002),
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
                                                      "${jsonResponse!['data']['bookings_fleet'][0]['users_fleet']['address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: jsonResponse!['data']
                                                                    [
                                                                    'bookings_fleet'][0]
                                                                [
                                                                'bookings_destinations'] !=
                                                            null
                                                        ? size.width * 0.3
                                                        : size.width * 0.4,
                                                    child: AutoSizeText(
                                                      "${jsonResponse!['data']['bookings_fleet'][0]['users_fleet']['address']}",
                                                      textAlign: TextAlign.left,
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: size.width * 0.01),
                                            jsonResponse!['data'][
                                                            'bookings_fleet'][0]
                                                        [
                                                        'bookings_destinations'] !=
                                                    null
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
                                                            "ETA ${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_time']}",
                                                        child: Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.23,
                                                          child: Text(
                                                            "ETA ${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_time']}",
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
                                            SizedBox(width: size.width * 0.02),
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
                                jsonResponse!['data']['bookings_fleet'][0]
                                            ['bookings_destinations'] !=
                                        null
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
                                                    "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['pickup_address']}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.6,
                                                  child: Text(
                                                    "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['pickup_address']}",
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
                                          SizedBox(height: size.height * 0.01),
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
                                                    "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_address']}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.53,
                                                  child: Text(
                                                    "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_address']}",
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
                                                    "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['pickup_address']}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.61,
                                                  child: Text(
                                                    "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['pickup_address']}",
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
                                          SizedBox(height: size.height * 0.01),
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
                                                    "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_address']}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.53,
                                                  child: Text(
                                                    "${jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']['destin_address']}",
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
                                          SizedBox(height: size.height * 0.01),
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
                                                    "${jsonResponse!['data']['bookings_fleet'][1]['bookings_destinations']['pickup_address']}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.61,
                                                  child: Text(
                                                    "${jsonResponse!['data']['bookings_fleet'][1]['bookings_destinations']['pickup_address']}",
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
                                          SizedBox(height: size.height * 0.01),
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
                                                    "${jsonResponse!['data']['bookings_fleet'][1]['bookings_destinations']['destin_address']}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.53,
                                                  child: Text(
                                                    "${jsonResponse!['data']['bookings_fleet'][1]['bookings_destinations']['destin_address']}",
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
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][1]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
                                            SizedBox(
                                                height: size.height * 0.01),
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][1]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
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
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${jsonResponse!['data']['bookings_fleet'][2]['bookings_destinations']['pickup_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.61,
                                                    child: Text(
                                                      "${jsonResponse!['data']['bookings_fleet'][2]['bookings_destinations']['pickup_address']}",
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
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][2]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
                                            SizedBox(
                                                height: size.height * 0.01),
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][2]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
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
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${jsonResponse!['data']['bookings_fleet'][2]['bookings_destinations']['destin_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.53,
                                                    child: Text(
                                                      "${jsonResponse!['data']['bookings_fleet'][2]['bookings_destinations']['destin_address']}",
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
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][3]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
                                            SizedBox(
                                                height: size.height * 0.01),
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][3]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
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
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${jsonResponse!['data']['bookings_fleet'][3]['bookings_destinations']['pickup_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.61,
                                                    child: Text(
                                                      "${jsonResponse!['data']['bookings_fleet'][3]['bookings_destinations']['pickup_address']}",
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
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][3]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
                                            SizedBox(
                                                height: size.height * 0.01),
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][3]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
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
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${jsonResponse!['data']['bookings_fleet'][3]['bookings_destinations']['destin_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.53,
                                                    child: Text(
                                                      "${jsonResponse!['data']['bookings_fleet'][3]['bookings_destinations']['destin_address']}",
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
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][4]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
                                            SizedBox(
                                                height: size.height * 0.01),
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][4]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
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
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${jsonResponse!['data']['bookings_fleet'][4]['bookings_destinations']['pickup_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.61,
                                                    child: Text(
                                                      "${jsonResponse!['data']['bookings_fleet'][4]['bookings_destinations']['pickup_address']}",
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
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][4]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
                                            SizedBox(
                                                height: size.height * 0.01),
                                          if (jsonResponse!['data']
                                                          ['bookings_fleet'][4]
                                                      ['bookings_destinations']
                                                  ['destin_address'] !=
                                              null)
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
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${jsonResponse!['data']['bookings_fleet'][4]['bookings_destinations']['destin_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.53,
                                                    child: Text(
                                                      "${jsonResponse!['data']['bookings_fleet'][4]['bookings_destinations']['destin_address']}",
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
                                      ),
                                jsonResponse!['data']['bookings_fleet'][0]
                                            ['bookings_destinations'] !=
                                        null
                                    ? const SizedBox()
                                    : SizedBox(height: size.height * 0.12),
                              ],
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
