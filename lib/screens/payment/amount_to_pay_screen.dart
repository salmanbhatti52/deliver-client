// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/screens/payment/amount_paid_screen.dart';

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
      print("response: $response");
      Fluttertoast.showToast(
        msg: "Transaction Successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: toastColor,
        textColor: whiteColor,
        fontSize: 12,
      );
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
      Fluttertoast.showToast(
        msg: "Transaction Failed!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: toastColor,
        textColor: whiteColor,
        fontSize: 12,
      );
    }
  }

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

  getAllSystemData() async {
    try {
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
        }
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  getLocation() {
    if (widget.singleData != null) {
      latDest = "${widget.singleData!['destin_latitude']}";
      lngDest = "${widget.singleData!['destin_longitude']}";
      destLat = double.parse(latDest!);
      destLng = double.parse(lngDest!);
      print("destLat: $destLat");
      print("destLng: $destLng");
    } else {
      print("No LatLng Data");
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
    getLocation();
    startPayStack();
    loadCustomMarker();
    double parsedValue = double.parse(widget.singleData!['total_charges']);
    totalAmount = (parsedValue + 0.5).floor();
    print("Rounded Integer: $totalAmount");
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
                              text: "${widget.singleData!['total_charges']}",
                              style: TextStyle(
                                color: orangeColor,
                                fontSize: 26,
                                fontFamily: 'Inter-Bold',
                              ),
                              children: [
                                TextSpan(
                                  text: '₦',
                                  style: TextStyle(
                                    color: orangeColor,
                                    fontSize: 20,
                                    fontFamily: 'Inter-Regular',
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
                                      Text(
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
                            onTap: () {
                              if (widget.singleData!["payment_gateways_id"] ==
                                  '1') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AmountPaidScreen(
                                      riderData: widget.riderData!,
                                      singleData: widget.singleData,
                                      multipleData: widget.multipleData,
                                      currentBookingId: widget.currentBookingId,
                                      bookingDestinationId:
                                          widget.bookingDestinationId,
                                    ),
                                  ),
                                );
                              } else {
                                makePayment();
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
