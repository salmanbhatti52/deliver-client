// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/screens/payment/amount_paid_screen.dart';
import 'package:deliver_client/models/update_booking_transaction_model.dart';

String? firstName;
String? lastName;
String? userEmail;

class AmountToPayScreen extends StatefulWidget {
  final Map? singleData;
  final Map? multipleData;
  final String? currentBookingId;
  final SearchRiderData? riderData;
  final String? bookingDestinationId;

  const AmountToPayScreen({
    super.key,
    this.riderData,
    this.singleData,
    this.multipleData,
    this.currentBookingId,
    this.bookingDestinationId,
  });

  @override
  State<AmountToPayScreen> createState() => _AmountToPayScreenState();
}

class _AmountToPayScreenState extends State<AmountToPayScreen> {
  String? currencyUnit;
  final int amount = 100000;
  int? totalAmount;
  final payStackClient = PaystackPlugin();
  final String reference =
      "unique_transaction_ref_${Random().nextInt(1000000)}";

  String? latDest;
  String? lngDest;
  double? destLat;
  double? destLng;
  GoogleMapController? mapController;
  BitmapDescriptor? customMarkerIcon;

  String? baseUrl = dotenv.env['BASE_URL'];
  String? publicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'];

  sharedPref() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userEmail = sharedPref.getString('email');
    firstName = sharedPref.getString('firstName');
    lastName = sharedPref.getString('lastName');
  }

  UpdateBookingTransactionModel updateBookingTransactionModel =
      UpdateBookingTransactionModel();

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
          "payer_name": "$firstName $lastName",
          "payer_email": userEmail,
          "total_amount": widget.singleData!.isNotEmpty
              ? widget.singleData!['total_charges']
              : widget.multipleData!['total_charges'],
          "payment_status": "Paid"
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

  void startPayStack() {
    payStackClient.initialize(publicKey: publicKey!);
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AmountPaidScreen(
            riderData: widget.riderData!,
            singleData: widget.singleData,
            multipleData: widget.multipleData,
            currentBookingId: widget.currentBookingId,
            bookingDestinationId: widget.bookingDestinationId,
          ),
        ),
      );
    } else {
      CustomToast.showToast(
        fontSize: 12,
        message: "Transaction Failed!",
      );
    }
  }

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

  getAllSystemData() async {
    try {
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
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

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
    sharedPref();
    if (widget.singleData!.isNotEmpty) {
      getLocationSingle();
    } else {
      getLocationMultiple();
      debugPrint("Multiple data so no polyline will be shown!");
      debugPrint("Multiple data so no custom marker will be shown!");
    }
    startPayStack();
    loadCustomMarker();
    if (widget.singleData!.isNotEmpty) {
      double parsedValue = double.parse(widget.singleData!['total_charges']);
      totalAmount = (parsedValue + 0.5).floor();
      debugPrint("Rounded Integer: $totalAmount");
    } else {
      double parsedValue = double.parse(widget.multipleData!['total_charges']);
      totalAmount = (parsedValue + 0.5).floor();
      debugPrint("Rounded Integer: $totalAmount");
    }

    // getAllSystemData();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: transparentColor,
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
                            "Amount to Pay",
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                                        "Pending",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: pendingColor,
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
                              // GestureDetector(
                              //   onTap: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => const PaymentScreen(),
                              //       ),
                              //     );
                              //   },
                              //   child: SvgPicture.asset(
                              //     'assets/images/big-orange-edit-icon.svg',
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.04),
                          GestureDetector(
                            onTap: () async {
                              if (widget.singleData!.isNotEmpty) {
                                if (widget.singleData!["payment_gateways_id"] ==
                                    '1') {
                                  await updateBookingTransaction();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AmountPaidScreen(
                                        riderData: widget.riderData!,
                                        singleData: widget.singleData,
                                        multipleData: widget.multipleData,
                                        currentBookingId:
                                            widget.currentBookingId,
                                        bookingDestinationId:
                                            widget.bookingDestinationId,
                                      ),
                                    ),
                                  );
                                } else {
                                  makePayment();
                                }
                              } else {
                                if (widget
                                        .multipleData!["payment_gateways_id"] ==
                                    '1') {
                                  await updateBookingTransaction();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AmountPaidScreen(
                                        riderData: widget.riderData!,
                                        singleData: widget.singleData,
                                        multipleData: widget.multipleData,
                                        currentBookingId:
                                            widget.currentBookingId,
                                        bookingDestinationId:
                                            widget.bookingDestinationId,
                                      ),
                                    ),
                                  );
                                } else {
                                  makePayment();
                                }
                              }
                            },
                            child: buttonGradient("PAY", context),
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
