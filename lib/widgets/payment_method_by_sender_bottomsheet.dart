// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/screens/search_riders_screen.dart';
import 'package:deliver_client/models/get_payment_getaways_model.dart';

bool isSelectedCard = false;

class PaymentMethodBySenderSheet extends StatefulWidget {
  final Map? singleData;
  final Map? multipleData;

  const PaymentMethodBySenderSheet(
      {super.key, this.singleData, this.multipleData});

  @override
  State<PaymentMethodBySenderSheet> createState() =>
      _PaymentMethodBySenderSheetState();
}

class _PaymentMethodBySenderSheetState
    extends State<PaymentMethodBySenderSheet> {
  String? cardId;
  bool isApiCalled = false;
  String? baseUrl = dotenv.env['BASE_URL'];

  GetPaymentGatewaysModel getPaymentGatewaysModel = GetPaymentGatewaysModel();

  getPaymentGateways() async {
    try {
      String apiUrl = "$baseUrl/get_payment_gateways";
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
        getPaymentGatewaysModel =
            getPaymentGatewaysModelFromJson(responseString);
        print(
            'getPaymentGatewaysModel status: ${getPaymentGatewaysModel.status}');
        print(
            'getPaymentGatewaysModel length: ${getPaymentGatewaysModel.data!.length}');
        for (int i = 0; i < getPaymentGatewaysModel.data!.length; i++) {
          if (getPaymentGatewaysModel.data?[i].name == "Card") {
            cardId = "${getPaymentGatewaysModel.data?[i].paymentGatewaysId}";
          }
          setState(() {});
        }
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    isSelectedCard = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      paymentMethodBySenderSheet(
        context,
        card: "Card",
        imageCard: "assets/images/pay-card-icon.svg",
        select: "Select",
      );
    });
    print("mapData Single: ${widget.singleData}");
    print("mapData Multiple: ${widget.multipleData}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
    );
  }

  Future<dynamic> paymentMethodBySenderSheet(
    BuildContext context, {
    card,
    imageCard,
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
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isSelectedCard = true;
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
                                    color: isSelectedCard == true
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
                                  card,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelectedCard == true
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
                                    color: isSelectedCard == true
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
                                child: SvgPicture.asset(imageCard),
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
                        print("cardId: $cardId");
                        print("isApiCalled: $isApiCalled");

                        if (getPaymentGatewaysModel.status == "success") {
                          Map? updatedData = Map.from(widget.singleData!);
                          Map? updatedData2 = Map.from(widget.multipleData!);
                          if (widget.multipleData!["delivery_type"] ==
                              "Multiple") {
                            if (updatedData2.isNotEmpty) {
                              updatedData2.addAll({
                                "payment_gateways_id": cardId,
                              });
                            } else {
                              updatedData2 = {};
                            }
                          } else {
                            if (updatedData.isNotEmpty) {
                              updatedData.addAll({
                                "payment_gateways_id": cardId,
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

// // ignore_for_file: avoid_print
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/screens/search_riders_screen.dart';
// import 'package:deliver_client/models/get_payment_getaways_model.dart';
//
// bool isSelectedCard = false;
// bool isSelectedCash = false;
//
// class PaymentMethodBySenderSheet extends StatefulWidget {
//   final Map? singleData;
//
//   const PaymentMethodBySenderSheet({super.key, this.singleData});
//
//   @override
//   State<PaymentMethodBySenderSheet> createState() =>
//       _PaymentMethodBySenderSheetState();
// }
//
// class _PaymentMethodBySenderSheetState
//     extends State<PaymentMethodBySenderSheet> {
//   String? cardId;
//   String? cashId;
//   String? baseUrl = dotenv.env['BASE_URL'];
//
//   GetPaymentGatewaysModel getPaymentGatewaysModel = GetPaymentGatewaysModel();
//
//   getPaymentGateways() async {
//     try {
//       String apiUrl = "$baseUrl/get_payment_gateways";
//       print("apiUrl: $apiUrl");
//       cashId = "";
//       final response = await http.get(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//       );
//       final responseString = response.body;
//       print("response: $responseString");
//       print("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         getPaymentGatewaysModel =
//             getPaymentGatewaysModelFromJson(responseString);
//         print(
//             'getPaymentGatewaysModel status: ${getPaymentGatewaysModel.status}');
//         print(
//             'getPaymentGatewaysModel length: ${getPaymentGatewaysModel.data!.length}');
//         for (int i = 0; i < getPaymentGatewaysModel.data!.length; i++) {
//           if (getPaymentGatewaysModel.data?[i].name == "Cash") {
//             cashId = "${getPaymentGatewaysModel.data?[i].paymentGatewaysId}";
//           } else if (getPaymentGatewaysModel.data?[i].name == "Card") {
//             cardId = "${getPaymentGatewaysModel.data?[i].paymentGatewaysId}";
//           }
//           setState(() {});
//         }
//       }
//     } catch (e) {
//       print('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     isSelectedCard = false;
//     isSelectedCash = false;
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       paymentMethodBySenderSheet(
//         context,
//         card: "Card",
//         imageCard: "assets/images/pay-card-icon.svg",
//         cash: "Cash",
//         imageCash: "assets/images/pay-cash-icon.svg",
//         select: "Select",
//       );
//     });
//     print(widget.singleData);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgColor,
//     );
//   }
//
//   Future<dynamic> paymentMethodBySenderSheet(
//     BuildContext context, {
//     card,
//     imageCard,
//     cash,
//     imageCash,
//     select,
//   }) {
//     var size = MediaQuery.of(context).size;
//     return showModalBottomSheet(
//       elevation: 0,
//       context: context,
//       enableDrag: false,
//       backgroundColor: whiteColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) => WillPopScope(
//             onWillPop: () async {
//               Navigator.pop(context);
//               Navigator.pop(context);
//               return false;
//             },
//             child: SizedBox(
//               width: size.width,
//               height: size.height * 0.45,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(height: size.height * 0.06),
//                   Text(
//                     'Select Payment Method',
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       color: blackColor,
//                       fontSize: 22,
//                       fontFamily: 'Syne-Bold',
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.04),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         GestureDetector(
//                           onTap: () async {
//                             await getPaymentGateways();
//                             setState(() {
//                               isSelectedCard = true;
//                               isSelectedCash = false;
//                               print("cardId: $cardId");
//                             });
//                           },
//                           child: Stack(
//                             children: [
//                               Container(
//                                 color: transparentColor,
//                                 width: MediaQuery.of(context).size.width * 0.42,
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.15,
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 child: Container(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.42,
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.12,
//                                   decoration: BoxDecoration(
//                                     color: isSelectedCard == true
//                                         ? orangeColor
//                                         : const Color(0xFFEBEBEB),
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 35,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   card,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSelectedCard == true
//                                         ? whiteColor
//                                         : drawerTextColor,
//                                     fontSize: 16,
//                                     fontFamily: 'Syne-Bold',
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 15,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   select,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSelectedCard == true
//                                         ? whiteColor
//                                         : supportTextColor,
//                                     fontSize: 14,
//                                     fontFamily: 'Syne-Regular',
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 left: 0,
//                                 right: 0,
//                                 child: SvgPicture.asset(imageCard),
//                               ),
//                             ],
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () async {
//                             await getPaymentGateways();
//                             setState(() {
//                               isSelectedCard = false;
//                               isSelectedCash = true;
//                               print("cashId: $cashId");
//                             });
//                           },
//                           child: Stack(
//                             children: [
//                               Container(
//                                 color: transparentColor,
//                                 width: MediaQuery.of(context).size.width * 0.42,
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.15,
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 child: Container(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.42,
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.12,
//                                   decoration: BoxDecoration(
//                                     color: isSelectedCash == true
//                                         ? orangeColor
//                                         : const Color(0xFFEBEBEB),
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 68,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   cash,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSelectedCash == true
//                                         ? whiteColor
//                                         : drawerTextColor,
//                                     fontSize: 16,
//                                     fontFamily: 'Syne-Bold',
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 90,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   select,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSelectedCash == true
//                                         ? whiteColor
//                                         : supportTextColor,
//                                     fontSize: 14,
//                                     fontFamily: 'Syne-Regular',
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 left: 0,
//                                 right: 0,
//                                 child: SvgPicture.asset(imageCash),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.04),
//                   GestureDetector(
//                     onTap: () {
//                       if (isSelectedCard == true) {
//                         Map? updatedData = Map.from(widget.singleData!);
//                         updatedData.addAll({
//                           "payment_gateways_id": cardId,
//                         });
//                         Future.delayed(const Duration(seconds: 2), () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SearchRidersScreen(
//                                 singleData: updatedData,
//                               ),
//                             ),
//                           );
//                         });
//                         // Navigator.push(
//                         //   context,
//                         //   MaterialPageRoute(
//                         //     builder: (context) => PayViaCardScreen(
//                         //       singleData: updatedData,
//                         //     ),
//                         //   ),
//                         // );
//                       }
//                       if (isSelectedCash == true) {
//                         Map? updatedData = Map.from(widget.singleData!);
//                         updatedData.addAll({
//                           "payment_gateways_id": cashId,
//                         });
//                         Future.delayed(const Duration(seconds: 2), () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => SearchRidersScreen(
//                                 singleData: updatedData,
//                               ),
//                             ),
//                           );
//                         });
//                       }
//                     },
//                     child: bottomSheetButtonGradientBig("NEXT", context),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// bool isSelectedBank = false;
// bool isSelectedCard = false;
// bool isSelectedWallet = false;

// class PaymentMethodBySenderSheet extends StatefulWidget {
//   final Map? singleData;
//   const PaymentMethodBySenderSheet({super.key, this.singleData});

//   @override
//   State<PaymentMethodBySenderSheet> createState() =>
//       _PaymentMethodBySenderSheetState();
// }

// class _PaymentMethodBySenderSheetState
//     extends State<PaymentMethodBySenderSheet> {
//   String? bankId;
//   String? cardId;
//   String? walletId;
//   GetPaymentGatewaysModel getPaymentGatewaysModel = GetPaymentGatewaysModel();

//   getPaymentGateways() async {
//     try {
//       String apiUrl = "$baseUrl/get_payment_gateways";
//       print("apiUrl: $apiUrl");
//       bankId = "";
//       final response = await http.get(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//       );
//       final responseString = response.body;
//       print("response: $responseString");
//       print("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         getPaymentGatewaysModel =
//             getPaymentGatewaysModelFromJson(responseString);
//         print(
//             'getPaymentGatewaysModel status: ${getPaymentGatewaysModel.status}');
//         print(
//             'getPaymentGatewaysModel length: ${getPaymentGatewaysModel.data!.length}');
//         for (int i = 0; i < getPaymentGatewaysModel.data!.length; i++) {
//           if (getPaymentGatewaysModel.data?[i].name == "Bank") {
//             bankId = "${getPaymentGatewaysModel.data?[i].paymentGatewaysId}";
//             print("bankId: $bankId");
//           } else if (getPaymentGatewaysModel.data?[i].name == "Flutterwave") {
//             cardId = "${getPaymentGatewaysModel.data?[i].paymentGatewaysId}";
//             print("cardId: $cardId");
//           } else if (getPaymentGatewaysModel.data?[i].name == "Wallet") {
//             walletId = "${getPaymentGatewaysModel.data?[i].paymentGatewaysId}";
//             print("walletId: $walletId");
//           }
//           setState(() {});
//         }
//       }
//     } catch (e) {
//       print('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     getPaymentGateways();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       paymentMethodBySenderSheet(
//         context,
//         bank: "Bank",
//         imageBank: "assets/images/pay-bank-icon.svg",
//         card: "Card",
//         imageCard: "assets/images/pay-card-icon.svg",
//         wallet: "Wallet",
//         imageWallet: "assets/images/pay-wallet-icon.svg",
//         select: "Select",
//       );
//       print("mapData: ${widget.singleData}");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgColor,
//     );
//   }

//   Future<dynamic> paymentMethodBySenderSheet(
//     BuildContext context, {
//     bank,
//     imageBank,
//     card,
//     imageCard,
//     wallet,
//     imageWallet,
//     select,
//   }) {
//     var size = MediaQuery.of(context).size;
//     return showModalBottomSheet(
//       elevation: 0,
//       context: context,
//       enableDrag: false,
//       backgroundColor: whiteColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setState) => WillPopScope(
//             onWillPop: () async {
//               Navigator.pop(context);
//               Navigator.pop(context);
//               return false;
//             },
//             child: SizedBox(
//               width: size.width,
//               height: size.height * 0.45,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(height: size.height * 0.06),
//                   Text(
//                     'Select Payment Method',
//                     textAlign: TextAlign.left,
//                     style: TextStyle(
//                       color: blackColor,
//                       fontSize: 22,
//                       fontFamily: 'Syne-Bold',
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.06),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         GestureDetector(
//                           onTap: () async {
//                             getPaymentGateways();
//                             setState(() {
//                               isSelectedBank = true;
//                               isSelectedCard = false;
//                               isSelectedWallet = false;
//                             });
//                           },
//                           child: Stack(
//                             children: [
//                               Container(
//                                 color: transparentColor,
//                                 width: MediaQuery.of(context).size.width * 0.28,
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.15,
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 child: Container(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.28,
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.12,
//                                   decoration: BoxDecoration(
//                                     color: isSelectedBank == true
//                                         ? orangeColor
//                                         : const Color(0xFFEBEBEB),
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 35,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   bank,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSelectedBank == true
//                                         ? whiteColor
//                                         : drawerTextColor,
//                                     fontSize: 16,
//                                     fontFamily: 'Syne-Bold',
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 15,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   select,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSelectedBank == true
//                                         ? whiteColor
//                                         : supportTextColor,
//                                     fontSize: 14,
//                                     fontFamily: 'Syne-Regular',
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 left: 0,
//                                 right: 0,
//                                 child: SvgPicture.asset(imageBank),
//                               ),
//                             ],
//                           ),
//                         ),
//                         // SizedBox(width: size.width * 0.03),
//                         GestureDetector(
//                           onTap: () async {
//                             getPaymentGateways();
//                             setState(() {
//                               isSelectedBank = false;
//                               isSelectedCard = true;
//                               isSelectedWallet = false;
//                             });
//                           },
//                           child: Stack(
//                             children: [
//                               Container(
//                                 color: transparentColor,
//                                 width: MediaQuery.of(context).size.width * 0.28,
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.15,
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 child: Container(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.28,
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.12,
//                                   decoration: BoxDecoration(
//                                     color: isSelectedCard == true
//                                         ? orangeColor
//                                         : const Color(0xFFEBEBEB),
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 35,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   card,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSelectedCard == true
//                                         ? whiteColor
//                                         : drawerTextColor,
//                                     fontSize: 16,
//                                     fontFamily: 'Syne-Bold',
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 15,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   select,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSelectedCard == true
//                                         ? whiteColor
//                                         : supportTextColor,
//                                     fontSize: 14,
//                                     fontFamily: 'Syne-Regular',
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 left: 0,
//                                 right: 0,
//                                 child: SvgPicture.asset(imageCard),
//                               ),
//                             ],
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () async {
//                             getPaymentGateways();
//                             setState(() {
//                               isSelectedBank = false;
//                               isSelectedCard = false;
//                               isSelectedWallet = true;
//                             });
//                           },
//                           child: Stack(
//                             children: [
//                               Container(
//                                 color: transparentColor,
//                                 width: MediaQuery.of(context).size.width * 0.28,
//                                 height:
//                                     MediaQuery.of(context).size.height * 0.15,
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 child: Container(
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.28,
//                                   height:
//                                       MediaQuery.of(context).size.height * 0.12,
//                                   decoration: BoxDecoration(
//                                     color: isSelectedWallet == true
//                                         ? orangeColor
//                                         : const Color(0xFFEBEBEB),
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 35,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   wallet,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSelectedWallet == true
//                                         ? whiteColor
//                                         : drawerTextColor,
//                                     fontSize: 14,
//                                     fontFamily: 'Syne-Bold',
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 15,
//                                 left: 0,
//                                 right: 0,
//                                 child: Text(
//                                   select,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     color: isSelectedWallet == true
//                                         ? whiteColor
//                                         : supportTextColor,
//                                     fontSize: 14,
//                                     fontFamily: 'Syne-Regular',
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 left: 0,
//                                 right: 0,
//                                 child: SvgPicture.asset(imageWallet),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.04),
//                   GestureDetector(
//                     onTap: () {
//                       if (isSelectedBank == true) {
//                         Map? updatedData = Map.from(widget.singleData!);
//                         updatedData.addAll({
//                           "payment_gateways_id": bankId,
//                         });
//                         setState(() {});
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => PayViaBankScreen(
//                               singleData: updatedData,
//                             ),
//                           ),
//                         );
//                       }
//                       if (isSelectedCard == true) {
//                         Map? updatedData = Map.from(widget.singleData!);
//                         updatedData.addAll({
//                           "payment_gateways_id": cardId,
//                         });
//                         setState(() {});
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => PayViaCardScreen(
//                               singleData: updatedData,
//                             ),
//                           ),
//                         );
//                       }
//                       if (isSelectedWallet == true) {
//                         Map? updatedData = Map.from(widget.singleData!);
//                         updatedData.addAll({
//                           "payment_gateways_id": walletId,
//                         });
//                         setState(() {});
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => PayViaWalletScreen(
//                               singleData: updatedData,
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                     child: bottomSheetButtonGradientBig("NEXT", context),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
