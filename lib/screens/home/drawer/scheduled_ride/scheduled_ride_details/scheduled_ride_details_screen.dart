// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:deliver_client/models/update_booking_transaction_model.dart';
import 'package:deliver_client/screens/booking_accepted_screen.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/cancel_booking_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/models/get_scheduled_booking_model.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart'
    as systemdata;

String? userId;

class ScheduledRideDetailScreen extends StatefulWidget {
  final Datum? getScheduledBookingModel;

  const ScheduledRideDetailScreen({super.key, this.getScheduledBookingModel});

  @override
  State<ScheduledRideDetailScreen> createState() =>
      _ScheduledRideDetailScreenState();
}

class _ScheduledRideDetailScreenState extends State<ScheduledRideDetailScreen> {
  DateTime? timeAdded;
  String? currencyUnit;
  String? distanceUnit;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];
  String? publicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'];
  ScrollController scrollController = ScrollController();

  final int amount = 100000;
  int? totalAmount;
  final payStackClient = PaystackPlugin();
  final String reference =
      "unique_transaction_ref_${Random().nextInt(1000000)}";
  UpdateBookingTransactionModel updateBookingTransactionModel =
      UpdateBookingTransactionModel();
  String? firstName;
  String? lastName;
  String? userEmail;
  sharedPref() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userEmail = sharedPref.getString('email');
    firstName = sharedPref.getString('firstName');
    lastName = sharedPref.getString('lastName');
  }

  updateBookingTransaction() async {
    // try {
    String apiUrl = "$baseUrl/maintain_booking_transaction";
    debugPrint("apiUrl: $apiUrl");
    debugPrint("bookings_id: ${widget.getScheduledBookingModel!.bookingsId}");
    debugPrint("payer_name: $firstName $lastName");
    debugPrint("payer_email: $userEmail");
    debugPrint(
        "total_amount: ${widget.getScheduledBookingModel!.totalCharges ?? widget.getScheduledBookingModel!.totalDeliveryCharges}");
    debugPrint("payment_status: Paid");
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        "bookings_id": widget.getScheduledBookingModel!.bookingsId.toString(),
        "total_amount": widget.getScheduledBookingModel != null
            ? widget.getScheduledBookingModel!.totalCharges
            : widget.getScheduledBookingModel!.totalDeliveryCharges,
        "payment_status": "Paid",
        "bookings_destinations_id": ""
      },
    );
    final responseString = response.body;
    debugPrint("response: $responseString");
    debugPrint("statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      updateBookingTransactionModel =
          updateBookingTransactionModelFromJson(responseString);
      debugPrint(
          'updateBookingTransactionModel status: ${updateBookingTransactionModel.status}');

      await getAllSystemData();
      CustomToast.showToast(message: "Your Ride is inProgress");
      setState(() {});
    }
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  void startPayStack() {
    payStackClient.initialize(publicKey: publicKey!);
  }

  void makePayment() async {
    final Charge charge = Charge()
      ..amount = totalAmount1! * 100
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
      debugPrint("response: $response");
      CustomToast.showToast(
        fontSize: 12,
        message: "Transaction Successful!",
      );
      await updateBookingTransaction();
      await getAllSystemData();
    } else {
      CustomToast.showToast(
        fontSize: 12,
        message: "Transaction Failed!",
      );
    }
  }

  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();

  Future<void> updateBookingStatus() async {
    // try {
    String apiUrl = "$baseUrl/get_updated_status_booking";
    debugPrint("apiUrl: $apiUrl");
    debugPrint(
        "currentBookingId: ${widget.getScheduledBookingModel!.bookingsId}");
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        "bookings_id": widget.getScheduledBookingModel!.bookingsId.toString(),
      },
    );
    final responseString = response.body;
    debugPrint("response: $responseString");
    debugPrint("statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      updateBookingStatusModel =
          updateBookingStatusModelFromJson(responseString);
      debugPrint(
          'updateBookingStatusModel status: ${updateBookingStatusModel.status}');
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      print("$jsonResponse");
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return;
    // }
  }

  systemdata.GetAllSystemDataModel getAllSystemDataModel =
      systemdata.GetAllSystemDataModel();

  getAllSystemData() async {
    // try {
    setState(() {
      isLoading = true;
    });
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
      getAllSystemDataModel =
          systemdata.getAllSystemDataModelFromJson(responseString);
      debugPrint(
          'getAllSystemDataModel status: ${getAllSystemDataModel.status}');
      debugPrint(
          'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
      for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
        if (getAllSystemDataModel.data?[i].type == "system_currency") {
          currencyUnit = "${getAllSystemDataModel.data?[i].description}";
          debugPrint("currencyUnit: $currencyUnit");
        }
        if (getAllSystemDataModel.data?[i].type == "distance_unit") {
          distanceUnit = "${getAllSystemDataModel.data?[i].description}";
          debugPrint("distanceUnit: $distanceUnit");
        }
      }
    }
    await updateBookingStatus();
    CustomToast.showToast(
        message: "${updateBookingStatusModel.data!.paymentStatus}");

    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  String formatTimeDifference(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays >= 365) {
      int years = (difference.inDays / 365).floor();
      return "${years == 1 ? '1 year' : '$years years'} ago";
    } else if (difference.inDays >= 30) {
      int months = (difference.inDays / 30).floor();
      return "${months == 1 ? '1 month' : '$months months'} ago";
    } else if (difference.inDays >= 7) {
      int weeks = (difference.inDays / 7).floor();
      return "${weeks == 1 ? '1 week' : '$weeks weeks'} ago";
    } else if (difference.inDays > 0) {
      return "${difference.inDays == 1 ? '1 day' : '${difference.inDays} days'} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours == 1 ? '1 hour' : '${difference.inHours} hours'} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes == 1 ? '1 minute' : '${difference.inMinutes} mins'} ago";
    } else {
      return "Just now";
    }
  }

  @override
  void initState() {
    super.initState();
    sharedPref();
    startPayStack();
    getAllSystemData();
    print("${widget.getScheduledBookingModel}");

    nextPageScrollController.addListener(() {
      setState(() {
        // Update the current index based on the scroll position
        currentIndex = (nextPageScrollController.offset /
                MediaQuery.of(context).size.width)
            .round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    // Use current date and time as a default value
    return Scaffold(
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
          "Scheduled Rides",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blackColor,
            fontSize: 20,
            fontFamily: 'Syne-Bold',
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                Icons.refresh,
                color: Colors.black,
              ),
            ),
            onPressed: () {
              // Add your refresh logic here
              getAllSystemData();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Container(
                width: 100,
                height: 100,
                color: transparentColor,
                child: Lottie.asset(
                  'assets/images/loading-icon.json',
                  fit: BoxFit.cover,
                ),
              ),
            )
          : updateBookingStatusModel.data!.status == "Accepted"
              ? Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: updateBookingStatusModel
                                  .data!.bookingsFleet!.length ??
                              0,
                          onPageChanged: (index) async {
                            setState(() {
                              currentIndex =
                                  index; // Update currentIndex when page changes
                            });
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                children: [
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          color: transparentColor,
                                          width: 60,
                                          height: 65,
                                          child: updateBookingStatusModel.data!.bookingsFleet?[index].usersFleet?.profilePic != null
                                              ? FadeInImage(
                                            placeholder: const AssetImage("assets/images/user-profile.png"),
                                            image: NetworkImage(
                                              '$imageUrl${updateBookingStatusModel.data!.bookingsFleet?[index].usersFleet?.profilePic}',
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                              : Image.asset(
                                            "assets/images/user-profile.png", // Asset fallback image
                                            fit: BoxFit.cover,
                                          ),
                                          // child: FadeInImage(
                                          //   placeholder: const AssetImage(
                                          //     "assets/images/user-profile.png",
                                          //   ),
                                          //   image: NetworkImage(
                                          //     '$imageUrl${updateBookingStatusModel.data!.bookingsFleet?[index].usersFleet?.profilePic}',
                                          //   ),
                                          //   fit: BoxFit.cover,
                                          // ),
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.45,
                                            child: AutoSizeText(
                                              "${updateBookingStatusModel.data!.bookingsFleet?[index].usersFleet?.firstName} ${updateBookingStatusModel.data!.bookingsFleet?[index].usersFleet?.lastName}",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: drawerTextColor,
                                                fontSize: 16,
                                                fontFamily: 'Syne-Bold',
                                              ),
                                              minFontSize: 16,
                                              maxFontSize: 16,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '${updateBookingStatusModel.data!.bookingsFleet?[index].usersFleet?.bookingsRatings}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: blackColor,
                                              fontSize: 12,
                                              fontFamily: 'Inter-Regular',
                                            ),
                                          ),
                                          // Row(
                                          //   children: [
                                          //     Text(
                                          //       '${updateBookingStatusModel.data!.bookingsFleet?[index].usersFleetVehicles?.color} ',
                                          //       textAlign: TextAlign.left,
                                          //       style: TextStyle(
                                          //         color: textHaveAccountColor,
                                          //         fontSize: 12,
                                          //         fontFamily: 'Inter-Regular',
                                          //       ),
                                          //     ),
                                          //     Text(
                                          //       '${updateBookingStatusModel.data!.bookingsFleet?[index].usersFleetVehicles?.model}',
                                          //       textAlign: TextAlign.left,
                                          //       style: TextStyle(
                                          //         color: textHaveAccountColor,
                                          //         fontSize: 12,
                                          //         fontFamily: 'Inter-Regular',
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          SizedBox(height: size.height * 0.005),
                                          // Text(
                                          //   '${updateBookingStatusModel.data!.bookingsFleet?[index].usersFleetVehicles?.vehicleRegistrationNo}',
                                          //   textAlign: TextAlign.left,
                                          //   style: TextStyle(
                                          //     color: textHaveAccountColor,
                                          //     fontSize: 12,
                                          //     fontFamily: 'Inter-Regular',
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/date-picker-icon.svg',
                                        width: 15,
                                        height: 15,
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text(
                                        'Scheduled Date:',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text(
                                        '${updateBookingStatusModel.data!.deliveryDate}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Regular',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/time-picker-icon.svg',
                                        width: 15,
                                        height: 15,
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text(
                                        'Scheduled Time:',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Text(
                                        '${updateBookingStatusModel.data!.deliveryTime}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Regular',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  // SizedBox(
                                  //   width: MediaQuery.of(context).size.width,
                                  //   child: Expanded(
                                  //     child: ListView.builder(
                                  //       itemCount: widget
                                  //               .getScheduledBookingModel!
                                  //               .bookingsFleet
                                  //               ?.length ??
                                  //           0,
                                  //       itemBuilder: (context, index) {
                                  //         return ListTile(
                                  //           title: Text(
                                  //             '${widget.getScheduledBookingModel!.bookingsFleet?[index].dateModified}',
                                  //             textAlign: TextAlign.left,
                                  //             style: const TextStyle(
                                  //               color: Colors.black,
                                  //               fontSize: 14,
                                  //               fontFamily: 'Inter-Regular',
                                  //             ),
                                  //           ),
                                  //           trailing: GestureDetector(
                                  //             onTap: () {
                                  //               showDialog(
                                  //                 context: context,
                                  //                 barrierDismissible: false,
                                  //                 builder: (context) =>
                                  //                     cancelRide(context),
                                  //               );
                                  //             },
                                  //             child: const Icon(Icons.cancel),
                                  //           ),
                                  //         );
                                  //       },
                                  //     ),
                                  //   ),
                                  // ),
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
                                                "${updateBookingStatusModel.data!.bookingsFleet?[index].bookingsDestinations!.pickupAddress}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.6,
                                              child: AutoSizeText(
                                                "${updateBookingStatusModel.data!.bookingsFleet?[index].bookingsDestinations?.pickupAddress}",
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
                                          Text(
                                            'Dropoff',
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
                                                "${updateBookingStatusModel.data!.bookingsFleet?[index].bookingsDestinations?.destinAddress}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.6,
                                              child: AutoSizeText(
                                                "${updateBookingStatusModel.data!.bookingsFleet?[index].bookingsDestinations?.destinAddress}",
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
                                  SizedBox(height: size.height * 0.03),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/grey-location-icon.svg',
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Tooltip(
                                            message:
                                                "${updateBookingStatusModel.data!.bookingsFleet?[index].bookingsDestinations?.destinDistance} $distanceUnit",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.18,
                                              child: AutoSizeText(
                                                "${updateBookingStatusModel.data!.bookingsFleet?[index].bookingsDestinations?.destinDistance} $distanceUnit",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Regular',
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
                                      Column(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/grey-clock-icon.svg',
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Tooltip(
                                            message:
                                                "${updateBookingStatusModel.data!.bookingsFleet?[index].bookingsDestinations?.destinTime}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.38,
                                              child: AutoSizeText(
                                                "${updateBookingStatusModel.data!.bookingsFleet?[index].bookingsDestinations?.destinTime}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Regular',
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
                                      Column(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/grey-dollar-icon.svg',
                                            colorFilter: ColorFilter.mode(
                                                const Color(0xFF292D32)
                                                    .withOpacity(0.4),
                                                BlendMode.srcIn),
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          Tooltip(
                                            message:
                                                "$currencyUnit${updateBookingStatusModel.data!.totalCharges}",
                                            child: Container(
                                              color: transparentColor,
                                              width: size.width * 0.2,
                                              child: AutoSizeText(
                                                "$currencyUnit${updateBookingStatusModel.data!.totalCharges}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: textHaveAccountColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Regular',
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
                                    ],
                                  ),
                                  // SizedBox(height: size.height * 0.03),
                                  // SizedBox(height: size.height * 0.02),
                                ],
                              ),
                            );
                          }),
                    ),
                    Center(
                      child: Container(
                        color: Colors.transparent,
                        height: 12,
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            controller: nextPageScrollController,
                            itemCount: updateBookingStatusModel
                                .data!.bookingsFleet!.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  pageController.animateToPage(index,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(width: 3),
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: currentIndex == index
                                            ? Colors.orange
                                            : grey,
                                      ),
                                    ),
                                    const SizedBox(width: 3)
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.09),
                    (updateBookingStatusModel.data!.paymentBy == "Sender" &&
                            updateBookingStatusModel.data!.paymentStatus ==
                                "Unpaid")
                        ? GestureDetector(
                            onTap: () {
                              if (updateBookingStatusModel.data!.totalCharges !=
                                  null) {
                                double parsedValue = double.parse(
                                    updateBookingStatusModel
                                        .data!.totalCharges!);
                                totalAmount1 = (parsedValue + 0.5).floor();
                                debugPrint("Rounded Integer: $totalAmount");
                              } else {
                                double parsedValue = double.parse(
                                    updateBookingStatusModel
                                        .data!.totalDeliveryCharges!);
                                totalAmount = (parsedValue + 0.5).floor();
                                debugPrint("Rounded Integer: $totalAmount1");
                              }
                              makePayment();
                            },
                            child: buttonGradient("Make Payment", context),
                          )
                        : buttonGradient("In Progress", context),
                    SizedBox(height: size.height * 0.02),
                    GestureDetector(
                      onTap: () async {
                        final reasons =
                            await fetchCancellationReasons(); // Fetch cancellation reasons
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => cancelRide(context,
                              reasons), // Pass reasons to cancelRide function
                        );
                      },
                      child: buttonGradient("Cancel", context),
                    ),
                    SizedBox(height: size.height * 0.04),
                  ],
                )
              : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "Waiting for the ride to be accepted. You will be notified via notification. Make payment in case you selected the card payment.",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                            // fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  int? totalAmount1;
  PageController pageController = PageController();
  ScrollController nextPageScrollController = ScrollController();
  int currentIndex = 0;
  // cancelRide(BuildContext context) {
  //   var size = MediaQuery.of(context).size;
  //   return WillPopScope(
  //     onWillPop: () {
  //       return Future.value(false);
  //     },
  //     child: StatefulBuilder(
  //       builder: (context, setState) => Dialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(40),
  //         ),
  //         insetPadding: const EdgeInsets.only(left: 20, right: 20),
  //         child: SizedBox(
  //           height: size.height * 0.3,
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 20),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: Align(
  //                     alignment: Alignment.centerRight,
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(top: 15),
  //                       child: SvgPicture.asset("assets/images/close-icon.svg"),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(height: size.height * 0.01),
  //                 Text(
  //                   'Cancel Ride',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     color: orangeColor,
  //                     fontSize: 24,
  //                     fontFamily: 'Syne-Bold',
  //                   ),
  //                 ),
  //                 Text(
  //                   'Are you sure, you want\nto cancel this ride?',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     color: blackColor,
  //                     fontSize: 18,
  //                     fontFamily: 'Syne-Regular',
  //                   ),
  //                 ),
  //                 SizedBox(height: size.height * 0.01),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     GestureDetector(
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child:
  //                           dialogButtonTransparentGradientSmall("No", context),
  //                     ),
  //                     GestureDetector(
  //                       onTap: () async {
  //                         setState(() {
  //                           isLoading = true;
  //                         });
  //                         await cancelBooking();
  //                         if (cancelBookingModel.status == "success") {
  //                           Navigator.of(context).pushAndRemoveUntil(
  //                               MaterialPageRoute(
  //                                   builder: (context) =>
  //                                       const HomePageScreen()),
  //                               (Route<dynamic> route) => false);
  //                           setState(() {
  //                             isLoading = false;
  //                           });
  //                         } else {
  //                           CustomToast.showToast(
  //                             fontSize: 12,
  //                             message:
  //                                 "You have already cancelled this booking.",
  //                           );
  //                           setState(() {
  //                             isLoading = false;
  //                           });
  //                         }
  //                       },
  //                       child: isLoading
  //                           ? dialogButtonGradientSmallWithLoader(
  //                               "Please wait...", context)
  //                           : dialogButtonGradientSmall("Yes", context),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: size.height * 0.01),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  bool isCanceling = false;
  Future<List<RideCancellationReason>> fetchCancellationReasons() async {
    final response = await http.post(
      Uri.parse(
          'https://deliverbygfl.com/api/get_bookings_cancellations_reasons'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'user_type': 'Customer',
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        final List<dynamic> data = responseData['data'];
        return data.map((reasonData) {
          return RideCancellationReason(
            id: reasonData['bookings_cancellations_reasons_id'].toString(),
            reason: reasonData['reason'],
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch cancellation reasons');
      }
    } else {
      throw Exception('Failed to fetch cancellation reasons');
    }
  }

  CancelBookingModel cancelBookingModel = CancelBookingModel();

  cancelBooking(String cancellationReasonId) async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/cancel_booking_customers";
      debugPrint("apiUrl: $apiUrl");
      debugPrint(
          "bookings_id: ${widget.getScheduledBookingModel!.bookingsId.toString()}");
      // debugPrint("users_fleet_id: ${widget.fleetId}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "bookings_id": widget.getScheduledBookingModel!.bookingsId.toString(),
          "bookings_cancellations_reasons_id": cancellationReasonId
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        cancelBookingModel = cancelBookingModelFromJson(responseString);
        setState(() {});
        debugPrint('cancelBookingModel status: ${cancelBookingModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  cancelRide(BuildContext context, List<RideCancellationReason> reasons) {
    var size = MediaQuery.of(context).size;
    String? selectedReason;
    return StatefulBuilder(
      builder: (context, setState) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        insetPadding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
          height: size.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FutureBuilder<List<RideCancellationReason>>(
              future: fetchCancellationReasons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final cancellationReasons = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: SvgPicture.asset(
                                "assets/images/close-icon.svg"),
                          ),
                        ),
                      ),
                      Text(
                        'Cancel Ride',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: orangeColor,
                          fontSize: 24,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                      Text(
                        'Are you sure you want to cancel this ride?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 18,
                          fontFamily: 'Syne-Regular',
                        ),
                      ),
                      // Display cancellation reasons as radio buttons
                      Column(
                        children: cancellationReasons.map((reason) {
                          return Transform.scale(
                            scale: 0.9,
                            child: RadioListTile<String>(
                              title: Text(
                                reason.reason,
                                style: TextStyle(color: blackColor),
                              ),
                              value: reason.id,
                              groupValue: selectedReason,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedReason = value!;
                                });
                              },
                              activeColor: orangeColor,
                            ),
                          );
                        }).toList(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (selectedReason != null) {
                                setState(() {
                                  isLoading = true;
                                });
                                await cancelBooking(selectedReason!);
                                if (cancelBookingModel.status == "success") {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePageScreen(index: 0)),
                                    (Route<dynamic> route) => false,
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  CustomToast.showToast(
                                    fontSize: 12,
                                    message:
                                        "You have already cancelled this booking.",
                                  );
                                }
                              } else {
                                CustomToast.showToast(
                                  fontSize: 12,
                                  message:
                                      "Please select a cancellation reason.",
                                );
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: isLoading
                                ? dialogButtonGradientSmallWithLoader(
                                    "Please wait...", context)
                                : Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                        stops: const [0.1, 1.5],
                                        colors: [
                                          orangeColor,
                                          yellowColor,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Yes, Cancel Ride",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 16,
                                          fontFamily: 'Syne-Medium',
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
