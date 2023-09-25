// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/get_addresses_model.dart';
import 'package:deliver_client/models/delete_address_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

String? userId;

class FirstAddressScreen extends StatefulWidget {
  const FirstAddressScreen({super.key});

  @override
  State<FirstAddressScreen> createState() => _FirstAddressScreenState();
}

class _FirstAddressScreenState extends State<FirstAddressScreen> {
  bool isLoading = false;

  GetAddressesModel getAddressesModel = GetAddressesModel();

  getAddresses() async {
    try {
      setState(() {
        isLoading = true;
      });
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/get_addresses_customers";
      print("apiUrl: $apiUrl");
      print("userId: $userId");
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
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getAddressesModel = getAddressesModelFromJson(responseString);
        print('getAddressesModel status: ${getAddressesModel.status}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      setState(() {
        isLoading = false;
      });
      return null;
    }
  }

  DeleteAddressModel deleteAddressModel = DeleteAddressModel();

  deleteAddress(int? addressesId) async {
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$baseUrl/delete_address_customers";
      print("apiUrl: $apiUrl");
      print("addressesId: $addressesId");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "users_customers_addresses_id": addressesId.toString(),
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        deleteAddressModel = deleteAddressModelFromJson(responseString);
        print('deleteAddressModel status: ${deleteAddressModel.status}');
        setState(() {
          isLoading = false;
          getAddresses();
        });
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getAddresses();
  }

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
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            "Addresses",
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
            SizedBox(height: size.height * 0.02),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                color: transparentColor,
                height: size.height * 0.75,
                child: isLoading
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
                    : getAddressesModel.data != null
                        ? ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: getAddressesModel.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  Card(
                                    color: whiteColor,
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                                height: size.height * 0.02),
                                            Container(
                                              color: transparentColor,
                                              width: size.width * 0.65,
                                              child: Tooltip(
                                                message:
                                                    "${getAddressesModel.data![index].name}",
                                                child: Text(
                                                  "${getAddressesModel.data![index].name}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 16,
                                                    fontFamily: 'Syne-Bold',
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Container(
                                              color: transparentColor,
                                              width: size.width * 0.65,
                                              child: Tooltip(
                                                message:
                                                    "${getAddressesModel.data![index].address}",
                                                child: Text(
                                                  "${getAddressesModel.data![index].address}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 16,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.02),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (context) =>
                                                    deleteConformation(
                                                        getAddressesModel
                                                            .data![index]
                                                            .usersCustomersAddressesId));
                                          },
                                          child: Container(
                                            color: transparentColor,
                                            width: size.width * 0.055,
                                            height: size.height * 0.06,
                                            child: SvgPicture.asset(
                                              'assets/images/delete-icon.svg',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                ],
                              );
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/no-address-icon.svg',
                                  width: size.width * 0.3,
                                  height: size.height * 0.2,
                                ),
                                SizedBox(height: size.height * 0.03),
                                Text(
                                  "No Address Saved",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textHaveAccountColor,
                                    fontSize: 24,
                                    fontFamily: 'Syne-SemiBold',
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const HomePageScreen()),
                    (Route<dynamic> route) => false);
              },
              child: buttonGradient("Next", context),
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }

  Widget deleteConformation(int? index) {
    var size = MediaQuery.of(context).size;
    return StatefulBuilder(
      builder: (context, setState) => WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          insetPadding: const EdgeInsets.only(left: 20, right: 20),
          child: SizedBox(
            height: size.height * 0.3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: size.height * 0.01),
                  Text(
                    'Delete Address?'.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: orangeColor,
                      fontSize: 20,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  Text(
                    'Are you sure you want to delete this address?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 16,
                      fontFamily: 'Syne-Regular',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: dialogButtonTransparentGradientSmall(
                            'Cancel', context),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await deleteAddress(index);
                          if (deleteAddressModel.status == 'success') {
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: dialogButtonGradientSmall('Delete', context),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.01),
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
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:deliver_client/screens/home/home_page_screen.dart';

// class FirstAddressScreen extends StatefulWidget {
//   const FirstAddressScreen({super.key});

//   @override
//   State<FirstAddressScreen> createState() => _FirstAddressScreenState();
// }

// class _FirstAddressScreenState extends State<FirstAddressScreen> {
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         backgroundColor: bgColor,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         automaticallyImplyLeading: false,
//         title: Text(
//           "Addresses",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: blackColor,
//             fontSize: 20,
//             fontFamily: 'Syne-Bold',
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: size.height * 0.02),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Container(
//               color: transparentColor,
//               height: size.height * 0.75,
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Column(
//                   children: [
//                     Card(
//                       color: whiteColor,
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: size.height * 0.02),
//                               Container(
//                                 color: transparentColor,
//                                 width: size.width * 0.65,
//                                 child: AutoSizeText(
//                                   "Home",
//                                   textAlign: TextAlign.left,
//                                   style: TextStyle(
//                                     color: blackColor,
//                                     fontSize: 16,
//                                     fontFamily: 'Syne-Bold',
//                                   ),
//                                   minFontSize: 16,
//                                   maxFontSize: 16,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.01),
//                               Container(
//                                 color: transparentColor,
//                                 width: size.width * 0.65,
//                                 child: AutoSizeText(
//                                   "Lorem ipsum dolor sit amet, consete",
//                                   textAlign: TextAlign.left,
//                                   style: TextStyle(
//                                     color: blackColor,
//                                     fontSize: 16,
//                                     fontFamily: 'Syne-Regular',
//                                   ),
//                                   minFontSize: 16,
//                                   maxFontSize: 16,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               SizedBox(height: size.height * 0.02),
//                             ],
//                           ),
//                           SvgPicture.asset('assets/images/delete-icon.svg'),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const Spacer(),
//           GestureDetector(
//             onTap: () {
//               Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                       builder: (context) => const HomePageScreen()),
//                   (Route<dynamic> route) => false);
//             },
//             child: buttonGradient("NEXT", context),
//           ),
//           SizedBox(height: size.height * 0.03),
//         ],
//       ),
//     );
//   }
// }
