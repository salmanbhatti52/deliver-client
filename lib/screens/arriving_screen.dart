// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:deliver_client/models/send_otp_model.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
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
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
import 'package:deliver_client/screens/chat_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final UpdateBookingStatusModel? riderData;
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
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "termii_api_key") {
            termiiApiKey = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "message_type") {
            pinMessageType = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "from") {
            pinFrom = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "channel") {
            pinChannel = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "pin_attempts") {
            pinAttempts = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "pin_time_to_live") {
            pinExpiryTime = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "pin_length") {
            pinLength = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "pin_placeholder") {
            pinPlaceholder = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "message_text") {
            pinMessageText = "${getAllSystemDataModel.data?[i].description}";
          }
          if (getAllSystemDataModel.data?[i].type == "pin_type") {
            pinType = "${getAllSystemDataModel.data?[i].description}";
          }
        }
        await updateBookingStatus();
        await sendMessage();
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  String? passcode0;
  String? passcode1;
  String? passcode2;
  String? passcode3;
  String? passcode4;
  String? phoneNumber0;
  String? phoneNumber1;
  String? phoneNumber2;
  String? phoneNumber3;
  String? phoneNumber4;
  String? charges0;
  String? charges1;
  String? charges2;
  String? charges3;
  String? charges4;
  String? riderName0;
  String? riderName1;
  String? riderName2;
  String? riderName3;
  String? riderName4;
  Map<String, dynamic>? jsonResponse;
  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();

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

      // Access the passcode

      passcode0 = jsonResponse!['data']['bookings_fleet'][0]
              ['bookings_destinations']['passcode'] ??
          "";
      debugPrint("Passcode0: $passcode0");
      phoneNumber0 = jsonResponse!['data']['bookings_fleet'][0]
              ['bookings_destinations']['receiver_phone'] ??
          "";
      debugPrint("phoneNumber0: $phoneNumber0");
      charges0 = jsonResponse!['data']['bookings_fleet'][0]
              ['bookings_destinations']['destin_total_charges'] ??
          jsonResponse!['data']['bookings_fleet'][0]['bookings_destinations']
              ['destin_delivery_charges'];
      debugPrint("charges0: $charges0");
      riderName0 = jsonResponse!['data']['bookings_fleet'][0]['users_fleet']
              ['first_name'] ??
          "";
      debugPrint("riderName0: $riderName0");

      if (jsonResponse!['data']['bookings_fleet'].length > 1) {
        passcode1 = jsonResponse!['data']['bookings_fleet'][1]
                ['bookings_destinations']['passcode'] ??
            "";
        debugPrint("Passcode1: $passcode1");
        phoneNumber1 = jsonResponse!['data']['bookings_fleet'][1]
                ['bookings_destinations']['receiver_phone'] ??
            "";
        debugPrint("phoneNumber1: $phoneNumber1");
        charges1 = jsonResponse!['data']['bookings_fleet'][1]
                ['bookings_destinations']['destin_delivery_charges'] ??
            "";
        debugPrint("charges1: $charges1");
        riderName1 = jsonResponse!['data']['bookings_fleet'][1]['users_fleet']
                ['first_name'] ??
            "";
        debugPrint("riderName1: $riderName1");
      }
      if (jsonResponse!['data']['bookings_fleet'].length > 2) {
        passcode2 = jsonResponse!['data']['bookings_fleet'][2]
                ['bookings_destinations']['passcode'] ??
            "";
        debugPrint("Passcode2: $passcode2");
        phoneNumber2 = jsonResponse!['data']['bookings_fleet'][2]
                ['bookings_destinations']['receiver_phone'] ??
            "";
        debugPrint("phoneNumber2: $phoneNumber2");
        charges2 = jsonResponse!['data']['bookings_fleet'][2]
                ['bookings_destinations']['destin_delivery_charges'] ??
            "";
        debugPrint("charges2: $charges2");
        riderName2 = jsonResponse!['data']['bookings_fleet'][2]['users_fleet']
                ['first_name'] ??
            "";
        debugPrint("riderName2: $riderName2");
      }
      if (jsonResponse!['data']['bookings_fleet'].length > 3) {
        passcode3 = jsonResponse!['data']['bookings_fleet'][3]
                ['bookings_destinations']['passcode'] ??
            "";
        debugPrint("Passcode3: $passcode3");
        phoneNumber3 = jsonResponse!['data']['bookings_fleet'][3]
                ['bookings_destinations']['receiver_phone'] ??
            "";
        debugPrint("phoneNumber3: $phoneNumber3");
        charges3 = jsonResponse!['data']['bookings_fleet'][3]
                ['bookings_destinations']['destin_delivery_charges'] ??
            "";
        debugPrint("charges3: $charges3");
        riderName3 = jsonResponse!['data']['bookings_fleet'][3]['users_fleet']
                ['first_name'] ??
            "";
        debugPrint("riderName3: $riderName3");
      }
      if (jsonResponse!['data']['bookings_fleet'].length > 4) {
        passcode4 = jsonResponse!['data']['bookings_fleet'][4]
                ['bookings_destinations']['passcode'] ??
            "";
        debugPrint("Passcode4: $passcode4");
        phoneNumber4 = jsonResponse!['data']['bookings_fleet'][4]
                ['bookings_destinations']['receiver_phone'] ??
            "";
        debugPrint("phoneNumber4: $phoneNumber4");
        charges4 = jsonResponse!['data']['bookings_fleet'][4]
                ['bookings_destinations']['destin_delivery_charges'] ??
            "";
        debugPrint("charges4: $charges4");
        riderName4 = jsonResponse!['data']['bookings_fleet'][4]['users_fleet']
                ['first_name'] ??
            "";
        debugPrint("riderName4: $riderName4");
      }

      if (updateBookingStatusModel.data?.bookingsFleet?[0].bookingsDestinations
              ?.bookingsDestinationsStatus?.name ==
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
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  String? pinID;
  String? termiiApiKey;
  String? pinMessageType;
  String? pinTo;
  String? pinFrom;
  String? pinChannel;
  String? pinAttempts;
  String? pinExpiryTime;
  String? pinLength;
  String? pinPlaceholder;
  String? pinMessageText;
  String? pinType;
  String? tremiiUrl = dotenv.env['TERMII_URL'];
  SendOtpModel sendOtpModel = SendOtpModel();
  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode =
      const CountryCode(name: 'Nigeria', code: 'NG', dialCode: '+234');

  sendMessage() async {
    try {
      String apiUrl = "$tremiiUrl/send";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("apiKey: $termiiApiKey");
      debugPrint("messageType: $pinMessageType");
      debugPrint("to: ${countryCode!.dialCode + phoneNumber0.toString()}");
      debugPrint("from: $pinFrom");
      debugPrint("channel: $pinChannel");
      debugPrint("attempts: $pinAttempts");
      debugPrint("expiryTime: $pinExpiryTime");
      debugPrint("length: $pinLength");
      debugPrint("placeholder: $pinPlaceholder");
      debugPrint("messageText: $pinMessageText");
      debugPrint("pinType: $pinType");
      int bookingsLength = jsonResponse!['data']['bookings_fleet'].length;

// Iterate over the bookings_fleet array
      for (int i = 0; i < bookingsLength; i++) {
        // Get the passcode, phone number, charges, and rider name for the current booking
        String passcode = jsonResponse!['data']['bookings_fleet'][i]
                ['bookings_destinations']['passcode'] ??
            "";
        String phoneNumber = jsonResponse!['data']['bookings_fleet'][i]
                ['bookings_destinations']['receiver_phone'] ??
            "";
        String charges = jsonResponse!['data']['bookings_fleet'][i]
                ['bookings_destinations']['destin_delivery_charges'] ??
            jsonResponse!['data']['bookings_fleet'][i]['bookings_destinations']
                ['destin_total_charges'];
        String riderName = jsonResponse!['data']['bookings_fleet'][i]
                ['users_fleet']['first_name'] ??
            "";

        debugPrint("Passcode$i: $passcode");
        debugPrint("phoneNumber$i: $phoneNumber");
        debugPrint("charges$i: $charges");
        debugPrint("riderName$i: $riderName");
        var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
        var body = {
          "api_key": termiiApiKey,
          "to": countryCode!.dialCode + phoneNumber,
          "from": "N-Alert",
          "sms":
              "Hello, your passcode is $passcode. Your rider is $riderName and the delivery charges are $charges.",
          "type": "plain",
          "channel": "dnd"
        };

        var response = await http.post(
          Uri.parse('https://api.ng.termii.com/api/sms/send'),
          headers: headers,
          body: body,
        );
        print(body);
        print("Send Message Response ${response.request}");
        print("Response Body: ${response.body}");
        final responseString = response.body;
        // Send a message to the current phone number
        // var response = await http.post(
        //   Uri.parse('https://termii.com/api/sms/send'),
        //   // body: {
        //   //   "api_key": termiiApiKey,
        //   //   "message_type": pinMessageType,
        //   //   "to": countryCode!.dialCode + phoneNumber,
        //   //   "from": pinFrom,
        //   //   "channel": pinChannel,
        //   //   "pin_attempts": pinAttempts,
        //   //   "pin_time_to_live": pinExpiryTime,
        //   //   "pin_length": pinLength,
        //   //   "pin_placeholder": passcode, // Use the passcode instead of the OTP
        //   //   "message_text":
        //   //       "Hello, your passcode is $passcode. Your rider is $riderName and the delivery charges are $charges.",
        //   //   "pin_type": pinType,
        //   // },
        //   body: {
        //     "api_key": termiiApiKey,
        //     "to": "2348039749289",
        //     "from": "N-Alert",
        //     "sms":
        //         "Hello, your passcode is $passcode. Your rider is $riderName and the delivery charges are $charges.",
        //     "type": "plain",
        //     "channel": "dnd"
        //   },
        // );

        print("Send Message Response ${response.request}");
        print("Response Body: ${response.body}");

        debugPrint("sendOtpModel status: response: $responseString");
        debugPrint("statusCode: ${response.statusCode}");
        if (response.statusCode == 200) {
          sendOtpModel = sendOtpModelFromJson(responseString);
          pinID = sendOtpModel.pinId;

          debugPrint("pinID: $pinID");
          setState(() {});
          debugPrint('sendOtpModel status: ${sendOtpModel.status}');
        }
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
      latRider = "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.latitude}";
      lngRider = "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.longitude}";
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
      latRider = "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.latitude}";
      lngRider = "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.longitude}";
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
                                              '$imageUrl${widget.riderData!.data!.bookingsFleet![0].usersFleet!.profilePic}',
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
                                              "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.firstName} ${widget.riderData!.data!.bookingsFleet![0].usersFleet!.lastName}",
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
                                                  "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.bookingsRatings}",
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
                                          // Container(
                                          //   color: transparentColor,
                                          //   width: size.width * 0.45,
                                          //   child: AutoSizeText(
                                          //     "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.usersFleetVehicles!.color} ${widget.riderData!.data!.bookingsFleet![0].usersFleet!.usersFleetVehicles!.model} (${widget.riderData!.data!.bookingsFleet![0].usersFleet!.usersFleetVehicles!.vehicleRegistrationNo})",
                                          //     textAlign: TextAlign.center,
                                          //     style: TextStyle(
                                          //       color: textHaveAccountColor,
                                          //       fontSize: 14,
                                          //       fontFamily: 'Syne-Regular',
                                          //     ),
                                          //     minFontSize: 14,
                                          //     maxFontSize: 14,
                                          //     maxLines: 1,
                                          //     overflow: TextOverflow.ellipsis,
                                          //   ),
                                          // ),
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
                                                    riderId: widget.riderData!.data!.bookingsFleet![0].usersFleet!.usersFleetId
                                                        .toString(),
                                                    name:
                                                        "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.firstName} ${widget.riderData!.data!.bookingsFleet![0].usersFleet!.lastName}",
                                                    address:widget.riderData!.data!.bookingsFleet![0].usersFleet!.address,
                                                    phone:
                                                        widget.riderData!.data!.bookingsFleet![0].usersFleet!.phone,
                                                    image: widget.riderData!.data!.bookingsFleet![0].usersFleet!.profilePic,
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
                                                  "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.phone}");
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
                                                      GestureDetector(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      "$passcode0"));
                                                          CustomToast.showToast(
                                                            fontSize: 12,
                                                            message:
                                                                "$passcode0 copied to clipboard",
                                                          );
                                                        },
                                                        child: Tooltip(
                                                          message: "$passcode0",
                                                          child: Text(
                                                            "Passcode ${passcode0 ?? '--'}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color:
                                                                  orangeColor,
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
                                                      ),
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
                                                      GestureDetector(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      "$passcode1"));
                                                          CustomToast.showToast(
                                                            fontSize: 12,
                                                            message:
                                                                "$passcode1 copied to clipboard",
                                                          );
                                                        },
                                                        child: Tooltip(
                                                          message: "$passcode1",
                                                          child: Text(
                                                            "Passcode ${passcode1 ?? '--'}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color:
                                                                  orangeColor,
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
                                                      ),
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
                                                        GestureDetector(
                                                          onTap: () {
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text:
                                                                        "$passcode2"));
                                                            CustomToast
                                                                .showToast(
                                                              fontSize: 12,
                                                              message:
                                                                  "$passcode2 copied to clipboard",
                                                            );
                                                          },
                                                          child: Tooltip(
                                                            message:
                                                                "$passcode2",
                                                            child: Text(
                                                              "Passcode ${passcode2 ?? '--'}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    orangeColor,
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
                                                        ),
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
                                                        GestureDetector(
                                                          onTap: () {
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text:
                                                                        "$passcode3"));
                                                            CustomToast
                                                                .showToast(
                                                              fontSize: 12,
                                                              message:
                                                                  "$passcode3 copied to clipboard",
                                                            );
                                                          },
                                                          child: Tooltip(
                                                            message:
                                                                "$passcode3",
                                                            child: Text(
                                                              "Passcode ${passcode3 ?? '--'}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    orangeColor,
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
                                                        ),
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
                                                        GestureDetector(
                                                          onTap: () {
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text:
                                                                        "$passcode4"));
                                                            CustomToast
                                                                .showToast(
                                                              fontSize: 12,
                                                              message:
                                                                  "$passcode4 copied to clipboard",
                                                            );
                                                          },
                                                          child: Tooltip(
                                                            message:
                                                                "$passcode4",
                                                            child: Text(
                                                              "Passcode ${passcode4 ?? '--'}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    orangeColor,
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
                                                        ),
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
                                  GestureDetector(
                                      onTap: () {
                                        timer?.cancel();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              callbackFunction: startTimer,
                                              riderId: widget.riderData!.data!.bookingsFleet![0].usersFleet!.usersFleetId
                                                  .toString(),
                                              name:
                                                  "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.firstName} ${widget.riderData!.data!.bookingsFleet![0].usersFleet!.lastName}",
                                              address:
                                                  widget.riderData!.data!.bookingsFleet![0].usersFleet!.address,
                                              phone: widget.riderData!.data!.bookingsFleet![0].usersFleet!.phone,
                                              image:
                                                  widget.riderData!.data!.bookingsFleet![0].usersFleet!.profilePic,
                                            ),
                                          ),
                                        );
                                      },
                                      child: buttonGradient(
                                          "Talk to Admin", context)),
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
