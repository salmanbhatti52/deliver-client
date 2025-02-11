// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:deliver_client/models/cancel_booking_model.dart';
import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:deliver_client/models/update_booking_transaction_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:deliver_client/widgets/remove_coma.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:deliver_client/screens/chat_screen.dart';
import 'package:deliver_client/screens/arriving_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';

class BookingAcceptedScreen extends StatefulWidget {
  final double? distance;
  final Map? singleData;
  final Map? multipleData;
  final String? passCode;
  final String? currentBookingId;
  final UpdateBookingStatusModel? riderData;
  final String? bookingDestinationId;

  const BookingAcceptedScreen({
    super.key,
    this.distance,
    this.singleData,
    this.multipleData,
    this.passCode,
    this.currentBookingId,
    this.riderData,
    this.bookingDestinationId,
  });

  @override
  State<BookingAcceptedScreen> createState() => _BookingAcceptedScreenState();
}

class _BookingAcceptedScreenState extends State<BookingAcceptedScreen> {
  bool isLoading = false;

  String? lat;
  String? lng;
  Timer? timer;
  double? riderLat;
  double? riderLng;
  String? currencyUnit;
  String? distanceUnit;
  int currentIndex = 0;
  GoogleMapController? mapController;
  BitmapDescriptor? customMarkerIcon;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];
  String? publicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'];
  ScrollController scrollController = ScrollController();

  final int amount = 100000;
  int? totalAmount;
  final payStackClient = PaystackPlugin();
  final String reference =
      "unique_transaction_ref_${Random().nextInt(1000000)}";
  UpdateBookingTransactionModel updateBookingTransactionModel =
      UpdateBookingTransactionModel();
  String? firstName;
  String? lastName;
  String? userEmail;
  sharedPref() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userEmail = sharedPref.getString('email');
    firstName = sharedPref.getString('firstName');
    lastName = sharedPref.getString('lastName');
  }

  updateBookingTransaction() async {
    try {
      String apiUrl = "$baseUrl/maintain_booking_transaction";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("bookings_id: ${widget.currentBookingId}");
      debugPrint("payer_name: $firstName $lastName");
      debugPrint("payer_email: $userEmail");
      debugPrint(
          "total_amount: ${widget.singleData!.isNotEmpty ? widget.singleData!['total_charges'] : widget.multipleData!['total_charges']}");
      debugPrint("payment_status: Paid");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "bookings_id": widget.currentBookingId,
          // "payer_name": "$firstName $lastName",
          // "payer_email": userEmail,
          "total_amount": widget.singleData!.isNotEmpty
              ? widget.singleData!['total_charges']
              : widget.multipleData!['total_charges'],
          "payment_status": "Paid",
          "bookings_destinations_id": "" // payment_by = 'Receiver'
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        updateBookingTransactionModel =
            updateBookingTransactionModelFromJson(responseString);
        debugPrint(
            'updateBookingTransactionModel status: ${updateBookingTransactionModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  Future<String?> fetchPaymentGatewayKey() async {
    String apiUrl = "$baseUrl/get_payment_gateway_key";
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded', // Ensure correct content type
        },
        body: {
          "payment_gateways_id": "2",
        },
      );

      print("Response Body: ${response.body}"); // Log response for debugging

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData["status"] == "success") {
          return responseData["data"]["key"];
        } else {
          print("API Error: ${responseData["status"]}");
        }
      } else {
        print("Failed to fetch key. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching payment gateway key: $e");
    }
    return null;
  }

  void getKeyAndStartPayment() async {
    String? publicKey = await fetchPaymentGatewayKey();

    if (publicKey != null) {
      print("Public Key: $publicKey");
      startPayStack(publicKey);
    } else {
      print("Failed to fetch payment key");
    }
  }


  void startPayStack(String publicKey) {
    payStackClient.initialize(publicKey: publicKey);
  }

  void makePayment() async {
    final Charge charge = Charge()
      ..amount = totalAmount! * 100
      ..currency = 'NGN'
      ..email = userEmail
      ..reference = reference;

    final CheckoutResponse response = await payStackClient.checkout(
      context,
      charge: charge,
      method: CheckoutMethod.card,
      logo: SvgPicture.asset(
        'assets/images/logo-paystack-icon.svg',
      ),
    );

    if (response.status && response.reference == reference) {
      debugPrint("response: $response");
      CustomToast.showToast(
        fontSize: 12,
        message: "Transaction Successful!",
      );
      await updateBookingTransaction();
      await getAllSystemData();
    } else {
      CustomToast.showToast(
        fontSize: 12,
        message: "Transaction Failed!",
      );
    }
  }

  var passcodeVerified;
  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();

  updateBookingStatus() async {
    // try {
    String apiUrl = "$baseUrl/get_updated_status_booking";
    debugPrint("apiUrl: $apiUrl");
    debugPrint("currentBookingId: ${widget.currentBookingId}");
    var body = {
      "bookings_id": widget.currentBookingId,
      "users_fleet_id": "147" // used in rider-app
    };
    print(body);
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
      print(
          "updateBookingStatusModel.data?.status: ${updateBookingStatusModel.data?.status}");

      // Initialize a list to store passcode_verified statuses

      if (updateBookingStatusModel.data?.status == "Ongoing") {
        timer?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArrivingScreen(
              distance: widget.distance,
              singleData: widget.singleData,
              multipleData: widget.multipleData,
              passCode: widget.passCode,
              riderData: widget.riderData!,
              currentBookingId: widget.currentBookingId,
              bookingDestinationId: widget.bookingDestinationId,
            ),
          ),
        );
      }

      // Now you have a list of passcode_verified statuses for each booking
      // You can use passcodeVerifiedList as needed
      if (mounted) {
        setState(() {});
      }
    }
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

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
        await updateBookingStatus();
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

  // route() {
  //   timer?.cancel();
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //     builder: (context) => ArrivingScreen(
  //       distance: widget.distance,
  //       singleData: widget.singleData,
  //       multipleData: widget.multipleData,
  //       passCode: widget.passCode,
  //       riderData: widget.riderData!,
  //       currentBookingId: widget.currentBookingId,
  //       bookingDestinationId: widget.bookingDestinationId,
  //     ),
  //   ),
  // );
  // }

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
    sharedPref();
    getKeyAndStartPayment();
    // startPayStack();
    updateBookingStatus();
    lat = "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.latitude}";
    lng = "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.longitude}";
    riderLat = double.parse(lat!);
    riderLng = double.parse(lng!);
    debugPrint("riderLat: $riderLat");
    debugPrint("riderLng: $riderLng");
    startTimer();
    if (widget.singleData!.isNotEmpty) {
      // Remove commas and parse the string to a double
      String cleanedSingleData =
          widget.singleData!['total_charges'].replaceAll(',', '');
      double parsedValue = double.parse(cleanedSingleData);
      totalAmount = (parsedValue + 0.5).floor();
      debugPrint("Rounded Integer: $totalAmount");
    } else {
      // Remove commas and parse the string to a double
      String cleanedMultipleData =
          widget.multipleData!['total_charges'].replaceAll(',', '');
      double parsedValue = double.parse(cleanedMultipleData);
      totalAmount = (parsedValue + 0.5).floor();
      debugPrint("Rounded Integer: $totalAmount");
    }

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
                          },
                        ),
                      ),
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
                                          child: widget.riderData?.data?.bookingsFleet?[0].usersFleet?.profilePic != null &&
                                              widget.riderData!.data!.bookingsFleet![0].usersFleet!.profilePic!.isNotEmpty
                                              ? FadeInImage(
                                            placeholder: const AssetImage("assets/images/user-profile.png"),
                                            image: NetworkImage(
                                              '$imageUrl${widget.riderData!.data!.bookingsFleet![0].usersFleet!.profilePic}',
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
                                          //     '$imageUrl${widget.riderData!.data!.bookingsFleet![0].usersFleet!.profilePic}',
                                          //   ),
                                          //   fit: BoxFit.cover,
                                          // ),
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
                                          //     "${widget.riderData!.data!.bookingsFleet![0].vehicles!.} ${widget.riderData!.usersFleetVehicles!.model} (${widget.riderData!.usersFleetVehicles!.vehicleRegistrationNo})",
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
                                                    riderId: widget
                                                        .riderData!
                                                        .data!
                                                        .bookingsFleet![0]
                                                        .usersFleet!
                                                        .usersFleetId
                                                        .toString(),
                                                    name:
                                                        "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.firstName} ${widget.riderData!.data!.bookingsFleet![0].usersFleet!.lastName}",
                                                    address: widget
                                                        .riderData!
                                                        .data!
                                                        .bookingsFleet![0]
                                                        .usersFleet!
                                                        .address,
                                                    phone: widget
                                                        .riderData!
                                                        .data!
                                                        .bookingsFleet![0]
                                                        .usersFleet!
                                                        .phone,
                                                    image: widget
                                                        .riderData!
                                                        .data!
                                                        .bookingsFleet![0]
                                                        .usersFleet!
                                                        .profilePic,
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
                                                          "${widget.singleData?["destin_distance"]} $distanceUnit",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.18,
                                                        child: AutoSizeText(
                                                          "${widget.singleData?["destin_distance"]} $distanceUnit",
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
                                                                    "${widget.distance?.toStringAsFixed(2)} $distanceUnit",
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
                                                                    "${widget.distance?.toStringAsFixed(2)} $distanceUnit",
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
                                                                      "${widget.distance?.toStringAsFixed(2)} $distanceUnit",
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
                                                                      "${widget.distance?.toStringAsFixed(2)} $distanceUnit",
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
                                                                      "${widget.multipleData?["destin_distance"]} $distanceUnit",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.18,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.multipleData?["destin_distance"]} $distanceUnit",
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
                                      ? SizedBox(height: size.height * 0.02)
                                      : SizedBox(height: size.height * 0.01),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      (updateBookingStatusModel
                                                      .data!.paymentBy ==
                                                  "Sender" &&
                                              updateBookingStatusModel
                                                      .data!.paymentStatus ==
                                                  "Unpaid")
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (widget
                                                      .singleData!.isNotEmpty) {
                                                    double parsedValue = double
                                                        .parse(removeCommaFromString(
                                                            widget.singleData![
                                                                'total_charges']));
                                                    totalAmount =
                                                        (parsedValue + 0.5)
                                                            .floor();
                                                    debugPrint(
                                                        "Rounded Integer: $totalAmount");
                                                  } else {
                                                    double parsedValue = double
                                                        .parse(removeCommaFromString(
                                                            widget.multipleData![
                                                                'total_charges']));
                                                    totalAmount =
                                                        (parsedValue + 0.5)
                                                            .floor();
                                                    debugPrint(
                                                        "Rounded Integer: $totalAmount");
                                                  }
                                                  makePayment();
                                                },
                                                child: buttonGradientSmall(
                                                    "Make Payment", context),
                                              ),
                                            )
                                          : const Text(""),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            final reasons =
                                                await fetchCancellationReasons(); // Fetch cancellation reasons
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) => cancelRide(
                                                  context,
                                                  reasons), // Pass reasons to cancelRide function
                                            );
                                          },
                                          child: buttonGradientSmall(
                                              "CANCEL", context),
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
                      Positioned(
                        top: 45,
                        right: 20,
                        child: GestureDetector(
                          onTap: () async {
                            await getAllSystemData();
                          },
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.black,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
      ),
    );
  }

  bool isCanceling = false;
  Future<List<RideCancellationReason>> fetchCancellationReasons() async {
    final response = await http.post(
      Uri.parse(
          'https://deliverbygfl.com/api/get_bookings_cancellations_reasons'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'user_type': 'Customer',
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        final List<dynamic> data = responseData['data'];
        return data.map((reasonData) {
          return RideCancellationReason(
            id: reasonData['bookings_cancellations_reasons_id'].toString(),
            reason: reasonData['reason'],
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch cancellation reasons');
      }
    } else {
      throw Exception('Failed to fetch cancellation reasons');
    }
  }

  CancelBookingModel cancelBookingModel = CancelBookingModel();

  cancelBooking(String cancellationReasonId) async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/cancel_booking_customers";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("bookings_id: ${widget.currentBookingId}");
      // debugPrint("users_fleet_id: ${widget.fleetId}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "bookings_id": widget.currentBookingId,
          "bookings_cancellations_reasons_id": cancellationReasonId
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        cancelBookingModel = cancelBookingModelFromJson(responseString);
        setState(() {});
        debugPrint('cancelBookingModel status: ${cancelBookingModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  cancelRide(BuildContext context, List<RideCancellationReason> reasons) {
    var size = MediaQuery.of(context).size;
    String? selectedReason;
    return StatefulBuilder(
      builder: (context, setState) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        insetPadding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
          height: size.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FutureBuilder<List<RideCancellationReason>>(
              future: fetchCancellationReasons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final cancellationReasons = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: SvgPicture.asset(
                                "assets/images/close-icon.svg"),
                          ),
                        ),
                      ),
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
                        'Are you sure you want to cancel this ride?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 18,
                          fontFamily: 'Syne-Regular',
                        ),
                      ),
                      // Display cancellation reasons as radio buttons
                      Column(
                        children: cancellationReasons.map((reason) {
                          return Transform.scale(
                            scale: 0.9,
                            child: RadioListTile<String>(
                              title: Text(
                                reason.reason,
                                style: TextStyle(color: blackColor),
                              ),
                              value: reason.id,
                              groupValue: selectedReason,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedReason = value!;
                                });
                              },
                              activeColor: orangeColor,
                            ),
                          );
                        }).toList(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (selectedReason != null) {
                                setState(() {
                                  isLoading = true;
                                });
                                await cancelBooking(selectedReason!);
                                if (cancelBookingModel.status == "success") {
                                  timer?.cancel();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePageScreen(index: 0)),
                                    (Route<dynamic> route) => false,
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  CustomToast.showToast(
                                    fontSize: 12,
                                    message:
                                        "You have already cancelled this booking.",
                                  );
                                }
                              } else {
                                CustomToast.showToast(
                                  fontSize: 12,
                                  message:
                                      "Please select a cancellation reason.",
                                );
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: isLoading
                                ? dialogButtonGradientSmallWithLoader(
                                    "Please wait...", context)
                                : Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                        stops: const [0.1, 1.5],
                                        colors: [
                                          orangeColor,
                                          yellowColor,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Yes, Cancel Ride",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 16,
                                          fontFamily: 'Syne-Medium',
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class RideCancellationReason {
  final String id;
  final String reason;

  RideCancellationReason({required this.id, required this.reason});
}
