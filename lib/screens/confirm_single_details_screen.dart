// ignore_for_file: avoid_print

import 'package:deliver_client/utils/buttondown.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:speech_balloon/speech_balloon.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/widgets/who_will_pay_bottomsheet.dart';
import 'dart:convert' as convert;

class ConfirmSingleDetailsScreen extends StatefulWidget {
  final Map? singleData;
  const ConfirmSingleDetailsScreen({super.key, this.singleData});

  @override
  State<ConfirmSingleDetailsScreen> createState() =>
      _ConfirmSingleDetailsScreenState();
}

class _ConfirmSingleDetailsScreenState
    extends State<ConfirmSingleDetailsScreen> {
  String? currencyUnit;
  String? vatCharges;
  double? doubleVatCharges;
  double? totalVatCharges;
  double? totalVatAmount;
  double? roundedTotalVatAmount;
  double? totalPrice;
  double? roundedTotalPrice;

  String? baseUrl = dotenv.env['BASE_URL'];

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
          if (getAllSystemDataModel.data?[i].type == "vat_charges") {
            vatCharges = "${getAllSystemDataModel.data?[i].description}";
            doubleVatCharges = double.parse(vatCharges!);
            debugPrint("doubleVatCharges: $doubleVatCharges");
            setState(() {});
            calculateVATCharges(doubleVatCharges!,
                double.parse(widget.singleData!["destin_total_charges"]));
          }
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  calculateVATCharges(double vat, double deliveryCharges) {
    debugPrint("deliveryCharges: $deliveryCharges");
    double vatPercentage = vat / 100.0;
    totalVatCharges = deliveryCharges - (deliveryCharges * vatPercentage);
    debugPrint("totalVatCharges: $totalVatCharges");
    totalVatAmount = deliveryCharges - totalVatCharges!;
    debugPrint("totalVatAmount: $totalVatAmount");
    roundedTotalVatAmount = double.parse(totalVatAmount!.toStringAsFixed(2));
    debugPrint("roundedTotalVatAmount: $roundedTotalVatAmount");
    calculateTotalPrice(deliveryCharges, roundedTotalVatAmount!);
  }

  calculateTotalPrice(double deliveryCharges, double roundedTotalVatAmount) {
    totalPrice = deliveryCharges + roundedTotalVatAmount;
    debugPrint("totalPrice: $totalPrice");
    roundedTotalPrice = double.parse(totalPrice!.toStringAsFixed(2));
    debugPrint("roundedTotalAmount: $roundedTotalPrice");
  }

  Future<String> getEncodedPolyline() async {
    var url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${widget.singleData!["pickup_latitude"]},${widget.singleData!["pickup_longitude"]}&destination=${widget.singleData!["destin_latitude"]},${widget.singleData!["destin_longitude"]}&key${dotenv.env['MAPS_KEY']}',
    );

    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var routes = jsonResponse['routes'] as List;
      var overviewPolyline = routes[0]['overview_polyline'];
      var points = overviewPolyline['points'];
      return points;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      return '';
    }
  }

  bool opened = false;
  bool closed = false;
  @override
  initState() {
    super.initState();
    getAllSystemData();
    debugPrint("mapData: ${widget.singleData}");
    // getEncodedPolyline();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
      body: getAllSystemDataModel.data != null
          ? Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        double.parse(
                            widget.singleData!["destin_latitude"].toString()),
                        double.parse(
                            widget.singleData!["destin_longitude"].toString()),
                      ),
                      zoom: 14.4746,
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
                // Positioned(
                //   top: 240,
                //   right: 120,
                //   child: Image.asset(
                //     'assets/images/bike-icon.png',
                //     width: 100,
                //     height: 100,
                //   ),
                // ),
                // Positioned(
                //   top: 101,
                //   right: 4,
                //   child: SvgPicture.asset('assets/images/bike-path-icon.svg'),
                // ),
                Positioned(
                  top: 225,
                  right: 135,
                  child: SpeechBalloon(
                    nipLocation: NipLocation.bottom,
                    nipHeight: 12,
                    color: orangeColor,
                    borderColor: borderColor,
                    width: size.width * 0.3,
                    height: size.height * 0.05,
                    borderRadius: 10,
                    offset: const Offset(10, 0),
                    child: Center(
                      child: Text(
                        "${widget.singleData!["destin_time"]}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 12,
                          fontFamily: 'Syne-SemiBold',
                        ),
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: size.height * 0.1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          height: opened ? 325 : 150,
                          color: whiteColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: size.height * 0.02),
                                  Container(
                                    color: transparentColor,
                                    width: size.width,
                                    height: size.height * 0.08,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Fare",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: orangeColor,
                                            fontSize: 32,
                                            fontFamily: 'Syne-Bold',
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.02),
                                        Text(
                                          "$currencyUnit",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: orangeColor,
                                            fontSize: 38,
                                            fontFamily: 'Syne-Bold',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(width: size.width * 0.02),
                                        Tooltip(
                                          message: roundedTotalPrice.toString(),
                                          child: Container(
                                            color: transparentColor,
                                            child: AutoSizeText(
                                              roundedTotalPrice.toString(),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: blackColor,
                                                fontSize: 32,
                                                fontFamily: 'Inter-Bold',
                                              ),
                                              maxLines: 1,
                                              maxFontSize: 32,
                                              minFontSize: 24,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Discount: ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '$currencyUnit ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      Text(
                                        "${widget.singleData?["destin_discount"]}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.05),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.005),
                                  Row(
                                    children: [
                                      Text(
                                        'VAT Fee ($doubleVatCharges%): ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '$currencyUnit ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      Text(
                                        "$roundedTotalVatAmount",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.05),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.005),
                                  Row(
                                    children: [
                                      Text(
                                        'Total Price: ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '$currencyUnit ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      Text(
                                        '$totalPrice',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.05),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/orange-location-big-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.04),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pickup',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 14,
                                              fontFamily: 'Syne-Regular',
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Tooltip(
                                            message:
                                                "${widget.singleData?["pickup_address"]}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.62,
                                              child: AutoSizeText(
                                                "${widget.singleData?["pickup_address"]}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                                minFontSize: 14,
                                                maxFontSize: 14,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Divider(
                                    thickness: 1,
                                    color: dividerColor,
                                    indent: 30,
                                    endIndent: 30,
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/send-small-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.04),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Dropoff',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Syne-Regular',
                                                ),
                                              ),
                                              SizedBox(width: size.width * 0.3),
                                              Text(
                                                '$currencyUnit ',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: orangeColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                              ),
                                              Tooltip(
                                                message:
                                                    "${widget.singleData?["destin_total_charges"]}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.18,
                                                  child: AutoSizeText(
                                                    "${widget.singleData?["destin_total_charges"]}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
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
                                          SizedBox(height: size.height * 0.01),
                                          Tooltip(
                                            message:
                                                "${widget.singleData?["destin_address"]}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.62,
                                              child: AutoSizeText(
                                                "${widget.singleData?["destin_address"]}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                                minFontSize: 14,
                                                maxFontSize: 14,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 680,
                      left: 165,
                      child: Align(
                        alignment: const Alignment(0.5, 0.5),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              opened = !opened;
                            });
                          },
                          child: opened
                              ? detailsButtonUp(context)
                              : detailsButtonDown(context),
                        ),
                      ),
                    ),
                  ],
                ),

                Positioned(
                  bottom: 15,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Map? updatedData = Map.from(widget.singleData!);
                      updatedData.addAll({
                        "total_vat_charges": roundedTotalVatAmount.toString(),
                        "total_charges": totalPrice.toString(),
                        "total_discount": "0.00",
                        "total_discounted_charges": "0.00",
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WhoWillPaySheet(
                            singleData: updatedData,
                            multipleData: const {},
                          ),
                        ),
                      );
                    },
                    child: buttonGradient1("CONFIRM", context),
                  ),
                ),
              ],
            )
          : Center(
              child: Container(
                width: 100,
                height: 100,
                color: transparentColor,
                child: Lottie.asset(
                  'assets/images/loading-icon.json',
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }
}
