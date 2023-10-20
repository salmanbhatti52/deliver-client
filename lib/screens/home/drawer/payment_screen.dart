import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController nameOnCardController = TextEditingController();
  TextEditingController mmYYController = TextEditingController();
  TextEditingController cvvController = TextEditingController();
  final GlobalKey<FormState> paymentFormKey = GlobalKey<FormState>();
  bool statusCash = false;
  bool statusCard = true;
  bool statusWallet = false;
  bool statusBank = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePageScreen()),
            (Route<dynamic> route) => false);
        return false;
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: SvgPicture.asset(
                  'assets/images/back-icon.svg',
                  width: 22,
                  height: 22,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            title: Text(
              "Select Payment Method",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackColor,
                fontSize: 18,
                fontFamily: 'Syne-Bold',
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          "Use Cash",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: drawerTextColor,
                            fontSize: 18,
                            fontFamily: 'Syne-Regular',
                          ),
                        ),
                        const Spacer(),
                        FlutterSwitch(
                          width: 35,
                          height: 20,
                          activeColor: blackColor,
                          inactiveColor: whiteColor,
                          activeToggleBorder:
                              Border.all(color: blackColor, width: 2),
                          inactiveToggleBorder:
                              Border.all(color: blackColor, width: 2),
                          inactiveSwitchBorder:
                              Border.all(color: blackColor, width: 2),
                          toggleSize: 12,
                          value: statusCash,
                          borderRadius: 50,
                          onToggle: (val) {
                            setState(() {
                              statusCash = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          "Use card for payment",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: drawerTextColor,
                            fontSize: 18,
                            fontFamily: 'Syne-Regular',
                          ),
                        ),
                        const Spacer(),
                        FlutterSwitch(
                          width: 35,
                          height: 20,
                          activeColor: blackColor,
                          inactiveColor: whiteColor,
                          activeToggleBorder:
                              Border.all(color: blackColor, width: 2),
                          inactiveToggleBorder:
                              Border.all(color: blackColor, width: 2),
                          inactiveSwitchBorder:
                              Border.all(color: blackColor, width: 2),
                          toggleSize: 12,
                          value: statusCard,
                          borderRadius: 50,
                          onToggle: (val) {
                            setState(() {
                              statusCard = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Card(
                    color: whiteColor,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: size.height * 0.02),
                              Text(
                                "Name on Card",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 18,
                                  fontFamily: 'Syne-Bold',
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),
                              Text(
                                "2348-XXXX-XXXX-XXX3",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: textHaveAccountColor,
                                  fontSize: 16,
                                  fontFamily: 'Inter-Regular',
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                            ],
                          ),
                          SvgPicture.asset('assets/images/delete-icon.svg'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    "Add a new card",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 18,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/images/lock-icon.svg'),
                        SizedBox(width: size.width * 0.02),
                        Text(
                          "Secure Payments",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: orangeColor,
                            fontSize: 12,
                            fontFamily: 'Inter-Regular',
                          ),
                        ),
                        const Spacer(),
                        SvgPicture.asset('assets/images/mastercard-icon.svg'),
                        SizedBox(width: size.width * 0.01),
                        SvgPicture.asset('assets/images/visa-card-icon.svg'),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: nameOnCardController,
                      cursorColor: orangeColor,
                      keyboardType: TextInputType.text,
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Name on Card field is required!';
                      //   }
                      //   return null;
                      // },
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 14,
                        fontFamily: 'Inter-Regular',
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: filledColor,
                        errorStyle: TextStyle(
                          color: redColor,
                          fontSize: 12,
                          fontFamily: 'Inter-Bold',
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(
                            color: redColor,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        hintText: "Name on Card",
                        hintStyle: TextStyle(
                          color: hintColor,
                          fontSize: 12,
                          fontFamily: 'Inter-Light',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: cardNumberController,
                      cursorColor: orangeColor,
                      keyboardType: TextInputType.text,
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Card Number field is required!';
                      //   }
                      //   return null;
                      // },
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 14,
                        fontFamily: 'Inter-Regular',
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: filledColor,
                        errorStyle: TextStyle(
                          color: redColor,
                          fontSize: 12,
                          fontFamily: 'Inter-Bold',
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          borderSide: BorderSide(
                            color: redColor,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        hintText: "Card Number",
                        hintStyle: TextStyle(
                          color: hintColor,
                          fontSize: 12,
                          fontFamily: 'Inter-Light',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          color: transparentColor,
                          width: size.width * 0.38,
                          child: TextFormField(
                            controller: mmYYController,
                            cursorColor: orangeColor,
                            keyboardType: TextInputType.text,
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'MM/YY field is required!';
                            //   }
                            //   return null;
                            // },
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 14,
                              fontFamily: 'Inter-Regular',
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: filledColor,
                              errorStyle: TextStyle(
                                color: redColor,
                                fontSize: 12,
                                fontFamily: 'Inter-Bold',
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: redColor,
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              hintText: "MM/YY",
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 12,
                                fontFamily: 'Inter-Light',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          color: transparentColor,
                          width: size.width * 0.38,
                          child: TextFormField(
                            controller: cvvController,
                            cursorColor: orangeColor,
                            keyboardType: TextInputType.text,
                            // validator: (value) {
                            //   if (value == null || value.isEmpty) {
                            //     return 'CVV field is required!';
                            //   }
                            //   return null;
                            // },
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 14,
                              fontFamily: 'Inter-Regular',
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: filledColor,
                              errorStyle: TextStyle(
                                color: redColor,
                                fontSize: 12,
                                fontFamily: 'Inter-Bold',
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: redColor,
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              hintText: "CVV",
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 12,
                                fontFamily: 'Inter-Light',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.17),
                  buttonGradient('SAVE', context),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:flutter_switch/flutter_switch.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/screens/home/home_page_screen.dart';

// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen({super.key});

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   TextEditingController cardNumberController = TextEditingController();
//   TextEditingController nameOnCardController = TextEditingController();
//   TextEditingController mmYYController = TextEditingController();
//   TextEditingController cvvController = TextEditingController();
//   final GlobalKey<FormState> paymentFormKey = GlobalKey<FormState>();
//   bool statusCash = false;
//   bool statusCard = true;
//   bool statusWallet = false;
//   bool statusBank = false;

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return WillPopScope(
//       onWillPop: () async {
//         Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(builder: (context) => const HomePageScreen()),
//             (Route<dynamic> route) => false);
//         return false;
//       },
//       child: GestureDetector(
//         onTap: () {
//           FocusManager.instance.primaryFocus?.unfocus();
//         },
//         child: Scaffold(
//           backgroundColor: bgColor,
//           appBar: AppBar(
//             backgroundColor: bgColor,
//             elevation: 0,
//             scrolledUnderElevation: 0,
//             leading: GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 20),
//                 child: SvgPicture.asset(
//                   'assets/images/back-icon.svg',
//                   width: 22,
//                   height: 22,
//                   fit: BoxFit.scaleDown,
//                 ),
//               ),
//             ),
//             title: Text(
//               "Select Payment Method",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: blackColor,
//                 fontSize: 18,
//                 fontFamily: 'Syne-Bold',
//               ),
//             ),
//             centerTitle: true,
//           ),
//           body: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   SizedBox(height: size.height * 0.03),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: [
//                         Text(
//                           "Use Cash",
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                             color: drawerTextColor,
//                             fontSize: 18,
//                             fontFamily: 'Syne-Regular',
//                           ),
//                         ),
//                         const Spacer(),
//                         FlutterSwitch(
//                           width: 35,
//                           height: 20,
//                           activeColor: blackColor,
//                           inactiveColor: whiteColor,
//                           activeToggleBorder:
//                               Border.all(color: blackColor, width: 2),
//                           inactiveToggleBorder:
//                               Border.all(color: blackColor, width: 2),
//                           inactiveSwitchBorder:
//                               Border.all(color: blackColor, width: 2),
//                           toggleSize: 12,
//                           value: statusCash,
//                           borderRadius: 50,
//                           onToggle: (val) {
//                             setState(() {
//                               statusCash = val;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.03),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: [
//                         Text(
//                           "Use card for payment",
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                             color: drawerTextColor,
//                             fontSize: 18,
//                             fontFamily: 'Syne-Regular',
//                           ),
//                         ),
//                         const Spacer(),
//                         FlutterSwitch(
//                           width: 35,
//                           height: 20,
//                           activeColor: blackColor,
//                           inactiveColor: whiteColor,
//                           activeToggleBorder:
//                               Border.all(color: blackColor, width: 2),
//                           inactiveToggleBorder:
//                               Border.all(color: blackColor, width: 2),
//                           inactiveSwitchBorder:
//                               Border.all(color: blackColor, width: 2),
//                           toggleSize: 12,
//                           value: statusCard,
//                           borderRadius: 50,
//                           onToggle: (val) {
//                             setState(() {
//                               statusCard = val;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.03),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: [
//                         Text(
//                           "Wallet Payment",
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                             color: drawerTextColor,
//                             fontSize: 18,
//                             fontFamily: 'Syne-Regular',
//                           ),
//                         ),
//                         const Spacer(),
//                         FlutterSwitch(
//                           width: 35,
//                           height: 20,
//                           activeColor: blackColor,
//                           inactiveColor: whiteColor,
//                           activeToggleBorder:
//                               Border.all(color: blackColor, width: 2),
//                           inactiveToggleBorder:
//                               Border.all(color: blackColor, width: 2),
//                           inactiveSwitchBorder:
//                               Border.all(color: blackColor, width: 2),
//                           toggleSize: 12,
//                           value: statusWallet,
//                           borderRadius: 50,
//                           onToggle: (val) {
//                             setState(() {
//                               statusWallet = val;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.03),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: [
//                         Text(
//                           "Bank",
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                             color: drawerTextColor,
//                             fontSize: 18,
//                             fontFamily: 'Syne-Regular',
//                           ),
//                         ),
//                         const Spacer(),
//                         FlutterSwitch(
//                           width: 35,
//                           height: 20,
//                           activeColor: blackColor,
//                           inactiveColor: whiteColor,
//                           activeToggleBorder:
//                               Border.all(color: blackColor, width: 2),
//                           inactiveToggleBorder:
//                               Border.all(color: blackColor, width: 2),
//                           inactiveSwitchBorder:
//                               Border.all(color: blackColor, width: 2),
//                           toggleSize: 12,
//                           value: statusBank,
//                           borderRadius: 50,
//                           onToggle: (val) {
//                             setState(() {
//                               statusBank = val;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.03),
//                   Card(
//                     color: whiteColor,
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: size.height * 0.02),
//                               Text(
//                                 "Name on Card",
//                                 textAlign: TextAlign.left,
//                                 style: TextStyle(
//                                   color: blackColor,
//                                   fontSize: 18,
//                                   fontFamily: 'Syne-Bold',
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.01),
//                               Text(
//                                 "2348-XXXX-XXXX-XXX3",
//                                 textAlign: TextAlign.left,
//                                 style: TextStyle(
//                                   color: textHaveAccountColor,
//                                   fontSize: 16,
//                                   fontFamily: 'Inter-Regular',
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.02),
//                             ],
//                           ),
//                           SvgPicture.asset('assets/images/delete-icon.svg'),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.03),
//                   Text(
//                     "Add a new card",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: blackColor,
//                       fontSize: 18,
//                       fontFamily: 'Syne-Bold',
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.03),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       children: [
//                         SvgPicture.asset('assets/images/lock-icon.svg'),
//                         SizedBox(width: size.width * 0.02),
//                         Text(
//                           "Secure Payments",
//                           textAlign: TextAlign.left,
//                           style: TextStyle(
//                             color: orangeColor,
//                             fontSize: 12,
//                             fontFamily: 'Inter-Regular',
//                           ),
//                         ),
//                         const Spacer(),
//                         SvgPicture.asset('assets/images/mastercard-icon.svg'),
//                         SizedBox(width: size.width * 0.01),
//                         SvgPicture.asset('assets/images/visa-card-icon.svg'),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.02),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: TextFormField(
//                       controller: nameOnCardController,
//                       cursorColor: orangeColor,
//                       keyboardType: TextInputType.text,
//                       // validator: (value) {
//                       //   if (value == null || value.isEmpty) {
//                       //     return 'Name on Card field is required!';
//                       //   }
//                       //   return null;
//                       // },
//                       style: TextStyle(
//                         color: blackColor,
//                         fontSize: 14,
//                         fontFamily: 'Inter-Regular',
//                       ),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: filledColor,
//                         errorStyle: TextStyle(
//                           color: redColor,
//                           fontSize: 12,
//                           fontFamily: 'Inter-Bold',
//                         ),
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         errorBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide(
//                             color: redColor,
//                             width: 1,
//                           ),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 10),
//                         hintText: "Name on Card",
//                         hintStyle: TextStyle(
//                           color: hintColor,
//                           fontSize: 12,
//                           fontFamily: 'Inter-Light',
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.03),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: TextFormField(
//                       controller: cardNumberController,
//                       cursorColor: orangeColor,
//                       keyboardType: TextInputType.text,
//                       // validator: (value) {
//                       //   if (value == null || value.isEmpty) {
//                       //     return 'Card Number field is required!';
//                       //   }
//                       //   return null;
//                       // },
//                       style: TextStyle(
//                         color: blackColor,
//                         fontSize: 14,
//                         fontFamily: 'Inter-Regular',
//                       ),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: filledColor,
//                         errorStyle: TextStyle(
//                           color: redColor,
//                           fontSize: 12,
//                           fontFamily: 'Inter-Bold',
//                         ),
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         enabledBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedErrorBorder: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide.none,
//                         ),
//                         errorBorder: OutlineInputBorder(
//                           borderRadius: const BorderRadius.all(
//                             Radius.circular(10),
//                           ),
//                           borderSide: BorderSide(
//                             color: redColor,
//                             width: 1,
//                           ),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20, vertical: 10),
//                         hintText: "Card Number",
//                         hintStyle: TextStyle(
//                           color: hintColor,
//                           fontSize: 12,
//                           fontFamily: 'Inter-Light',
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.02),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           color: transparentColor,
//                           width: size.width * 0.38,
//                           child: TextFormField(
//                             controller: mmYYController,
//                             cursorColor: orangeColor,
//                             keyboardType: TextInputType.text,
//                             // validator: (value) {
//                             //   if (value == null || value.isEmpty) {
//                             //     return 'MM/YY field is required!';
//                             //   }
//                             //   return null;
//                             // },
//                             style: TextStyle(
//                               color: blackColor,
//                               fontSize: 14,
//                               fontFamily: 'Inter-Regular',
//                             ),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: filledColor,
//                               errorStyle: TextStyle(
//                                 color: redColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Inter-Bold',
//                               ),
//                               border: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               enabledBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               focusedBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               focusedErrorBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               errorBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide(
//                                   color: redColor,
//                                   width: 1,
//                                 ),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 10),
//                               hintText: "MM/YY",
//                               hintStyle: TextStyle(
//                                 color: hintColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Inter-Light',
//                               ),
//                             ),
//                           ),
//                         ),
//                         Container(
//                           color: transparentColor,
//                           width: size.width * 0.38,
//                           child: TextFormField(
//                             controller: cvvController,
//                             cursorColor: orangeColor,
//                             keyboardType: TextInputType.text,
//                             // validator: (value) {
//                             //   if (value == null || value.isEmpty) {
//                             //     return 'CVV field is required!';
//                             //   }
//                             //   return null;
//                             // },
//                             style: TextStyle(
//                               color: blackColor,
//                               fontSize: 14,
//                               fontFamily: 'Inter-Regular',
//                             ),
//                             decoration: InputDecoration(
//                               filled: true,
//                               fillColor: filledColor,
//                               errorStyle: TextStyle(
//                                 color: redColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Inter-Bold',
//                               ),
//                               border: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               enabledBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               focusedBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               focusedErrorBorder: const OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide.none,
//                               ),
//                               errorBorder: OutlineInputBorder(
//                                 borderRadius: const BorderRadius.all(
//                                   Radius.circular(10),
//                                 ),
//                                 borderSide: BorderSide(
//                                   color: redColor,
//                                   width: 1,
//                                 ),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 10),
//                               hintText: "CVV",
//                               hintStyle: TextStyle(
//                                 color: hintColor,
//                                 fontSize: 12,
//                                 fontFamily: 'Inter-Light',
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: size.height * 0.07),
//                   buttonGradient('SAVE', context),
//                   SizedBox(height: size.height * 0.02),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
