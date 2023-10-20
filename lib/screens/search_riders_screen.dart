// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/widgets/search_rider_listview.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';

class SearchRidersScreen extends StatefulWidget {
  final Map? singleData;

  const SearchRidersScreen({super.key, this.singleData});

  @override
  State<SearchRidersScreen> createState() => _SearchRidersScreenState();
}

class _SearchRidersScreenState extends State<SearchRidersScreen> {
  String? userRadius;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];

  SearchRiderModel searchRiderModel = SearchRiderModel();

  searchRider() async {
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$baseUrl/get_riders_available";
      print("apiUrl: $apiUrl");
      print("vehiclesId: ${widget.singleData?["vehicles_id"]}");
      print("pickupLatitude: ${widget.singleData?["pickup_latitude"]}");
      print("pickupLongitude: ${widget.singleData?["pickup_longitude"]}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "pickup_latitude": widget.singleData?["pickup_latitude"],
          "pickup_longitude": widget.singleData?["pickup_longitude"],
          "vehicles_id": widget.singleData?["vehicles_id"],
        },
      );
      final responseString = response.body;
      var data = jsonDecode(responseString);
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (data["status"] == "success") {
        if (response.statusCode == 200) {
          searchRiderModel = searchRiderModelFromJson(responseString);
          print('searchRiderModel status: ${searchRiderModel.status}');
          print('searchRiderModel length: ${searchRiderModel.data!.length}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

  getAllSystemData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$baseUrl/get_all_system_data";
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
        getAllSystemDataModel = getAllSystemDataModelFromJson(responseString);
        print('getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        print(
            'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "user_radius") {
            userRadius = "${getAllSystemDataModel.data?[i].description}";
            print("userRadius: $userRadius");
          }
        }
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

// Create a function to check if riders are within the radius
  bool areRidersWithinRadius(String? userRadius, double radiusThreshold) {
    if (userRadius != null) {
      double parsedRadius = double.tryParse(userRadius) ??
          0.0; // Parse the userRadius to a double
      return parsedRadius <= radiusThreshold;
    }
    return false; // Handle cases where userRadius is null
  }

  @override
  initState() {
    super.initState();
    searchRider();
    getAllSystemData();
    // print('singleData: ${widget.singleData}');
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/home-location-background.png'),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.5, 1],
            colors: [
              bgColor,
              bgColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: transparentColor,
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
            title: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text(
                "Searching for Ride",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blackColor,
                  fontSize: 20,
                  fontFamily: 'Syne-Bold',
                ),
              ),
            ),
            centerTitle: true,
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
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 120),
                        child: searchRiderModel.data != null
                            ? areRidersWithinRadius(userRadius, 10.0)
                                ? Container(
                                    color: transparentColor,
                                    height: size.height * 0.48,
                                    child: Stack(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/searching_circle-icon.svg',
                                        ),
                                        ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              searchRiderModel.data?.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            print(
                                                "length: ${searchRiderModel.data?.length}");
                                            return RidersList(
                                              singleData: widget.singleData,
                                              searchRider:
                                                  searchRiderModel.data?[index],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    color: transparentColor,
                                    height: size.height * 0.48,
                                    child: Stack(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/searching_circle-icon.svg',
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Text(
                                            "No Riders Available",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 24,
                                              fontFamily: 'Syne-SemiBold',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                            : Container(
                                color: transparentColor,
                                height: size.height * 0.48,
                                child: Stack(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/searching_circle-icon.svg',
                                    ),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      bottom: 0,
                                      child: Text(
                                        "No Riders Available",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 24,
                                          fontFamily: 'Syne-SemiBold',
                                        ),
                                      ),
                                    ),
                                  ],
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
                        child: buttonGradient("CANCEL", context),
                      ),
                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
