// // ignore_for_file: avoid_print, use_build_context_synchronously
//
// import 'package:lottie/lottie.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_switch/flutter_switch.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:deliver_client/models/add_bank_card_model.dart';
// import 'package:deliver_client/models/get_bank_card_model.dart';
// import 'package:deliver_client/screens/home/home_page_screen.dart';
// import 'package:deliver_client/models/delete_bank_card_model.dart';
// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
//
// String? userId;
//
// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen({super.key});
//
//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   TextEditingController cardNumberController = TextEditingController();
//   TextEditingController nameOnCardController = TextEditingController();
//   TextEditingController mmYYController = TextEditingController();
//   TextEditingController cvvController = TextEditingController();
//   final GlobalKey<FormState> paymentFormKey = GlobalKey<FormState>();
//   bool isLoading = false;
//   bool isLoading2 = false;
//   bool statusCash = false;
//   bool statusCard = true;
//
//   // bool statusWallet = false;
//   // bool statusBank = false;
//   String? baseUrl = dotenv.env['BASE_URL'];
//
//   AddBankCardModel addBankCardModel = AddBankCardModel();
//
//   addBankCard() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//       SharedPreferences sharedPref = await SharedPreferences.getInstance();
//       userId = sharedPref.getString('userId');
//       String apiUrl = "$baseUrl/add_bank_card_customers";
//       debugPrint("apiUrl: $apiUrl");
//       debugPrint("userId: $userId");
//       debugPrint("cardHolderName: ${nameOnCardController.text}");
//       debugPrint("cardNumber: ${cardNumberController.text}");
//       debugPrint("expiryDate: ${mmYYController.text}");
//       debugPrint("cvv: ${cvvController.text}");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "users_customers_id": userId,
//           "card_holder_name": nameOnCardController.text,
//           "card_number": cardNumberController.text,
//           "expiry_date": mmYYController.text,
//           "cvv": cvvController.text,
//         },
//       );
//       final responseString = response.body;
//       debugPrint("response: $responseString");
//       debugPrint("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         addBankCardModel = addBankCardModelFromJson(responseString);
//         debugPrint('addBankCardModel status: ${addBankCardModel.status}');
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }
//
//   GetBankCardModel getBankCardModel = GetBankCardModel();
//
//   getBankCard() async {
//     try {
//       setState(() {
//         isLoading = true;
//       });
//       SharedPreferences sharedPref = await SharedPreferences.getInstance();
//       userId = sharedPref.getString('userId');
//       String apiUrl = "$baseUrl/get_banks_cards_customers";
//       debugPrint("apiUrl: $apiUrl");
//       debugPrint("userId: $userId");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "users_customers_id": userId,
//         },
//       );
//       final responseString = response.body;
//       debugPrint("response: $responseString");
//       debugPrint("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         getBankCardModel = getBankCardModelFromJson(responseString);
//         debugPrint('getBankCardModel status: ${getBankCardModel.status}');
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }
//
//   DeleteBankCardModel deleteBankCardModel = DeleteBankCardModel();
//
//   deleteBankCard(int? bankCardId) async {
//     try {
//       String apiUrl = "$baseUrl/delete_bank_card_customers";
//       debugPrint("apiUrl: $apiUrl");
//       debugPrint("bankCardId: $bankCardId");
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {
//           'Accept': 'application/json',
//         },
//         body: {
//           "banks_cards_id": bankCardId.toString(),
//         },
//       );
//       final responseString = response.body;
//       debugPrint("response: $responseString");
//       debugPrint("statusCode: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         deleteBankCardModel = deleteBankCardModelFromJson(responseString);
//         debugPrint('deleteBankCardModel status: ${deleteBankCardModel.status}');
//         setState(() {
//           getBankCard();
//         });
//       }
//     } catch (e) {
//       debugPrint('Something went wrong = ${e.toString()}');
//       return null;
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     getBankCard();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     var cardNumberFormatter = MaskTextInputFormatter(
//         mask: '#### #### #### ####',
//         filter: {"#": RegExp(r'[0-9]')},
//         type: MaskAutoCompletionType.lazy);
//     var expiryFormatter = MaskTextInputFormatter(
//         mask: '##/##',
//         filter: {"#": RegExp(r'[0-9]')},
//         type: MaskAutoCompletionType.lazy);
//     var cvvFormatter = MaskTextInputFormatter(
//         mask: '###',
//         filter: {"#": RegExp(r'[0-9]')},
//         type: MaskAutoCompletionType.lazy);
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
//               child: Form(
//                 key: paymentFormKey,
//                 child: Column(
//                   children: [
//                     SizedBox(height: size.height * 0.03),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         children: [
//                           Text(
//                             "Use Cash",
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               color: drawerTextColor,
//                               fontSize: 18,
//                               fontFamily: 'Syne-Regular',
//                             ),
//                           ),
//                           const Spacer(),
//                           FlutterSwitch(
//                             width: 35,
//                             height: 20,
//                             activeColor: blackColor,
//                             inactiveColor: whiteColor,
//                             activeToggleBorder:
//                                 Border.all(color: blackColor, width: 2),
//                             inactiveToggleBorder:
//                                 Border.all(color: blackColor, width: 2),
//                             inactiveSwitchBorder:
//                                 Border.all(color: blackColor, width: 2),
//                             toggleSize: 12,
//                             value: statusCash,
//                             borderRadius: 50,
//                             onToggle: (val) {
//                               setState(() {
//                                 statusCash = val;
//                                 if (statusCash) {
//                                   statusCard = false;
//                                 }
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.03),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 20),
//                       child: Row(
//                         children: [
//                           Text(
//                             "Use card for payment",
//                             textAlign: TextAlign.left,
//                             style: TextStyle(
//                               color: drawerTextColor,
//                               fontSize: 18,
//                               fontFamily: 'Syne-Regular',
//                             ),
//                           ),
//                           const Spacer(),
//                           FlutterSwitch(
//                             width: 35,
//                             height: 20,
//                             activeColor: blackColor,
//                             inactiveColor: whiteColor,
//                             activeToggleBorder:
//                                 Border.all(color: blackColor, width: 2),
//                             inactiveToggleBorder:
//                                 Border.all(color: blackColor, width: 2),
//                             inactiveSwitchBorder:
//                                 Border.all(color: blackColor, width: 2),
//                             toggleSize: 12,
//                             value: statusCard,
//                             borderRadius: 50,
//                             onToggle: (val) {
//                               setState(() {
//                                 statusCard = val;
//                                 if (statusCard) {
//                                   statusCash = false;
//                                 }
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: size.height * 0.03),
//                     statusCard == true
//                         ? Column(
//                             children: [
//                               isLoading
//                                   ? Center(
//                                       child: Container(
//                                         width: 60,
//                                         height: 60,
//                                         color: transparentColor,
//                                         child: Lottie.asset(
//                                           'assets/images/loading-icon.json',
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                     )
//                                   : getBankCardModel.data != null
//                                       ? ListView.builder(
//                                           physics:
//                                               const NeverScrollableScrollPhysics(),
//                                           shrinkWrap: true,
//                                           scrollDirection: Axis.vertical,
//                                           itemCount:
//                                               getBankCardModel.data!.length,
//                                           itemBuilder: (BuildContext context,
//                                               int index) {
//                                             String originalText = "${getBankCardModel.data![index].cardNumber}";
//                                             List<String> segments = originalText.split(' ');
//                                             String formattedText = '${segments.first} ${segments.sublist(1, segments.length - 1).map((segment) {
//                                                   return 'XXXX';
//                                                 }).join(' ')} ${segments.last}';
//                                             debugPrint(formattedText);
//                                             return Card(
//                                               color: whiteColor,
//                                               elevation: 5,
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                               ),
//                                               child: Padding(
//                                                 padding:
//                                                     const EdgeInsets.symmetric(
//                                                         horizontal: 20),
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         SizedBox(
//                                                             height:
//                                                                 size.height *
//                                                                     0.02),
//                                                         Text(
//                                                           "${getBankCardModel.data![index].cardHolderName}",
//                                                           textAlign:
//                                                               TextAlign.left,
//                                                           style: TextStyle(
//                                                             color: blackColor,
//                                                             fontSize: 18,
//                                                             fontFamily:
//                                                                 'Syne-Bold',
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                             height:
//                                                                 size.height *
//                                                                     0.01),
//                                                         Text(
//                                                           formattedText,
//                                                           textAlign:
//                                                               TextAlign.left,
//                                                           style: TextStyle(
//                                                             color:
//                                                                 textHaveAccountColor,
//                                                             fontSize: 16,
//                                                             fontFamily:
//                                                                 'Inter-Regular',
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                             height:
//                                                                 size.height *
//                                                                     0.02),
//                                                       ],
//                                                     ),
//                                                     GestureDetector(
//                                                       onTap: () {
//                                                         showDialog(
//                                                             context: context,
//                                                             barrierDismissible:
//                                                                 false,
//                                                             builder: (context) =>
//                                                                 deleteConformation(
//                                                                     getBankCardModel
//                                                                         .data![
//                                                                             index]
//                                                                         .banksCardsId));
//                                                       },
//                                                       child: SvgPicture.asset(
//                                                         'assets/images/delete-icon.svg',
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         )
//                                       : Card(
//                                           color: whiteColor,
//                                           elevation: 5,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                           ),
//                                           child: Padding(
//                                             padding: const EdgeInsets.symmetric(
//                                                 horizontal: 55, vertical: 30),
//                                             child: Text(
//                                               "No Card Added Yet!",
//                                               textAlign: TextAlign.left,
//                                               style: TextStyle(
//                                                 color: blackColor,
//                                                 fontSize: 18,
//                                                 fontFamily: 'Syne-Bold',
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                               SizedBox(height: size.height * 0.03),
//                               Text(
//                                 "Add a new card",
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: blackColor,
//                                   fontSize: 18,
//                                   fontFamily: 'Syne-Bold',
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.03),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 20),
//                                 child: Row(
//                                   children: [
//                                     SvgPicture.asset(
//                                       'assets/images/lock-icon.svg',
//                                     ),
//                                     SizedBox(width: size.width * 0.02),
//                                     Text(
//                                       "Secure Payments",
//                                       textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                         color: orangeColor,
//                                         fontSize: 12,
//                                         fontFamily: 'Inter-Regular',
//                                       ),
//                                     ),
//                                     const Spacer(),
//                                     SvgPicture.asset(
//                                       'assets/images/mastercard-icon.svg',
//                                     ),
//                                     SizedBox(width: size.width * 0.01),
//                                     SvgPicture.asset(
//                                       'assets/images/visa-card-icon.svg',
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.02),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 20),
//                                 child: TextFormField(
//                                   controller: nameOnCardController,
//                                   cursorColor: orangeColor,
//                                   keyboardType: TextInputType.text,
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Name on Card is required!';
//                                     }
//                                     return null;
//                                   },
//                                   style: TextStyle(
//                                     color: blackColor,
//                                     fontSize: 14,
//                                     fontFamily: 'Inter-Regular',
//                                   ),
//                                   decoration: InputDecoration(
//                                     filled: true,
//                                     fillColor: filledColor,
//                                     errorStyle: TextStyle(
//                                       color: redColor,
//                                       fontSize: 10,
//                                       fontFamily: 'Inter-Bold',
//                                     ),
//                                     border: const OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(10),
//                                       ),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     enabledBorder: const OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(10),
//                                       ),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     focusedBorder: const OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(10),
//                                       ),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     focusedErrorBorder:
//                                         const OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(10),
//                                       ),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     errorBorder: OutlineInputBorder(
//                                       borderRadius: const BorderRadius.all(
//                                         Radius.circular(10),
//                                       ),
//                                       borderSide: BorderSide(
//                                         color: redColor,
//                                         width: 1,
//                                       ),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 10),
//                                     hintText: "Name on Card",
//                                     hintStyle: TextStyle(
//                                       color: hintColor,
//                                       fontSize: 12,
//                                       fontFamily: 'Inter-Light',
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.03),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 20),
//                                 child: TextFormField(
//                                   controller: cardNumberController,
//                                   cursorColor: orangeColor,
//                                   keyboardType: TextInputType.number,
//                                   inputFormatters: [cardNumberFormatter],
//                                   validator: (value) {
//                                     if (value == null || value.isEmpty) {
//                                       return 'Card Number is required!';
//                                     }
//                                     return null;
//                                   },
//                                   style: TextStyle(
//                                     color: blackColor,
//                                     fontSize: 14,
//                                     fontFamily: 'Inter-Regular',
//                                   ),
//                                   decoration: InputDecoration(
//                                     filled: true,
//                                     fillColor: filledColor,
//                                     errorStyle: TextStyle(
//                                       color: redColor,
//                                       fontSize: 10,
//                                       fontFamily: 'Inter-Bold',
//                                     ),
//                                     border: const OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(10),
//                                       ),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     enabledBorder: const OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(10),
//                                       ),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     focusedBorder: const OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(10),
//                                       ),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     focusedErrorBorder:
//                                         const OutlineInputBorder(
//                                       borderRadius: BorderRadius.all(
//                                         Radius.circular(10),
//                                       ),
//                                       borderSide: BorderSide.none,
//                                     ),
//                                     errorBorder: OutlineInputBorder(
//                                       borderRadius: const BorderRadius.all(
//                                         Radius.circular(10),
//                                       ),
//                                       borderSide: BorderSide(
//                                         color: redColor,
//                                         width: 1,
//                                       ),
//                                     ),
//                                     contentPadding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 10),
//                                     hintText: "Card Number",
//                                     hintStyle: TextStyle(
//                                       color: hintColor,
//                                       fontSize: 12,
//                                       fontFamily: 'Inter-Light',
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.02),
//                               Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 20),
//                                 child: Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Container(
//                                       color: transparentColor,
//                                       width: size.width * 0.38,
//                                       child: TextFormField(
//                                         controller: mmYYController,
//                                         cursorColor: orangeColor,
//                                         inputFormatters: [expiryFormatter],
//                                         keyboardType: TextInputType.number,
//                                         validator: (value) {
//                                           if (value == null || value.isEmpty) {
//                                             return 'MM/YY is required!';
//                                           }
//                                           return null;
//                                         },
//                                         style: TextStyle(
//                                           color: blackColor,
//                                           fontSize: 14,
//                                           fontFamily: 'Inter-Regular',
//                                         ),
//                                         decoration: InputDecoration(
//                                           filled: true,
//                                           fillColor: filledColor,
//                                           errorStyle: TextStyle(
//                                             color: redColor,
//                                             fontSize: 10,
//                                             fontFamily: 'Inter-Bold',
//                                           ),
//                                           border: const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(10),
//                                             ),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           enabledBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(10),
//                                             ),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           focusedBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(10),
//                                             ),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           focusedErrorBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(10),
//                                             ),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           errorBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 const BorderRadius.all(
//                                               Radius.circular(10),
//                                             ),
//                                             borderSide: BorderSide(
//                                               color: redColor,
//                                               width: 1,
//                                             ),
//                                           ),
//                                           contentPadding:
//                                               const EdgeInsets.symmetric(
//                                                   horizontal: 20, vertical: 10),
//                                           hintText: "MM/YY",
//                                           hintStyle: TextStyle(
//                                             color: hintColor,
//                                             fontSize: 12,
//                                             fontFamily: 'Inter-Light',
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     Container(
//                                       color: transparentColor,
//                                       width: size.width * 0.38,
//                                       child: TextFormField(
//                                         controller: cvvController,
//                                         cursorColor: orangeColor,
//                                         inputFormatters: [cvvFormatter],
//                                         keyboardType: TextInputType.number,
//                                         validator: (value) {
//                                           if (value == null || value.isEmpty) {
//                                             return 'CVV is required!';
//                                           }
//                                           return null;
//                                         },
//                                         style: TextStyle(
//                                           color: blackColor,
//                                           fontSize: 14,
//                                           fontFamily: 'Inter-Regular',
//                                         ),
//                                         decoration: InputDecoration(
//                                           filled: true,
//                                           fillColor: filledColor,
//                                           errorStyle: TextStyle(
//                                             color: redColor,
//                                             fontSize: 10,
//                                             fontFamily: 'Inter-Bold',
//                                           ),
//                                           border: const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(10),
//                                             ),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           enabledBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(10),
//                                             ),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           focusedBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(10),
//                                             ),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           focusedErrorBorder:
//                                               const OutlineInputBorder(
//                                             borderRadius: BorderRadius.all(
//                                               Radius.circular(10),
//                                             ),
//                                             borderSide: BorderSide.none,
//                                           ),
//                                           errorBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 const BorderRadius.all(
//                                               Radius.circular(10),
//                                             ),
//                                             borderSide: BorderSide(
//                                               color: redColor,
//                                               width: 1,
//                                             ),
//                                           ),
//                                           contentPadding:
//                                               const EdgeInsets.symmetric(
//                                                   horizontal: 20, vertical: 10),
//                                           hintText: "CVV",
//                                           hintStyle: TextStyle(
//                                             color: hintColor,
//                                             fontSize: 12,
//                                             fontFamily: 'Inter-Light',
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.17),
//                               GestureDetector(
//                                 onTap: () async {
//                                   if (paymentFormKey.currentState!.validate()) {
//                                     await addBankCard();
//                                     if (addBankCardModel.status == 'success') {
//                                       getBankCard();
//                                     } else {
//                                       Fluttertoast.showToast(
//                                         msg: "Please try again! ",
//                                         toastLength: Toast.LENGTH_SHORT,
//                                         gravity: ToastGravity.BOTTOM,
//                                         timeInSecForIosWeb: 2,
//                                         backgroundColor: toastColor,
//                                         textColor: whiteColor,
//                                         fontSize: 12,
//                                       );
//                                     }
//                                   }
//                                 },
//                                 child: isLoading2
//                                     ? buttonGradientWithLoader(
//                                         "Please Wait...", context)
//                                     : buttonGradient('SAVE', context),
//                               ),
//                               SizedBox(height: size.height * 0.02),
//                             ],
//                           )
//                         : const SizedBox(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget deleteConformation(int? index) {
//     var size = MediaQuery.of(context).size;
//     return StatefulBuilder(
//       builder: (context, setState) => WillPopScope(
//         onWillPop: () {
//           return Future.value(false);
//         },
//         child: Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(40),
//           ),
//           insetPadding: const EdgeInsets.only(left: 20, right: 20),
//           child: SizedBox(
//             height: size.height * 0.3,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   SizedBox(height: size.height * 0.01),
//                   Text(
//                     'Delete Card Details?'.toUpperCase(),
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: orangeColor,
//                       fontSize: 18,
//                       fontFamily: 'Syne-Bold',
//                     ),
//                   ),
//                   Text(
//                     'Are you sure you want to delete this card?',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: blackColor,
//                       fontSize: 16,
//                       fontFamily: 'Syne-Regular',
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: dialogButtonTransparentGradientSmall(
//                             'Cancel', context),
//                       ),
//                       GestureDetector(
//                         onTap: () async {
//                           await deleteBankCard(index);
//                           if (deleteBankCardModel.status == 'success') {
//                             Navigator.pop(context);
//                           } else {
//                             Navigator.pop(context);
//                           }
//                         },
//                         child: dialogButtonGradientSmall('Delete', context),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: size.height * 0.01),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:flutter_svg/flutter_svg.dart';
// // import 'package:deliver_client/utils/colors.dart';
// // import 'package:flutter_switch/flutter_switch.dart';
// // import 'package:deliver_client/widgets/buttons.dart';
// // import 'package:deliver_client/screens/home/home_page_screen.dart';
//
// // class PaymentScreen extends StatefulWidget {
// //   const PaymentScreen({super.key});
//
// //   @override
// //   State<PaymentScreen> createState() => _PaymentScreenState();
// // }
//
// // class _PaymentScreenState extends State<PaymentScreen> {
// //   TextEditingController cardNumberController = TextEditingController();
// //   TextEditingController nameOnCardController = TextEditingController();
// //   TextEditingController mmYYController = TextEditingController();
// //   TextEditingController cvvController = TextEditingController();
// //   final GlobalKey<FormState> paymentFormKey = GlobalKey<FormState>();
// //   bool statusCash = false;
// //   bool statusCard = true;
// //   bool statusWallet = false;
// //   bool statusBank = false;
//
// //   @override
// //   Widget build(BuildContext context) {
// //     var size = MediaQuery.of(context).size;
// //     return WillPopScope(
// //       onWillPop: () async {
// //         Navigator.of(context).pushAndRemoveUntil(
// //             MaterialPageRoute(builder: (context) => const HomePageScreen()),
// //             (Route<dynamic> route) => false);
// //         return false;
// //       },
// //       child: GestureDetector(
// //         onTap: () {
// //           FocusManager.instance.primaryFocus?.unfocus();
// //         },
// //         child: Scaffold(
// //           backgroundColor: bgColor,
// //           appBar: AppBar(
// //             backgroundColor: bgColor,
// //             elevation: 0,
// //             scrolledUnderElevation: 0,
// //             leading: GestureDetector(
// //               onTap: () {
// //                 Navigator.pop(context);
// //               },
// //               child: Padding(
// //                 padding: const EdgeInsets.only(left: 20),
// //                 child: SvgPicture.asset(
// //                   'assets/images/back-icon.svg',
// //                   width: 22,
// //                   height: 22,
// //                   fit: BoxFit.scaleDown,
// //                 ),
// //               ),
// //             ),
// //             title: Text(
// //               "Select Payment Method",
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 color: blackColor,
// //                 fontSize: 18,
// //                 fontFamily: 'Syne-Bold',
// //               ),
// //             ),
// //             centerTitle: true,
// //           ),
// //           body: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 20),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 children: [
// //                   SizedBox(height: size.height * 0.03),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 20),
// //                     child: Row(
// //                       children: [
// //                         Text(
// //                           "Use Cash",
// //                           textAlign: TextAlign.left,
// //                           style: TextStyle(
// //                             color: drawerTextColor,
// //                             fontSize: 18,
// //                             fontFamily: 'Syne-Regular',
// //                           ),
// //                         ),
// //                         const Spacer(),
// //                         FlutterSwitch(
// //                           width: 35,
// //                           height: 20,
// //                           activeColor: blackColor,
// //                           inactiveColor: whiteColor,
// //                           activeToggleBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           inactiveToggleBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           inactiveSwitchBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           toggleSize: 12,
// //                           value: statusCash,
// //                           borderRadius: 50,
// //                           onToggle: (val) {
// //                             setState(() {
// //                               statusCash = val;
// //                             });
// //                           },
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: size.height * 0.03),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 20),
// //                     child: Row(
// //                       children: [
// //                         Text(
// //                           "Use card for payment",
// //                           textAlign: TextAlign.left,
// //                           style: TextStyle(
// //                             color: drawerTextColor,
// //                             fontSize: 18,
// //                             fontFamily: 'Syne-Regular',
// //                           ),
// //                         ),
// //                         const Spacer(),
// //                         FlutterSwitch(
// //                           width: 35,
// //                           height: 20,
// //                           activeColor: blackColor,
// //                           inactiveColor: whiteColor,
// //                           activeToggleBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           inactiveToggleBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           inactiveSwitchBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           toggleSize: 12,
// //                           value: statusCard,
// //                           borderRadius: 50,
// //                           onToggle: (val) {
// //                             setState(() {
// //                               statusCard = val;
// //                             });
// //                           },
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: size.height * 0.03),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 20),
// //                     child: Row(
// //                       children: [
// //                         Text(
// //                           "Wallet Payment",
// //                           textAlign: TextAlign.left,
// //                           style: TextStyle(
// //                             color: drawerTextColor,
// //                             fontSize: 18,
// //                             fontFamily: 'Syne-Regular',
// //                           ),
// //                         ),
// //                         const Spacer(),
// //                         FlutterSwitch(
// //                           width: 35,
// //                           height: 20,
// //                           activeColor: blackColor,
// //                           inactiveColor: whiteColor,
// //                           activeToggleBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           inactiveToggleBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           inactiveSwitchBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           toggleSize: 12,
// //                           value: statusWallet,
// //                           borderRadius: 50,
// //                           onToggle: (val) {
// //                             setState(() {
// //                               statusWallet = val;
// //                             });
// //                           },
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: size.height * 0.03),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 20),
// //                     child: Row(
// //                       children: [
// //                         Text(
// //                           "Bank",
// //                           textAlign: TextAlign.left,
// //                           style: TextStyle(
// //                             color: drawerTextColor,
// //                             fontSize: 18,
// //                             fontFamily: 'Syne-Regular',
// //                           ),
// //                         ),
// //                         const Spacer(),
// //                         FlutterSwitch(
// //                           width: 35,
// //                           height: 20,
// //                           activeColor: blackColor,
// //                           inactiveColor: whiteColor,
// //                           activeToggleBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           inactiveToggleBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           inactiveSwitchBorder:
// //                               Border.all(color: blackColor, width: 2),
// //                           toggleSize: 12,
// //                           value: statusBank,
// //                           borderRadius: 50,
// //                           onToggle: (val) {
// //                             setState(() {
// //                               statusBank = val;
// //                             });
// //                           },
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: size.height * 0.03),
// //                   Card(
// //                     color: whiteColor,
// //                     elevation: 5,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 20),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               SizedBox(height: size.height * 0.02),
// //                               Text(
// //                                 "Name on Card",
// //                                 textAlign: TextAlign.left,
// //                                 style: TextStyle(
// //                                   color: blackColor,
// //                                   fontSize: 18,
// //                                   fontFamily: 'Syne-Bold',
// //                                 ),
// //                               ),
// //                               SizedBox(height: size.height * 0.01),
// //                               Text(
// //                                 "2348-XXXX-XXXX-XXX3",
// //                                 textAlign: TextAlign.left,
// //                                 style: TextStyle(
// //                                   color: textHaveAccountColor,
// //                                   fontSize: 16,
// //                                   fontFamily: 'Inter-Regular',
// //                                 ),
// //                               ),
// //                               SizedBox(height: size.height * 0.02),
// //                             ],
// //                           ),
// //                           SvgPicture.asset('assets/images/delete-icon.svg'),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: size.height * 0.03),
// //                   Text(
// //                     "Add a new card",
// //                     textAlign: TextAlign.center,
// //                     style: TextStyle(
// //                       color: blackColor,
// //                       fontSize: 18,
// //                       fontFamily: 'Syne-Bold',
// //                     ),
// //                   ),
// //                   SizedBox(height: size.height * 0.03),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 20),
// //                     child: Row(
// //                       children: [
// //                         SvgPicture.asset('assets/images/lock-icon.svg'),
// //                         SizedBox(width: size.width * 0.02),
// //                         Text(
// //                           "Secure Payments",
// //                           textAlign: TextAlign.left,
// //                           style: TextStyle(
// //                             color: orangeColor,
// //                             fontSize: 12,
// //                             fontFamily: 'Inter-Regular',
// //                           ),
// //                         ),
// //                         const Spacer(),
// //                         SvgPicture.asset('assets/images/mastercard-icon.svg'),
// //                         SizedBox(width: size.width * 0.01),
// //                         SvgPicture.asset('assets/images/visa-card-icon.svg'),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: size.height * 0.02),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 20),
// //                     child: TextFormField(
// //                       controller: nameOnCardController,
// //                       cursorColor: orangeColor,
// //                       keyboardType: TextInputType.text,
// //                       // validator: (value) {
// //                       //   if (value == null || value.isEmpty) {
// //                       //     return 'Name on Card field is required!';
// //                       //   }
// //                       //   return null;
// //                       // },
// //                       style: TextStyle(
// //                         color: blackColor,
// //                         fontSize: 14,
// //                         fontFamily: 'Inter-Regular',
// //                       ),
// //                       decoration: InputDecoration(
// //                         filled: true,
// //                         fillColor: filledColor,
// //                         errorStyle: TextStyle(
// //                           color: redColor,
// //                           fontSize: 12,
// //                           fontFamily: 'Inter-Bold',
// //                         ),
// //                         border: const OutlineInputBorder(
// //                           borderRadius: BorderRadius.all(
// //                             Radius.circular(10),
// //                           ),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                         enabledBorder: const OutlineInputBorder(
// //                           borderRadius: BorderRadius.all(
// //                             Radius.circular(10),
// //                           ),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                         focusedBorder: const OutlineInputBorder(
// //                           borderRadius: BorderRadius.all(
// //                             Radius.circular(10),
// //                           ),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                         focusedErrorBorder: const OutlineInputBorder(
// //                           borderRadius: BorderRadius.all(
// //                             Radius.circular(10),
// //                           ),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                         errorBorder: OutlineInputBorder(
// //                           borderRadius: const BorderRadius.all(
// //                             Radius.circular(10),
// //                           ),
// //                           borderSide: BorderSide(
// //                             color: redColor,
// //                             width: 1,
// //                           ),
// //                         ),
// //                         contentPadding: const EdgeInsets.symmetric(
// //                             horizontal: 20, vertical: 10),
// //                         hintText: "Name on Card",
// //                         hintStyle: TextStyle(
// //                           color: hintColor,
// //                           fontSize: 12,
// //                           fontFamily: 'Inter-Light',
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: size.height * 0.03),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 20),
// //                     child: TextFormField(
// //                       controller: cardNumberController,
// //                       cursorColor: orangeColor,
// //                       keyboardType: TextInputType.text,
// //                       // validator: (value) {
// //                       //   if (value == null || value.isEmpty) {
// //                       //     return 'Card Number field is required!';
// //                       //   }
// //                       //   return null;
// //                       // },
// //                       style: TextStyle(
// //                         color: blackColor,
// //                         fontSize: 14,
// //                         fontFamily: 'Inter-Regular',
// //                       ),
// //                       decoration: InputDecoration(
// //                         filled: true,
// //                         fillColor: filledColor,
// //                         errorStyle: TextStyle(
// //                           color: redColor,
// //                           fontSize: 12,
// //                           fontFamily: 'Inter-Bold',
// //                         ),
// //                         border: const OutlineInputBorder(
// //                           borderRadius: BorderRadius.all(
// //                             Radius.circular(10),
// //                           ),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                         enabledBorder: const OutlineInputBorder(
// //                           borderRadius: BorderRadius.all(
// //                             Radius.circular(10),
// //                           ),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                         focusedBorder: const OutlineInputBorder(
// //                           borderRadius: BorderRadius.all(
// //                             Radius.circular(10),
// //                           ),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                         focusedErrorBorder: const OutlineInputBorder(
// //                           borderRadius: BorderRadius.all(
// //                             Radius.circular(10),
// //                           ),
// //                           borderSide: BorderSide.none,
// //                         ),
// //                         errorBorder: OutlineInputBorder(
// //                           borderRadius: const BorderRadius.all(
// //                             Radius.circular(10),
// //                           ),
// //                           borderSide: BorderSide(
// //                             color: redColor,
// //                             width: 1,
// //                           ),
// //                         ),
// //                         contentPadding: const EdgeInsets.symmetric(
// //                             horizontal: 20, vertical: 10),
// //                         hintText: "Card Number",
// //                         hintStyle: TextStyle(
// //                           color: hintColor,
// //                           fontSize: 12,
// //                           fontFamily: 'Inter-Light',
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: size.height * 0.02),
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 20),
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Container(
// //                           color: transparentColor,
// //                           width: size.width * 0.38,
// //                           child: TextFormField(
// //                             controller: mmYYController,
// //                             cursorColor: orangeColor,
// //                             keyboardType: TextInputType.text,
// //                             // validator: (value) {
// //                             //   if (value == null || value.isEmpty) {
// //                             //     return 'MM/YY field is required!';
// //                             //   }
// //                             //   return null;
// //                             // },
// //                             style: TextStyle(
// //                               color: blackColor,
// //                               fontSize: 14,
// //                               fontFamily: 'Inter-Regular',
// //                             ),
// //                             decoration: InputDecoration(
// //                               filled: true,
// //                               fillColor: filledColor,
// //                               errorStyle: TextStyle(
// //                                 color: redColor,
// //                                 fontSize: 12,
// //                                 fontFamily: 'Inter-Bold',
// //                               ),
// //                               border: const OutlineInputBorder(
// //                                 borderRadius: BorderRadius.all(
// //                                   Radius.circular(10),
// //                                 ),
// //                                 borderSide: BorderSide.none,
// //                               ),
// //                               enabledBorder: const OutlineInputBorder(
// //                                 borderRadius: BorderRadius.all(
// //                                   Radius.circular(10),
// //                                 ),
// //                                 borderSide: BorderSide.none,
// //                               ),
// //                               focusedBorder: const OutlineInputBorder(
// //                                 borderRadius: BorderRadius.all(
// //                                   Radius.circular(10),
// //                                 ),
// //                                 borderSide: BorderSide.none,
// //                               ),
// //                               focusedErrorBorder: const OutlineInputBorder(
// //                                 borderRadius: BorderRadius.all(
// //                                   Radius.circular(10),
// //                                 ),
// //                                 borderSide: BorderSide.none,
// //                               ),
// //                               errorBorder: OutlineInputBorder(
// //                                 borderRadius: const BorderRadius.all(
// //                                   Radius.circular(10),
// //                                 ),
// //                                 borderSide: BorderSide(
// //                                   color: redColor,
// //                                   width: 1,
// //                                 ),
// //                               ),
// //                               contentPadding: const EdgeInsets.symmetric(
// //                                   horizontal: 20, vertical: 10),
// //                               hintText: "MM/YY",
// //                               hintStyle: TextStyle(
// //                                 color: hintColor,
// //                                 fontSize: 12,
// //                                 fontFamily: 'Inter-Light',
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         Container(
// //                           color: transparentColor,
// //                           width: size.width * 0.38,
// //                           child: TextFormField(
// //                             controller: cvvController,
// //                             cursorColor: orangeColor,
// //                             keyboardType: TextInputType.text,
// //                             // validator: (value) {
// //                             //   if (value == null || value.isEmpty) {
// //                             //     return 'CVV field is required!';
// //                             //   }
// //                             //   return null;
// //                             // },
// //                             style: TextStyle(
// //                               color: blackColor,
// //                               fontSize: 14,
// //                               fontFamily: 'Inter-Regular',
// //                             ),
// //                             decoration: InputDecoration(
// //                               filled: true,
// //                               fillColor: filledColor,
// //                               errorStyle: TextStyle(
// //                                 color: redColor,
// //                                 fontSize: 12,
// //                                 fontFamily: 'Inter-Bold',
// //                               ),
// //                               border: const OutlineInputBorder(
// //                                 borderRadius: BorderRadius.all(
// //                                   Radius.circular(10),
// //                                 ),
// //                                 borderSide: BorderSide.none,
// //                               ),
// //                               enabledBorder: const OutlineInputBorder(
// //                                 borderRadius: BorderRadius.all(
// //                                   Radius.circular(10),
// //                                 ),
// //                                 borderSide: BorderSide.none,
// //                               ),
// //                               focusedBorder: const OutlineInputBorder(
// //                                 borderRadius: BorderRadius.all(
// //                                   Radius.circular(10),
// //                                 ),
// //                                 borderSide: BorderSide.none,
// //                               ),
// //                               focusedErrorBorder: const OutlineInputBorder(
// //                                 borderRadius: BorderRadius.all(
// //                                   Radius.circular(10),
// //                                 ),
// //                                 borderSide: BorderSide.none,
// //                               ),
// //                               errorBorder: OutlineInputBorder(
// //                                 borderRadius: const BorderRadius.all(
// //                                   Radius.circular(10),
// //                                 ),
// //                                 borderSide: BorderSide(
// //                                   color: redColor,
// //                                   width: 1,
// //                                 ),
// //                               ),
// //                               contentPadding: const EdgeInsets.symmetric(
// //                                   horizontal: 20, vertical: 10),
// //                               hintText: "CVV",
// //                               hintStyle: TextStyle(
// //                                 color: hintColor,
// //                                 fontSize: 12,
// //                                 fontFamily: 'Inter-Light',
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: size.height * 0.07),
// //                   buttonGradient('SAVE', context),
// //                   SizedBox(height: size.height * 0.02),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
