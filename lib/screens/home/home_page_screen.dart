import 'dart:convert';

import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:deliver_client/screens/home/tabbar_items/inporgress_screen_off_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/app_drawer.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:deliver_client/screens/home/tabbar_items/new_screen.dart';
import 'package:deliver_client/screens/home/tabbar_items/inprogress_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class HomePageScreen extends StatefulWidget {
  final int? index;
  final Map? singleData;
  final String? passCode;
  final Map? multipleData;
  final String? currentBookingId;
  final UpdateBookingStatusModel? riderData;
  final String? bookingDestinationId;

  const HomePageScreen({
    super.key,
    this.index,
    this.singleData,
    this.passCode,
    this.multipleData,
    this.currentBookingId,
    this.riderData,
    this.bookingDestinationId,
  });

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen>
    with SingleTickerProviderStateMixin {
  String? token;
  TabController? tabController;
  DateTime? currentBackPressTime;
  one() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize(appID);
    await fetchSystemSettingsDescription397();

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    OneSignal.Notifications.requestPermission(true);

    token = OneSignal.User.pushSubscription.id;
    print('token Response: $token');
    setState(() {});
  }

  Future<bool> onExitApp() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      CustomToast.showToast(
        fontSize: 12,
        message: "Tap again to exit",
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
    one();
  }

  bool systemSettings = false;
  String? mapRefreshSystem;
  Future<String?> fetchSystemSettingsDescription397() async {
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

        final setting398 = data['data'].firstWhere(
            (setting) => setting['system_settings_id'] == 398,
            orElse: () => null);
        setState(() {
          systemSettings = false;
        });
        if (setting398 != null) {
          // Extract and return the description if setting 28 exists
          mapRefreshSystem = setting398['description'];
          print("mapRefreshTime: $mapRefreshSystem");

          return mapRefreshSystem;
        } else {
          throw Exception('System setting with ID 40 not found');
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

  @override
  void dispose() {
    super.dispose();
    tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TabController tabController = TabController(length: 2, vsync: this);
    return WillPopScope(
      onWillPop: onExitApp,
      child: systemSettings
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (mapRefreshSystem == "Enable"
              ? DefaultTabController(
                  length: 2,
                  initialIndex: widget.index ?? 0,
                  child: Scaffold(
                    backgroundColor: bgColor,
                    drawer: AppDrawer(
                      singleData: widget.singleData,
                      passCode: widget.passCode,
                      multipleData: widget.multipleData,
                      currentBookingId: widget.currentBookingId,
                      riderData: widget.riderData,
                      bookingDestinationId: widget.bookingDestinationId,
                    ),
                    body: Stack(
                      children: [
                        Positioned(
                          top: 40,
                          left: 20,
                          child: Builder(builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: SvgPicture.asset(
                                  'assets/images/menu-icon.svg'),
                            );
                          }),
                        ),
                        Positioned(
                          top: 35,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 3),
                                  child: TabBar(
                                    // controller: tabController,
                                    indicator: BoxDecoration(
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
                                    isScrollable: true,
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    labelColor: whiteColor,
                                    labelStyle: TextStyle(
                                      color: whiteColor,
                                      fontSize: 14,
                                      fontFamily: 'Syne-Medium',
                                    ),
                                    unselectedLabelColor:
                                        const Color(0xFF929292),
                                    unselectedLabelStyle: const TextStyle(
                                      color: Color(0xFF929292),
                                      fontSize: 14,
                                      fontFamily: 'Syne-Regular',
                                    ),
                                    tabs: const [
                                      Tab(text: "    New    "),
                                      Tab(text: "In Progress"),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                color: transparentColor,
                                width: double.maxFinite,
                                height: MediaQuery.of(context).size.height,
                                child: TabBarView(
                                  // controller: tabController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    NewScreen(),
                                    InProgressHomeScreen(
                                      singleData: widget.singleData,
                                      passCode: widget.passCode,
                                      multipleData: widget.multipleData,
                                      currentBookingId: widget.currentBookingId,
                                      riderData: widget.riderData,
                                      bookingDestinationId:
                                          widget.bookingDestinationId,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : DefaultTabController(
                  length: 2,
                  initialIndex: widget.index ?? 0,
                  child: Scaffold(
                    backgroundColor: bgColor,
                    drawer: AppDrawer(
                      singleData: widget.singleData,
                      passCode: widget.passCode,
                      multipleData: widget.multipleData,
                      currentBookingId: widget.currentBookingId,
                      riderData: widget.riderData,
                      bookingDestinationId: widget.bookingDestinationId,
                    ),
                    body: Stack(
                      children: [
                        Positioned(
                          top: 40,
                          left: 20,
                          child: Builder(builder: (context) {
                            return GestureDetector(
                              onTap: () {
                                Scaffold.of(context).openDrawer();
                              },
                              child: SvgPicture.asset(
                                  'assets/images/menu-icon.svg'),
                            );
                          }),
                        ),
                        Positioned(
                          top: 35,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 3),
                                  child: TabBar(
                                    // controller: tabController,
                                    indicator: BoxDecoration(
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
                                    isScrollable: true,
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    labelColor: whiteColor,
                                    labelStyle: TextStyle(
                                      color: whiteColor,
                                      fontSize: 14,
                                      fontFamily: 'Syne-Medium',
                                    ),
                                    unselectedLabelColor:
                                        const Color(0xFF929292),
                                    unselectedLabelStyle: const TextStyle(
                                      color: Color(0xFF929292),
                                      fontSize: 14,
                                      fontFamily: 'Syne-Regular',
                                    ),
                                    tabs: const [
                                      Tab(text: "    New    "),
                                      Tab(text: "In Progress"),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                color: transparentColor,
                                width: double.maxFinite,
                                height: MediaQuery.of(context).size.height,
                                child: TabBarView(
                                  // controller: tabController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    NewScreen(),
                                    InProgressOffRoute(
                                      singleData: widget.singleData,
                                      passCode: widget.passCode,
                                      multipleData: widget.multipleData,
                                      currentBookingId: widget.currentBookingId,
                                      riderData: widget.riderData,
                                      bookingDestinationId:
                                          widget.bookingDestinationId,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
    );
  }
}
