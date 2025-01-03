// ignore_for_file: use_build_context_synchronously

import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:deliver_client/screens/home/drawer/support/newSupport.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:deliver_client/widgets/orderTracking.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/get_profile_model.dart';
import 'package:deliver_client/screens/login/login_screen.dart';
import 'package:deliver_client/models/get_support_admin_model.dart';
import 'package:deliver_client/screens/home/drawer/legal_screen.dart';
import 'package:deliver_client/screens/home/drawer/profile/profile_screen.dart';
import 'package:deliver_client/screens/home/drawer/support/support_screen.dart';
import 'package:deliver_client/screens/home/drawer/update_location_screen.dart';
import 'package:deliver_client/screens/home/drawer/settings/settings_screen.dart';
import 'package:deliver_client/screens/home/drawer/address/drawer_address_screen.dart';
import 'package:deliver_client/screens/home/drawer/ride_history/ride_history_screen.dart';
import 'package:deliver_client/screens/home/drawer/scheduled_ride/scheduled_ride_screen.dart';

String? userId;
String? firstName;
String? lastName;
String? profilePic;

class AppDrawer extends StatefulWidget {
  final int? index;
  final Map? singleData;
  final Map? multipleData;
  final String? passCode;
  final String? currentBookingId;
  final UpdateBookingStatusModel? riderData;
  final String? bookingDestinationId;

  const AppDrawer({
    super.key,
    this.index,
    this.singleData,
    this.multipleData,
    this.passCode,
    this.currentBookingId,
    this.riderData,
    this.bookingDestinationId,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  sharedPrefs() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('userId');
    firstName = sharedPref.getString('firstName');
    lastName = sharedPref.getString('lastName');
    profilePic = sharedPref.getString('profilePic');
    debugPrint('sharedPrefs userId: $userId');
    debugPrint('sharedPrefs firstName: $firstName');
    debugPrint('sharedPrefs lastName: $lastName');
    debugPrint('sharedPrefs profilePic: $profilePic');
    setState(() {});
  }

  GetProfileModel getProfileModel = GetProfileModel();

  getProfile() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/get_profile_customers";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("userId: $userId");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "users_customers_id": userId,
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getProfileModel = getProfileModelFromJson(responseString);
        setState(() {});
        debugPrint('getProfileModel status: ${getProfileModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  String? getAdminId;
  String? getAdminName;
  String? getAdminImage;
  String? getAdminAddress;

  GetSupportAdminModel getSupportAdminModel = GetSupportAdminModel();

  getSupportAdmin() async {
    try {
      String apiUrl = "$baseUrl/get_admin_list";
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
        getSupportAdminModel = getSupportAdminModelFromJson(responseString);
        setState(() {});
        debugPrint(
            'getSupportAdminModel status: ${getSupportAdminModel.status}');
        debugPrint(
            'getSupportAdminModel length: ${getSupportAdminModel.data!.length}');
        for (int i = 0; i < getSupportAdminModel.data!.length; i++) {
          getAdminId = "${getSupportAdminModel.data![0].usersSystemId}";
          getAdminName = "${getSupportAdminModel.data![0].name}";
          getAdminImage = "${getSupportAdminModel.data![0].profilePic}";
          getAdminAddress = "${getSupportAdminModel.data![0].address}";
        }
        debugPrint('getAdminId: $getAdminId');
        debugPrint('getAdminName: $getAdminName');
        debugPrint('getAdminImage: $getAdminImage');
        debugPrint('getAdminAddress: $getAdminAddress');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  removeDataFormSharedPreferences() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.clear();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // getProfile();
    sharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
        color: transparentColor,
        width: size.width * 0.7,
        child:
            // getProfileModel.data != null
            //     ?
            Drawer(
          backgroundColor: whiteColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.04),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset('assets/images/back-icon.svg'),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      color: transparentColor,
                      width: 120,
                      height: 120,
                      child: profilePic != null &&
                          profilePic!.isNotEmpty
                          ? FadeInImage(
                        placeholder: const AssetImage("assets/images/user-profile.png"),
                        image: NetworkImage(
                          '$imageUrl$profilePic',
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
                      //     '$imageUrl$profilePic',
                      //   ),
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    '$firstName $lastName',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: drawerTextColor,
                      fontSize: 14,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Container(
                    color: transparentColor,
                    height: size.height * 0.7,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        buildMenuItem(
                          title: 'Profile',
                          image: 'assets/images/drawer-profile-icon.svg',
                          onTap: () {
                            selectedItem(context, 0);
                          },
                        ),
                        buildMenuItem(
                          title: 'Ride History',
                          image: 'assets/images/drawer-history-icon.svg',
                          onTap: () {
                            selectedItem(context, 1);
                          },
                        ),
                        buildMenuItem(
                          title: 'Scheduled Rides',
                          image: 'assets/images/drawer-history-icon.svg',
                          onTap: () {
                            selectedItem(context, 2);
                          },
                        ),
                        buildMenuItem(
                          title: 'Addresses',
                          image: 'assets/images/drawer-address-icon.svg',
                          onTap: () {
                            selectedItem(context, 3);
                          },
                        ),
                        buildMenuItem(
                          title: 'Tracking',
                          image: 'assets/images/drawer-address-icon.svg',
                          onTap: () {
                            selectedItem(context, 10);
                          },
                        ),
                        buildMenuItem(
                          title: 'Update Location',
                          image:
                              'assets/images/drawer-update-location-icon.svg',
                          onTap: () {
                            selectedItem(context, 4);
                          },
                        ),
                        buildMenuItem(
                          title: 'Settings',
                          image: 'assets/images/drawer-setting-icon.svg',
                          onTap: () {
                            selectedItem(context, 5);
                          },
                        ),
                        // buildMenuItem(
                        //   title: 'Payment',
                        //   image: 'assets/images/drawer-payment-icon.svg',
                        //   onTap: () {
                        //     selectedItem(context, 6);
                        //   },
                        // ),
                        buildMenuItem(
                          title: 'Loyalty Points',
                          image: 'assets/images/drawer-points-icon.svg',
                          onTap: () {
                            selectedItem(context, 6);
                          },
                        ),
                        buildMenuItem(
                          title: 'Support',
                          image: 'assets/images/drawer-support-icon.svg',
                          onTap: () async {
                            await getSupportAdmin();
                            selectedItem(context, 7);
                          },
                        ),
                        buildMenuItem(
                          title: 'Legal',
                          image: 'assets/images/drawer-legal-icon.svg',
                          onTap: () {
                            selectedItem(context, 8);
                          },
                        ),
                        // SizedBox(height: size.height * 0.04),
                        buildMenuItem(
                          title: 'Logout',
                          image: 'assets/images/drawer-logout-icon.svg',
                          onTap: () {
                            selectedItem(context, 9);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        // : Drawer(
        //     backgroundColor: whiteColor,
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(horizontal: 20),
        //       child: SingleChildScrollView(
        //         child: Column(
        //           children: [
        //             SizedBox(height: size.height * 0.04),
        //             Align(
        //               alignment: Alignment.centerLeft,
        //               child: GestureDetector(
        //                 onTap: () {
        //                   Navigator.pop(context);
        //                 },
        //                 child:
        //                     SvgPicture.asset('assets/images/back-icon.svg'),
        //               ),
        //             ),
        //             SizedBox(height: size.height * 0.03),
        //             ClipRRect(
        //               borderRadius: BorderRadius.circular(10),
        //               child: Container(
        //                 color: transparentColor,
        //                 width: 120,
        //                 height: 120,
        //                 child: Image.asset(
        //                   "assets/images/user-profile.png",
        //                   fit: BoxFit.cover,
        //                 ),
        //               ),
        //             ),
        //             SizedBox(height: size.height * 0.02),
        //             Text(
        //               '',
        //               textAlign: TextAlign.center,
        //               style: TextStyle(
        //                 color: drawerTextColor,
        //                 fontSize: 14,
        //                 fontFamily: 'Syne-Bold',
        //               ),
        //             ),
        //             SizedBox(height: size.height * 0.02),
        //             Container(
        //               color: transparentColor,
        //               height: size.height * 0.705,
        //               child: ListView(
        //                 physics: const NeverScrollableScrollPhysics(),
        //                 scrollDirection: Axis.vertical,
        //                 children: [
        //                   buildMenuItem(
        //                     title: 'Profile',
        //                     image: 'assets/images/drawer-profile-icon.svg',
        //                     onTap: () {
        //                       selectedItem(context, 0);
        //                     },
        //                   ),
        //                   buildMenuItem(
        //                     title: 'Ride History',
        //                     image: 'assets/images/drawer-history-icon.svg',
        //                     onTap: () {
        //                       selectedItem(context, 1);
        //                     },
        //                   ),
        //                   buildMenuItem(
        //                     title: 'Scheduled Rides',
        //                     image: 'assets/images/drawer-history-icon.svg',
        //                     onTap: () {
        //                       selectedItem(context, 2);
        //                     },
        //                   ),
        //                   buildMenuItem(
        //                     title: 'Addresses',
        //                     image: 'assets/images/drawer-address-icon.svg',
        //                     onTap: () {
        //                       selectedItem(context, 3);
        //                     },
        //                   ),
        //                   buildMenuItem(
        //                     title: 'Update Location',
        //                     image:
        //                         'assets/images/drawer-update-location-icon.svg',
        //                     onTap: () {},
        //                   ),
        //                   buildMenuItem(
        //                     title: 'Settings',
        //                     image: 'assets/images/drawer-setting-icon.svg',
        //                     onTap: () {
        //                       selectedItem(context, 5);
        //                     },
        //                   ),
        //                   // buildMenuItem(
        //                   //   title: 'Payment',
        //                   //   image: 'assets/images/drawer-payment-icon.svg',
        //                   //   onTap: () {
        //                   //     selectedItem(context, 6);
        //                   //   },
        //                   // ),
        //                   buildMenuItem(
        //                     title: 'Loyalty Points',
        //                     image: 'assets/images/drawer-points-icon.svg',
        //                     onTap: () {
        //                       selectedItem(context, 6);
        //                     },
        //                   ),
        //                   buildMenuItem(
        //                     title: 'Support',
        //                     image: 'assets/images/drawer-support-icon.svg',
        //                     onTap: () {},
        //                   ),
        //                   buildMenuItem(
        //                     title: 'Legal',
        //                     image: 'assets/images/drawer-legal-icon.svg',
        //                     onTap: () {
        //                       selectedItem(context, 8);
        //                     },
        //                   ),
        //                   // SizedBox(height: size.height * 0.04),
        //                   buildMenuItem(
        //                     title: 'Logout',
        //                     image: 'assets/images/drawer-logout-icon.svg',
        //                     onTap: () {
        //                       selectedItem(context, 9);
        //                     },
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        );
  }

  Widget buildMenuItem({
    required String title,
    required String image,
    VoidCallback? onTap,
  }) {
    final hoverColor = transparentColor;

    return ListTile(
      leading: SvgPicture.asset(image),
      title: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: drawerTextColor,
          fontSize: 16,
          fontFamily: 'Syne-Medium',
        ),
      ),
      hoverColor: hoverColor,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
      onTap: onTap,
    );
  }

  selectedItem(BuildContext context, int index) {
    Navigator.pop(context);

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideHistoryScreen(
              singleData: widget.singleData,
              passCode: widget.passCode,
              multipleData: widget.multipleData,
              currentBookingId: widget.currentBookingId,
              riderData: widget.riderData,
              bookingDestinationId: widget.bookingDestinationId,
            ),
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ScheduledRideScreen(),
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DrawerAddressScreen(),
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UpdateLocationScreen(),
          ),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
        break;
      // case 6:
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => const PaymentScreen(),
      //     ),
      //   );
      //   break;
      case 6:
        CustomToast.showToast(
          fontSize: 12,
          message: "This feature is not yet available. Coming soon",
        );
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const LoyaltyPointScreen(),
        //   ),
        // );
        break;
      case 7:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewSupportPage(
              getAdminId: getAdminId,
              getAdminName: getAdminName,
              getAdminImage: getAdminImage,
              getAdminAddress: getAdminAddress,
            ),
          ),
        );
        break;
      case 8:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LegalScreen(),
          ),
        );
        break;
      case 9:
        removeDataFormSharedPreferences();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false);
        break;
      case 10:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OrderTrackingScreen(),
          ),
        );
        break;
    }
  }
}
