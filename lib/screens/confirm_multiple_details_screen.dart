// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables, must_be_immutable

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

class ConfirmMultipleDetailsScreen extends StatefulWidget {
  Map<int, dynamic>? indexData0;
  Map<int, dynamic>? indexData1;
  Map<int, dynamic>? indexData2;
  Map<int, dynamic>? indexData3;
  Map<int, dynamic>? indexData4;
  final Map? multipleData;

  ConfirmMultipleDetailsScreen({
    super.key,
    this.indexData0,
    this.indexData1,
    this.indexData2,
    this.indexData3,
    this.indexData4,
    this.multipleData,
  });

  @override
  State<ConfirmMultipleDetailsScreen> createState() =>
      _ConfirmMultipleDetailsScreenState();
}

class _ConfirmMultipleDetailsScreenState
    extends State<ConfirmMultipleDetailsScreen> {
  var dataForIndex0;
  var dataForIndex1;
  var dataForIndex2;
  var dataForIndex3;
  var dataForIndex4;

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
        debugPrint('getAllSystemDataModel status: ${getAllSystemDataModel.status}');
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

    dataForIndex0 = widget.indexData0;
    debugPrint("Data for Index 0: $dataForIndex0");
    // debugPrint("pickupController for Index 0: ${dataForIndex0[0]["pickupController"]}");

    dataForIndex1 = widget.indexData1;
    debugPrint("Data for Index 1: $dataForIndex1");

    dataForIndex2 = widget.indexData2;
    debugPrint("Data for Index 2: $dataForIndex2");

    dataForIndex3 = widget.indexData3;
    debugPrint("Data for Index 3: $dataForIndex3");

    dataForIndex4 = widget.indexData4;
    debugPrint("Data for Index 4: $dataForIndex4");
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
      body: getAllSystemDataModel.data != null
          ? Stack(
              children: [
                Image.asset(
                  'assets/images/home-location-background.png',
                  fit: BoxFit.cover,
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
                  top: 240,
                  right: 120,
                  child: Image.asset(
                    'assets/images/bike-icon.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                Positioned(
                  top: 101,
                  right: 4,
                  child: SvgPicture.asset('assets/images/bike-path-icon.svg'),
                ),
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
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 85,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: size.width * 0.6,
                      height: size.height * 0.45,
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
                                height: size.height * 0.09,
                                child: Row(
                                  children: [
                                    SizedBox(width: size.width * 0.02),
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
                                        width: size.width * 0.359,
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
                                    SizedBox(width: size.width * 0.05),
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
                              ),
                              SizedBox(height: size.height * 0.005),
                              Row(
                                children: [
                                  Text(
                                    'VAT Fee (${doubleVatCharges.toString()}%): ',
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
                                    roundedTotalVatAmount.toString(),
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
                                    totalPrice.toString(),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            '${dataForIndex0[0]["pickupController"]}',
                                        child: Container(
                                          color: transparentColor,
                                          width: size.width * 0.62,
                                          child: AutoSizeText(
                                            '${dataForIndex0[0]["pickupController"]}',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                                maxFontSize: 14,
                                                minFontSize: 12,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size.height * 0.01),
                                      Tooltip(
                                        message:
                                            '${dataForIndex0[0]['destinationController']}',
                                        child: Container(
                                          color: transparentColor,
                                          width: size.width * 0.62,
                                          child: AutoSizeText(
                                            '${dataForIndex0[0]['destinationController']}',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            '${dataForIndex1[1]["pickupController"]}',
                                        child: Container(
                                          color: transparentColor,
                                          width: size.width * 0.62,
                                          child: AutoSizeText(
                                            '${dataForIndex1[1]["pickupController"]}',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                                maxFontSize: 14,
                                                minFontSize: 12,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size.height * 0.01),
                                      Tooltip(
                                        message:
                                            '${dataForIndex1[1]['destinationController']}',
                                        child: Container(
                                          color: transparentColor,
                                          width: size.width * 0.62,
                                          child: AutoSizeText(
                                            '${dataForIndex1[1]['destinationController']}',
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
                              widget.multipleData!['destin_distance2'] != '0.00'
                                  ? Divider(
                                      thickness: 1,
                                      color: dividerColor,
                                      indent: 30,
                                      endIndent: 30,
                                    )
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance2'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance2'] != '0.00'
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
                                                  '${dataForIndex2[2]["pickupController"]}',
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.62,
                                                child: AutoSizeText(
                                                  '${dataForIndex2[2]["pickupController"]}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
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
                              widget.multipleData!['destin_distance2'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance2'] != '0.00'
                                  ? Divider(
                                      thickness: 1,
                                      color: dividerColor,
                                      indent: 30,
                                      endIndent: 30,
                                    )
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance2'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance2'] != '0.00'
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
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.3),
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
                                                      "${widget.multipleData!["destin_delivery_charges2"]}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.16,
                                                    child: AutoSizeText(
                                                      "${widget.multipleData!["destin_delivery_charges2"]}",
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
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Tooltip(
                                              message:
                                                  '${dataForIndex2[2]['destinationController']}',
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.62,
                                                child: AutoSizeText(
                                                  '${dataForIndex2[2]['destinationController']}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
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
                              widget.multipleData!['destin_distance2'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance3'] != '0.00'
                                  ? Divider(
                                      thickness: 1,
                                      color: dividerColor,
                                      indent: 30,
                                      endIndent: 30,
                                    )
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance3'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance3'] != '0.00'
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
                                                  '${dataForIndex3[3]["pickupController"]}',
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.62,
                                                child: AutoSizeText(
                                                  '${dataForIndex3[3]["pickupController"]}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
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
                              widget.multipleData!['destin_distance3'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance3'] != '0.00'
                                  ? Divider(
                                      thickness: 1,
                                      color: dividerColor,
                                      indent: 30,
                                      endIndent: 30,
                                    )
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance3'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance3'] != '0.00'
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
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.3),
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
                                                      "${widget.multipleData!["destin_delivery_charges3"]}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.16,
                                                    child: AutoSizeText(
                                                      "${widget.multipleData!["destin_delivery_charges3"]}",
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
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Tooltip(
                                              message:
                                                  '${dataForIndex3[3]['destinationController']}',
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.62,
                                                child: AutoSizeText(
                                                  '${dataForIndex3[3]['destinationController']}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
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
                              widget.multipleData!['destin_distance3'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance4'] != '0.00'
                                  ? Divider(
                                      thickness: 1,
                                      color: dividerColor,
                                      indent: 30,
                                      endIndent: 30,
                                    )
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance4'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance4'] != '0.00'
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
                                                  '${dataForIndex4[4]["pickupController"]}',
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.62,
                                                child: AutoSizeText(
                                                  '${dataForIndex4[4]["pickupController"]}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
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
                              widget.multipleData!['destin_distance4'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance4'] != '0.00'
                                  ? Divider(
                                      thickness: 1,
                                      color: dividerColor,
                                      indent: 30,
                                      endIndent: 30,
                                    )
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance4'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              widget.multipleData!['destin_distance4'] != '0.00'
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
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.3),
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
                                                      "${widget.multipleData!["destin_delivery_charges4"]}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.16,
                                                    child: AutoSizeText(
                                                      "${widget.multipleData!["destin_delivery_charges4"]}",
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
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Tooltip(
                                              message:
                                                  '${dataForIndex4[4]['destinationController']}',
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.62,
                                                child: AutoSizeText(
                                                  '${dataForIndex4[4]['destinationController']}',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
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
                              widget.multipleData!['destin_distance4'] != '0.00'
                                  ? SizedBox(height: size.height * 0.01)
                                  : const SizedBox(),
                              SizedBox(height: size.height * 0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      Map? updatedData2 = Map.from(widget.multipleData!);
                      updatedData2.addAll({
                        "pickup_address0": dataForIndex0[0]["pickupController"],
                        "pickup_latitude0": dataForIndex0[0]["pickupLatLng"]
                            ["latitude"],
                        "pickup_longitude0": dataForIndex0[0]["pickupLatLng"]
                            ["longitude"],
                        "destin_address0": dataForIndex0[0]
                            ["destinationController"],
                        "destin_latitude0": dataForIndex0[0]
                            ["destinationLatLng"]["latitude"],
                        "destin_longitude0": dataForIndex0[0]
                            ["destinationLatLng"]["longitude"],
                        "receiver_name0": dataForIndex0[0]
                            ["receiversNameController"],
                        "receiver_phone0": dataForIndex0[0]
                            ["receiversNumberController"],
                        "pickup_address1": dataForIndex1[1]["pickupController"],
                        "pickup_latitude1": dataForIndex1[1]["pickupLatLng"]
                            ["latitude"],
                        "pickup_longitude1": dataForIndex1[1]["pickupLatLng"]
                            ["longitude"],
                        "destin_address1": dataForIndex1[1]
                            ['destinationController'],
                        "destin_latitude1": dataForIndex1[1]
                            ['destinationLatLng']["latitude"],
                        "destin_longitude1": dataForIndex1[1]
                            ['destinationLatLng']["longitude"],
                        "receiver_name1": dataForIndex1[1]
                            ["receiversNameController"],
                        "receiver_phone1": dataForIndex1[1]
                            ["receiversNumberController"],
                        "pickup_address2":
                            dataForIndex2[2]["pickupController"] ?? "",
                        "pickup_latitude2":
                            dataForIndex2[2]["pickupLatLng"] != 'null'
                                ? dataForIndex2[2]["pickupLatLng"]
                                : "null",
                        "pickup_longitude2":
                            dataForIndex2[2]["pickupLatLng"] != 'null'
                                ? dataForIndex2[2]["pickupLatLng"]
                                : "null",
                        "destin_address2":
                            dataForIndex2[2]['destinationController'] ?? "",
                        "destin_latitude2":
                            dataForIndex2[2]['destinationLatLng'] != 'null'
                                ? dataForIndex2[2]['destinationLatLng']
                                : "null",
                        "destin_longitude2":
                            dataForIndex2[2]['destinationLatLng'] != 'null'
                                ? dataForIndex2[2]['destinationLatLng']
                                : "null",
                        "receiver_name2":
                            dataForIndex2[2]["receiversNameController"] ?? "",
                        "receiver_phone2":
                            dataForIndex2[2]["receiversNumberController"] ?? "",
                        "pickup_address3":
                            dataForIndex3[3]["pickupController"] ?? "",
                        "pickup_latitude3":
                            dataForIndex3[3]["pickupLatLng"] != 'null'
                                ? dataForIndex3[3]["pickupLatLng"]
                                : "null",
                        "pickup_longitude3":
                            dataForIndex3[3]["pickupLatLng"] != 'null'
                                ? dataForIndex3[3]["pickupLatLng"]
                                : "null",
                        "destin_address3":
                            dataForIndex3[3]['destinationController'] ?? "",
                        "destin_latitude3":
                            dataForIndex3[3]['destinationLatLng'] != 'null'
                                ? dataForIndex3[3]['destinationLatLng']
                                : "null",
                        "destin_longitude3":
                            dataForIndex3[3]['destinationLatLng'] != 'null'
                                ? dataForIndex3[3]['destinationLatLng']
                                : "null",
                        "receiver_name3":
                            dataForIndex3[3]["receiversNameController"] ?? "",
                        "receiver_phone3":
                            dataForIndex3[3]["receiversNumberController"] ?? "",
                        "pickup_address4":
                            dataForIndex4[4]["pickupController"] ?? "",
                        "pickup_latitude4":
                            dataForIndex4[4]["pickupLatLng"] != 'null'
                                ? dataForIndex4[4]["pickupLatLng"]
                                : "null",
                        "pickup_longitude4":
                            dataForIndex4[4]["pickupLatLng"] != 'null'
                                ? dataForIndex4[4]["pickupLatLng"]
                                : "null",
                        "destin_address4":
                            dataForIndex4[4]['destinationController'] ?? "",
                        "destin_latitude4":
                            dataForIndex4[4]['destinationLatLng'] != 'null'
                                ? dataForIndex4[4]['destinationLatLng']
                                : "null",
                        "destin_longitude4":
                            dataForIndex4[4]['destinationLatLng'] != 'null'
                                ? dataForIndex4[4]['destinationLatLng']
                                : "null",
                        "receiver_name4":
                            dataForIndex4[4]["receiversNameController"] ?? "",
                        "receiver_phone4":
                            dataForIndex4[4]["receiversNumberController"] ?? "",
                        "destin_total_charges": roundedTotalPrice.toString(),
                        "total_vat_charges": roundedTotalVatAmount.toString(),
                        "total_charges": totalPrice.toString(),
                        "total_discount": "0.00",
                        "total_discounted_charges": "0.00",
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WhoWillPaySheet(
                            singleData: const {},
                            multipleData: updatedData2,
                          ),
                        ),
                      );
                    },
                    child: buttonGradient("CONFIRM", context),
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
