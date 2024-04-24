// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable
import 'package:intl/intl.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/screens/rate_driver_screen.dart';
import 'package:deliver_client/utils/buttondown.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/widgets/who_will_pay_bottomsheet.dart';

class ReceiptScreenMultiple extends StatefulWidget {
  Map<int, dynamic>? indexData0;
  Map<int, dynamic>? indexData1;
  Map<int, dynamic>? indexData2;
  Map<int, dynamic>? indexData3;
  Map<int, dynamic>? indexData4;
  final Map? multipleData;
  final String? currentBookingId;
  final SearchRiderData? riderData;
  final String? bookingDestinationId;
  final String? date;
  final String? paymentType;
  final String? ridername;

  ReceiptScreenMultiple(
      {super.key,
      this.indexData0,
      this.indexData1,
      this.indexData2,
      this.indexData3,
      this.indexData4,
      this.multipleData,
      this.riderData,
      this.currentBookingId,
      this.bookingDestinationId,
      this.paymentType,
      this.ridername,
      this.date});

  @override
  State<ReceiptScreenMultiple> createState() => _ReceiptScreenMultipleState();
}

class _ReceiptScreenMultipleState extends State<ReceiptScreenMultiple> {
  String? currencyUnit;
  String? vatCharges;
  double? discountCharges;
  double? deliveryCharges;
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
            calculateVATCharges(doubleVatCharges!);
          }
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  allCharges() {
    deliveryCharges =
        double.parse(widget.multipleData!["destin_delivery_charges0"]) +
            double.parse(widget.multipleData!["destin_delivery_charges1"]) +
            double.parse(widget.multipleData!["destin_delivery_charges2"]) +
            double.parse(widget.multipleData!["destin_delivery_charges3"]) +
            double.parse(widget.multipleData!["destin_delivery_charges4"]);
    debugPrint("deliveryCharges: $deliveryCharges");
  }

  allDiscountCharges() {
    discountCharges = double.parse(widget.multipleData!["destin_discount0"]) +
        double.parse(widget.multipleData!["destin_discount1"]) +
        double.parse(widget.multipleData!["destin_discount2"]) +
        double.parse(widget.multipleData!["destin_discount3"]) +
        double.parse(widget.multipleData!["destin_discount4"]);
    debugPrint("discountCharges: $discountCharges");
  }

  calculateVATCharges(double vat) {
    debugPrint("deliveryCharges: $deliveryCharges");
    double vatPercentage = vat / 100.0;
    totalVatCharges = deliveryCharges! - (deliveryCharges! * vatPercentage);
    debugPrint("totalVatCharges: $totalVatCharges");
    totalVatAmount = deliveryCharges! - totalVatCharges!;
    debugPrint("totalVatAmount: $totalVatAmount");
    roundedTotalVatAmount = double.parse(totalVatAmount!.toStringAsFixed(2));
    debugPrint("roundedTotalVatAmount: $roundedTotalVatAmount");
    calculateTotalPrice(roundedTotalVatAmount!);
  }

  calculateTotalPrice(double roundedTotalVatAmount) {
    totalPrice = deliveryCharges! + roundedTotalVatAmount;
    debugPrint("totalPrice: $totalPrice");
    roundedTotalPrice = double.parse(totalPrice!.toStringAsFixed(2));
    debugPrint("roundedTotalAmount: $roundedTotalPrice");
  }

  @override
  initState() {
    super.initState();
    allCharges();
    getAllSystemData();
    allDiscountCharges();
    debugPrint("multipleData:  ${widget.multipleData}");
    // if (widget.dataForIndexes != null) {
    //   for (var i = 0; i < widget.dataForIndexes!.length; i++) {
    //     final dataForIndex = widget.dataForIndexes![i];
    //     final dataIndex = dataForIndex.keys.first; // Get the index
    //     final data = dataForIndex[dataIndex];
    //
    //     // Check if data contains null values
    //     if (data.containsValue(null)) {
    //       debugPrint("Data for Index $dataIndex: Data contains null values");
    //     } else {
    //       debugPrint("Data for Index Number $dataIndex: $data");
    //     }
    //   }
    // }
  }

  bool opened = false;
  bool closed = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
      body: getAllSystemDataModel.data != null
          ? Stack(
              children: [
                // Image.asset(
                //   'assets/images/home-location-background.png',
                //   fit: BoxFit.cover,
                // ),
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

                // Positioned(
                //   top: 225,
                //   right: 135,
                //   child: SpeechBalloon(
                //     nipLocation: NipLocation.bottom,
                //     nipHeight: 12,
                //     color: orangeColor,
                //     borderColor: borderColor,
                //     width: size.width * 0.3,
                //     height: size.height * 0.05,
                //     borderRadius: 10,
                //     offset: const Offset(10, 0),
                //     child: Center(
                //       child: Text(
                //         "4 hours 5 mins",
                //         textAlign: TextAlign.center,
                //         style: TextStyle(
                //           color: whiteColor,
                //           fontSize: 12,
                //           fontFamily: 'Syne-SemiBold',
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Stack(
                  children: [
                    Positioned(
                      left: 20,
                      right: 20,
                      top: 90,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          height: 620,
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
                                          "Receipt",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: orangeColor,
                                            fontSize: 32,
                                            fontFamily: 'Syne-Bold',
                                          ),
                                        ),

                                        // SizedBox(width: size.width * 0.13),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Rider Name",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 12,
                                          fontFamily: 'Syne-Bold',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.13),
                                      Text(
                                        "${widget.ridername}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 12,
                                          fontFamily: 'Syne-Bold',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    color: transparentColor,
                                    width: size.width,
                                    height: size.height * 0.08,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "Date",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: orangeColor,
                                            fontSize: 12,
                                            fontFamily: 'Syne-Bold',
                                          ),
                                        ),
                                        SizedBox(width: size.width * 0.005),
                                        Text(
                                          widget.date != null
                                              ? DateFormat('EEEE, MMMM d, y')
                                                  .format(DateTime.parse(
                                                      widget.date!))
                                              : 'Default Date',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: blackColor,
                                            fontSize: 12,
                                            fontFamily: 'Syne-Bold',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Text(
                                        "Payment Method",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 12,
                                          fontFamily: 'Syne-Bold',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.13),
                                      Text(
                                        "${widget.paymentType}",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 12,
                                          fontFamily: 'Syne-Bold',
                                        ),
                                      ),
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
                                            'Pickup 1',
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
                                                '${widget.multipleData!["pickup_address"] ?? ""}',
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.62,
                                              child: AutoSizeText(
                                                '${widget.multipleData!["pickup_address"] ?? ""}',
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
                                                'Dropoff 1',
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
                                                    "${widget.multipleData!["destin_delivery_charges0"]}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.16,
                                                  child: AutoSizeText(
                                                    "${widget.multipleData!["destin_delivery_charges0"]}",
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
                                                '${widget.multipleData!['destin_address0']}',
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.62,
                                              child: AutoSizeText(
                                                '${widget.multipleData!['destin_address0']}',
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
                                        'assets/images/orange-location-big-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.04),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Pickup 2',
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
                                                '${widget.multipleData!["pickup_address1"]}',
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.62,
                                              child: AutoSizeText(
                                                '${widget.multipleData!["pickup_address1"]}',
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
                                          'assets/images/send-small-icon.svg'),
                                      SizedBox(width: size.width * 0.04),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Dropoff 2',
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
                                                    "${widget.multipleData!["destin_delivery_charges1"]}",
                                                child: Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.16,
                                                  child: AutoSizeText(
                                                    "${widget.multipleData!["destin_delivery_charges1"]}",
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
                                                '${widget.multipleData!['destin_address1']}',
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.62,
                                              child: AutoSizeText(
                                                '${widget.multipleData!['destin_address1']}',
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
                                  widget.multipleData!['destin_distance2'] !=
                                          '0.00'
                                      ? Divider(
                                          thickness: 1,
                                          color: dividerColor,
                                          indent: 30,
                                          endIndent: 30,
                                        )
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance2'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance2'] !=
                                          '0.00'
                                      ? Row(
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
                                                  'Pickup 3',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: size.height * 0.01),
                                                Tooltip(
                                                  message:
                                                      '${widget.multipleData!["pickup_address2"]}',
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.62,
                                                    child: AutoSizeText(
                                                      '${widget.multipleData!["pickup_address2"]}',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      minFontSize: 14,
                                                      maxFontSize: 14,
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
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance2'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance2'] !=
                                          '0.00'
                                      ? Divider(
                                          thickness: 1,
                                          color: dividerColor,
                                          indent: 30,
                                          endIndent: 30,
                                        )
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance2'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance2'] !=
                                          '0.00'
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                                'assets/images/send-small-icon.svg'),
                                            SizedBox(width: size.width * 0.04),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Dropoff 3',
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
                                                        width:
                                                            size.width * 0.3),
                                                    Text(
                                                      '$currencyUnit ',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: orangeColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                    ),
                                                    Tooltip(
                                                      message:
                                                          "${widget.multipleData!["destin_delivery_charges2"]}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.16,
                                                        child: AutoSizeText(
                                                          "${widget.multipleData!["destin_delivery_charges2"]}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
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
                                                    height: size.height * 0.01),
                                                Tooltip(
                                                  message:
                                                      '${widget.multipleData!['destin_address2']}',
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.62,
                                                    child: AutoSizeText(
                                                      '${widget.multipleData!['destin_address2']}',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      minFontSize: 14,
                                                      maxFontSize: 14,
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
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance2'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance3'] !=
                                          '0.00'
                                      ? Divider(
                                          thickness: 1,
                                          color: dividerColor,
                                          indent: 30,
                                          endIndent: 30,
                                        )
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance3'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance3'] !=
                                          '0.00'
                                      ? Row(
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
                                                  'Pickup 4',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: size.height * 0.01),
                                                Tooltip(
                                                  message:
                                                      '${widget.multipleData!["pickup_address3"]}',
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.62,
                                                    child: AutoSizeText(
                                                      '${widget.multipleData!["pickup_address3"]}',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      minFontSize: 14,
                                                      maxFontSize: 14,
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
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance3'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance3'] !=
                                          '0.00'
                                      ? Divider(
                                          thickness: 1,
                                          color: dividerColor,
                                          indent: 30,
                                          endIndent: 30,
                                        )
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance3'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance3'] !=
                                          '0.00'
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                                'assets/images/send-small-icon.svg'),
                                            SizedBox(width: size.width * 0.04),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Dropoff 4',
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
                                                        width:
                                                            size.width * 0.3),
                                                    Text(
                                                      '$currencyUnit ',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: orangeColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                    ),
                                                    Tooltip(
                                                      message:
                                                          "${widget.multipleData!["destin_delivery_charges3"]}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.16,
                                                        child: AutoSizeText(
                                                          "${widget.multipleData!["destin_delivery_charges3"]}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
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
                                                    height: size.height * 0.01),
                                                Tooltip(
                                                  message:
                                                      '${widget.multipleData!['destin_address3']}',
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.62,
                                                    child: AutoSizeText(
                                                      '${widget.multipleData!['destin_address3']}',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      minFontSize: 14,
                                                      maxFontSize: 14,
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
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance3'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance4'] !=
                                          '0.00'
                                      ? Divider(
                                          thickness: 1,
                                          color: dividerColor,
                                          indent: 30,
                                          endIndent: 30,
                                        )
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance4'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance4'] !=
                                          '0.00'
                                      ? Row(
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
                                                  'Pickup 5',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: size.height * 0.01),
                                                Tooltip(
                                                  message:
                                                      '${widget.multipleData!["pickup_address4"]}',
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.62,
                                                    child: AutoSizeText(
                                                      '${widget.multipleData!["pickup_address4"]}',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      minFontSize: 14,
                                                      maxFontSize: 14,
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
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance4'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance4'] !=
                                          '0.00'
                                      ? Divider(
                                          thickness: 1,
                                          color: dividerColor,
                                          indent: 30,
                                          endIndent: 30,
                                        )
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance4'] !=
                                          '0.00'
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance4'] !=
                                          '0.00'
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                                'assets/images/send-small-icon.svg'),
                                            SizedBox(width: size.width * 0.04),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Dropoff 5',
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
                                                        width:
                                                            size.width * 0.3),
                                                    Text(
                                                      '$currencyUnit ',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: orangeColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                    ),
                                                    Tooltip(
                                                      message:
                                                          "${widget.multipleData!["destin_delivery_charges4"]}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.16,
                                                        child: AutoSizeText(
                                                          "${widget.multipleData!["destin_delivery_charges4"]}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
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
                                                    height: size.height * 0.01),
                                                Tooltip(
                                                  message:
                                                      '${widget.multipleData!['destin_address4']}',
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.62,
                                                    child: AutoSizeText(
                                                      '${widget.multipleData!['destin_address4']}',
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      minFontSize: 14,
                                                      maxFontSize: 14,
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
                                      : const SizedBox(),
                                  widget.multipleData!['destin_distance4'] !=
                                          ' '
                                      ? SizedBox(height: size.height * 0.01)
                                      : const SizedBox(),
                                  SizedBox(height: size.height * 0.020),

                                  discountCharges == "0.0"
                                      ? Row(
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
                                              discountCharges.toString(),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: blackColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter-Medium',
                                              ),
                                            ),
                                            SizedBox(width: size.width * 0.05),
                                          ],
                                        )
                                      : const SizedBox(),
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
                                  Divider(
                                    thickness: 2,
                                    color: dividerColor,
                                    indent: 1,
                                    endIndent: 15,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Total Bill: ',
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
                                  SizedBox(height: size.height * 0.020),
                                  Center(
                                    child: Image.asset(
                                      'assets/images/paid1.png',
                                      width: 150,
                                      height: 150,
                                    ),
                                  ),

                                  // SizedBox(height: size.height * 0.005),
                                  // Row(
                                  //   children: [
                                  //     Text(
                                  //       'VAT Fee (${doubleVatCharges.toString()}%): ',
                                  //       textAlign: TextAlign.left,
                                  //       style: TextStyle(
                                  //         color: blackColor,
                                  //         fontSize: 14,
                                  //         fontFamily: 'Inter-Medium',
                                  //       ),
                                  //     ),
                                  //     const Spacer(),
                                  //     Text(
                                  //       '$currencyUnit ',
                                  //       textAlign: TextAlign.left,
                                  //       style: TextStyle(
                                  //         color: orangeColor,
                                  //         fontSize: 14,
                                  //         fontFamily: 'Inter-Medium',
                                  //       ),
                                  //     ),
                                  //     Text(
                                  //       roundedTotalVatAmount.toString(),
                                  //       textAlign: TextAlign.left,
                                  //       style: TextStyle(
                                  //         color: blackColor,
                                  //         fontSize: 14,
                                  //         fontFamily: 'Inter-Medium',
                                  //       ),
                                  //     ),
                                  //     SizedBox(width: size.width * 0.05),
                                  //   ],
                                  // ),
                                  // SizedBox(height: size.height * 0.005),
                                  // Row(
                                  //   children: [
                                  //     Text(
                                  //       'Total Price: ',
                                  //       textAlign: TextAlign.left,
                                  //       style: TextStyle(
                                  //         color: blackColor,
                                  //         fontSize: 14,
                                  //         fontFamily: 'Inter-Medium',
                                  //       ),
                                  //     ),
                                  //     const Spacer(),
                                  //     Text(
                                  //       '$currencyUnit ',
                                  //       textAlign: TextAlign.left,
                                  //       style: TextStyle(
                                  //         color: orangeColor,
                                  //         fontSize: 14,
                                  //         fontFamily: 'Inter-Medium',
                                  //       ),
                                  //     ),
                                  //     Text(
                                  //       totalPrice.toString(),
                                  //       textAlign: TextAlign.left,
                                  //       style: TextStyle(
                                  //         color: blackColor,
                                  //         fontSize: 14,
                                  //         fontFamily: 'Inter-Medium',
                                  //       ),
                                  //     ),
                                  //     SizedBox(width: size.width * 0.05),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ),
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
                      Map? updatedData2 = Map.from(widget.multipleData!);
                      updatedData2.addAll({
                        "pickup_address0":
                            widget.multipleData!["pickupController"],
                        // "pickup_latitude0": "0",
                        // "pickup_longitude0": "0",
                        "destin_address0":
                            widget.multipleData!["destinationController"],
                        // "destin_latitude0": "0",
                        // "destin_longitude0": "0",
                        "receiver_name0":
                            widget.multipleData!["receiversNameController"],
                        "receiver_phone0":
                            widget.multipleData!["receiversNumberController"],
                        "pickup_address1":
                            widget.multipleData!["pickupController"],
                        // "pickup_latitude1": "0",
                        // "pickup_longitude1": "0",
                        "destin_address1":
                            widget.multipleData!['destinationController'],
                        // "destin_latitude1": "0",
                        // "destin_longitude1": "0",
                        "receiver_name1":
                            widget.multipleData!["receiversNameController"],
                        "receiver_phone1":
                            widget.multipleData!["receiversNumberController"],
                        "pickup_address2":
                            widget.multipleData!["pickupController"] ?? "",
                        // "pickup_latitude2":
                        //     widget.multipleData!["pickupLatLng"] != 'null'
                        //         ? widget.multipleData!["pickupLatLng"]
                        //         : "0",
                        // "pickup_longitude2":
                        //     widget.multipleData!["pickupLatLng"] != 'null'
                        //         ? widget.multipleData!["pickupLatLng"]
                        //         : "0",
                        "destin_address2":
                            widget.multipleData!['destinationController'] ?? "",
                        // "destin_latitude2":
                        //     widget.multipleData!['destinationLatLng'] != 'null'
                        //         ? widget.multipleData!['destinationLatLng']
                        //         : "0",
                        // "destin_longitude2":
                        //     widget.multipleData!['destinationLatLng'] != 'null'
                        //         ? widget.multipleData!['destinationLatLng']
                        //         : "0",
                        "receiver_name2":
                            widget.multipleData!["receiversNameController"] ??
                                "",
                        "receiver_phone2":
                            widget.multipleData!["receiversNumberController"] ??
                                "",
                        "pickup_address3":
                            widget.multipleData!["pickupController"] ?? "",
                        // "pickup_latitude3":
                        //     widget.multipleData!["pickupLatLng"] != 'null'
                        //         ? widget.multipleData!["pickupLatLng"]
                        //         : "0",
                        // "pickup_longitude3":
                        //     widget.multipleData!["pickupLatLng"] != 'null'
                        //         ? widget.multipleData!["pickupLatLng"]
                        //         : "0",
                        "destin_address3":
                            widget.multipleData!['destinationController'] ?? "",
                        // "destin_latitude3":
                        //     widget.multipleData!['destinationLatLng'] != 'null'
                        //         ? widget.multipleData!['destinationLatLng']
                        //         : "0",
                        // "destin_longitude3":
                        //     widget.multipleData!['destinationLatLng'] != 'null'
                        //         ? widget.multipleData!['destinationLatLng']
                        //         : "0",
                        "receiver_name3":
                            widget.multipleData!["receiversNameController"] ??
                                "",
                        "receiver_phone3":
                            widget.multipleData!["receiversNumberController"] ??
                                "",
                        "pickup_address4":
                            widget.multipleData!["pickupController"] ?? "",
                        // "pickup_latitude4":
                        //     widget.multipleData!["pickupLatLng"] != 'null'
                        //         ? widget.multipleData!["pickupLatLng"]
                        //         : "0",
                        // "pickup_longitude4":
                        //     widget.multipleData!["pickupLatLng"] != 'null'
                        //         ? widget.multipleData!["pickupLatLng"]
                        //         : "0",
                        "destin_address4":
                            widget.multipleData!['destinationController'] ?? "",
                        // "destin_latitude4":
                        //     widget.multipleData!['destinationLatLng'] != 'null'
                        //         ? widget.multipleData!['destinationLatLng']
                        //         : "0",
                        // "destin_longitude4":
                        //     widget.multipleData!['destinationLatLng'] != 'null'
                        //         ? widget.multipleData!['destinationLatLng']
                        //         : "0",
                        "receiver_name4":
                            widget.multipleData!["receiversNameController"] ??
                                "",
                        "receiver_phone4":
                            widget.multipleData!["receiversNumberController"] ??
                                "",
                        "destin_total_charges": roundedTotalPrice.toString(),
                        "total_vat_charges": roundedTotalVatAmount.toString(),
                        "total_charges": totalPrice.toString(),
                        "total_discount": "0.00",
                        "total_discounted_charges": "0.00",
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RateDriverScreen(
                            riderData: widget.riderData!,
                            currentBookingId: widget.currentBookingId,
                            bookingDestinationId: widget.bookingDestinationId,
                          ),
                        ),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => WhoWillPaySheet(
                      //       singleData: const {},
                      //       multipleData: updatedData2,
                      //     ),
                      //   ),
                      // );
                    },
                    child: buttonGradient("Next", context),
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
