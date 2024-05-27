// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/widgets/payment_method_by_sender_bottomsheet.dart';
import 'package:deliver_client/widgets/payment_method_by_receiver_bottomsheet.dart';

bool isSelectedPayNow = false;
bool isSelectedPayLater = false;

class WhoWillPaySheet extends StatefulWidget {
  final Map? singleData;
  final Map? multipleData;
  const WhoWillPaySheet({super.key, this.singleData, this.multipleData});

  @override
  State<WhoWillPaySheet> createState() => _WhoWillPaySheetState();
}

class _WhoWillPaySheetState extends State<WhoWillPaySheet> {
  @override
  void initState() {
    super.initState();
    isSelectedPayNow = false;
    isSelectedPayLater = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      whoWillPaySheet(
        context,
        payNow: "Pay Now",
        imagepayNow: "assets/images/pay-now-icon.svg",
        sender: "Sender",
        payLater: "Pay on Delivery",
        imagepayLater: "assets/images/pay-later-icon.svg",
        receiver: "Receiver",
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

  Future<dynamic> whoWillPaySheet(BuildContext context,
      {payNow, imagepayNow, sender, payLater, imagepayLater, receiver}) {
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
                    'Make Payment',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 22,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelectedPayNow = true;
                            isSelectedPayLater = false;
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                              color: transparentColor,
                              width: MediaQuery.of(context).size.width * 0.42,
                              height: MediaQuery.of(context).size.height * 0.15,
                            ),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.42,
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                decoration: BoxDecoration(
                                  color: isSelectedPayNow == true
                                      ? orangeColor
                                      : const Color(0xFFEBEBEB),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 35,
                              left: 0,
                              right: 0,
                              child: Text(
                                payNow,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelectedPayNow == true
                                      ? whiteColor
                                      : drawerTextColor,
                                  fontSize: 16,
                                  fontFamily: 'Syne-Bold',
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 0,
                              right: 0,
                              child: Text(
                                sender,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelectedPayNow == true
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
                              child: SvgPicture.asset(imagepayNow),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSelectedPayNow = false;
                            isSelectedPayLater = true;
                          });
                        },
                        child: Stack(
                          children: [
                            Container(
                              color: transparentColor,
                              width: MediaQuery.of(context).size.width * 0.42,
                              height: MediaQuery.of(context).size.height * 0.15,
                            ),
                            Positioned(
                              bottom: 0,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.42,
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                                decoration: BoxDecoration(
                                  color: isSelectedPayLater == true
                                      ? orangeColor
                                      : const Color(0xFFEBEBEB),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 35,
                              left: 0,
                              right: 0,
                              child: Text(
                                payLater,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelectedPayLater == true
                                      ? whiteColor
                                      : drawerTextColor,
                                  fontSize: 16,
                                  fontFamily: 'Syne-Bold',
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 15,
                              left: 0,
                              right: 0,
                              child: Text(
                                receiver,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelectedPayLater == true
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
                              child: SvgPicture.asset(imagepayLater),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.04),
                  GestureDetector(
                    onTap: () {
                      if (isSelectedPayNow == true) {
                        Map? updatedData = Map.from(widget.singleData!);
                        Map? updatedData2 = Map.from(widget.multipleData!);
                        if (widget.multipleData!["delivery_type"] ==
                            "Multiple") {
                          if (updatedData2.isNotEmpty) {
                            updatedData2.addAll({
                              "payment_by": "Sender",
                            });
                          } else {
                            updatedData2 = {};
                          }
                        } else {
                          if (updatedData.isNotEmpty) {
                            updatedData.addAll({
                              "payment_by": "Sender",
                            });
                          } else {
                            updatedData = {};
                          }
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentMethodBySenderSheet(
                              singleData: updatedData,
                              multipleData: updatedData2,
                            ),
                          ),
                        );
                        // paymentMethodBySenderSheet(
                        //   bank: "Bank",
                        //   imageBank: "assets/images/pay-bank-icon.svg",
                        //   card: "Card",
                        //   imageCard: "assets/images/pay-card-icon.svg",
                        //   wallet: "Wallet",
                        //   imageWallet: "assets/images/pay-wallet-icon.svg",
                        //   select: "Select",
                        //   context,
                        // );
                      }
                      if (isSelectedPayLater == true) {
                        // paymentMethodByReceiverSheet(
                        //   // bank: "Bank",
                        //   // imageBank: "assets/images/pay-bank-icon.svg",
                        //   cash: "Cash",
                        //   imageCash: "assets/images/pay-cash-icon.svg",
                        //   select: "Select",
                        //   context,
                        // );
                        Map? updatedData = Map.from(widget.singleData!);
                        Map? updatedData2 = Map.from(widget.multipleData!);
                        if (widget.multipleData!["delivery_type"] ==
                            "Multiple") {
                          if (updatedData2.isNotEmpty) {
                            updatedData2.addAll({
                              "payment_by": "Receiver",
                            });
                          } else {
                            updatedData2 = {};
                          }
                        } else {
                          if (updatedData.isNotEmpty) {
                            updatedData.addAll({
                              "payment_by": "Receiver",
                            });
                          } else {
                            updatedData = {};
                          }
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentMethodByReceiverSheet(
                              singleData: updatedData,
                              multipleData: updatedData2,
                            ),
                          ),
                        );
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
