// ignore_for_file: use_build_context_synchronously

import 'dart:math' as math;
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
  final Map? multipleData;
  const SearchRidersScreen({super.key, this.singleData, this.multipleData});

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
      String apiUrl = "$baseUrl/get_riders_reachable";
      debugPrint("apiUrl: $apiUrl");
      debugPrint(
          "vehiclesId: ${widget.singleData!.isNotEmpty ? widget.singleData!["vehicles_id"] : widget.multipleData!["vehicles_id"]}");
      debugPrint(
          "pickup_address11111: ${widget.singleData!.isNotEmpty ? widget.singleData!["pickup_address"] : widget.multipleData!["pickup_address"]}");
      debugPrint(
          "pickupLongitude: ${widget.singleData!.isNotEmpty ? widget.singleData!["pickup_longitude"] : widget.multipleData!["pickup_longitude0"]}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "vehicles_id": widget.singleData!.isNotEmpty
              ? widget.singleData!["vehicles_id"]
              : widget.multipleData!["vehicles_id"].toString(),
          "pickup_address": widget.singleData!.isNotEmpty
              ? widget.singleData!["pickup_address"]
              : widget.multipleData!["pickup_address"].toString(),
        },
      );
      final responseString = response.body;
      var data = jsonDecode(responseString);
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (data["status"] == "success") {
        if (response.statusCode == 200) {
          searchRiderModel = searchRiderModelFromJson(responseString);
          debugPrint('searchRiderModel status: ${searchRiderModel.status}');
          await radiusFider();
          debugPrint(
              'searchRiderModel length: ${searchRiderModel.data!.length}');

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
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  List<SearchRiderData>? filteredRiders;
  radiusFider() {
    // Assuming you have parsed the JSON response into a list of rider objects
    // Assuming you have parsed the JSON response into a SearchRiderModel object
    // Given location coordinates and radius
    double? givenLatitude; // Latitude of the given location
    double? givenLongitude; // Longitude of the given location
    double radiusThreshold =
        double.parse(userRadius ?? '0'); // Radius in kilometers
    double degreesToRadians(double degrees) {
      return degrees * (math.pi / 180);
    }

    double calculateDistanceInKm(
        double lat1, double lon1, double lat2, double lon2) {
      const int earthRadius = 6371; // Radius of the Earth in kilometers

      double dLat = degreesToRadians(lat2 - lat1);
      double dLon = degreesToRadians(lon2 - lon1);

      double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(degreesToRadians(lat1)) *
              math.cos(degreesToRadians(lat2)) *
              math.sin(dLon / 2) *
              math.sin(dLon / 2);
      double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      double distance = earthRadius * c;

      return distance;
    }

// Extract latitude and longitude from pickup_longitude and pickup_latitude
    if (widget.singleData!.isNotEmpty) {
      givenLatitude = double.parse(widget.singleData!["pickup_latitude"]);
      givenLongitude = double.parse(widget.singleData!["pickup_longitude"]);
    } else if (widget.multipleData!.isNotEmpty) {
      givenLatitude = double.parse(widget.multipleData!["pickup_latitude"]);
      givenLongitude = double.parse(widget.multipleData!["pickup_longitude0"]);
    }

// Filter riders within the specified radius
    filteredRiders = searchRiderModel.data!.where((rider) {
      double riderLatitude = double.parse(rider.latitude!);
      double riderLongitude = double.parse(rider.longitude!);
      double distance = double.parse(rider.distance!);

      // Calculate distance between given location and rider's location
      double distanceInKm = calculateDistanceInKm(
          givenLatitude!, givenLongitude!, riderLatitude, riderLongitude);

      // Check if the rider is within the radius
      return distanceInKm <= radiusThreshold;
    }).toList();
    debugPrint('filteredRiders length: $filteredRiders');
    for (var rider in filteredRiders!) {
      print('users_fleet_id: ${rider.usersFleetId}');
      print('name: ${rider.firstName}');
      print('one_signal_id: ${rider.oneSignalId}');
      print('user_type: ${rider.userType}');
      // Print other attributes as needed
    }
  }

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

  getAllSystemData() async {
    try {
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
        await searchRider();
        getAllSystemDataModel = getAllSystemDataModelFromJson(responseString);
        debugPrint(
            'getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        debugPrint(
            'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "user_radius") {
            userRadius = "${getAllSystemDataModel.data?[i].description}";
            debugPrint("userRadius: $userRadius");
          }
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
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
    debugPrint('singleData: ${widget.singleData}');
    debugPrint('multipleData: ${widget.multipleData}');
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
            actions: [
              InkWell(
                onTap: () async {
                  await searchRider();
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(
                    Icons.refresh,
                    color: blackColor,
                    size: 22,
                  ),
                ),
              ),
            ],
            centerTitle: true,
          ),
          body: isLoading == true
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
                                          itemCount: filteredRiders!
                                              .length, // Use filteredRiders length
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            debugPrint(
                                                "length: ${filteredRiders!.length}");
                                            return RidersList(
                                              singleData:
                                                  widget.singleData!.isNotEmpty
                                                      ? widget.singleData
                                                      : const {},
                                              multipleData: widget
                                                      .multipleData!.isNotEmpty
                                                  ? widget.multipleData
                                                  : const {},
                                              searchRider: filteredRiders![
                                                  index], // Use filteredRiders
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
