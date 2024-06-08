// ignore_for_file: use_build_context_synchronously

import 'dart:math' as math;
import 'dart:convert';
import 'package:deliver_client/models/create_booking_model.dart';
import 'package:deliver_client/models/schedule_booking_model.dart';
import 'package:deliver_client/screens/waitingForRiders.dart';
// import 'package:deliver_client/screens/home/tabbar_items/new_screen.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/widgets/search_rider_listview.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  double? radiusThreshold;
  SearchRiderModel searchRiderModel = SearchRiderModel();
  void showToastError(
    String? msg,
    FToast fToast, {
    Color toastColor = Colors.white,
    int seconds = 2,
    double fontSize = 16.0,
  }) {
    final Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(15.0),
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.75),
            Colors.orange.withOpacity(0.75),
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
      child: Text(
        msg ?? '',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(seconds: seconds),
    );
  }

  /// Location permission methods for longitude and latitude:
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         )));
      showToastError(
          'Location services are disabled. Please enable the services',
          FToast().init(context),
          seconds: 4);
      setState(() {
        isLoading = false;
      });
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('Location permissions are denied')));
        showToastError(
            'Location permissions are denied', FToast().init(context),
            seconds: 4);
        setState(() {
          isLoading = false;
        });
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //     content: Text(
      //         )));
      showToastError(
          'Location permissions are permanently denied, Enable it from app permission',
          FToast().init(context),
          seconds: 4);
      setState(() {
        isLoading = false;
      });
      return false;
    }
    return true;
  }

  var hasPermission = false;
  Position? _currentPosition;
  String? currentLat;
  String? currentLng;
  LatLng? currentLocation;
  LatLng? selectedLocation;
  LatLng? selectedAddressLocation;
  Future<void> getCurrentLocation() async {
    hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 5),
      forceAndroidLocationManager: true,
    );

    final List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      final Placemark currentPlace = placemarks.first;
      final String currentAddress =
          "${currentPlace.name}, ${currentPlace.locality}, ${currentPlace.country}";

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation = null; // Clear selected location
        selectedAddressLocation = null; // Clear address location
        currentLat = position.latitude.toString();
        currentLng = position.longitude.toString();
        debugPrint("currentLat: $currentLat");
        debugPrint("currentLng: $currentLng");
        debugPrint("currentPickupLocation: $currentAddress");
      });
    }
  }

  double? distanceInMeters;
  Future<void> searchRider() async {
    // try {
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
    if (response.statusCode == 200) {
      searchRiderModel = searchRiderModelFromJson(responseString);
      debugPrint('searchRiderModel status: ${searchRiderModel.status}');
      debugPrint('searchRiderModel length: ${searchRiderModel.data!.length}');
      radiusThreshold = double.parse(userRadius ?? '0'); // Radius in kilometers
      await getCurrentLocation();
      givenLatitude = double.parse(currentLat!);
      givenLongitude = double.parse(currentLng!);
      print(
          'Given Latitude of Multiple: $givenLatitude, Given Longitude of Multiple: $givenLongitude');

      print('Radius threshold: $radiusThreshold km');
      List<SearchRiderData> ridersWithinRadius =
          searchRiderModel.data!.where((rider) {
        String RiderName = rider.firstName!;
        double riderLatitude = double.parse(rider.latitude!);
        double riderLongitude = double.parse(rider.longitude!);
        distanceInKm = calculateDistanceInKm(
            givenLatitude!, givenLongitude!, riderLatitude, riderLongitude);

        print('Rider coordinates: ($riderLatitude, $riderLongitude)');
        print('Rider Name: $RiderName');
        print('Distance to rider: $distanceInKm km');
        distanceInMeters = distanceInKm! * 1000;
        print('Distance to rider: $distanceInMeters m');

        return distanceInKm! <= radiusThreshold!;
      }).toList();

      if (ridersWithinRadius.isEmpty) {
        setState(() {
          isLoading = false;
        });
        CustomToast.showToast(
            message:
                "No riders found within the radius of $radiusThreshold km");
        return;
      }

      // ... rest of your code ...
      print("ridersWithinRadius: $ridersWithinRadius");
      bookingsFleet = ridersWithinRadius.map((rider) {
        return {
          "users_fleet_id": rider.usersFleetId.toString(),
          "vehicles_id": widget.singleData!.isNotEmpty
              ? widget.singleData!["vehicles_id"].toString()
              : widget.multipleData!["vehicles_id"].toString(),
        };
      }).toList();
      print("bookingsFleet: $bookingsFleet");

      if (widget.singleData!.isNotEmpty) {
        if (widget.singleData!["type"] == "booking") {
          await createBooking();
          if (createBookingModel.status == "success") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WaitingForRiders(
                  distance: distanceInKm,
                  singleData: widget.singleData,
                  multipleData: widget.multipleData,
                  currentBookingId:
                      createBookingModel.data!.bookingsId.toString(),
                  bookingDestinationId: createBookingModel
                      .data?.bookingsFleet?[0].bookingsDestinationsId
                      .toString(),
                ),
              ),
            );
          }
        } else if (widget.singleData!["type"] == "schedule") {
          await scheduleBooking();
          if (scheduleBookingModel.status == "success") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePageScreen(index: 0
                    // distance: distanceInMeters,
                    // singleData: widget.singleData,
                    // multipleData: widget.multipleData,
                    // currentBookingId:
                    //     scheduleBookingModel.data!.bookingsId.toString(),
                    // bookingDestinationId: scheduleBookingModel
                    //     .data?.bookingsFleet?[0].bookingsDestinationsId
                    //     .toString(),
                    ),
              ),
            );
            CustomToast.showToast(
              fontSize: 12,
              message: "You Successfully Book a Single Schedule Ride",
            );
          }
        }
      } else if (widget.multipleData!.isNotEmpty) {
        if (widget.multipleData!["type"] == "booking") {
          await createBooking();
          if (createBookingModel.status == "success") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WaitingForRiders(
                  distance: distanceInKm,
                  singleData: widget.singleData,
                  multipleData: widget.multipleData,
                  currentBookingId:
                      createBookingModel.data!.bookingsId.toString(),
                  bookingDestinationId: createBookingModel
                      .data?.bookingsFleet?[0].bookingsDestinationsId
                      .toString(),
                ),
              ),
            );
          }
        } else if (widget.multipleData!["type"] == "schedule") {
          await scheduleBooking();
          if (scheduleBookingModel.status == "success") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePageScreen(index: 0),
              ),
            );
            CustomToast.showToast(
              fontSize: 12,
              message: "You Successfully Book a Multiple Schedule Ride",
            );
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    }
    // } else {
    //   searchRiderModel = searchRiderModelFromJson(responseString);

    //   CustomToast.showToast(message: "Something went Wrong");
    //   setState(() {
    //     isLoading = false;
    //   });
    // }
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  double calculateDistanceInKm(
      double lat1, double lon1, double lat2, double lon2) {
    const int earthRadius = 6371; // Radius of the Earth in kilometers

    double degreesToRadians(double degrees) {
      return degrees * (math.pi / 180);
    }

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

  List<Map<String, String>>? bookingsFleet;
  double? givenLatitude; // Latitude of the given location
  double? givenLongitude;
  List<double> distanceRider = [];
  double? distanceInKm;
  List<SearchRiderData>? filteredRiders;
//   radiusFinder() {
//     double radiusThreshold =
//         double.parse(userRadius ?? '0'); // Radius in kilometers
//     double degreesToRadians(double degrees) {
//       return degrees * (math.pi / 180);
//     }

//     double calculateDistanceInKm(
//         double lat1, double lon1, double lat2, double lon2) {
//       const int earthRadius = 6371; // Radius of the Earth in kilometers

//       double dLat = degreesToRadians(lat2 - lat1);
//       double dLon = degreesToRadians(lon2 - lon1);

//       double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
//           math.cos(degreesToRadians(lat1)) *
//               math.cos(degreesToRadians(lat2)) *
//               math.sin(dLon / 2) *
//               math.sin(dLon / 2);
//       double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//       double distance = earthRadius * c;

//       return distance;
//     }

// // Extract latitude and longitude from pickup_longitude and pickup_latitude
//     if (widget.singleData!.isNotEmpty) {
//       givenLatitude = double.parse(widget.singleData!["pickup_latitude"]);
//       givenLongitude = double.parse(widget.singleData!["pickup_longitude"]);
//     } else if (widget.multipleData!.isNotEmpty) {
//       givenLatitude = double.parse(widget.multipleData!["pickup_latitude0"]);
//       givenLongitude = double.parse(widget.multipleData!["pickup_longitude0"]);
//       print(
//           'Given Latitude of Multiple: $givenLatitude, Given Longitude of Multiple: $givenLongitude');
//     }

// // Filter riders within the specified radius
//     filteredRiders = searchRiderModel.data!.where((rider) {
//       double riderLatitude = double.parse(rider.latitude!);
//       double riderLongitude = double.parse(rider.longitude!);
//       debugPrint(
//           'Given Latitude: $givenLatitude, Given Longitude: $givenLongitude');
//       debugPrint(
//           'Rider Latitude: $riderLatitude, Rider Longitude: $riderLongitude');
//       // double distance = double.parse(rider.distance!);

//       // Calculate distance between given location and rider's location
//       distanceInKm = calculateDistanceInKm(
//           givenLatitude!, givenLongitude!, riderLatitude, riderLongitude);
//       debugPrint('Calculated distance: $distanceInKm');
//       debugPrint('Radius Threshold: $radiusThreshold');
//       distanceRider.add(distanceInKm!);
//       print("distanceRider: $distanceRider");
//       // Check if the rider is within the radius
//       return distanceInKm! <= radiusThreshold;
//     }).toList();
//     debugPrint('filteredRiders length: $filteredRiders');

//     for (var rider in filteredRiders!) {
//       print('users_fleet_id: ${rider.usersFleetId}');
//       print('name: ${rider.firstName}');
//       print('one_signal_id: ${rider.oneSignalId}');
//       print('user_type: ${rider.userType}');
//       // Print other attributes as needed
//     }
//   }

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

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
      // print("latLongData $latLongData");
      await searchRider();
    }
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
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

  String? currentBookingId;

  CreateBookingModel createBookingModel = CreateBookingModel();

  Future<void> createBooking() async {
    // try {
    setState(() {
      isLoading = true;
    });
    // SharedPreferences sharedPref = await SharedPreferences.getInstance();
    // final userId = sharedPref.getString('userId');
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('userId');
    print("userIdddddddddddddddddddddddddddd: $userId");
    // final Map<String, dynamic> requestData = {
    //   "users_fleet_id": widget.searchRider?.usersFleetId,
    //   "vehicles_id": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["vehicles_id"]
    //       : widget.multipleData!["vehicles_id"],
    //   "users_customers_id": userId,
    //   "bookings_types_id": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["bookings_types_id"]
    //       : widget.multipleData!["bookings_types_id"],
    //   "delivery_type": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["delivery_type"]
    //       : widget.multipleData!["delivery_type"],
    //   "bookings_destinations": [
    //     {
    //       "pickup_address": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["pickup_address"]
    //           : widget.multipleData!["pickup_address0"],
    //       "pickup_latitude": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["pickup_latitude"]
    //           : widget.multipleData!["pickup_latitude0"],
    //       "pickup_longitude": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["pickup_longitude"]
    //           : widget.multipleData!["pickup_longitude0"],
    //       "destin_address": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_address"]
    //           : widget.multipleData!["destin_address0"],
    //       "destin_latitude": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_latitude"]
    //           : widget.multipleData!["destin_latitude0"],
    //       "destin_longitude": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_longitude"]
    //           : widget.multipleData!["destin_longitude0"],
    //       "destin_distance": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_distance"]
    //           : widget.multipleData!["destin_distance0"],
    //       "destin_time": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_time"]
    //           : widget.multipleData!["destin_time0"],
    //       "destin_delivery_charges": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_delivery_charges"]
    //           : widget.multipleData!["destin_delivery_charges0"],
    //       "destin_vat_charges": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_vat_charges"]
    //           : widget.multipleData!["destin_vat_charges0"],
    //       "destin_total_charges": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_total_charges"]
    //           : widget.multipleData!["destin_total_charges0"],
    //       "destin_discount": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_discount"]
    //           : widget.multipleData!["destin_discount0"],
    //       "destin_discounted_charges": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_discounted_charges"]
    //           : widget.multipleData!["destin_discounted_charges0"],
    //       "receiver_name": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["receiver_name"]
    //           : widget.multipleData!["receiver_name0"],
    //       "receiver_phone": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["receiver_phone"]
    //           : widget.multipleData!["receiver_phone0"],
    //     },
    //     if (widget.multipleData!["pickup_address1"] != null &&
    //         widget.multipleData!["pickup_address1"].isNotEmpty)
    //       {
    //         "pickup_address": widget.multipleData!["pickup_address1"],
    //         "pickup_latitude": widget.multipleData!["pickup_latitude1"],
    //         "pickup_longitude": widget.multipleData!["pickup_longitude1"],
    //         "destin_address": widget.multipleData!["destin_address1"],
    //         "destin_latitude": widget.multipleData!["destin_latitude1"],
    //         "destin_longitude": widget.multipleData!["destin_longitude1"],
    //         "destin_distance": widget.multipleData!["destin_distance1"],
    //         "destin_time": widget.multipleData!["destin_time1"],
    //         "destin_delivery_charges":
    //             widget.multipleData!["destin_delivery_charges1"],
    //         "destin_vat_charges": widget.multipleData!["destin_vat_charges1"],
    //         "destin_total_charges":
    //             widget.multipleData!["destin_total_charges1"],
    //         "destin_discount": widget.multipleData!["destin_discount1"],
    //         "destin_discounted_charges":
    //             widget.multipleData!["destin_discounted_charges1"],
    //         "receiver_name": widget.multipleData!["receiver_name1"],
    //         "receiver_phone": widget.multipleData!["receiver_phone1"],
    //       },
    //     if (widget.multipleData!["pickup_address2"] != null &&
    //         widget.multipleData!["pickup_address2"].isNotEmpty)
    //       {
    //         "pickup_address": widget.multipleData!["pickup_address2"],
    //         "pickup_latitude": widget.multipleData!["pickup_latitude2"]
    //             ["latitude"],
    //         "pickup_longitude": widget.multipleData!["pickup_longitude2"]
    //             ["longitude"],
    //         "destin_address": widget.multipleData!["destin_address2"],
    //         "destin_latitude": widget.multipleData!["destin_latitude2"]
    //             ["latitude"],
    //         "destin_longitude": widget.multipleData!["destin_longitude2"]
    //             ["longitude"],
    //         "destin_distance": widget.multipleData!["destin_distance2"],
    //         "destin_time": widget.multipleData!["destin_time2"],
    //         "destin_delivery_charges":
    //             widget.multipleData!["destin_delivery_charges2"],
    //         "destin_vat_charges": widget.multipleData!["destin_vat_charges2"],
    //         "destin_total_charges":
    //             widget.multipleData!["destin_total_charges2"],
    //         "destin_discount": widget.multipleData!["destin_discount2"],
    //         "destin_discounted_charges":
    //             widget.multipleData!["destin_discounted_charges2"],
    //         "receiver_name": widget.multipleData!["receiver_name2"],
    //         "receiver_phone": widget.multipleData!["receiver_phone2"],
    //       },
    //     if (widget.multipleData!["pickup_address3"] != null &&
    //         widget.multipleData!["pickup_address3"].isNotEmpty)
    //       {
    //         "pickup_address": widget.multipleData!["pickup_address3"],
    //         "pickup_latitude": widget.multipleData!["pickup_latitude3"]
    //             ["latitude"],
    //         "pickup_longitude": widget.multipleData!["pickup_longitude3"]
    //             ["longitude"],
    //         "destin_address": widget.multipleData!["destin_address3"],
    //         "destin_latitude": widget.multipleData!["destin_latitude3"]
    //             ["latitude"],
    //         "destin_longitude": widget.multipleData!["destin_longitude3"]
    //             ["longitude"],
    //         "destin_distance": widget.multipleData!["destin_distance3"],
    //         "destin_time": widget.multipleData!["destin_time3"],
    //         "destin_delivery_charges":
    //             widget.multipleData!["destin_delivery_charges3"],
    //         "destin_vat_charges": widget.multipleData!["destin_vat_charges3"],
    //         "destin_total_charges":
    //             widget.multipleData!["destin_total_charges3"],
    //         "destin_discount": widget.multipleData!["destin_discount3"],
    //         "destin_discounted_charges":
    //             widget.multipleData!["destin_discounted_charges3"],
    //         "receiver_name": widget.multipleData!["receiver_name3"],
    //         "receiver_phone": widget.multipleData!["receiver_phone3"],
    //       },
    //     if (widget.multipleData!["pickup_address4"] != null &&
    //         widget.multipleData!["pickup_address4"].isNotEmpty)
    //       {
    //         "pickup_address": widget.multipleData!["pickup_address4"],
    //         "pickup_latitude": widget.multipleData!["pickup_latitude4"]
    //             ["latitude"],
    //         "pickup_longitude": widget.multipleData!["pickup_longitude4"]
    //             ["longitude"],
    //         "destin_address": widget.multipleData!["destin_address4"],
    //         "destin_latitude": widget.multipleData!["destin_latitude4"]
    //             ["latitude"],
    //         "destin_longitude": widget.multipleData!["destin_longitude4"]
    //             ["longitude"],
    //         "destin_distance": widget.multipleData!["destin_distance4"],
    //         "destin_time": widget.multipleData!["destin_time4"],
    //         "destin_delivery_charges":
    //             widget.multipleData!["destin_delivery_charges4"],
    //         "destin_vat_charges": widget.multipleData!["destin_vat_charges4"],
    //         "destin_total_charges":
    //             widget.multipleData!["destin_total_charges4"],
    //         "destin_discount": widget.multipleData!["destin_discount4"],
    //         "destin_discounted_charges":
    //             widget.multipleData!["destin_discounted_charges4"],
    //         "receiver_name": widget.multipleData!["receiver_name4"],
    //         "receiver_phone": widget.multipleData!["receiver_phone4"],
    //       },
    //   ],
    //   "total_delivery_charges": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["destin_total_charges"]
    //       : widget.multipleData!["destin_total_charges"],
    //   "total_vat_charges": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["total_vat_charges"]
    //       : widget.multipleData!["total_vat_charges"],
    //   "total_charges": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["total_charges"]
    //       : widget.multipleData!["total_charges"],
    //   "total_discount": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["total_discount"]
    //       : widget.multipleData!["total_discount"],
    //   "total_discounted_charges": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["total_discounted_charges"]
    //       : widget.multipleData!["total_discounted_charges"],
    //   "payment_gateways_id": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["payment_gateways_id"]
    //       : widget.multipleData!["payment_gateways_id"],
    //   "payment_by": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["payment_by"]
    //       : widget.multipleData!["payment_by"],
    //   "payment_status": "Unpaid"
    // };
    final Map<String, dynamic> requestData = {
      // "users_fleet_id": searchRider?.usersFleetId,
      "bookings_fleet": bookingsFleet,
      "users_customers_id": userId.toString(),
      "bookings_types_id": widget.singleData!.isNotEmpty
          ? widget.singleData!["bookings_types_id"]
          : widget.multipleData!["bookings_types_id"],
      "delivery_type": widget.singleData!.isNotEmpty
          ? widget.singleData!["delivery_type"]
          : widget.multipleData!["delivery_type"],
      "bookings_destinations": [
        {
          "pickup_address": widget.singleData!.isNotEmpty
              ? widget.singleData!["pickup_address"]
              : widget.multipleData!["pickup_address0"],
          "pickup_latitude": widget.singleData!.isNotEmpty
              ? widget.singleData!["pickup_latitude"]
              : widget.multipleData!["pickup_latitude0"],
          "pickup_longitude": widget.singleData!.isNotEmpty
              ? widget.singleData!["pickup_longitude"]
              : widget.multipleData!["pickup_longitude0"],
          "destin_address": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_address"]
              : widget.multipleData!["destin_address0"],
          "destin_latitude": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_latitude"]
              : widget.multipleData!["destin_latitude0"],
          "destin_longitude": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_longitude"]
              : widget.multipleData!["destin_longitude0"],
          "destin_distance": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_distance"]
              : widget.multipleData!["destin_distance0"],
          "destin_time": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_time"]
              : widget.multipleData!["destin_time0"],
          "destin_delivery_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_delivery_charges"]
              : widget.multipleData!["destin_delivery_charges0"],
          "destin_vat_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_vat_charges"]
              : widget.multipleData!["destin_vat_charges0"],
          "destin_total_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_total_charges"]
              : widget.multipleData!["destin_total_charges0"],
          "destin_discount": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_discount"]
              : widget.multipleData!["destin_discount0"],
          "destin_discounted_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_discounted_charges"]
              : widget.multipleData!["destin_discounted_charges0"],
          "receiver_name": widget.singleData!.isNotEmpty
              ? widget.singleData!["receiver_name"]
              : widget.multipleData!["receiver_name0"],
          "receiver_phone": widget.singleData!.isNotEmpty
              ? widget.singleData!["receiver_phone"]
              : widget.multipleData!["receiver_phone0"],
          "svc_running_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["svc_running_charges0"]
              : widget.multipleData!["svc_running_charges0"],
          if (widget.singleData!.isNotEmpty &&
              widget.singleData!["tollgate_charges0"] != null)
            "tollgate_charges": widget.singleData!["tollgate_charges0"],
          if (widget.singleData!.isEmpty &&
              widget.multipleData!["tollgate_charges0"] != null)
            "tollgate_charges": widget.multipleData!["tollgate_charges0"],
        },
        if (widget.multipleData!["pickup_address1"] != null &&
            widget.multipleData!["pickup_address1"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address1"],
            "pickup_latitude": widget.multipleData!["pickup_latitude1"],
            "pickup_longitude": widget.multipleData!["pickup_longitude1"],
            "destin_address": widget.multipleData!["destin_address1"],
            "destin_latitude": widget.multipleData!["destin_latitude1"],
            "destin_longitude": widget.multipleData!["destin_longitude1"],
            "destin_distance": widget.multipleData!["destin_distance1"],
            "destin_time": widget.multipleData!["destin_time1"],
            "destin_delivery_charges":
                widget.multipleData!["destin_delivery_charges1"],
            "destin_vat_charges": widget.multipleData!["destin_vat_charges1"],
            "destin_total_charges":
                widget.multipleData!["destin_total_charges1"],
            "destin_discount": widget.multipleData!["destin_discount1"],
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges1"],
            "receiver_name": widget.multipleData!["receiver_name1"],
            "receiver_phone": widget.multipleData!["receiver_phone1"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges1"]
                : widget.multipleData!["svc_running_charges1"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges1"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges1"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges1"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges1"],
          },
        if (widget.multipleData!["pickup_address2"] != null &&
            widget.multipleData!["pickup_address2"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address2"],
            "pickup_latitude": widget.multipleData!["pickup_latitude2"],
            "pickup_longitude": widget.multipleData!["pickup_longitude2"],
            "destin_address": widget.multipleData!["destin_address2"],
            "destin_latitude": widget.multipleData!["destin_latitude2"],
            "destin_longitude": widget.multipleData!["destin_longitude2"],
            "destin_distance": widget.multipleData!["destin_distance2"],
            "destin_time": widget.multipleData!["destin_time2"],
            "destin_delivery_charges":
                widget.multipleData!["destin_delivery_charges2"],
            "destin_vat_charges": widget.multipleData!["destin_vat_charges2"],
            "destin_total_charges":
                widget.multipleData!["destin_total_charges2"],
            "destin_discount": widget.multipleData!["destin_discount2"],
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges2"],
            "receiver_name": widget.multipleData!["receiver_name2"],
            "receiver_phone": widget.multipleData!["receiver_phone2"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges2"]
                : widget.multipleData!["svc_running_charges2"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges2"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges2"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges2"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges2"],
          },
        if (widget.multipleData!["pickup_address3"] != null &&
            widget.multipleData!["pickup_address3"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address3"],
            "pickup_latitude": widget.multipleData!["pickup_latitude3"],
            "pickup_longitude": widget.multipleData!["pickup_longitude3"],
            "destin_address": widget.multipleData!["destin_address3"],
            "destin_latitude": widget.multipleData!["destin_latitude3"],
            "destin_longitude": widget.multipleData!["destin_longitude3"],
            "destin_distance": widget.multipleData!["destin_distance3"],
            "destin_time": widget.multipleData!["destin_time3"],
            "destin_delivery_charges":
                widget.multipleData!["destin_delivery_charges3"],
            "destin_vat_charges": widget.multipleData!["destin_vat_charges3"],
            "destin_total_charges":
                widget.multipleData!["destin_total_charges3"],
            "destin_discount": widget.multipleData!["destin_discount3"],
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges3"],
            "receiver_name": widget.multipleData!["receiver_name3"],
            "receiver_phone": widget.multipleData!["receiver_phone3"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges3"]
                : widget.multipleData!["svc_running_charges3"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges3"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges3"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges3"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges3"],
          },
        if (widget.multipleData!["pickup_address4"] != null &&
            widget.multipleData!["pickup_address4"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address4"],
            "pickup_latitude": widget.multipleData!["pickup_latitude4"],
            "pickup_longitude": widget.multipleData!["pickup_longitude4"],
            "destin_address": widget.multipleData!["destin_address4"],
            "destin_latitude": widget.multipleData!["destin_latitude4"],
            "destin_longitude": widget.multipleData!["destin_longitude4"],
            "destin_distance": widget.multipleData!["destin_distance4"],
            "destin_time": widget.multipleData!["destin_time4"],
            "destin_delivery_charges":
                widget.multipleData!["destin_delivery_charges4"],
            "destin_vat_charges": widget.multipleData!["destin_vat_charges4"],
            "destin_total_charges":
                widget.multipleData!["destin_total_charges4"],
            "destin_discount": widget.multipleData!["destin_discount4"],
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges4"],
            "receiver_name": widget.multipleData!["receiver_name4"],
            "receiver_phone": widget.multipleData!["receiver_phone4"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges4"]
                : widget.multipleData!["svc_running_charges4"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges4"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges4"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges4"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges4"],
          },
      ],
      "service_running": widget.singleData!.isNotEmpty
          ? widget.singleData!["service_running"]
          : widget.multipleData!["service_running"],
      "total_svc_running_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_svc_running_charges"]
          : widget.multipleData!["total_svc_running_charges"],
      if (widget.singleData!.isNotEmpty &&
          widget.singleData!["tollgate_charges"] != null)
        "tollgate_charges": widget.singleData!["tollgate_charges"],
      if (widget.singleData!.isEmpty &&
          widget.multipleData!["tollgate_charges"] != null)
        "tollgate_charges": widget.multipleData!["tollgate_charges"],
      "delivery_date": widget.singleData!.isNotEmpty
          ? widget.singleData!["delivery_date"]
          : widget.multipleData!["delivery_date"],
      "delivery_time": widget.singleData!.isNotEmpty
          ? widget.singleData!["delivery_time"]
          : widget.multipleData!["delivery_time"],
      "total_delivery_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["destin_total_charges"]
          : widget.multipleData!["destin_total_charges"],
      "total_vat_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_vat_charges"]
          : widget.multipleData!["total_vat_charges"],
      "total_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_charges"]
          : widget.multipleData!["total_charges"],
      "total_discount": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_discount"]
          : widget.multipleData!["total_discount"],
      "total_discounted_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_discounted_charges"]
          : widget.multipleData!["total_discounted_charges"],
      "payment_gateways_id": widget.singleData!.isNotEmpty
          ? widget.singleData!["payment_gateways_id"]
          : widget.multipleData!["payment_gateways_id"],
      "payment_by": widget.singleData!.isNotEmpty
          ? widget.singleData!["payment_by"]
          : widget.multipleData!["payment_by"],
      "payment_status": "Unpaid"
    };
    String apiUrl = "$baseUrl/send_request_booking";
    debugPrint("apiUrl: $apiUrl");
    debugPrint("requestData: $requestData");
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );
    final responseString = response.body;
    debugPrint("response: $responseString");
    debugPrint("statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      createBookingModel = createBookingModelFromJson(responseString);
      debugPrint('createBookingModel status: ${createBookingModel.status}');
      currentBookingId = createBookingModel.data?.bookingsId.toString();
      debugPrint('currentBookingId: $currentBookingId');
      setState(() {
        isLoading = false;
      });
    }
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  ScheduleBookingModel scheduleBookingModel = ScheduleBookingModel();

  Future<void> scheduleBooking() async {
    // try {
    setState(() {
      isLoading = true;
    });
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('userId');
    // final Map<String, dynamic> requestData = {
    //   "users_fleet_id": widget.searchRider?.usersFleetId,
    //   "vehicles_id": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["vehicles_id"]
    //       : widget.multipleData!["vehicles_id"],
    //   "users_customers_id": userId,
    //   "bookings_types_id": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["bookings_types_id"]
    //       : widget.multipleData!["bookings_types_id"],
    //   "delivery_type": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["delivery_type"]
    //       : widget.multipleData!["delivery_type"],
    //   "bookings_destinations": [
    //     {
    //       "pickup_address": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["pickup_address"]
    //           : widget.multipleData!["pickup_address0"],
    //       "pickup_latitude": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["pickup_latitude"]
    //           : widget.multipleData!["pickup_latitude0"],
    //       "pickup_longitude": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["pickup_longitude"]
    //           : widget.multipleData!["pickup_longitude0"],
    //       "destin_address": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_address"]
    //           : widget.multipleData!["destin_address0"],
    //       "destin_latitude": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_latitude"]
    //           : widget.multipleData!["destin_latitude0"],
    //       "destin_longitude": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_longitude"]
    //           : widget.multipleData!["destin_longitude0"],
    //       "destin_distance": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_distance"]
    //           : widget.multipleData!["destin_distance0"],
    //       "destin_time": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_time"]
    //           : widget.multipleData!["destin_time0"],
    //       "destin_delivery_charges": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_delivery_charges"]
    //           : widget.multipleData!["destin_delivery_charges0"],
    //       "destin_vat_charges": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_vat_charges"]
    //           : widget.multipleData!["destin_vat_charges0"],
    //       "destin_total_charges": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_total_charges"]
    //           : widget.multipleData!["destin_total_charges0"],
    //       "destin_discount": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_discount"]
    //           : widget.multipleData!["destin_discount0"],
    //       "destin_discounted_charges": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["destin_discounted_charges"]
    //           : widget.multipleData!["destin_discounted_charges0"],
    //       "receiver_name": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["receiver_name"]
    //           : widget.multipleData!["receiver_name0"],
    //       "receiver_phone": widget.singleData!.isNotEmpty
    //           ? widget.singleData!["receiver_phone"]
    //           : widget.multipleData!["receiver_phone0"],
    //     },
    //     if (widget.multipleData!["pickup_address1"] != null &&
    //         widget.multipleData!["pickup_address1"].isNotEmpty)
    //       {
    //         "pickup_address": widget.multipleData!["pickup_address1"],
    //         "pickup_latitude": widget.multipleData!["pickup_latitude1"],
    //         "pickup_longitude": widget.multipleData!["pickup_longitude1"],
    //         "destin_address": widget.multipleData!["destin_address1"],
    //         "destin_latitude": widget.multipleData!["destin_latitude1"],
    //         "destin_longitude": widget.multipleData!["destin_longitude1"],
    //         "destin_distance": widget.multipleData!["destin_distance1"],
    //         "destin_time": widget.multipleData!["destin_time1"],
    //         "destin_delivery_charges":
    //             widget.multipleData!["destin_delivery_charges1"],
    //         "destin_vat_charges": widget.multipleData!["destin_vat_charges1"],
    //         "destin_total_charges":
    //             widget.multipleData!["destin_total_charges1"],
    //         "destin_discount": widget.multipleData!["destin_discount1"],
    //         "destin_discounted_charges":
    //             widget.multipleData!["destin_discounted_charges1"],
    //         "receiver_name": widget.multipleData!["receiver_name1"],
    //         "receiver_phone": widget.multipleData!["receiver_phone1"],
    //       },
    //     if (widget.multipleData!["pickup_address2"] != null &&
    //         widget.multipleData!["pickup_address2"].isNotEmpty)
    //       {
    //         "pickup_address": widget.multipleData!["pickup_address2"],
    //         "pickup_latitude": widget.multipleData!["pickup_latitude2"]
    //             ["latitude"],
    //         "pickup_longitude": widget.multipleData!["pickup_longitude2"]
    //             ["longitude"],
    //         "destin_address": widget.multipleData!["destin_address2"],
    //         "destin_latitude": widget.multipleData!["destin_latitude2"]
    //             ["latitude"],
    //         "destin_longitude": widget.multipleData!["destin_longitude2"]
    //             ["longitude"],
    //         "destin_distance": widget.multipleData!["destin_distance2"],
    //         "destin_time": widget.multipleData!["destin_time2"],
    //         "destin_delivery_charges":
    //             widget.multipleData!["destin_delivery_charges2"],
    //         "destin_vat_charges": widget.multipleData!["destin_vat_charges2"],
    //         "destin_total_charges":
    //             widget.multipleData!["destin_total_charges2"],
    //         "destin_discount": widget.multipleData!["destin_discount2"],
    //         "destin_discounted_charges":
    //             widget.multipleData!["destin_discounted_charges2"],
    //         "receiver_name": widget.multipleData!["receiver_name2"],
    //         "receiver_phone": widget.multipleData!["receiver_phone2"],
    //       },
    //     if (widget.multipleData!["pickup_address3"] != null &&
    //         widget.multipleData!["pickup_address3"].isNotEmpty)
    //       {
    //         "pickup_address": widget.multipleData!["pickup_address3"],
    //         "pickup_latitude": widget.multipleData!["pickup_latitude3"]
    //             ["latitude"],
    //         "pickup_longitude": widget.multipleData!["pickup_longitude3"]
    //             ["longitude"],
    //         "destin_address": widget.multipleData!["destin_address3"],
    //         "destin_latitude": widget.multipleData!["destin_latitude3"]
    //             ["latitude"],
    //         "destin_longitude": widget.multipleData!["destin_longitude3"]
    //             ["longitude"],
    //         "destin_distance": widget.multipleData!["destin_distance3"],
    //         "destin_time": widget.multipleData!["destin_time3"],
    //         "destin_delivery_charges":
    //             widget.multipleData!["destin_delivery_charges3"],
    //         "destin_vat_charges": widget.multipleData!["destin_vat_charges3"],
    //         "destin_total_charges":
    //             widget.multipleData!["destin_total_charges3"],
    //         "destin_discount": widget.multipleData!["destin_discount3"],
    //         "destin_discounted_charges":
    //             widget.multipleData!["destin_discounted_charges3"],
    //         "receiver_name": widget.multipleData!["receiver_name3"],
    //         "receiver_phone": widget.multipleData!["receiver_phone3"],
    //       },
    //     if (widget.multipleData!["pickup_address4"] != null &&
    //         widget.multipleData!["pickup_address4"].isNotEmpty)
    //       {
    //         "pickup_address": widget.multipleData!["pickup_address4"],
    //         "pickup_latitude": widget.multipleData!["pickup_latitude4"]
    //             ["latitude"],
    //         "pickup_longitude": widget.multipleData!["pickup_longitude4"]
    //             ["longitude"],
    //         "destin_address": widget.multipleData!["destin_address4"],
    //         "destin_latitude": widget.multipleData!["destin_latitude4"]
    //             ["latitude"],
    //         "destin_longitude": widget.multipleData!["destin_longitude4"]
    //             ["longitude"],
    //         "destin_distance": widget.multipleData!["destin_distance4"],
    //         "destin_time": widget.multipleData!["destin_time4"],
    //         "destin_delivery_charges":
    //             widget.multipleData!["destin_delivery_charges4"],
    //         "destin_vat_charges": widget.multipleData!["destin_vat_charges4"],
    //         "destin_total_charges":
    //             widget.multipleData!["destin_total_charges4"],
    //         "destin_discount": widget.multipleData!["destin_discount4"],
    //         "destin_discounted_charges":
    //             widget.multipleData!["destin_discounted_charges4"],
    //         "receiver_name": widget.multipleData!["receiver_name4"],
    //         "receiver_phone": widget.multipleData!["receiver_phone4"],
    //       },
    //   ],
    //   "delivery_date": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["delivery_date"]
    //       : widget.multipleData!["delivery_date"],
    //   "delivery_time": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["delivery_time"]
    //       : widget.multipleData!["delivery_time"],
    //   "total_delivery_charges": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["destin_total_charges"]
    //       : widget.multipleData!["destin_total_charges"],
    //   "total_vat_charges": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["total_vat_charges"]
    //       : widget.multipleData!["total_vat_charges"],
    //   "total_charges": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["total_charges"]
    //       : widget.multipleData!["total_charges"],
    //   "total_discount": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["total_discount"]
    //       : widget.multipleData!["total_discount"],
    //   "total_discounted_charges": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["total_discounted_charges"]
    //       : widget.multipleData!["total_discounted_charges"],
    //   "payment_gateways_id": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["payment_gateways_id"]
    //       : widget.multipleData!["payment_gateways_id"],
    //   "payment_by": widget.singleData!.isNotEmpty
    //       ? widget.singleData!["payment_by"]
    //       : widget.multipleData!["payment_by"],
    //   "payment_status": "Unpaid"
    // };
    final Map<String, dynamic> requestData = {
      "bookings_fleet": bookingsFleet,
      "users_customers_id": userId.toString(),
      "bookings_types_id": widget.singleData!.isNotEmpty
          ? widget.singleData!["bookings_types_id"]
          : widget.multipleData!["bookings_types_id"],
      "delivery_type": widget.singleData!.isNotEmpty
          ? widget.singleData!["delivery_type"]
          : widget.multipleData!["delivery_type"],
      "bookings_destinations": [
        {
          "pickup_address": widget.singleData!.isNotEmpty
              ? widget.singleData!["pickup_address"]
              : widget.multipleData!["pickup_address0"],
          "pickup_latitude": widget.singleData!.isNotEmpty
              ? widget.singleData!["pickup_latitude"]
              : widget.multipleData!["pickup_latitude0"],
          "pickup_longitude": widget.singleData!.isNotEmpty
              ? widget.singleData!["pickup_longitude"]
              : widget.multipleData!["pickup_longitude0"],
          "destin_address": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_address"]
              : widget.multipleData!["destin_address0"],
          "destin_latitude": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_latitude"]
              : widget.multipleData!["destin_latitude0"],
          "destin_longitude": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_longitude"]
              : widget.multipleData!["destin_longitude0"],
          "destin_distance": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_distance"]
              : widget.multipleData!["destin_distance0"],
          "destin_time": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_time"]
              : widget.multipleData!["destin_time0"],
          "destin_delivery_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_delivery_charges"]
              : widget.multipleData!["destin_delivery_charges0"],
          "destin_vat_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_vat_charges"]
              : widget.multipleData!["destin_vat_charges0"],
          "destin_total_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_total_charges"]
              : widget.multipleData!["destin_total_charges0"],
          "destin_discount": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_discount"]
              : widget.multipleData!["destin_discount0"],
          "destin_discounted_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["destin_discounted_charges"]
              : widget.multipleData!["destin_discounted_charges0"],
          "receiver_name": widget.singleData!.isNotEmpty
              ? widget.singleData!["receiver_name"]
              : widget.multipleData!["receiver_name0"],
          "receiver_phone": widget.singleData!.isNotEmpty
              ? widget.singleData!["receiver_phone"]
              : widget.multipleData!["receiver_phone0"],
          "svc_running_charges": widget.singleData!.isNotEmpty
              ? widget.singleData!["svc_running_charges0"]
              : widget.multipleData!["svc_running_charges0"],
          if (widget.singleData!.isNotEmpty &&
              widget.singleData!["tollgate_charges0"] != null)
            "tollgate_charges": widget.singleData!["tollgate_charges0"],
          if (widget.singleData!.isEmpty &&
              widget.multipleData!["tollgate_charges0"] != null)
            "tollgate_charges": widget.multipleData!["tollgate_charges0"],
        },
        if (widget.multipleData!["pickup_address1"] != null &&
            widget.multipleData!["pickup_address1"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address1"],
            "pickup_latitude": widget.multipleData!["pickup_latitude1"],
            "pickup_longitude": widget.multipleData!["pickup_longitude1"],
            "destin_address": widget.multipleData!["destin_address1"],
            "destin_latitude": widget.multipleData!["destin_latitude1"],
            "destin_longitude": widget.multipleData!["destin_longitude1"],
            "destin_distance": widget.multipleData!["destin_distance1"],
            "destin_time": widget.multipleData!["destin_time1"],
            "destin_delivery_charges":
                widget.multipleData!["destin_delivery_charges1"],
            "destin_vat_charges": widget.multipleData!["destin_vat_charges1"],
            "destin_total_charges":
                widget.multipleData!["destin_total_charges1"],
            "destin_discount": widget.multipleData!["destin_discount1"],
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges1"],
            "receiver_name": widget.multipleData!["receiver_name1"],
            "receiver_phone": widget.multipleData!["receiver_phone1"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges1"]
                : widget.multipleData!["svc_running_charges1"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges1"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges1"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges1"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges1"],
          },
        if (widget.multipleData!["pickup_address2"] != null &&
            widget.multipleData!["pickup_address2"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address2"],
            "pickup_latitude": widget.multipleData!["pickup_latitude2"],
            "pickup_longitude": widget.multipleData!["pickup_longitude2"],
            "destin_address": widget.multipleData!["destin_address2"],
            "destin_latitude": widget.multipleData!["destin_latitude2"],
            "destin_longitude": widget.multipleData!["destin_longitude2"],
            "destin_distance": widget.multipleData!["destin_distance2"],
            "destin_time": widget.multipleData!["destin_time2"],
            "destin_delivery_charges":
                widget.multipleData!["destin_delivery_charges2"],
            "destin_vat_charges": widget.multipleData!["destin_vat_charges2"],
            "destin_total_charges":
                widget.multipleData!["destin_total_charges2"],
            "destin_discount": widget.multipleData!["destin_discount2"],
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges2"],
            "receiver_name": widget.multipleData!["receiver_name2"],
            "receiver_phone": widget.multipleData!["receiver_phone2"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges2"]
                : widget.multipleData!["svc_running_charges2"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges2"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges2"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges2"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges2"],
          },
        if (widget.multipleData!["pickup_address3"] != null &&
            widget.multipleData!["pickup_address3"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address3"],
            "pickup_latitude": widget.multipleData!["pickup_latitude3"],
            "pickup_longitude": widget.multipleData!["pickup_longitude3"],
            "destin_address": widget.multipleData!["destin_address3"],
            "destin_latitude": widget.multipleData!["destin_latitude3"],
            "destin_longitude": widget.multipleData!["destin_longitude3"],
            "destin_distance": widget.multipleData!["destin_distance3"],
            "destin_time": widget.multipleData!["destin_time3"],
            "destin_delivery_charges":
                widget.multipleData!["destin_delivery_charges3"],
            "destin_vat_charges": widget.multipleData!["destin_vat_charges3"],
            "destin_total_charges":
                widget.multipleData!["destin_total_charges3"],
            "destin_discount": widget.multipleData!["destin_discount3"],
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges3"],
            "receiver_name": widget.multipleData!["receiver_name3"],
            "receiver_phone": widget.multipleData!["receiver_phone3"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges3"]
                : widget.multipleData!["svc_running_charges3"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges3"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges3"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges3"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges3"],
          },
        if (widget.multipleData!["pickup_address4"] != null &&
            widget.multipleData!["pickup_address4"].isNotEmpty)
          {
            "pickup_address": widget.multipleData!["pickup_address4"],
            "pickup_latitude": widget.multipleData!["pickup_latitude4"],
            "pickup_longitude": widget.multipleData!["pickup_longitude4"],
            "destin_address": widget.multipleData!["destin_address4"],
            "destin_latitude": widget.multipleData!["destin_latitude4"],
            "destin_longitude": widget.multipleData!["destin_longitude4"],
            "destin_distance": widget.multipleData!["destin_distance4"],
            "destin_time": widget.multipleData!["destin_time4"],
            "destin_delivery_charges":
                widget.multipleData!["destin_delivery_charges4"],
            "destin_vat_charges": widget.multipleData!["destin_vat_charges4"],
            "destin_total_charges":
                widget.multipleData!["destin_total_charges4"],
            "destin_discount": widget.multipleData!["destin_discount4"],
            "destin_discounted_charges":
                widget.multipleData!["destin_discounted_charges4"],
            "receiver_name": widget.multipleData!["receiver_name4"],
            "receiver_phone": widget.multipleData!["receiver_phone4"],
            "svc_running_charges": widget.singleData!.isNotEmpty
                ? widget.singleData!["svc_running_charges4"]
                : widget.multipleData!["svc_running_charges4"],
            if (widget.singleData!.isNotEmpty &&
                widget.singleData!["tollgate_charges4"] != null)
              "tollgate_charges": widget.singleData!["tollgate_charges4"],
            if (widget.singleData!.isEmpty &&
                widget.multipleData!["tollgate_charges4"] != null)
              "tollgate_charges": widget.multipleData!["tollgate_charges4"],
          },
      ],
      "service_running": widget.singleData!.isNotEmpty
          ? widget.singleData!["service_running"]
          : widget.multipleData!["service_running"],
      "total_svc_running_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_svc_running_charges"]
          : widget.multipleData!["total_svc_running_charges"],
      if (widget.singleData!.isNotEmpty &&
          widget.singleData!["tollgate_charges"] != null)
        "tollgate_charges": widget.singleData!["tollgate_charges"],
      if (widget.singleData!.isEmpty &&
          widget.multipleData!["tollgate_charges"] != null)
        "tollgate_charges": widget.multipleData!["tollgate_charges"],
      "delivery_date": widget.singleData!.isNotEmpty
          ? widget.singleData!["delivery_date"]
          : widget.multipleData!["delivery_date"],
      "delivery_time": widget.singleData!.isNotEmpty
          ? widget.singleData!["delivery_time"]
          : widget.multipleData!["delivery_time"],
      "total_delivery_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["destin_total_charges"]
          : widget.multipleData!["destin_total_charges"],
      "total_vat_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_vat_charges"]
          : widget.multipleData!["total_vat_charges"],
      "total_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_charges"]
          : widget.multipleData!["total_charges"],
      "total_discount": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_discount"]
          : widget.multipleData!["total_discount"],
      "total_discounted_charges": widget.singleData!.isNotEmpty
          ? widget.singleData!["total_discounted_charges"]
          : widget.multipleData!["total_discounted_charges"],
      "payment_gateways_id": widget.singleData!.isNotEmpty
          ? widget.singleData!["payment_gateways_id"]
          : widget.multipleData!["payment_gateways_id"],
      "payment_by": widget.singleData!.isNotEmpty
          ? widget.singleData!["payment_by"]
          : widget.multipleData!["payment_by"],
      "payment_status": "Unpaid"
    };
    String apiUrl = "$baseUrl/send_request_booking_scheduled";
    debugPrint("apiUrl: $apiUrl");
    debugPrint("requestData: $requestData");
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );
    final responseString = response.body;
    debugPrint("response: $responseString");
    debugPrint("statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      scheduleBookingModel = scheduleBookingModelFromJson(responseString);
      debugPrint('scheduleBookingModel status: ${scheduleBookingModel.status}');
      currentBookingId = scheduleBookingModel.data?.bookingsId.toString();
      debugPrint('currentBookingId: $currentBookingId');
      setState(() {
        isLoading = false;
      });
    }
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return;
    // }
  }

  @override
  initState() {
    super.initState();
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
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Container(
                          child: Text(
                              "No riders found within the radius of $radiusThreshold km"),
                        ),
                      ),
                    ],
                  )),
      ),
    );
  }
}
