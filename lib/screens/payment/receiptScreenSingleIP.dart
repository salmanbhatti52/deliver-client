// ignore_for_file: avoid_print
import 'package:deliver_client/screens/payment/rateDriverFromIP.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'dart:convert' as convert;

class ReceiptScreenSingleIP extends StatefulWidget {
  final Map? singleData;
  final String? currentBookingId;
  final Map? riderData;
  final String? bookingDestinationId;
  final String? date;
  final String? paymentType;
  final String? ridername;
  const ReceiptScreenSingleIP(
      {super.key,
      this.singleData,
      this.riderData,
      this.currentBookingId,
      this.bookingDestinationId,
      this.paymentType,
      this.ridername,
      this.date});

  @override
  State<ReceiptScreenSingleIP> createState() => _ReceiptScreenSingleIPState();
}

class _ReceiptScreenSingleIPState extends State<ReceiptScreenSingleIP> {
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
        if (getAllSystemDataModel.data?[i].type == "vat_charges_pct") {
          vatCharges = "${getAllSystemDataModel.data?[i].description}";
          doubleVatCharges = double.parse(vatCharges!);
          debugPrint("doubleVatCharges: $doubleVatCharges");

          // calculateVATCharges(
          //     doubleVatCharges!,
          //     double.parse(widget.singleData!['bookings_fleet'][0]
          //         ['bookings_destinations']["destin_total_charges"]));
        }
      }
    }
    setState(() {});
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
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
    print("${widget.date}");
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
                Stack(
                  children: [
                    Positioned(
                      top: 90,
                      left: 20,
                      right: 20,
                      // bottom: size.height * 0.1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Material(
                          elevation: 5.0,
                          child: Container(
                            width: double.infinity,
                            height: 620,
                            color: whiteColor,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                                    SizedBox(height: size.height * 0.02),
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
                                    SizedBox(height: size.height * 0.02),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                        SizedBox(width: size.width * 0.06),
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
                                    SizedBox(height: size.height * 0.02),
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
                                              'Pickup',
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
                                                  "${widget.singleData?['bookings_fleet'][0]['bookings_destinations']["pickup_address"]}",
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.62,
                                                child: AutoSizeText(
                                                  "${widget.singleData?['bookings_fleet'][0]['bookings_destinations']["pickup_address"]}",
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
                                                      "${widget.singleData?['bookings_fleet'][0]['bookings_destinations']["destin_delivery_charges"]}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.18,
                                                    child: AutoSizeText(
                                                      "${widget.singleData?['bookings_fleet'][0]['bookings_destinations']["destin_delivery_charges"]}",
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
                                                  "${widget.singleData?['bookings_fleet'][0]['bookings_destinations']["destin_address"]}",
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.62,
                                                child: AutoSizeText(
                                                  "${widget.singleData?['bookings_fleet'][0]['bookings_destinations']["destin_address"]}",
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
                                            SizedBox(
                                                height: size.height * 0.01),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 0.03),
                                    widget.singleData?["destin_discount"] == 0
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
                                                "${widget.singleData?['bookings_fleet'][0]['bookings_destinations']["destin_discount"]}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Medium',
                                                ),
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.05),
                                            ],
                                          )
                                        : const SizedBox(),
                                    SizedBox(height: size.height * 0.005),
                                    Row(
                                      children: [
                                        Text(
                                          'Delivery Charges: ',
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
                                          "${widget.singleData?['bookings_fleet'][0]['bookings_destinations']["destin_delivery_charges"]}",
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
                                          "${widget.singleData!["total_vat_charges"]}",
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
                                    Row(
                                      children: [
                                        Text(
                                          'Service Charges:',
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
                                          "${widget.singleData!["total_svc_running_charges"]}",
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
                                          "${widget.singleData?['total_delivery_charges']}",
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
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   top: MediaQuery.of(context).size.height *
                    //       0.875, // Adjust this value based on screen size
                    //   left: MediaQuery.of(context).size.width *
                    //       0.44, // Adjust this value based on screen size
                    //   child: Align(
                    //     alignment: Alignment.center,
                    //     child: GestureDetector(
                    //       onTap: () {
                    //         setState(() {
                    //           opened = !opened;
                    //         });
                    //       },
                    //       child: opened
                    //           ? detailsButtonDown(context)
                    //           : detailsButtonUp(context),
                    //     ),
                    //   ),
                    // ),
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
                          builder: (context) => RateDriverFromIP(
                            riderData: widget.riderData!,
                            currentBookingId: widget.currentBookingId,
                            bookingDestinationId: widget
                                .singleData!['bookings_fleet'][0]
                                    ['bookings_destinations_id']
                                .toString(),
                          ),
                        ),
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => WhoWillPaySheet(
                      //       singleData: updatedData,
                      //       multipleData: const {},
                      //     ),
                      //   ),
                      // );
                    },
                    child: buttonGradient1("Next", context),
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
