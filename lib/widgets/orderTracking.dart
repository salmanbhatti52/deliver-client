import 'dart:convert';

import 'package:deliver_client/models/tracking_order_model.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({Key? key}) : super(key: key);

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  TextEditingController tracking = TextEditingController();
  TrackingOrderModel trackingOrderModel = TrackingOrderModel();
  bool isLoading1 = false;
  orderTracking() async {
    setState(() {
      isLoading1 = true;
    });
    var headersList = {'Accept': '*/*', 'Content-Type': 'application/json'};
    var url = Uri.parse('https://deliverbygfl.com/api/bookings_track');

    var body = {"bookings_id": tracking.text};

    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode == 200) {
      trackingOrderModel = trackingOrderModelFromJson(resBody);
      setState(() {
        isLoading1 = false;
      });
      print(resBody);
    } else {
      print(res.reasonPhrase);
      trackingOrderModel = trackingOrderModelFromJson(resBody);
      setState(() {
        isLoading1 = false;
      });
    }
  }

  bool systemSettings = false;
  String? trackingPrefix;

  Future<String?> fetchSystemSettingsDescription28() async {
    const String apiUrl = 'https://deliverbygfl.com/api/get_all_system_data';
    setState(() {
      systemSettings = true;
    });
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        final Map<String, dynamic> data = json.decode(response.body);

        // Find the setting with system_settings_id equal to 26
        final setting395 = data['data'].firstWhere(
            (setting) => setting['system_settings_id'] == 395,
            orElse: () => null);
        setState(() {
          systemSettings = false;
        });
        if (setting395 != null) {
          // Extract and return the description if setting 28 exists
          trackingPrefix = setting395['description'];
          print("trackingPrefix: $trackingPrefix");

          return trackingPrefix;
        } else {
          throw Exception('System setting with ID 395 not found');
        }
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to fetch system settings');
      }
    } catch (e) {
      // Catch any exception that might occur during the process
      print('Error fetching system settings: $e');
      return null;
    }
  }

  String? formattedDate0;
  String? formattedDate1;
  String? formattedDate2;
  String? formattedDate3;
  String? formattedDate4;
  String? formattedEstimatedDeliveryTime;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchSystemSettingsDescription28();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
          "Tracking",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blackColor,
            fontSize: 20,
            fontFamily: 'Syne-Bold',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 13, right: 13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    color: transparentColor,
                    width: size.width * 0.8,
                    child: TextFormField(
                      controller: tracking,
                      cursorColor: orangeColor,
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        color: blackColor,
                        fontSize: 14,
                        fontFamily: 'Inter-Regular',
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: whiteColor,
                        errorStyle: TextStyle(
                          color: redColor,
                          fontSize: 10,
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
                        hintText: "Enter Tracking Number",
                        hintStyle: TextStyle(
                          color: hintColor,
                          fontSize: 12,
                          fontFamily: 'Inter-Light',
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (tracking.text.isEmpty) {
                        CustomToast.showToast(
                            message: 'Please Enter Tracking Number');
                      } else {
                        await orderTracking();
                      }
                    },
                    child: buttonGradientTiny(
                      "GO",
                      context,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          trackingOrderModel.data != null
              ? SmoothPageIndicator(
                  controller:
                      pageController, // Use the same PageController here
                  count: trackingOrderModel.data!.bookings.bookingsDestinations
                      .length, // This should match the itemCount of the PageView.builder
                  effect: const WormEffect(
                    dotWidth: 10,
                    dotHeight: 10,
                    activeDotColor: Colors.orange,
                    dotColor: Colors.grey,
                    spacing: 6,
                  ), // Example effect, choose and customize as needed
                )
              : const Text(""),
          trackingOrderModel.data != null
              ? Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: trackingOrderModel
                        .data!.bookings.bookingsDestinations.length,
                    itemBuilder: (context, index) {
                      formattedDate0 = DateFormat("h:mm a d MMMM yyyy").format(
                          DateTime.parse(trackingOrderModel
                              .data!.bookings.dateAdded
                              .toString()));
                      formattedDate1 = trackingOrderModel.data!.bookings
                                  .bookingsDestinations[index].pickupTime !=
                              null
                          ? DateFormat("h:mm a d MMMM yyyy").format(
                              DateTime.parse(trackingOrderModel.data!.bookings
                                  .bookingsDestinations[index].pickupTime
                                  .toString()))
                          : null;
                      formattedDate4 = trackingOrderModel
                          .data!
                          .bookings
                          .bookingsDestinations[index]
                          .bookingsDestinationsStatus
                          .name
                          .toString();

                      formattedDate2 = trackingOrderModel.data!.bookings
                                  .bookingsDestinations[index].deliveredTime !=
                              null
                          ? DateFormat("h:mm a d MMMM yyyy").format(
                              DateTime.parse(trackingOrderModel.data!.bookings
                                  .bookingsDestinations[index].deliveredTime
                                  .toString()))
                          : null;
                      // Example base DateTime object. Replace this with your actual base DateTime
                      DateTime baseDateTime = DateTime
                          .now(); // Example, replace with actual base time

                      // Extract duration from destinTime
                      String durationString = trackingOrderModel
                          .data!.bookings.bookingsDestinations[index].destinTime
                          .toString();
                      // Example format of durationString: "9 mins"

                      // Split the durationString into numeric and unit parts
                      var durationParts =
                          RegExp(r'(\d+)\s*(\w+)').firstMatch(durationString);
                      int durationValue = int.parse(durationParts!.group(1)!);
                      String durationUnit = durationParts.group(2)!;

                      // Add the duration to baseDateTime based on the unit
                      DateTime adjustedDateTime = baseDateTime;
                      if (durationUnit.contains('min')) {
                        adjustedDateTime =
                            baseDateTime.add(Duration(minutes: durationValue));
                      } else if (durationUnit.contains('hour')) {
                        adjustedDateTime =
                            baseDateTime.add(Duration(hours: durationValue));
                      } // Add more conditions for different units if necessary

                      // Format the adjustedDateTime
                      formattedDate3 = DateFormat("h:mm a d MMMM yyyy")
                          .format(adjustedDateTime);
                      // Parse the pickup time
                      DateTime? pickupTime = trackingOrderModel.data!.bookings
                                  .bookingsDestinations[index].pickupTime !=
                              null
                          ? DateTime.parse(trackingOrderModel.data!.bookings
                              .bookingsDestinations[index].pickupTime
                              .toString())
                          : null;

                      // Add 9 minutes to the pickup time to get the estimated delivery time

                      if (pickupTime != null) {
                        DateTime estimatedDeliveryTime =
                            pickupTime.add(const Duration(minutes: 9));
                        formattedEstimatedDeliveryTime =
                            DateFormat("d MMMM yyyy h:mm a")
                                .format(estimatedDeliveryTime);
                      } else {
                        // Handle the case when pickupTime is null. For example, set formattedEstimatedDeliveryTime to null or a default value.
                        formattedEstimatedDeliveryTime =
                            null; // or a default value if needed
                      }
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10.0), // Rounded corners
                          ),
                          elevation: 4.0, // Shadow intensity
                          shadowColor: Colors.white.withOpacity(0.5),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text(
                                        "Track Order",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        "$trackingPrefix${trackingOrderModel.data!.bookingsId}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: filledColor, // Set the divider color
                                  thickness:
                                      1, // Set the thickness of the divider
                                  indent:
                                      20, // Optional: add an indent to the start of the divider
                                  endIndent:
                                      20, // Optional: add an end indent to the end of the divider
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      const Text(
                                        "Estimated Delivery",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        formattedEstimatedDeliveryTime ??
                                            "Pending",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: filledColor, // Set the divider color
                                  thickness:
                                      1, // Set the thickness of the divider
                                  indent:
                                      20, // Optional: add an indent to the start of the divider
                                  endIndent:
                                      20, // Optional: add an end indent to the end of the divider
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: ListView(
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                      _buildTimelineTile(
                                        isFirst: true,
                                        isLast: false,
                                        // Assuming formattedDate0 is related to this event's time
                                        isPast: formattedDate0 != null,
                                        eventCard: _buildEventCard(
                                          title: 'Pick-up Request Accepted',
                                          description:
                                              formattedDate0 ?? 'Pending',
                                          icon: Icons.shopping_cart,
                                        ),
                                      ),
                                      _buildTimelineTile(
                                        isFirst: false,
                                        isLast: false,
                                        // Assuming formattedDate1 is related to this event's time
                                        isPast: formattedDate1 != null,
                                        eventCard: _buildEventCard(
                                          title: 'Order Confirmed',
                                          description:
                                              formattedDate1 ?? 'Pending',
                                          icon: Icons.check_circle,
                                        ),
                                      ),
                                      _buildTimelineTile(
                                        isFirst: false,
                                        isLast: true,
                                        // Assuming there's a variable like formattedDate for this event
                                        // isPast: true, // Original
                                        isPast: formattedDate1 !=
                                            null, // Example variable for shipped date
                                        eventCard: _buildEventCard(
                                          title: 'Order Shipped',
                                          description: formattedDate1 != null
                                              ? 'Your order has been shipped and is on its destination.'
                                              : 'Your order is pending shipment.',
                                          icon: Icons.local_shipping,
                                        ),
                                      ),
                                      // _buildTimelineTile(
                                      //   isFirst: false,
                                      //   isLast: true,
                                      //   // Assuming formattedDate2 is related to this event's time
                                      //   isPast: formattedDate2 != null,
                                      //   eventCard: _buildEventCard(
                                      //     title: '$formattedDate4',
                                      //     description:
                                      //         formattedDate2 ?? 'Pending',
                                      //     icon: Icons.home,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const Text(""),
        ],
      ),
    );
  }

  Widget _buildTimelineTile({
    required bool isFirst,
    required bool isLast,
    required bool isPast,
    bool isActive = false,
    required Widget eventCard,
  }) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
          color: isPast ? Colors.orange : Colors.grey.shade300, thickness: 2),
      indicatorStyle: IndicatorStyle(
        width: 23,
        color: isPast || isActive ? Colors.orange : Colors.grey.shade300,
        iconStyle: IconStyle(
          color: Colors.white,
          iconData: Icons.check,
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: eventCard,
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String description,
    required IconData icon,
    double width = 350, // Default width, can be adjusted as needed
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: filledColor.withOpacity(0.90), // Use the customizable color
        borderRadius: BorderRadius.circular(10), // Rounded corners
        border: Border.all(color: Colors.grey.shade300), // Border color
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  PageController pageController = PageController();
}
