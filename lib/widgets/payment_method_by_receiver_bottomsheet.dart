// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/screens/search_riders_screen.dart';
import 'package:deliver_client/models/get_payment_getaways_model.dart';

// bool isSelectedBank = true;
bool isSelectedCash = false;

class PaymentMethodByReceiverSheet extends StatefulWidget {
  final Map? singleData;
  final Map? multipleData;

  const PaymentMethodByReceiverSheet(
      {super.key, this.singleData, this.multipleData});

  @override
  State<PaymentMethodByReceiverSheet> createState() =>
      _PaymentMethodByReceiverSheetState();
}

class _PaymentMethodByReceiverSheetState
    extends State<PaymentMethodByReceiverSheet> {
  String? cashId;
  bool isApiCalled = false;
  String? baseUrl = dotenv.env['BASE_URL'];

  GetPaymentGatewaysModel getPaymentGatewaysModel = GetPaymentGatewaysModel();

  getPaymentGateways() async {
    try {
      String apiUrl = "$baseUrl/get_payment_gateways";
      debugPrint("apiUrl: $apiUrl");
      cashId = "";
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
        getPaymentGatewaysModel =
            getPaymentGatewaysModelFromJson(responseString);
        debugPrint(
            'getPaymentGatewaysModel status: ${getPaymentGatewaysModel.status}');
        debugPrint(
            'getPaymentGatewaysModel length: ${getPaymentGatewaysModel.data!.length}');
        for (int i = 0; i < getPaymentGatewaysModel.data!.length; i++) {
          if (getPaymentGatewaysModel.data?[i].name == "Cash") {
            cashId = "${getPaymentGatewaysModel.data?[i].paymentGatewaysId}";
          }
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    isSelectedCash = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      paymentMethodByReceiverSheet(
        context,
        // bank: "Bank",
        // imageBank: "assets/images/pay-bank-icon.svg",
        cash: "Cash",
        imageCash: "assets/images/pay-cash-icon.svg",
        select: "Select",
      );
    });
    debugPrint("mapData Single: ${widget.singleData}");
    debugPrint("mapData Multiple: ${widget.multipleData}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
    );
  }

  Future<dynamic> paymentMethodByReceiverSheet(
    BuildContext context, {
    cash,
    imageCash,
    select,
  }) {
    var size = MediaQuery.of(context).size;
    return showModalBottomSheet(
      elevation: 0,
      context: context,
      enableDrag: false,
      backgroundColor: whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => WillPopScope(
            onWillPop: () async {
              Navigator.pop(context);
              Navigator.pop(context);
              return false;
            },
            child: SizedBox(
              width: size.width,
              height: size.height * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.06),
                  Text(
                    'Select Payment Method',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 22,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // GestureDetector(
                        //   onTap: () async {
                        //     await getPaymentGateways();
                        //     setState(() {
                        //       isSelectedBank = true;
                        //       isSelectedCash = false;
                        //     });
                        //   },
                        //   child: Stack(
                        //     children: [
                        //       Container(
                        //         color: transparentColor,
                        //         width: MediaQuery.of(context).size.width * 0.42,
                        //         height: MediaQuery.of(context).size.height * 0.15,
                        //       ),
                        //       Positioned(
                        //         bottom: 0,
                        //         child: Container(
                        //           width: MediaQuery.of(context).size.width * 0.42,
                        //           height: MediaQuery.of(context).size.height * 0.12,
                        //           decoration: BoxDecoration(
                        //             color: isSelectedBank == true
                        //                 ? orangeColor
                        //                 : const Color(0xFFEBEBEB),
                        //             borderRadius: BorderRadius.circular(15),
                        //           ),
                        //         ),
                        //       ),
                        //       Positioned(
                        //         bottom: 35,
                        //         left: 0,
                        //         right: 0,
                        //         child: Text(
                        //           bank,
                        //           textAlign: TextAlign.center,
                        //           style: TextStyle(
                        //             color: isSelectedBank == true
                        //                 ? whiteColor
                        //                 : drawerTextColor,
                        //             fontSize: 16,
                        //             fontFamily: 'Syne-Bold',
                        //           ),
                        //         ),
                        //       ),
                        //       Positioned(
                        //         bottom: 15,
                        //         left: 0,
                        //         right: 0,
                        //         child: Text(
                        //           select,
                        //           textAlign: TextAlign.center,
                        //           style: TextStyle(
                        //             color: isSelectedBank == true
                        //                 ? whiteColor
                        //                 : supportTextColor,
                        //             fontSize: 14,
                        //             fontFamily: 'Syne-Regular',
                        //           ),
                        //         ),
                        //       ),
                        //       Positioned(
                        //         top: 0,
                        //         left: 0,
                        //         right: 0,
                        //         child: SvgPicture.asset(imageBank),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // isSelectedBank = false;
                              isSelectedCash = true;
                            });
                          },
                          child: Stack(
                            children: [
                              Container(
                                color: transparentColor,
                                width: MediaQuery.of(context).size.width * 0.5,
                                height:
                                    MediaQuery.of(context).size.height * 0.17,
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height:
                                      MediaQuery.of(context).size.height * 0.14,
                                  decoration: BoxDecoration(
                                    color: isSelectedCash == true
                                        ? orangeColor
                                        : const Color(0xFFEBEBEB),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 68,
                                left: 0,
                                right: 0,
                                child: Text(
                                  cash,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelectedCash == true
                                        ? whiteColor
                                        : drawerTextColor,
                                    fontSize: 16,
                                    fontFamily: 'Syne-Bold',
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 90,
                                left: 0,
                                right: 0,
                                child: Text(
                                  select,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelectedCash == true
                                        ? whiteColor
                                        : supportTextColor,
                                    fontSize: 14,
                                    fontFamily: 'Syne-Regular',
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: SvgPicture.asset(imageCash),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  GestureDetector(
                    onTap: () async {
                      if (!isApiCalled) {
                        setState(() {
                          isApiCalled = true;
                        });

                        await getPaymentGateways();
                        debugPrint("cashId: $cashId");
                        debugPrint("isApiCalled: $isApiCalled");

                        if (getPaymentGatewaysModel.status == "success") {
                          Map? updatedData = Map.from(widget.singleData!);
                          Map? updatedData2 = Map.from(widget.multipleData!);
                          if (widget.multipleData!["delivery_type"] ==
                              "Multiple") {
                            if (updatedData2.isNotEmpty) {
                              updatedData2.addAll({
                                "payment_gateways_id": cashId,
                              });
                            } else {
                              updatedData2 = {};
                            }
                          } else {
                            if (updatedData.isNotEmpty) {
                              updatedData.addAll({
                                "payment_gateways_id": cashId,
                              });
                            } else {
                              updatedData = {};
                            }
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchRidersScreen(
                                singleData: updatedData,
                                multipleData: updatedData2,
                              ),
                            ),
                          ).then((value) {
                            setState(() {
                              isApiCalled = false;
                            });
                          });
                        }
                      }
                    },
                    child: bottomSheetButtonGradientBig("NEXT", context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
