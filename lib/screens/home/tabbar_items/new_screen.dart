// ignore_for_file: must_be_immutable, use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:deliver_client/models/get_distance_addresses_model.dart';
import 'package:deliver_client/models/get_profile_model.dart';
import 'package:deliver_client/screens/home/drawer/settings/delete_account_screen.dart';
import 'package:deliver_client/screens/login/login_screen.dart';
import 'package:deliver_client/screens/search_riders_screen.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:google_maps_webservice_ex/places.dart';
import 'package:flutter/services.dart'
    show
        FilteringTextInputFormatter,
        LengthLimitingTextInputFormatter,
        SystemNavigator,
        rootBundle;
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/widgets/home_textfields.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/get_vehicles_model.dart';
import 'package:deliver_client/utils/distance_matrix_api.dart';
import 'package:deliver_client/models/get_addresses_model.dart';
import 'package:deliver_client/screens/schedule_ride_screen.dart';
import 'package:deliver_client/models/get_services_type_model.dart';
import 'package:deliver_client/models/get_bookings_type_model.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/screens/confirm_single_details_screen.dart';
import 'package:deliver_client/screens/confirm_multiple_details_screen.dart';

String? userId;
Map latLongData = {};

class NewScreen extends StatefulWidget {
  late double? location;

  NewScreen({super.key, this.location});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> with WidgetsBindingObserver {
  TextEditingController pickupController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController receiversNameController = TextEditingController();
  TextEditingController receiversNumberController = TextEditingController();
  final DraggableScrollableController dragController =
      DraggableScrollableController();

  String? baseUrl = dotenv.env['BASE_URL'];
  String? mapsKey = dotenv.env['MAPS_KEY'];

  int selectedRadio = 1;
  Map addSingleData = {};
  Map addMultipleData = {};

  bool isSelectedBus = false;
  bool isSelectedCourier = true;
  bool addressesVisible = false;
  bool isSelectedAddress = false;
  List<String> addresses = [];
  double? doubleSystemLat;
  double? doubleSystemLng;
  String? systemLat;
  String? systemLng;
  String? pickupLat;
  String? pickupLng;

  String? addressLat;
  String? addressLng;
  String? currentLat;
  String? currentLng;
  String? destinationLat;
  String? destinationLng;
  String? courierId;
  String? otherId;
  String? bookingName;
  String? vehicleId;
  String? selectedVehicle;
  List<String> vehiclesType = [];
  String? bookingsTypeId;
  String? selectedBookingType;
  List<String> bookingType = [];
  // String? toKm;
  // String? toKm0;
  // String? toKm1;
  // String? toKm2;
  // String? toKm3;
  // String? toKm4;
  // String? fromKm;
  // String? fromKm0;
  // String? fromKm1;
  // String? fromKm2;
  // String? fromKm3;
  // String? fromKm4;
  // String? perKmAmount;
  // String? perKmAmount0;
  // String? perKmAmount1;
  // String? perKmAmount2;
  // String? perKmAmount3;
  // String? perKmAmount4;

  LatLng? origin;
  LatLng? destination;

  String? minPageLength;
  String? maxPageLength;

  int? minPageLen;
  int? maxPageLen;
  int? dataIndex1;
  List<String> distances = [];
  List<String> durations = [];
  Map<String, dynamic>? distanceData;
  Map<int, Map<String, String>> dataForIndex1 = {};
  Map<int, Map<String, dynamic>> distanceDataMap = {};
  List<Map<int, Map<String, String>>> distanceDurationList = [];
  var indexData0;
  var indexData1;
  var indexData2;
  var indexData3;
  var indexData4;
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> dataForIndexes = [];
  List<Map<String, dynamic>> allDataForIndexes1 = [];
  List<List<Map<String, dynamic>>> allDataForIndexes = [];
  bool isLoading = false;
  bool isLoadingAddress = false;
  bool isLoading2 = false;
  String? emaildata;
  void showSessionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Your session is expired, please re-login',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                removeDataFormSharedPreferences();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  sharedPrefs() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('userId');
    firstName = sharedPref.getString('firstName');
    lastName = sharedPref.getString('lastName');
    emaildata = sharedPref.getString('email');
    debugPrint('sharedPrefs userId: $userId');
    debugPrint('sharedPrefs firstName: $firstName');
    debugPrint('sharedPrefs lastName: $lastName');
    debugPrint('sharedPrefs emaildata: $emaildata');
    if (getProfileModel.data!.email != emaildata) {
      showSessionExpiredDialog(context);
    }
  }

  removeDataFormSharedPreferences() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    await sharedPref.clear();
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
        await sharedPrefs();
        debugPrint('getProfileModel status: ${getProfileModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();
  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Timeout',
            style: TextStyle(
              color: Color(0xFFFF6302), // Theme color
              fontWeight: FontWeight.bold, // Font weight
            ),
          ),
          content: const Text(
            'Please check your internet connection or try again later.',
            style: TextStyle(
              color: Colors.black87, // Default color
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                SystemNavigator.pop(); // Exiting the application
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFFFF6302), // Theme color
                  fontWeight: FontWeight.bold, // Font weight
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  getAllSystemData() async {
    try {
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
        tapCount = 0;
        print("tapCountHome: $tapCount");
        debugPrint(
            'getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "system_latitude") {
            systemLat = "${getAllSystemDataModel.data?[i].description}";
            doubleSystemLat = double.parse(systemLat!);
          }
          if (getAllSystemDataModel.data?[i].type == "system_longitude") {
            systemLng = "${getAllSystemDataModel.data?[i].description}";
            doubleSystemLng = double.parse(systemLng!);
          }
          if (getAllSystemDataModel.data?[i].type ==
              "min_multiple_delivery_parcel") {
            minPageLength = "${getAllSystemDataModel.data?[i].description}";
            minPageLen = int.parse(minPageLength!);
          }
          if (getAllSystemDataModel.data?[i].type ==
              "max_multiple_delivery_parcel") {
            maxPageLength = "${getAllSystemDataModel.data?[i].description}";
            maxPageLen = int.parse(maxPageLength!);
          }
          setState(() {});
        }
      } else if (response.statusCode == 500) {
        showCustomDialog(context);
      }
    } on TimeoutException catch (_) {
      // Handle timeout exception
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Timeout'),
            content: const Text(
                'Please check your internet connection or try again later.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetAddressesModel getAddressesModel = GetAddressesModel();

  getAddresses() async {
    // try {
    setState(() {
      isLoadingAddress = true;
    });
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('userId');
    String apiUrl = "$baseUrl/get_addresses_customers";
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
      getAddressesModel = getAddressesModelFromJson(responseString);
      await getProfile();

      debugPrint('getAddressesModel status: ${getAddressesModel.status}');
      for (int i = 0; i < getAddressesModel.data!.length; i++) {
        addresses.add("${getAddressesModel.data?[i]}");
      }
      setState(() {
        isLoadingAddress = false;
      });
    }
    // } catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  GetServiceTypesModel getServiceTypesModel = GetServiceTypesModel();

  getServiceTypes() async {
    try {
      String apiUrl = "$baseUrl/get_service_types";
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
        getServiceTypesModel = getServiceTypesModelFromJson(responseString);
        debugPrint(
            'getServiceTypesModel status: ${getServiceTypesModel.status}');
        setState(() {});
        for (int i = 0; i < getServiceTypesModel.data!.length; i++) {
          if (getServiceTypesModel.data?[i].name == "Deliver a Parcel") {
            courierId = "${getServiceTypesModel.data?[i].serviceTypesId}";
          }
          if (getServiceTypesModel.data?[i].name == "Book a Van") {
            otherId = "${getServiceTypesModel.data?[i].serviceTypesId}";
            getVehiclesByServiceType(courierId);
            setState(() {});
          }
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  Timer? fetchDataTimer;

  GetVehiclesByServiceTypeModel getVehiclesByServiceTypeModel =
      GetVehiclesByServiceTypeModel();

  getVehiclesByServiceType(String? serviceId) async {
    try {
      String apiUrl = "$baseUrl/get_vehicles_by_service_type";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("serviceTypesId: $serviceId");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "service_types_id": serviceId,
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getVehiclesByServiceTypeModel =
            getVehiclesByServiceTypeModelFromJson(responseString);
        setState(() {});
        debugPrint(
            'getVehiclesByServiceTypeModel status: ${getVehiclesByServiceTypeModel.status}');
        for (int i = 0; i < getVehiclesByServiceTypeModel.data!.length; i++) {
          vehiclesType.add("${getVehiclesByServiceTypeModel.data?[i].name}");
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetBookingsTypeModel getBookingsTypeModel = GetBookingsTypeModel();

  getBookingsType() async {
    try {
      String apiUrl = "$baseUrl/get_bookings_types";
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
        getBookingsTypeModel = getBookingsTypeModelFromJson(responseString);
        setState(() {});
        debugPrint(
            'getBookingsTypeModel status: ${getBookingsTypeModel.status}');
        for (int i = 0; i < getBookingsTypeModel.data!.length; i++) {
          bookingName = getBookingsTypeModel.data?[i].name;
          bookingType.add("$bookingName");
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  // GetChargesModel getChargesModel = GetChargesModel();

  // getChargesSingle(String? bTypeId) async {
  //   try {
  //     String apiUrl = "$baseUrl/get_charges_parameters";
  //     Map<String, String> distanceMap = {
  //       "0": distance!.split(" ")[0],
  //     };
  //     Map<String, dynamic> requestBody = {
  //       "bookings_types_id": bTypeId,
  //       "distance": distanceMap,
  //     };
  //     debugPrint("apiUrl: $apiUrl");
  //     debugPrint("bookingsTypeId: $bTypeId");
  //     debugPrint("requestBody: $requestBody");
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Accept': 'application/json',
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(requestBody),
  //     );
  //     final responseString = response.body;
  //     debugPrint("response: $responseString");
  //     debugPrint("statusCode: ${response.statusCode}");
  //     if (response.statusCode == 200) {
  //       getChargesModel = getChargesModelFromJson(responseString);
  //       debugPrint('getChargesModel status: ${getChargesModel.status}');
  //       debugPrint('getChargesModel length: ${getChargesModel.data!.length}');
  //       toKm = "${getChargesModel.data![0].firstMilesTo}";
  //       fromKm = "${getChargesModel.data![0].firstMilesFrom}";
  //       perKmAmount = "${getChargesModel.data![0].firstMilesAmount}";
  //       setState(() {});
  //     }
  //   } catch (e) {
  //     debugPrint('Something went wrong  = ${e.toString()}');
  //     return null;
  //   }
  // }

  String? distance0;
  String? distance1;
  String? distance2;
  String? distance3;
  String? distance4;

  String? duration0;
  String? duration1;
  String? duration2;
  String? duration3;
  String? duration4;

  String? pickupLatt;
  String? pickupLong;
  String? destinLatt;
  String? destinLong;
  String? totalDeliveryAmount;
  String? totalVatCharges;
  String? totalTollGateCharges;
  String? totalServiceCharges;
  String? serviceRunning;
  String? serviceRunningCharges;
  String? tollGateCharges;
  String? roundedTotalAmount;
  String? totalChargesM;
  String? totalVatM;
  String? totalDisM;

  String? pickupLat0;
  String? pickupLng0;
  String? destinLat0;
  String? destinLng0;

  String? pickupLat1;
  String? pickupLng1;
  String? destinLat1;
  String? destinLng1;

  String? pickupLat2;
  String? pickupLng2;
  String? destinLat2;
  String? destinLng2;

  String? pickupLat3;
  String? pickupLng3;
  String? destinLat3;
  String? destinLng3;

  String? pickupLat4;
  String? pickupLng4;
  String? destinLat4;
  String? destinLng4;

  String? totalDeliveryAmount0;
  String? totalDeliveryAmount1;
  String? totalDeliveryAmount2;
  String? totalDeliveryAmount3;
  String? totalDeliveryAmount4;

  String? serviceCharges0;
  String? serviceCharges1;
  String? serviceCharges2;
  String? serviceCharges3;
  String? serviceCharges4;

  String? tollGateCharges0;
  String? tollGateCharges1;
  String? tollGateCharges2;
  String? tollGateCharges3;
  String? tollGateCharges4;

  String? totalVatCharges0;
  String? totalVatCharges1;
  String? totalVatCharges2;
  String? totalVatCharges3;
  String? totalVatCharges4;

  String? roundedTotalAmount0;
  String? roundedTotalAmount1;
  String? roundedTotalAmount2;
  String? roundedTotalAmount3;
  String? roundedTotalAmount4;

  GetDistanceAddressesModel getDistanceAddressesModel =
      GetDistanceAddressesModel();
  Future<void> getDistanceAddress(String? bTypeId, String? vehicleId) async {
    debugPrint("pickup: ${pickupController.text}");
    debugPrint("Destin: ${destinationController.text}");
    Map<String, dynamic>? requestBody;
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$baseUrl/get_booking_charges";

      List<Map<String, String>> addresses = [];
      List<Map<String, String>> addresses2 = [];
      if (filteredData.isNotEmpty) {
        for (var i = 0; i < filteredData.length; i++) {
          String? pickupAddress = filteredData[i]["$i"]["pickupController"];
          String? destinationAddress =
              filteredData[i]["$i"]["destinationController"];

          if (pickupAddress != null &&
              destinationAddress != null &&
              pickupAddress.isNotEmpty &&
              destinationAddress.isNotEmpty) {
            addresses.add({
              "pickup": pickupAddress,
              "destin": destinationAddress,
            });
          }
        }
      } else if (pickupController.text.isNotEmpty &&
          destinationController.text.isNotEmpty) {
        addresses2.add({
          "pickup": pickupController.text,
          "destin": destinationController.text,
        });
      } else {
        setState(() {
          isLoading = false;
        });
        CustomToast.showToast(
          fontSize: 12,
          message: "${getDistanceAddressesModel.message}",
        );
      }

      if (addresses.isNotEmpty) {
        requestBody = {
          "bookings_types_id": "$bTypeId",
          "vehicles_id": vehicleId,
          "addresses": addresses,
        };
      } else if (addresses.isEmpty) {
        requestBody = {
          "bookings_types_id": "$bTypeId",
          "vehicles_id": vehicleId,
          "addresses": addresses2,
        };
      }

      debugPrint("apiUrl: $apiUrl");
      debugPrint("requestBody: $requestBody");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        getDistanceAddressesModel =
            getDistanceAddressesModelFromJson(responseString);
        totalChargesM = getDistanceAddressesModel.data!.totalCharges;
        totalVatM = getDistanceAddressesModel.data!.totalVatCharges;
        if (getDistanceAddressesModel.data != null) {
          for (int i = 0;
              i < getDistanceAddressesModel.data!.bookingsDestinations!.length;
              i++) {
            final distance = getDistanceAddressesModel
                .data!.bookingsDestinations![i].destinDistance
                .toString();
            final duration = getDistanceAddressesModel
                .data!.bookingsDestinations![i].destinTime;
            pickupLatt = getDistanceAddressesModel
                .data!.bookingsDestinations![i].pickupLatitude
                .toString();
            pickupLong = getDistanceAddressesModel
                .data!.bookingsDestinations![i].pickupLongitude
                .toString();
            destinLatt = getDistanceAddressesModel
                .data!.bookingsDestinations![i].destinLatitude
                .toString();
            destinLong = getDistanceAddressesModel
                .data!.bookingsDestinations![i].destinLongitude
                .toString();
            totalDeliveryAmount = getDistanceAddressesModel
                .data!.bookingsDestinations![i].destinDeliveryCharges
                .toString();
            totalVatCharges = getDistanceAddressesModel
                .data!.bookingsDestinations![i].destinVatCharges
                .toString();
            roundedTotalAmount = getDistanceAddressesModel
                .data!.bookingsDestinations![i].destinTotalCharges
                .toString();
            serviceRunning =
                getDistanceAddressesModel.data?.serviceRunning.toString();
            totalServiceCharges =
                getDistanceAddressesModel.data?.totalServiceCharges.toString();
            totalTollGateCharges =
                getDistanceAddressesModel.data?.totalTollGateCharges;
            tollGateCharges = getDistanceAddressesModel
                .data!.bookingsDestinations?[i].totalTollGateCharges;
            serviceRunningCharges = getDistanceAddressesModel
                .data!.bookingsDestinations?[i].totalServiceCharges
                .toString();
            if (duration == null) {
              Fluttertoast.showToast(
                msg: "Distance fetching problem",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 2,
                fontSize: 16.0,
                textColor: Colors.white,
                backgroundColor: Colors.red,
              );
              continue;
            }

            // Convert to double only if distance and duration are not null
            // final double? distanceDouble = double.tryParse(distance);
            // final double? durationDouble = double.tryParse(duration);
            debugPrint('Distance $i: $distance');
            debugPrint('Duration $i: $duration');
            debugPrint('Pickup Latitude $i: $pickupLatt');
            debugPrint('Pickup Longitude $i: $pickupLong');
            debugPrint('Destination Latitude $i: $destinLatt');
            debugPrint('Destination Longitude $i: $destinLong');
            switch (i) {
              case 0:
                distance0 = distance;
                duration0 = duration;
                pickupLat0 = pickupLatt;
                pickupLng0 = pickupLong;
                destinLat0 = destinLatt;
                destinLng0 = destinLong;
                totalDeliveryAmount0 = totalDeliveryAmount;
                totalVatCharges0 = totalVatCharges;
                roundedTotalAmount0 = roundedTotalAmount;
                serviceCharges0 = serviceRunningCharges;
                tollGateCharges0 = tollGateCharges;
                debugPrint('distance0 = $distance0');
                debugPrint('duration0 = $duration0');
                debugPrint('pickupLat0 = $pickupLat0');
                debugPrint('pickupLng0 = $pickupLng0');
                debugPrint('destinLat0 = $destinLat0');
                debugPrint('destinLng0 = $destinLng0');
                debugPrint('totalDeliveryAmount0 = $totalDeliveryAmount0');
                debugPrint('totalVatCharges0 = $totalVatCharges0');
                debugPrint('roundedTotalAmount0 = $roundedTotalAmount0');
                debugPrint('serviceCharges0 = $serviceCharges0');
                debugPrint('tollGateCharges0 = $tollGateCharges0');
                break;
              case 1:
                distance1 = distance;
                duration1 = duration;
                pickupLat1 = pickupLatt;
                pickupLng1 = pickupLong;
                destinLat1 = destinLatt;
                destinLng1 = destinLong;
                totalDeliveryAmount1 = totalDeliveryAmount;
                totalVatCharges1 = totalVatCharges;
                roundedTotalAmount1 = roundedTotalAmount;
                serviceCharges1 = serviceRunningCharges;
                tollGateCharges1 = tollGateCharges;
                debugPrint('distance1 = $distance1');
                debugPrint('duration1 = $duration1');
                debugPrint('pickupLat1 = $pickupLat1');
                debugPrint('pickupLng1 = $pickupLng1');
                debugPrint('destinLat1 = $destinLat1');
                debugPrint('destinLng1 = $destinLng1');
                debugPrint('totalDeliveryAmount1 = $totalDeliveryAmount1');
                debugPrint('totalVatCharges1 = $totalVatCharges1');
                debugPrint('roundedTotalAmount1 = $roundedTotalAmount1');
                debugPrint('serviceCharges1 = $serviceCharges1');
                debugPrint('tollGateCharges1 = $tollGateCharges1');
                break;
              case 2:
                distance2 = distance;
                duration2 = duration;
                pickupLat2 = pickupLatt;
                pickupLng2 = pickupLong;
                destinLat2 = destinLatt;
                destinLng2 = destinLong;
                totalDeliveryAmount2 = totalDeliveryAmount;
                totalVatCharges2 = totalVatCharges;
                roundedTotalAmount2 = roundedTotalAmount;
                serviceCharges2 = serviceRunningCharges;
                tollGateCharges2 = tollGateCharges;
                break;
              case 3:
                distance3 = distance;
                duration3 = duration;
                pickupLat3 = pickupLatt;
                pickupLng3 = pickupLong;
                destinLat3 = destinLatt;
                destinLng3 = destinLong;
                totalDeliveryAmount3 = totalDeliveryAmount;
                totalVatCharges3 = totalVatCharges;
                roundedTotalAmount3 = roundedTotalAmount;
                serviceCharges3 = serviceRunningCharges;
                tollGateCharges3 = tollGateCharges;
                break;
              case 4:
                distance4 = distance;
                duration4 = duration;
                pickupLat4 = pickupLatt;
                pickupLng4 = pickupLong;
                destinLat4 = destinLatt;
                destinLng4 = destinLong;
                totalDeliveryAmount4 = totalDeliveryAmount;
                totalVatCharges4 = totalVatCharges;
                roundedTotalAmount4 = roundedTotalAmount;
                serviceCharges4 = serviceRunningCharges;
                tollGateCharges4 = tollGateCharges;
                break;
              default:
                // Handle if there are more distances than predefined variables
                break;
            }
          }
        }
        setState(() {
          isLoading = false;
        });
      } else {
        debugPrint("Non-200 status code received: ${response.statusCode}");
        // Handle other status codes as needed
        CustomToast.showToast(
          fontSize: 12,
          message: "${getDistanceAddressesModel.message}",
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Something went wrong: $e\n$stackTrace');
      CustomToast.showToast(
        fontSize: 12,
        message: "${getDistanceAddressesModel.message}",
      );
    }
  }

  int currentIndex = 0;
  late List<Widget> pages;
  PageController pageController = PageController();

  void addPage() {
    if (pages.length >= maxPageLen!) {
      return; // Limit reached, do not add more pages
    }
    setState(() {
      pages.add(HomeTextFields(
        currentIndex: currentIndex,
        pageController: pageController,
        isSelectedAddress: isSelectedAddress,
        pickupController: pickupControllers[currentIndex],
        destinationController: destinationControllers[currentIndex],
        receiversNameController: receiversNameControllers[currentIndex],
        receiversNumberController: receiversNumberControllers[currentIndex],
      ));
    });
  }

  void removePage() {
    if (pages.length <= minPageLen!) {
      return; // Limit reached, do not remove more pages
    }
    pages.removeAt(currentIndex);
    setState(() {
      pageController.jumpToPage(currentIndex - 1);
    });
  }

  var places;
  List<PlacesSearchResult> pickUpPredictions = [];
  List<PlacesSearchResult> destinationPredictions = [];
  GoogleMapController? mapController;
  MarkerId? selectedMarker;
  LatLng? currentLocation;
  LatLng? selectedLocation;
  LatLng? selectedAddressLocation;
  BitmapDescriptor? customMarkerIcon;
  Timer? _debounceTimer;
  int apiHitCount = 0;
  Future<void> searchPickUpPlaces(String input) async {
    if (input.isNotEmpty) {
      // Cancel previous debounce timer
      if (_debounceTimer != null) {
        _debounceTimer!.cancel();
      }

      // Start a new debounce timer
      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        final response = await places.searchByText(input);
        apiHitCount++; // Increment API hit count

        // Track analytics event
        if (response.isOkay) {
          setState(() {
            pickUpPredictions = response.results;
          });
        }
      });
    }
  }

  Future<void> searchDestinationPlaces(String input) async {
    if (input.isNotEmpty) {
      // Cancel previous debounce timer
      if (_debounceTimer != null) {
        _debounceTimer!.cancel();
      }

      // Start a new debounce timer
      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        final response = await places.searchByText(input);
        apiHitCount++; // Increment API hit count

        // Track analytics event
        if (response.isOkay) {
          setState(() {
            destinationPredictions = response.results;
          });
        }
      });
    }
  }

  Future<void> getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
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
        selectedMarker = const MarkerId('currentLocation');
        pickupController.text = currentAddress;
        currentLat = position.latitude.toString();
        currentLng = position.longitude.toString();
        debugPrint("currentLat: $currentLat");
        debugPrint("currentLng: $currentLng");
        debugPrint("currentPickupLocation: $currentAddress");
      });

      mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(currentLocation!, 15));
    }
  }

  void onPickUpLocationSelected(LatLng location, double zoomLevel) {
    setState(() {
      selectedLocation = location;
      currentLocation = null; // Clear current location
      selectedAddressLocation = null; // Clear address location
      selectedMarker = const MarkerId('selectedLocation');
    });

    mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation!, zoomLevel));
  }

  void onPickUpLocationSavedAddresses(LatLng location, double zoomLevel) {
    setState(() {
      selectedAddressLocation = location;
      currentLocation = null; // Clear current location
      selectedLocation = null; // Clear address location
      selectedMarker = const MarkerId('selectedAddressLocation');
    });

    mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(selectedAddressLocation!, zoomLevel));
  }

  Future<void> loadCustomMarker() async {
    final ByteData bytes = await rootBundle.load(
      'assets/images/current-location-name-white-icon.png',
    );
    final Uint8List list = bytes.buffer.asUint8List();

    customMarkerIcon = BitmapDescriptor.fromBytes(list);

    setState(() {});
  }

  var api;

  // calculateDistanceTimeSingle() async {
  //   final origin =
  //       '${pickupLat ?? currentLat ?? addressLat},${pickupLng ?? currentLng ?? addressLng}'; // Format coordinates as "latitude,longitude"
  //   final destination =
  //       '$destinationLat,$destinationLng'; // Format coordinates as "latitude,longitude"
  //   try {
  //     final data = await api.getDistanceAndTime(origin, destination);
  //     distance = data['rows'][0]['elements'][0]['distance']['text'];
  //     duration = data['rows'][0]['elements'][0]['duration']['text'];
  //     debugPrint("distance: $distance");
  //     debugPrint("duration: $duration");
  //   } catch (e) {
  //     debugPrint("Error: $e");
  //   }
  // }

  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getAddresses();
    getServiceTypes();
    getBookingsType();
    loadCustomMarker();
    getAllSystemData();
    api = DistanceMatrixAPI("$mapsKey");
    places = GoogleMapsPlaces(apiKey: mapsKey);
    pages = [
      HomeTextFields(
        currentIndex: currentIndex,
        pageController: pageController,
        isSelectedAddress: isSelectedAddress,
        pickupController: pickupControllers[currentIndex],
        destinationController: destinationControllers[currentIndex],
        receiversNameController: receiversNameControllers[currentIndex],
        receiversNumberController: receiversNumberControllers[currentIndex],
      ),
      HomeTextFields(
        currentIndex: currentIndex,
        pageController: pageController,
        isSelectedAddress: isSelectedAddress,
        pickupController: pickupControllers[currentIndex],
        destinationController: destinationControllers[currentIndex],
        receiversNameController: receiversNameControllers[currentIndex],
        receiversNumberController: receiversNumberControllers[currentIndex],
      ),
    ];
  }

  @override
  void dispose() {
    dragController.dispose();
    pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final value = WidgetsBinding.instance.window.viewInsets.bottom;
    if (value > 0) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  final countryPicker = const FlCountryCodePicker();
  CountryCode? countryCode =
      const CountryCode(name: 'Nigeria', code: 'NG', dialCode: '+234');

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenHeight * 0.02;
    return Scaffold(
      backgroundColor: bgColor,
      body: doubleSystemLat != null
          ? ListView(
              controller: _scrollController,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Select service type",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: drawerTextColor,
                          fontSize: 20,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            vehiclesType.clear();
                            selectedVehicle = null;
                            getVehiclesByServiceType(courierId);
                            setState(() {
                              isSelectedBus = false;
                              isSelectedCourier = true;
                              debugPrint("courierId: $courierId");
                            });
                          },
                          child: Stack(
                            children: [
                              Container(
                                color: transparentColor,
                                width: MediaQuery.of(context).size.width * 0.43,
                                height:
                                    MediaQuery.of(context).size.height * 0.14,
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.43,
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                      stops: const [0.1, 1.5],
                                      colors: [
                                        isSelectedCourier == true
                                            ? orangeColor
                                            : const Color(0xFFEBEBEB),
                                        isSelectedCourier == true
                                            ? yellowColor
                                            : const Color(0xFFEBEBEB),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Text(
                                  "Deliver a Parcel",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelectedCourier == true
                                        ? whiteColor
                                        : drawerTextColor,
                                    fontSize: fontSize,
                                    fontFamily: 'Syne-Bold',
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                left: 0,
                                right: 0,
                                child: SvgPicture.asset(
                                  "assets/images/login-parcel-icon.svg",
                                  width: size.width * 0.07,
                                  height: size.height * 0.07,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: size.width * 0.04),
                        GestureDetector(
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'In the works!',
                                    style: TextStyle(
                                      color: orangeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: const Text(
                                    'Stay Tuned for the Big Reveal..',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 18,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                );
                              },
                            );
                            // vehiclesType.clear();
                            // selectedVehicle = null;
                            // getVehiclesByServiceType(otherId);
                            // setState(() {
                            //   isSelectedBus = true;
                            //   isSelectedCourier = false;
                            //   debugPrint("otherId: $otherId");
                            // });
                          },
                          child: Stack(
                            children: [
                              Container(
                                color: transparentColor,
                                width: MediaQuery.of(context).size.width * 0.43,
                                height:
                                    MediaQuery.of(context).size.height * 0.14,
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.43,
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                      stops: const [0.1, 1.5],
                                      colors: [
                                        isSelectedBus == true
                                            ? orangeColor
                                            : const Color(0xFFEBEBEB),
                                        isSelectedBus == true
                                            ? yellowColor
                                            : const Color(0xFFEBEBEB),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Text(
                                  "Book a Van",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelectedBus == true
                                        ? whiteColor
                                        : drawerTextColor,
                                    fontSize: fontSize,
                                    fontFamily: 'Syne-Bold',
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 5,
                                left: 0,
                                right: 0,
                                child: SvgPicture.asset(
                                  "assets/images/login-truck-icon.svg",
                                  width: size.width * 0.07,
                                  height: size.height * 0.07,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                for (int i = 0;
                                    i < 5 && i < distanceDurationList.length;
                                    i++) {
                                  final entry = distanceDurationList[i];
                                  debugPrint(
                                      "distanceDurationList[$i]: $entry");
                                }
                              });
                            },
                            child: Text(
                              "Find best rider?",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: drawerTextColor,
                                fontSize: 20,
                                fontFamily: 'Syne-Bold',
                              ),
                            ),
                          ),
                          if (selectedRadio == 1)
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedAddress = true;
                                    });
                                  },
                                  child: isSelectedAddress == true
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isSelectedAddress = false;
                                            });
                                          },
                                          child: SvgPicture.asset(
                                            'assets/images/checkmark-icon.svg',
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          'assets/images/uncheckmark-icon.svg',
                                        ),
                                ),
                                SizedBox(width: size.width * 0.01),
                                Text(
                                  "Saved Addresses",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: drawerTextColor,
                                    fontSize: 12,
                                    fontFamily: 'Syne-Bold',
                                  ),
                                ),
                              ],
                            ),
                          if (selectedRadio == 2)
                            Row(
                              children: [
                                // GestureDetector(
                                //   onTap: () {
                                //     removePage();
                                //     setState(() {});
                                //   },
                                //   child: SvgPicture.asset(
                                //     'assets/images/minus-icon.svg',
                                //   ),
                                // ),
                                // SizedBox(width: size.width * 0.02),
                                // GestureDetector(
                                //   onTap: () {
                                //     addPage();
                                //     setState(() {});
                                //   },
                                //   child: SvgPicture.asset(
                                //     'assets/images/add-icon.svg',
                                //   ),
                                // ),
                                SizedBox(width: size.width * 0.03),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedAddress = true;
                                    });
                                  },
                                  child: isSelectedAddress == true
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isSelectedAddress = false;
                                            });
                                          },
                                          child: SvgPicture.asset(
                                            'assets/images/checkmark-icon.svg',
                                          ),
                                        )
                                      : SvgPicture.asset(
                                          'assets/images/uncheckmark-icon.svg',
                                        ),
                                ),
                                SizedBox(width: size.width * 0.01),
                                Text(
                                  "Saved Addresses",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: drawerTextColor,
                                    fontSize: 12,
                                    fontFamily: 'Syne-Bold',
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Theme(
                      data: ThemeData(
                        unselectedWidgetColor: orangeColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Radio(
                                value: 1,
                                groupValue: selectedRadio,
                                activeColor: orangeColor,
                                visualDensity: VisualDensity.compact,
                                onChanged: (value) {
                                  setState(() {
                                    selectedRadio = value!;
                                  });
                                },
                              ),
                              Text(
                                "Single Delivery",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: drawerTextColor,
                                  fontSize: 14,
                                  fontFamily: 'Syne-Bold',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Radio(
                                value: 2,
                                groupValue: selectedRadio,
                                activeColor: orangeColor,
                                visualDensity: VisualDensity.compact,
                                onChanged: (value) {
                                  setState(() {
                                    selectedRadio = value!;
                                  });
                                },
                              ),
                              Text(
                                "Multiple Delivery",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: drawerTextColor,
                                  fontSize: 14,
                                  fontFamily: 'Syne-Bold',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    if (selectedRadio == 1) singleTextField(),
                    if (selectedRadio == 2) multiPageView(),
                    SizedBox(height: size.height * 0.015),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/info-icon.svg",
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField(
                                  icon: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: SvgPicture.asset(
                                      'assets/images/dropdown-icon.svg',
                                      width: 5,
                                      height: 5,
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: filledColor,
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
                                    hintText: 'Select Vehicle',
                                    hintStyle: TextStyle(
                                      color: hintColor,
                                      fontSize: 12,
                                      fontFamily: 'Inter-Light',
                                    ),
                                    errorStyle: TextStyle(
                                      color: redColor,
                                      fontSize: 10,
                                      fontFamily: 'Inter-Bold',
                                    ),
                                  ),
                                  padding: const EdgeInsets.only(right: 5),
                                  borderRadius: BorderRadius.circular(10),
                                  items: vehiclesType
                                      .map(
                                        (item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              color: blackColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter-Regular',
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  value: selectedVehicle,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedVehicle = value;
                                      debugPrint("selectedVehicle: $value");
                                      if (getVehiclesByServiceTypeModel.data !=
                                          null) {
                                        for (int i = 0;
                                            i <
                                                getVehiclesByServiceTypeModel
                                                    .data!.length;
                                            i++) {
                                          if (getVehiclesByServiceTypeModel
                                                  .data?[i].name ==
                                              value) {
                                            vehicleId =
                                                getVehiclesByServiceTypeModel
                                                    .data?[i].vehiclesId
                                                    .toString();
                                            debugPrint(
                                                'vehicleId: ${getVehiclesByServiceTypeModel.data?[i].vehiclesId.toString()}');
                                          }
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.015),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/info-icon.svg",
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: ButtonTheme(
                              alignedDropdown: true,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField(
                                  icon: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: SvgPicture.asset(
                                      'assets/images/dropdown-icon.svg',
                                      width: 5,
                                      height: 5,
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: filledColor,
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
                                    hintText: 'Select Booking Type',
                                    hintStyle: TextStyle(
                                      color: hintColor,
                                      fontSize: 12,
                                      fontFamily: 'Inter-Light',
                                    ),
                                    errorStyle: TextStyle(
                                      color: redColor,
                                      fontSize: 10,
                                      fontFamily: 'Inter-Bold',
                                    ),
                                  ),
                                  padding: const EdgeInsets.only(right: 5),
                                  borderRadius: BorderRadius.circular(10),
                                  items: bookingType
                                      .map(
                                        (item) => DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              color: blackColor,
                                              fontSize: 14,
                                              fontFamily: 'Inter-Regular',
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  value: selectedBookingType,
                                  onChanged: (value) async {
                                    selectedBookingType = value;
                                    debugPrint("selectedBookingType: $value");
                                    if (getBookingsTypeModel.data != null) {
                                      for (int i = 0;
                                          i < getBookingsTypeModel.data!.length;
                                          i++) {
                                        if ("${getBookingsTypeModel.data?[i].name}" ==
                                            value) {
                                          bookingsTypeId = getBookingsTypeModel
                                              .data?[i].bookingsTypesId
                                              .toString();
                                          debugPrint(
                                              'bookingsTypeId: $bookingsTypeId');
                                        }
                                      }
                                    }
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selectedRadio == 2)
                      Column(
                        children: [
                          SizedBox(height: size.height * 0.025),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        removePage();
                                        setState(() {});
                                      },
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/minus-icon.svg',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (pageController.page!.toInt() > 0) {
                                    pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: SvgPicture.asset(
                                  'assets/images/orange-left-arrow-icon.svg',
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              DotsIndicator(
                                dotsCount: pages.length,
                                position: currentIndex,
                                decorator: DotsDecorator(
                                  color: dotsColor, // Inactive color
                                  activeColor: orangeColor,
                                  spacing:
                                      const EdgeInsets.symmetric(horizontal: 3),
                                ),
                                onTap: (index) {
                                  pageController.animateToPage(
                                    currentIndex = index,
                                    duration: const Duration(
                                      milliseconds: 500,
                                    ),
                                    curve: Curves.linear,
                                  );
                                },
                              ),
                              SizedBox(width: size.width * 0.02),
                              GestureDetector(
                                onTap: () {
                                  if (pageController.page!.toInt() <
                                      pages.length - 1) {
                                    pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: SvgPicture.asset(
                                  'assets/images/orange-right-arrow-icon.svg',
                                ),
                              ),
                              SizedBox(width: size.width * 0.02),
                              GestureDetector(
                                onTap: () {
                                  addPage();
                                  setState(() {});
                                },
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/add-icon.svg',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    SizedBox(height: size.height * 0.025),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (selectedRadio == 1) {
                                if (pickupController.text.isEmpty &&
                                    destinationController.text.isEmpty &&
                                    receiversNameController.text.isEmpty &&
                                    receiversNumberController.text.isEmpty &&
                                    selectedVehicle == null &&
                                    selectedBookingType == null) {
                                  if (pickupController.text.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please fill pickup address!",
                                    );
                                  } else if (destinationController
                                      .text.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message:
                                          "Please fill destination address!",
                                    );
                                  } else if (receiversNameController
                                      .text.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please fill receiver's name!",
                                    );
                                  } else if (receiversNumberController
                                      .text.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please fill receiver's number!",
                                    );
                                  } else if (selectedVehicle == null) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please select a vehicle!",
                                    );
                                  } else if (selectedBookingType == null) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please select booking type!",
                                    );
                                  }
                                } else {
                                  setState(() {
                                    isLoading2 = true;
                                  });
                                  await getDistanceAddress(
                                      bookingsTypeId, vehicleId);
                                  if (double.parse(distance0!) <= 1.0) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message:
                                          "Distance should be greater than 1.0 Km!",
                                    );
                                    setState(() {
                                      isLoading2 = false;
                                    });
                                  } else {
                                    // await getDistanceAddress(bookingsTypeId);
                                    addSingleData = {
                                      "type": "schedule",
                                      "vehicles_id": vehicleId,
                                      "service_running": serviceRunning,
                                      "delivery_charges": totalDeliveryAmount0,
                                      "total_svc_running_charges":
                                          totalServiceCharges,
                                      "total_tollgate_charges":
                                          totalTollGateCharges ?? "0",
                                      "svc_running_charges0": serviceCharges0,
                                      "tollgate_charges0":
                                          tollGateCharges0 ?? "0",
                                      "bookings_types_id": bookingsTypeId,
                                      "delivery_type": selectedRadio == 1
                                          ? "Single"
                                          : "Multiple",
                                      "pickup_address": pickupController.text,
                                      "pickup_latitude": pickupLat0,
                                      "pickup_longitude": pickupLng0,
                                      "destin_address":
                                          destinationController.text,
                                      "destin_latitude": destinLat0,
                                      "destin_longitude": destinLng0,
                                      "destin_distance": distance0,
                                      "destin_time": duration0,
                                      "destin_delivery_charges":
                                          totalDeliveryAmount0,
                                      "destin_vat_charges": totalVatCharges0,
                                      "destin_total_charges":
                                          roundedTotalAmount0 ?? "0.00",
                                      "destin_discount": "0.00",
                                      "destin_discounted_charges": "0.00",
                                      "receiver_name":
                                          receiversNameController.text,
                                      "receiver_phone":
                                          receiversNumberController.text,
                                    };
                                    setState(() {
                                      isLoading2 = false;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ScheduleRideScreen(
                                          selectedRadio: selectedRadio,
                                          scheduledSingleData: addSingleData,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                              if (selectedRadio == 2) {
                                showDialog(
                                  context: context,
                                  // barrierDismissible:
                                  //     false, // Prevents dialog from closing when tapping outside
                                  builder: (context) {
                                    return Dialog(
                                      backgroundColor: Colors
                                          .transparent, // Make dialog transparent
                                      elevation: 0, // Remove shadow
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(
                                              color: orangeColor,
                                              strokeWidth: 2,
                                            ), // Your progress indicator
                                            const SizedBox(height: 20),
                                            const Text(
                                              'Loading Data...',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontFamily: 'Inter-Bold',
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            const Text(
                                              'Please wait while data is being loaded.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Inter-Regular',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                                await getDistanceAddress(
                                    bookingsTypeId, vehicleId);
                                // Add a delay to ensure data is populated in allDataForIndexes1
                                Future.delayed(const Duration(seconds: 2),
                                    () async {
                                  // Close the loading dialog

                                  if (filteredData.isNotEmpty) {
                                    if (distance0 != null &&
                                            double.parse(distance0!) <= 1.0 ||
                                        distance1 != null &&
                                            double.parse(distance1!) <= 1.0 ||
                                        distance2 != null &&
                                            double.parse(distance2!) <= 1.0 ||
                                        distance3 != null &&
                                            double.parse(distance3!) <= 1.0 ||
                                        distance4 != null &&
                                            double.parse(distance4!) <= 1.0) {
                                      CustomToast.showToast(
                                        fontSize: 12,
                                        message:
                                            "Distance should be greater than 1.0 Km!",
                                      );
                                    } else {
                                      await getDistanceAddress(
                                          bookingsTypeId, vehicleId);
                                      addMultipleData = {
                                        "type": "schedule",
                                        "vehicles_id": vehicleId,
                                        "totalChargesM": totalChargesM,
                                        "totalVatM": totalVatM,
                                        "service_running": serviceRunning,
                                        "total_svc_running_charges":
                                            totalServiceCharges,
                                        "total_tollgate_charges":
                                            totalTollGateCharges ?? "0",
                                        "svc_running_charges0": serviceCharges0,
                                        "tollgate_charges0":
                                            tollGateCharges0 ?? "0",
                                        "svc_running_charges1": serviceCharges1,
                                        "tollgate_charges1":
                                            tollGateCharges1 ?? "0",
                                        "svc_running_charges2": serviceCharges2,
                                        "tollgate_charges2":
                                            tollGateCharges2 ?? "0",
                                        "svc_running_charges3": serviceCharges3,
                                        "tollgate_charges3":
                                            tollGateCharges3 ?? "0",
                                        "svc_running_charges4": serviceCharges4,
                                        "tollgate_charges4":
                                            tollGateCharges4 ?? "0",
                                        "bookings_types_id": bookingsTypeId,
                                        "delivery_type": selectedRadio == 1
                                            ? "Single"
                                            : "Multiple",
                                        "pickup_latitude0":
                                            "$pickupLat0" != 'null'
                                                ? "$pickupLat0"
                                                : "0",
                                        "pickup_longitude0":
                                            "$pickupLng0" != 'null'
                                                ? "$pickupLng0"
                                                : "0",
                                        "destin_latitude0":
                                            "$destinLat0" != 'null'
                                                ? "$destinLat0"
                                                : "0",
                                        "destin_longitude0":
                                            "$destinLng0" != 'null'
                                                ? "$destinLng0"
                                                : "0",
                                        "pickup_latitude1":
                                            "$pickupLat1" != 'null'
                                                ? "$pickupLat1"
                                                : "0",
                                        "pickup_longitude1":
                                            "$pickupLng1" != 'null'
                                                ? "$pickupLng1"
                                                : "0",
                                        "destin_latitude1":
                                            "$destinLat1" != 'null'
                                                ? "$destinLat1"
                                                : "0",
                                        "destin_longitude1":
                                            "$destinLng1" != 'null'
                                                ? "$destinLng1"
                                                : "0",
                                        "pickup_latitude2":
                                            "$pickupLat2" != 'null'
                                                ? "$pickupLat2"
                                                : "0",
                                        "pickup_longitude2":
                                            "$pickupLat2" != 'null'
                                                ? "$pickupLat2"
                                                : "0",
                                        "destin_latitude2":
                                            "$destinLat2" != 'null'
                                                ? "$destinLat2"
                                                : "0",
                                        "destin_longitude2":
                                            "$destinLng2" != 'null'
                                                ? "$destinLng2"
                                                : "0",
                                        "pickup_latitude3":
                                            "$pickupLat3" != 'null'
                                                ? "$pickupLat3"
                                                : "0",
                                        "pickup_longitude3":
                                            "$pickupLng3" != 'null'
                                                ? "$pickupLng3"
                                                : "0",
                                        "destin_latitude3":
                                            "$destinLat3" != 'null'
                                                ? "$destinLat3"
                                                : "0",
                                        "destin_longitude3":
                                            "$destinLng3" != 'null'
                                                ? "$destinLng3"
                                                : "0",
                                        "pickup_latitude4":
                                            "$pickupLng4" != 'null'
                                                ? "$pickupLng4"
                                                : "0",
                                        "pickup_longitude4":
                                            "$pickupLng4" != 'null'
                                                ? "$pickupLng4"
                                                : "0",
                                        "destin_latitude4":
                                            "$destinLat4" != 'null'
                                                ? "$destinLat4"
                                                : "0",
                                        "destin_longitude4":
                                            "$destinLng4" != 'null'
                                                ? "$destinLng4"
                                                : "0",
                                        "destin_distance0": distance0,
                                        "destin_time0": duration0,
                                        "destin_delivery_charges0":
                                            totalDeliveryAmount0 ?? "0.00",
                                        "destin_vat_charges0": totalVatCharges0,
                                        "destin_total_charges0":
                                            roundedTotalAmount0,
                                        "destin_discount0": "0.00",
                                        "destin_discounted_charges0": "0.00",
                                        "destin_distance1": distance1,
                                        "destin_time1": duration1,
                                        "destin_delivery_charges1":
                                            totalDeliveryAmount1 ?? "0.00",
                                        "destin_vat_charges1":
                                            totalVatCharges1 ?? "0.00",
                                        "destin_total_charges1":
                                            roundedTotalAmount1 ?? "0.00",
                                        "destin_discount1": "0.00",
                                        "destin_discounted_charges1": "0.00",
                                        "destin_distance2": distance2 ?? "0.00",
                                        "destin_time2": duration2,
                                        "destin_delivery_charges2":
                                            totalDeliveryAmount2 ?? "0.00",
                                        "destin_vat_charges2":
                                            totalVatCharges2 ?? "0.00",
                                        "destin_total_charges2":
                                            roundedTotalAmount2 ?? "0.00",
                                        "destin_discount2": "0.00",
                                        "destin_discounted_charges2": "0.00",
                                        "destin_distance3": distance3 ?? "0.00",
                                        "destin_time3": duration3,
                                        "destin_delivery_charges3":
                                            totalDeliveryAmount3 ?? "0.00",
                                        "destin_vat_charges3":
                                            totalVatCharges3 ?? "0.00",
                                        "destin_total_charges3":
                                            roundedTotalAmount3 ?? "0.00",
                                        "destin_discount3": "0.00",
                                        "destin_discounted_charges3": "0.00",
                                        "destin_distance4": distance4 ?? "0.00",
                                        "destin_time4": duration4,
                                        "destin_delivery_charges4":
                                            totalDeliveryAmount4 ?? "0.00",
                                        "destin_vat_charges4":
                                            totalVatCharges4 ?? "0.00",
                                        "destin_total_charges4":
                                            roundedTotalAmount4 ?? "0.00",
                                        "destin_discount4": "0.00",
                                        "destin_discounted_charges4": "0.00",
                                      };

                                      List<Map<int, dynamic>> indexData =
                                          List.filled(5, {});

                                      for (var i = 0;
                                          i < filteredData.length;
                                          i++) {
                                        final dataForIndex = filteredData[i];
                                        final dataIndexString = dataForIndex
                                            .keys
                                            .first; // Get the index as a String
                                        final dataIndex =
                                            int.tryParse(dataIndexString);

                                        if (dataIndex != null &&
                                            dataIndex >= 0 &&
                                            dataIndex <= 4) {
                                          indexData[dataIndex] = dataForIndex
                                              .map((key, value) => MapEntry(
                                                  int.parse(key), value));
                                        } else {
                                          debugPrint(
                                              "Invalid or out of bounds index: $dataIndexString");
                                        }
                                      }

                                      // Separate the data into different lists based on their indices
                                      Map<int, dynamic> indexData0 =
                                          indexData[0];
                                      Map<int, dynamic> indexData1 =
                                          indexData[1];
                                      Map<int, dynamic> indexData2 =
                                          indexData[2];
                                      Map<int, dynamic> indexData3 =
                                          indexData[3];
                                      Map<int, dynamic> indexData4 =
                                          indexData[4];

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ScheduleRideScreen(
                                            indexData0: indexData0,
                                            indexData1: indexData1,
                                            indexData2: indexData2,
                                            indexData3: indexData3,
                                            indexData4: indexData4,
                                            selectedRadio: selectedRadio,
                                            scheduledMultipleData:
                                                addMultipleData,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          insetPadding: const EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: SizedBox(
                                            width: size.width,
                                            height: size.height * 0.25,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                          height: size.height *
                                                              0.02),
                                                      Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Text(
                                                          "Just a moment...",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: orangeColor,
                                                            fontSize: 20,
                                                            fontFamily:
                                                                'Inter-Bold',
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: size.height *
                                                              0.03),
                                                      Text(
                                                        'Please make sure data is available before proceeding.',
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Regular',
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: size.height *
                                                              0.02),
                                                    ],
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 140),
                                                    child:
                                                        dialogButtonGradientSmall(
                                                            "OK", context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
                                });
                              }
                            },
                            child: isLoading2
                                ? buttonTransparentGradientSmallWithLoader(
                                    "Please Wait...", context)
                                : buttonTransparentGradientSmall(
                                    "SCHEDULE RIDE",
                                    context,
                                  ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (selectedRadio == 1) {
                                if (pickupController.text.isEmpty ||
                                    destinationController.text.isEmpty ||
                                    receiversNameController.text.isEmpty ||
                                    receiversNumberController.text.isEmpty ||
                                    selectedVehicle == null ||
                                    selectedBookingType == null) {
                                  if (pickupController.text.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please fill pickup address!",
                                    );
                                  } else if (destinationController
                                      .text.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message:
                                          "Please fill destination address!",
                                    );
                                  } else if (receiversNameController
                                      .text.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please fill receiver's name!",
                                    );
                                  } else if (receiversNumberController
                                      .text.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please fill receiver's number!",
                                    );
                                  } else if (selectedVehicle == null) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please select a vehicle!",
                                    );
                                  } else if (selectedBookingType == null) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please select booking type!",
                                    );
                                  }
                                } else {
                                  await getDistanceAddress(
                                      bookingsTypeId, vehicleId);
                                  if (double.parse(distance0!) <= 1.0) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message:
                                          "Distance should be greater than 1.0 Km!",
                                    );
                                    setState(() {
                                      isLoading = false;
                                    });
                                  } else {
                                    await getDistanceAddress(
                                        bookingsTypeId, vehicleId!);

                                    addSingleData = {
                                      "type": "booking",
                                      "vehicles_id": vehicleId,
                                      "delivery_charges": totalDeliveryAmount0,
                                      "service_running": serviceRunning,
                                      "total_svc_running_charges":
                                          totalServiceCharges,
                                      "total_tollgate_charges":
                                          totalTollGateCharges ?? "0",
                                      "svc_running_charges0": serviceCharges0,
                                      "tollgate_charges0":
                                          tollGateCharges0 ?? "0",
                                      "bookings_types_id": bookingsTypeId,
                                      "delivery_type": selectedRadio == 1
                                          ? "Single"
                                          : "Multiple",
                                      "pickup_address": pickupController.text,
                                      "pickup_latitude": pickupLat0,
                                      "pickup_longitude": pickupLng0,
                                      "destin_address":
                                          destinationController.text,
                                      "destin_latitude": destinLat0,
                                      "destin_longitude": destinLng0,
                                      "destin_distance": distance0,
                                      "destin_time": duration0,
                                      "destin_delivery_charges":
                                          totalDeliveryAmount0,
                                      "destin_vat_charges": totalVatCharges0,
                                      "destin_total_charges":
                                          roundedTotalAmount0 ?? "0.00",
                                      "destin_discount": "0.00",
                                      "destin_discounted_charges": "0.00",
                                      "receiver_name":
                                          receiversNameController.text,
                                      "receiver_phone":
                                          receiversNumberController.text,
                                    };
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ConfirmSingleDetailsScreen(
                                          singleData: addSingleData,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                              if (selectedRadio == 2) {
                                if (pickupControllers.isEmpty &&
                                    destinationControllers.isEmpty &&
                                    receiversNameControllers.isEmpty &&
                                    receiversNumberControllers.isEmpty &&
                                    selectedVehicle == null &&
                                    selectedBookingType == null &&
                                    pickupControllers.length < 2 &&
                                    destinationControllers.length < 2 &&
                                    receiversNameControllers.length < 2 &&
                                    receiversNumberControllers.length < 2) {
                                  if (pickupControllers.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please fill pickup address!",
                                    );
                                  } else if (destinationControllers.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message:
                                          "Please fill destination address!",
                                    );
                                  } else if (receiversNameControllers.isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please fill receiver's name!",
                                    );
                                  } else if (receiversNumberControllers
                                      .isEmpty) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please fill receiver's number!",
                                    );
                                  } else if (selectedVehicle == null) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please select a vehicle!",
                                    );
                                  } else if (selectedBookingType == null) {
                                    CustomToast.showToast(
                                      fontSize: 12,
                                      message: "Please select booking type!",
                                    );
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  if (pickupControllers.isEmpty &&
                                      destinationControllers.isEmpty &&
                                      receiversNameControllers.isEmpty &&
                                      receiversNumberControllers.isEmpty &&
                                      selectedVehicle == null &&
                                      selectedBookingType == null &&
                                      pickupControllers.length < 2 &&
                                      destinationControllers.length < 2 &&
                                      receiversNameControllers.length < 2 &&
                                      receiversNumberControllers.length < 2) {
                                    if (pickupControllers.isEmpty) {
                                      CustomToast.showToast(
                                        fontSize: 12,
                                        message: "Please fill pickup address!",
                                      );
                                    } else if (destinationControllers.isEmpty) {
                                      CustomToast.showToast(
                                        fontSize: 12,
                                        message:
                                            "Please fill destination address!",
                                      );
                                    } else if (receiversNameControllers
                                        .isEmpty) {
                                      CustomToast.showToast(
                                        fontSize: 12,
                                        message: "Please fill receiver's name!",
                                      );
                                    } else if (receiversNumberControllers
                                        .isEmpty) {
                                      CustomToast.showToast(
                                        fontSize: 12,
                                        message:
                                            "Please fill receiver's number!",
                                      );
                                    } else if (selectedVehicle == null) {
                                      CustomToast.showToast(
                                        fontSize: 12,
                                        message: "Please select a vehicle!",
                                      );
                                    } else if (selectedBookingType == null) {
                                      CustomToast.showToast(
                                        fontSize: 12,
                                        message: "Please select booking type!",
                                      );
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                  } else {
                                    await getDistanceAddress(
                                        bookingsTypeId, vehicleId);

                                    if (getDistanceAddressesModel.status ==
                                        "success") {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return WillPopScope(
                                            onWillPop: () async =>
                                                !isLoading, // Prevents dialog from closing when isLoading is true
                                            child: Dialog(
                                              backgroundColor: Colors
                                                  .transparent, // Make dialog transparent
                                              elevation: 0, // Remove shadow
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CircularProgressIndicator(
                                                      color: orangeColor,
                                                      strokeWidth: 2,
                                                    ), // Your progress indicator
                                                    const SizedBox(height: 20),
                                                    const Text(
                                                      'Loading Data...',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontFamily:
                                                            'Inter-Bold',
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'Please wait while data is being loaded.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Regular',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                      // Add a delay to ensure data is populated in allDataForIndexes1
                                    }

                                    Future.delayed(const Duration(seconds: 2),
                                        () async {
                                      // Close the loading dialog
                                      // Navigator.of(context).pop();

                                      if (filteredData.isNotEmpty &&
                                          pickupLat0 != null &&
                                          pickupLat1 != null) {
                                        addMultipleData = {
                                          "type": "booking",
                                          "totalChargesM": totalChargesM,
                                          "totalVatM": totalVatM,
                                          "vehicles_id": vehicleId,
                                          "service_running": serviceRunning,
                                          "total_svc_running_charges":
                                              totalServiceCharges,
                                          "total_tollgate_charges":
                                              totalTollGateCharges ?? "0",
                                          "svc_running_charges0":
                                              serviceCharges0,
                                          "tollgate_charges0":
                                              tollGateCharges0 ?? "0",
                                          "svc_running_charges1":
                                              serviceCharges1,
                                          "tollgate_charges1":
                                              tollGateCharges1 ?? "0",
                                          "svc_running_charges2":
                                              serviceCharges2,
                                          "tollgate_charges2":
                                              tollGateCharges2 ?? "0",
                                          "svc_running_charges3":
                                              serviceCharges3,
                                          "tollgate_charges3":
                                              tollGateCharges3 ?? "0",
                                          "svc_running_charges4":
                                              serviceCharges4,
                                          "tollgate_charges4":
                                              tollGateCharges4 ?? "0",
                                          "bookings_types_id": bookingsTypeId,
                                          "delivery_type": selectedRadio == 1
                                              ? "Single"
                                              : "Multiple",
                                          "pickup_latitude0":
                                              "$pickupLat0" != 'null'
                                                  ? "$pickupLat0"
                                                  : "0",
                                          "pickup_longitude0":
                                              "$pickupLng0" != 'null'
                                                  ? "$pickupLng0"
                                                  : "0",
                                          "destin_latitude0":
                                              "$destinLat0" != 'null'
                                                  ? "$destinLat0"
                                                  : "0",
                                          "destin_longitude0":
                                              "$destinLng0" != 'null'
                                                  ? "$destinLng0"
                                                  : "0",
                                          "pickup_latitude1":
                                              "$pickupLat1" != 'null'
                                                  ? "$pickupLat1"
                                                  : "0",
                                          "pickup_longitude1":
                                              "$pickupLng1" != 'null'
                                                  ? "$pickupLng1"
                                                  : "0",
                                          "destin_latitude1":
                                              "$destinLat1" != 'null'
                                                  ? "$destinLat1"
                                                  : "0",
                                          "destin_longitude1":
                                              "$destinLng1" != 'null'
                                                  ? "$destinLng1"
                                                  : "0",
                                          "pickup_latitude2":
                                              "$pickupLat2" != 'null'
                                                  ? "$pickupLat2"
                                                  : "0",
                                          "pickup_longitude2":
                                              "$pickupLat2" != 'null'
                                                  ? "$pickupLat2"
                                                  : "0",
                                          "destin_latitude2":
                                              "$destinLat2" != 'null'
                                                  ? "$destinLat2"
                                                  : "0",
                                          "destin_longitude2":
                                              "$destinLng2" != 'null'
                                                  ? "$destinLng2"
                                                  : "0",
                                          "pickup_latitude3":
                                              "$pickupLat3" != 'null'
                                                  ? "$pickupLat3"
                                                  : "0",
                                          "pickup_longitude3":
                                              "$pickupLng3" != 'null'
                                                  ? "$pickupLng3"
                                                  : "0",
                                          "destin_latitude3":
                                              "$destinLat3" != 'null'
                                                  ? "$destinLat3"
                                                  : "0",
                                          "destin_longitude3":
                                              "$destinLng3" != 'null'
                                                  ? "$destinLng3"
                                                  : "0",
                                          "pickup_latitude4":
                                              "$pickupLng4" != 'null'
                                                  ? "$pickupLng4"
                                                  : "0",
                                          "pickup_longitude4":
                                              "$pickupLng4" != 'null'
                                                  ? "$pickupLng4"
                                                  : "0",
                                          "destin_latitude4":
                                              "$destinLat4" != 'null'
                                                  ? "$destinLat4"
                                                  : "0",
                                          "destin_longitude4":
                                              "$destinLng4" != 'null'
                                                  ? "$destinLng4"
                                                  : "0",
                                          "destin_distance0": distance0,
                                          "destin_time0": duration0,
                                          "destin_delivery_charges0":
                                              totalDeliveryAmount0 ?? "0.00",
                                          "destin_vat_charges0":
                                              totalVatCharges0,
                                          "destin_total_charges0":
                                              roundedTotalAmount0,
                                          "destin_discount0": "0.00",
                                          "destin_discounted_charges0": "0.00",
                                          "destin_distance1": distance1,
                                          "destin_time1": duration1,
                                          "destin_delivery_charges1":
                                              totalDeliveryAmount1 ?? "0.00",
                                          "destin_vat_charges1":
                                              totalVatCharges1 ?? "0.00",
                                          "destin_total_charges1":
                                              roundedTotalAmount1 ?? "0.00",
                                          "destin_discount1": "0.00",
                                          "destin_discounted_charges1": "0.00",
                                          "destin_distance2":
                                              distance2 ?? "0.00",
                                          "destin_time2": duration2,
                                          "destin_delivery_charges2":
                                              totalDeliveryAmount2 ?? "0.00",
                                          "destin_vat_charges2":
                                              totalVatCharges2 ?? "0.00",
                                          "destin_total_charges2":
                                              roundedTotalAmount2 ?? "0.00",
                                          "destin_discount2": "0.00",
                                          "destin_discounted_charges2": "0.00",
                                          "destin_distance3":
                                              distance3 ?? "0.00",
                                          "destin_time3": duration3,
                                          "destin_delivery_charges3":
                                              totalDeliveryAmount3 ?? "0.00",
                                          "destin_vat_charges3":
                                              totalVatCharges3 ?? "0.00",
                                          "destin_total_charges3":
                                              roundedTotalAmount3 ?? "0.00",
                                          "destin_discount3": "0.00",
                                          "destin_discounted_charges3": "0.00",
                                          "destin_distance4":
                                              distance4 ?? "0.00",
                                          "destin_time4": duration4,
                                          "destin_delivery_charges4":
                                              totalDeliveryAmount4 ?? "0.00",
                                          "destin_vat_charges4":
                                              totalVatCharges4 ?? "0.00",
                                          "destin_total_charges4":
                                              roundedTotalAmount4 ?? "0.00",
                                          "destin_discount4": "0.00",
                                          "destin_discounted_charges4": "0.00",
                                        };

                                        debugPrint(
                                            "filteredData: $filteredData");

                                        List<Map<int, dynamic>> indexData =
                                            List.filled(5, {});

                                        for (var i = 0;
                                            i < filteredData.length;
                                            i++) {
                                          final dataForIndex = filteredData[i];
                                          final dataIndexString = dataForIndex
                                              .keys
                                              .first; // Get the index as a String
                                          final dataIndex =
                                              int.tryParse(dataIndexString);

                                          if (dataIndex != null &&
                                              dataIndex >= 0 &&
                                              dataIndex <= 4) {
                                            indexData[dataIndex] = dataForIndex
                                                .map((key, value) => MapEntry(
                                                    int.parse(key), value));
                                          } else {
                                            debugPrint(
                                                "Invalid or out of bounds index: $dataIndexString");
                                          }
                                        }

                                        // Separate the data into different lists based on their indices
                                        Map<int, dynamic> indexData0 =
                                            indexData[0];
                                        Map<int, dynamic> indexData1 =
                                            indexData[1];
                                        Map<int, dynamic> indexData2 =
                                            indexData[2];
                                        Map<int, dynamic> indexData3 =
                                            indexData[3];
                                        Map<int, dynamic> indexData4 =
                                            indexData[4];

                                        debugPrint("indexData0: $indexData0");
                                        debugPrint("indexData1: $indexData1");
                                        debugPrint("indexData2: $indexData2");
                                        debugPrint("indexData3: $indexData3");
                                        debugPrint("indexData4: $indexData4");
                                        print(
                                            "addMultipleData: $addMultipleData");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ConfirmMultipleDetailsScreen(
                                              indexData0: indexData0,
                                              indexData1: indexData1,
                                              indexData2: indexData2,
                                              indexData3: indexData3,
                                              indexData4: indexData4,
                                              multipleData: addMultipleData,
                                            ),
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          // barrierDismissible:
                                          //     false, // Prevents dialog from closing when tapping outside
                                          builder: (context) {
                                            return Dialog(
                                              backgroundColor: Colors
                                                  .transparent, // Make dialog transparent
                                              elevation: 0, // Remove shadow
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Your progress indicator
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Error',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontFamily:
                                                            'Inter-Bold',
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                    Text(
                                                      'Please Fill the Both Delivery Fields.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Regular',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    });
                                  }
                                }
                              }
                            },
                            child: isLoading
                                ? buttonGradientSmallWithLoader(
                                    "Please Wait...",
                                    context,
                                  )
                                : buttonGradientSmall(
                                    "FIND RIDER",
                                    context,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/info-icon.svg",
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            'Note: Distance must be greater than 1 kilometer (km)',
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 10,
                              fontFamily: 'Inter-Bold',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            "assets/images/info-icon.svg",
                          ),
                          SizedBox(width: size.width * 0.02),
                          Text(
                            'Note: Please drag down to see your location on the map.',
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 10,
                              fontFamily: 'Inter-Bold',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.22),
                  ],
                ),
              ],
            )
          : Center(
              child: Container(
                width: 100,
                height: 100,
                color: transparentColor,
                child: lottie.Lottie.asset(
                  'assets/images/loading-icon.json',
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   var size = MediaQuery.of(context).size;
  //   return GestureDetector(
  //     onTap: () {
  //       FocusManager.instance.primaryFocus?.unfocus();
  //     },
  //     child: Scaffold(
  //       backgroundColor: bgColor,
  //       body: doubleSystemLat != null
  //           ? Container(
  //               color: transparentColor,
  //               width: size.width,
  //               height: size.height,
  //               child: Stack(
  //                 children: [
  //                   Container(
  //                     color: transparentColor,
  //                     width: size.width,
  //                     height: size.height * 0.631,
  //                     child: GoogleMap(
  //                       onMapCreated: (controller) {
  //                         mapController = controller;
  //                       },
  //                       mapType: MapType.normal,
  //                       myLocationEnabled: true,
  //                       zoomControlsEnabled: false,
  //                       padding: const EdgeInsets.only(top: 410, right: 10),
  //                       initialCameraPosition: CameraPosition(
  //                         target: LatLng(
  //                           doubleSystemLat != null ? doubleSystemLat! : 0.0,
  //                           doubleSystemLng != null ? doubleSystemLng! : 0.0,
  //                         ),
  //                         zoom: 6,
  //                       ),
  //                       markers: {
  //                         if (currentLocation != null)
  //                           Marker(
  //                             markerId: const MarkerId('currentLocation'),
  //                             position: currentLocation!,
  //                             icon: customMarkerIcon ??
  //                                 BitmapDescriptor.defaultMarker,
  //                           ),
  //                         if (selectedLocation != null)
  //                           Marker(
  //                             markerId: const MarkerId('selectedLocation'),
  //                             position: selectedLocation!,
  //                             icon: customMarkerIcon ??
  //                                 BitmapDescriptor.defaultMarker,
  //                           ),
  //                         if (selectedAddressLocation != null)
  //                           Marker(
  //                             markerId:
  //                                 const MarkerId('selectedAddressLocation'),
  //                             position: selectedAddressLocation!,
  //                             icon: customMarkerIcon ??
  //                                 BitmapDescriptor.defaultMarker,
  //                           ),
  //                       },
  //                     ),
  //                   ),
  //                   Align(
  //                     alignment: Alignment.topCenter,
  //                     child: bottomDetailsSheet(
  //                       context,
  //                     ), // Add the bottom sheet here
  //                   ),
  //                 ],
  //               ),
  //             )
  //           : Center(
  //               child: Container(
  //                 width: 100,
  //                 height: 100,
  //                 color: transparentColor,
  //                 child: lottie.Lottie.asset(
  //                   'assets/images/loading-icon.json',
  //                   fit: BoxFit.cover,
  //                 ),
  //               ),
  //             ),
  //     ),
  //   );
  // }

  List<TextEditingController> pickupControllers =
      List.generate(5, (_) => TextEditingController());
  List<TextEditingController> destinationControllers =
      List.generate(5, (_) => TextEditingController());
  List<TextEditingController> receiversNameControllers =
      List.generate(5, (_) => TextEditingController());
  List<TextEditingController> receiversNumberControllers =
      List.generate(5, (_) => TextEditingController());

  Widget singleTextField() {
    var size = MediaQuery.of(context).size;
    Text('API Hits in Single: $apiHitCount');
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      color: transparentColor,
      width: size.width,
      height: size.height * 0.3,
      child: Row(
        children: [
          SizedBox(width: size.width * 0.02),
          SvgPicture.asset('assets/images/home-location-path-icon.svg'),
          SizedBox(width: size.width * 0.02),
          SingleChildScrollView(
            child: Column(
              children: [
                // Text('API Hits: $apiHitCount'),
                isSelectedAddress == true
                    ? Container(
                        color: transparentColor,
                        width: size.width * 0.85,
                        child: Stack(
                          children: [
                            TextFormField(
                              controller: pickupController,
                              onChanged: (value) {
                                addresses.toList();
                              },
                              onTap: () {
                                setState(() {
                                  addressesVisible =
                                      true; // Show the list when the text field is tapped.
                                });
                              },
                              cursorColor: orangeColor,
                              keyboardType: TextInputType.text,
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
                                hintText: "Pickup Location",
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                              ),
                            ),
                            if (addressesVisible)
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: filledColor,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  width: size.width * 0.8,
                                  height: size.height * 0.2,
                                  child: ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    itemCount: getAddressesModel.data!.length,
                                    itemBuilder: (context, index) {
                                      final addresses =
                                          getAddressesModel.data![index];
                                      return ListTile(
                                        title: Text("${addresses.name}"),
                                        subtitle: Text(addresses.address ?? ''),
                                        onTap: () {
                                          addressesVisible = false;
                                          pickupController.text =
                                              "${addresses.address}";
                                          final double savedLat = double.parse(
                                              "${addresses.latitude}");
                                          final double savedLng = double.parse(
                                              "${addresses.longitude}");
                                          const double zoomLevel = 15.0;
                                          onPickUpLocationSavedAddresses(
                                              LatLng(savedLat, savedLng),
                                              zoomLevel);
                                          addressLat = savedLat.toString();
                                          addressLng = savedLng.toString();
                                          setState(() {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            debugPrint(
                                                "addressLat: $addressLat");
                                            debugPrint(
                                                "addressLng $addressLng");
                                            debugPrint(
                                                "addressLocation: ${addresses.address}");
                                          });
                                          // Move the map camera to the selected location
                                          mapController?.animateCamera(
                                              CameraUpdate.newLatLng(
                                                  selectedAddressLocation!));
                                        },
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Divider(
                                        color: textHaveAccountColor,
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    : Container(
                        color: transparentColor,
                        width: size.width * 0.85,
                        child: Stack(
                          children: [
                            TextFormField(
                              controller: pickupController,
                              onChanged: (value) {
                                searchPickUpPlaces(value);
                              },
                              onTap: () {
                                // pickupController.clear();
                                pickUpPredictions.clear();
                              },
                              cursorColor: orangeColor,
                              keyboardType: TextInputType.text,
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
                                hintText: "Pickup Location",
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    getCurrentLocation();
                                  },
                                  child: Container(
                                    color: transparentColor,
                                    child: SvgPicture.asset(
                                      'assets/images/gps-icon.svg',
                                      fit: BoxFit.scaleDown,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (pickUpPredictions.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 40),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: filledColor,
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  width: size.width * 0.8,
                                  height: size.height * 0.2,
                                  child: ListView.separated(
                                    scrollDirection: Axis.vertical,
                                    itemCount: pickUpPredictions.length,
                                    itemBuilder: (context, index) {
                                      final prediction =
                                          pickUpPredictions[index];
                                      return ListTile(
                                        title: Text(prediction.name),
                                        subtitle: Text(
                                            prediction.formattedAddress ?? ''),
                                        onTap: () {
                                          pickupController.text =
                                              prediction.formattedAddress!;
                                          final double lat =
                                              prediction.geometry!.location.lat;
                                          final double lng =
                                              prediction.geometry!.location.lng;
                                          const double zoomLevel = 15.0;
                                          onPickUpLocationSelected(
                                              LatLng(lat, lng), zoomLevel);
                                          pickupLat = lat.toString();
                                          pickupLng = lng.toString();
                                          setState(() {
                                            pickUpPredictions.clear();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            debugPrint("pickupLat: $pickupLat");
                                            debugPrint("pickupLng $pickupLng");
                                            debugPrint(
                                                "pickupLocation: ${prediction.formattedAddress}");
                                          });
                                          // Move the map camera to the selected location
                                          mapController?.animateCamera(
                                              CameraUpdate.newLatLng(
                                                  selectedLocation!));
                                        },
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Divider(
                                        color: textHaveAccountColor,
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                SizedBox(height: size.height * 0.015),
                Container(
                  color: transparentColor,
                  width: size.width * 0.85,
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: destinationController,
                        onChanged: (value) {
                          searchDestinationPlaces(value);
                        },
                        onTap: () {
                          // destinationController.clear();
                          destinationPredictions.clear();
                        },
                        cursorColor: orangeColor,
                        keyboardType: TextInputType.text,
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
                          hintText: "Destination",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 12,
                            fontFamily: 'Inter-Light',
                          ),
                        ),
                      ),
                      if (destinationPredictions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Container(
                            decoration: BoxDecoration(
                              color: filledColor,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            width: size.width * 0.8,
                            height: size.height * 0.2,
                            child: ListView.separated(
                              scrollDirection: Axis.vertical,
                              itemCount: destinationPredictions.length,
                              itemBuilder: (context, index) {
                                final prediction =
                                    destinationPredictions[index];
                                return ListTile(
                                  title: Text(prediction.name),
                                  subtitle:
                                      Text(prediction.formattedAddress ?? ''),
                                  onTap: () {
                                    destinationController.text =
                                        prediction.formattedAddress!;
                                    final double lat =
                                        prediction.geometry!.location.lat;
                                    final double lng =
                                        prediction.geometry!.location.lng;
                                    destinationLat = lat.toString();
                                    destinationLng = lng.toString();
                                    setState(() {
                                      destinationPredictions.clear();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      debugPrint(
                                          "destinationLat: $destinationLat");
                                      debugPrint(
                                          "destinationLng $destinationLng");
                                      debugPrint(
                                          "destinationLocation: ${prediction.formattedAddress}");
                                    });
                                  },
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  color: textHaveAccountColor,
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Container(
                  color: transparentColor,
                  width: size.width * 0.85,
                  child: TextFormField(
                    controller: receiversNameController,
                    cursorColor: orangeColor,
                    keyboardType: TextInputType.text,
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
                      hintText: "Receiver's Name",
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontSize: 12,
                        fontFamily: 'Inter-Light',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Container(
                  color: transparentColor,
                  width: size.width * 0.85,
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    controller: receiversNumberController,
                    cursorColor: orangeColor,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Contact Number is required!';
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 14,
                      fontFamily: 'Inter-Regular',
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      filled: true,
                      fillColor: filledColor,
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
                      // contentPadding: EdgeInsets.symmetric(
                      //   horizontal: screenWidth * 0.04,
                      //   vertical: screenHeight * 0.02,
                      // ),
                      hintText: "Contact Number",
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontSize: 12,
                        fontFamily: 'Inter-Light',
                      ),
                      prefixIcon: GestureDetector(
                        onTap: () async {
                          final code =
                              await countryPicker.showPicker(context: context);
                          setState(() {
                            countryCode = code;
                          });
                          debugPrint('countryName: ${countryCode!.name}');
                          debugPrint('countryCode: ${countryCode!.code}');
                          debugPrint(
                              'countryDialCode: ${countryCode!.dialCode}');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Container(
                                child: countryCode != null
                                    ? Image.asset(
                                        countryCode!.flagUri,
                                        package: countryCode!.flagImagePackage,
                                        width: 25,
                                        height: 20,
                                      )
                                    : SvgPicture.asset(
                                        'assets/images/flag-icon.svg',
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                countryCode?.dialCode ?? "+234",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            Text(
                              '|',
                              style: TextStyle(
                                color: hintColor,
                                fontSize: 12,
                                fontFamily: 'Inter-SemiBold',
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Container(
                //   color: transparentColor,
                //   width: size.width * 0.85,
                //   child: TextFormField(
                //     controller: receiversNumberController,
                //     cursorColor: orangeColor,
                //     keyboardType: TextInputType.phone,
                //     style: TextStyle(
                //       color: blackColor,
                //       fontSize: 14,
                //       fontFamily: 'Inter-Regular',
                //     ),
                //     decoration: InputDecoration(
                //       filled: true,
                //       fillColor: filledColor,
                //       errorStyle: TextStyle(
                //         color: redColor,
                //         fontSize: 10,
                //         fontFamily: 'Inter-Bold',
                //       ),
                //       border: const OutlineInputBorder(
                //         borderRadius: BorderRadius.all(
                //           Radius.circular(10),
                //         ),
                //         borderSide: BorderSide.none,
                //       ),
                //       enabledBorder: const OutlineInputBorder(
                //         borderRadius: BorderRadius.all(
                //           Radius.circular(10),
                //         ),
                //         borderSide: BorderSide.none,
                //       ),
                //       focusedBorder: const OutlineInputBorder(
                //         borderRadius: BorderRadius.all(
                //           Radius.circular(10),
                //         ),
                //         borderSide: BorderSide.none,
                //       ),
                //       focusedErrorBorder: const OutlineInputBorder(
                //         borderRadius: BorderRadius.all(
                //           Radius.circular(10),
                //         ),
                //         borderSide: BorderSide.none,
                //       ),
                //       errorBorder: OutlineInputBorder(
                //         borderRadius: const BorderRadius.all(
                //           Radius.circular(10),
                //         ),
                //         borderSide: BorderSide(
                //           color: redColor,
                //           width: 1,
                //         ),
                //       ),
                //       contentPadding: const EdgeInsets.symmetric(
                //           horizontal: 20, vertical: 10),
                //       hintText: "Receiver's Phone Number",
                //       hintStyle: TextStyle(
                //         color: hintColor,
                //         fontSize: 12,
                //         fontFamily: 'Inter-Light',
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//-----------------#################### IN USE FUNCTION ###############--------------------//
// Function to calculate distance and time for multiple deliveries

  // Future<void> calculateDistanceTimeMultiple(
  //     List<Map<String, double>?> pickupCoordinates,
  //     List<Map<String, double>?> destinationCoordinates) async {
  //   for (int i = 0; i < pickupCoordinates.length; i++) {
  //     final pickupLatLng = pickupCoordinates[i];
  //     final destinationLatLng = destinationCoordinates[i];
  //
  //     if (pickupLatLng != null && destinationLatLng != null) {
  //       final origin =
  //           '${pickupLatLng['latitude']},${pickupLatLng['longitude']}';
  //       final destination =
  //           '${destinationLatLng['latitude']},${destinationLatLng['longitude']}';
  //
  //       try {
  //         final data = await getDistanceAndTime(origin, destination);
  //
  //         String distance = data['rows'][0]['elements'][0]['distance']['text'];
  //         String duration = data['rows'][0]['elements'][0]['duration']['text'];
  //
  //         distances.add(distance);
  //         durations.add(duration);
  //
  //         // Store distances and durations in the list of maps
  //         distanceDurationList.add({
  //           i: {
  //             'distance': distance,
  //             'duration': duration,
  //           }
  //         });
  //         debugPrint("distanceDurationList $distanceDurationList");
  //         for (var i = 0; i < distanceDurationList.length; i++) {
  //           dataForIndex1 = distanceDurationList[i];
  //           dataIndex1 = dataForIndex1.keys.first; // Get the index
  //           distanceData = dataForIndex1[dataIndex1];
  //           // Check if data contains null values
  //           if (distanceData!.containsValue(null)) {
  //             debugPrint(
  //                 "Data for Index in distanceDurationList $dataIndex1: Data contains null values");
  //           } else {
  //             debugPrint(
  //                 "Data for Index in distanceDurationList $dataIndex1: $distanceData");
  //             // Store the data in the distanceDataMap
  //             distanceDataMap[dataIndex1!] = distanceData!;
  //           }
  //         }
  //         debugPrint("Delivery $i - Distance: $distance, Duration: $duration");
  //       } catch (e) {
  //         debugPrint("Error for Delivery $i: $e");
  //       }
  //     } else {
  //       debugPrint("Invalid coordinates for Delivery $i");
  //     }
  //   }
  // }

  List<String> getAddressesFromControllers(
      List<TextEditingController> controllers) {
    List<String> addresses = [];
    for (TextEditingController controller in controllers) {
      addresses.add(controller.text);
    }
    return addresses;
  }

  // Future<Map<String, double>?> getLatLongForAddress(String address) async {
  //   if (address.isNotEmpty) {
  //     try {
  //       final locations = await locationFromAddress(address);
  //       if (locations.isNotEmpty) {
  //         return {
  //           'latitude': locations[0].latitude,
  //           'longitude': locations[0].longitude,
  //         };
  //       } else {
  //         debugPrint('No results for address: $address');
  //         return null;
  //       }
  //     } catch (e) {
  //       debugPrint('Error geocoding address: $address');
  //       print(e);
  //       return null;
  //     }
  //   } else {
  //     debugPrint('Empty address for geocoding');
  //     return null;
  //   }
  // }

  Widget multiPageView() {
    var size = MediaQuery.of(context).size;
    List<String> pickupAddresses =
        getAddressesFromControllers(pickupControllers);
    List<String> destinationAddresses =
        getAddressesFromControllers(destinationControllers);
    List<String> receiversName =
        getAddressesFromControllers(receiversNameControllers);
    List<String> receiversNumber =
        getAddressesFromControllers(receiversNumberControllers);

    // Create a list to store all the geocoding futures

    Future<void> fetchData() async {
      allDataForIndexes1.clear();
      filteredData.clear();
      // Create a list to hold all geocoding futures
      // List<Future<void>> geocodingFutures = [];
      // List<Map<String, double>?> pickupLatLngList =
      //     List.filled(pickupAddresses.length, null);
      // List<Map<String, double>?> destinationLatLngList =
      //     List.filled(destinationAddresses.length, null);
      for (int index = 0;
          index < pickupAddresses.length && index < destinationAddresses.length;
          index++) {
        String pickupAddress = pickupAddresses[index];
        String destinationAddress = destinationAddresses[index];
        String receiverName = receiversName[index];
        String receiverNumber = receiversNumber[index];
        Map<String, dynamic> data = {
          'pickupController': pickupAddress,
          'destinationController': destinationAddress,
          // 'pickupLatLng': null,
          // 'destinationLatLng': null,
          'receiversNameController': receiverName,
          'receiversNumberController': receiverNumber,
        };

        // var pickupLatLngFuture = getLatLongForAddress(pickupAddress);
        // var destinationLatLngFuture = getLatLongForAddress(destinationAddress);
        //
        // geocodingFutures.add(pickupLatLngFuture.then((pickupLatLng) {
        //   if (pickupLatLng != null) {
        //     data['pickupLatLng'] = pickupLatLng;
        //     debugPrint('PickupLatLng for index $index: $pickupLatLng');
        //     pickupLatLngList[index] = pickupLatLng; // Store the pickupLatLng
        //   } else {
        //     debugPrint('Invalid PickupLatLng for index $index');
        //   }
        // }));
        //
        // geocodingFutures.add(destinationLatLngFuture.then((destinationLatLng) {
        //   if (destinationLatLng != null) {
        //     data['destinationLatLng'] = destinationLatLng;
        //     debugPrint(
        //         'DestinationLatLng for index $index: $destinationLatLng');
        //     destinationLatLngList[index] =
        //         destinationLatLng; // Store the destinationLatLng
        //   } else {
        //     debugPrint('Invalid DestinationLatLng for index $index');
        //   }
        // }));
        //
        // await Future.wait([pickupLatLngFuture, destinationLatLngFuture]);

        debugPrint("pickupController: ${data['pickupController']}");
        debugPrint("destinationController: ${data['destinationController']}");
        debugPrint("Data for index $index: $data");
        allDataForIndexes1.add({'$index': data});
        debugPrint(" allDataForIndexes Big: $allDataForIndexes1");
      }

      // Wait for all geocoding operations to complete before calculating distances and durations
      // await Future.wait(geocodingFutures);
      //
      // // Ensure that all geocoding has completed before calculating distances and durations
      // await calculateDistanceTimeMultiple(
      //     pickupLatLngList, destinationLatLngList);
      filteredData = allDataForIndexes1
          .where((entry) => entry.values.every((value) => value != null))
          .toList();
      debugPrint("filteredData: $filteredData");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        color: Colors.transparent,
        height: size.height * 0.295,
        child: PageView.builder(
          controller: pageController,
          scrollDirection: Axis.horizontal,
          onPageChanged: (value) async {
            setState(() {
              currentIndex = value;
              debugPrint('currentIndex: $currentIndex');
            });
            await fetchData();
          },
          itemCount: pages.length,
          itemBuilder: (context, index) {
            TextEditingController pickupController = pickupControllers[index];
            TextEditingController destinationController =
                destinationControllers[index];
            TextEditingController receiversNameController =
                receiversNameControllers[index];
            TextEditingController receiversNumberController =
                receiversNumberControllers[index];

            debugPrint('pageIndex: $index');
            debugPrint('isSelectedAddress: $isSelectedAddress');
            debugPrint('pickupController: ${pickupController.text}');
            debugPrint('destinationController: ${destinationController.text}');
            debugPrint(
                'receiversNameController: ${receiversNameController.text}');
            debugPrint(
                'receiversNumberController: ${receiversNumberController.text}');

            if (index == 1 &&
                pickupController.text.isNotEmpty &&
                destinationController.text.isNotEmpty &&
                receiversNameController.text.isNotEmpty &&
                receiversNumberController.text.isNotEmpty) {
              fetchData();
            } else if (index == 2 &&
                pickupController.text.isNotEmpty &&
                destinationController.text.isNotEmpty &&
                receiversNameController.text.isNotEmpty &&
                receiversNumberController.text.isNotEmpty) {
              fetchData();
            } else if (index == 3 &&
                pickupController.text.isNotEmpty &&
                destinationController.text.isNotEmpty &&
                receiversNameController.text.isNotEmpty &&
                receiversNumberController.text.isNotEmpty) {
              fetchData();
            } else if (index == 4 &&
                pickupController.text.isNotEmpty &&
                destinationController.text.isNotEmpty &&
                receiversNameController.text.isNotEmpty &&
                receiversNumberController.text.isNotEmpty) {
              fetchData();
            }

            return HomeTextFields(
              currentIndex: currentIndex,
              pageController: pageController,
              isSelectedAddress: isSelectedAddress,
              pickupController: pickupController,
              destinationController: destinationController,
              receiversNameController: receiversNameController,
              receiversNumberController: receiversNumberController,
            );
          },
        ),
      ),
    );
  }

  //-----------------#################### IN USE FUNCTION TILL HERE ###############--------------------//

  // Widget bottomDetailsSheet(BuildContext context) {
  //   var size = MediaQuery.of(context).size;
  //   final double screenHeight = MediaQuery.of(context).size.height;
  //   double fontSize = screenHeight * 0.02;
  //   return DraggableScrollableSheet(
  //     initialChildSize: .38,
  //     minChildSize: .38,
  //     maxChildSize: 1,
  //     controller: dragController,
  //     builder: (BuildContext context, ScrollController scrollController) {
  //       return ClipRRect(
  //         borderRadius: const BorderRadius.only(
  //           topLeft: Radius.circular(20),
  //           topRight: Radius.circular(20),
  //         ),
  //         child: SingleChildScrollView(
  //           controller: scrollController,
  //           child: Container(
  //             width: size.width,
  //             height: size.height,
  //             decoration: BoxDecoration(
  //               color: whiteColor,
  //               borderRadius: const BorderRadius.only(
  //                 topLeft: Radius.circular(20),
  //                 topRight: Radius.circular(20),
  //               ),
  //             ),
  //             child: ListView(
  //               controller: scrollController,
  //               physics: const AlwaysScrollableScrollPhysics(),
  //               children: [
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Center(
  //                       child: Container(
  //                         width: size.width * 0.3,
  //                         height: 6,
  //                         decoration: BoxDecoration(
  //                           color: dividerColor,
  //                           borderRadius: BorderRadius.circular(100),
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(height: size.height * 0.03),
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 20),
  //                       child: Text(
  //                         "Select service type",
  //                         textAlign: TextAlign.left,
  //                         style: TextStyle(
  //                           color: drawerTextColor,
  //                           fontSize: 20,
  //                           fontFamily: 'Syne-Bold',
  //                         ),
  //                       ),
  //                     ),
  //                     SizedBox(height: size.height * 0.02),
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         GestureDetector(
  //                           onTap: () async {
  //                             vehiclesType.clear();
  //                             selectedVehicle = null;
  //                             getVehiclesByServiceType(courierId);
  //                             setState(() {
  //                               isSelectedBus = false;
  //                               isSelectedCourier = true;
  //                               debugPrint("courierId: $courierId");
  //                             });
  //                           },
  //                           child: Stack(
  //                             children: [
  //                               Container(
  //                                 color: transparentColor,
  //                                 width:
  //                                     MediaQuery.of(context).size.width * 0.43,
  //                                 height:
  //                                     MediaQuery.of(context).size.height * 0.14,
  //                               ),
  //                               Positioned(
  //                                 bottom: 0,
  //                                 child: Container(
  //                                   width: MediaQuery.of(context).size.width *
  //                                       0.43,
  //                                   height: MediaQuery.of(context).size.height *
  //                                       0.1,
  //                                   decoration: BoxDecoration(
  //                                     gradient: LinearGradient(
  //                                       begin: Alignment.centerRight,
  //                                       end: Alignment.centerLeft,
  //                                       stops: const [0.1, 1.5],
  //                                       colors: [
  //                                         isSelectedCourier == true
  //                                             ? orangeColor
  //                                             : const Color(0xFFEBEBEB),
  //                                         isSelectedCourier == true
  //                                             ? yellowColor
  //                                             : const Color(0xFFEBEBEB),
  //                                       ],
  //                                     ),
  //                                     borderRadius: BorderRadius.circular(15),
  //                                   ),
  //                                 ),
  //                               ),
  //                               Positioned(
  //                                 bottom: 20,
  //                                 left: 0,
  //                                 right: 0,
  //                                 child: Text(
  //                                   "Deliver a Parcel",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: isSelectedCourier == true
  //                                         ? whiteColor
  //                                         : drawerTextColor,
  //                                     fontSize: fontSize,
  //                                     fontFamily: 'Syne-Bold',
  //                                   ),
  //                                 ),
  //                               ),
  //                               Positioned(
  //                                 top: 5,
  //                                 left: 0,
  //                                 right: 0,
  //                                 child: SvgPicture.asset(
  //                                   "assets/images/login-parcel-icon.svg",
  //                                   width: size.width * 0.07,
  //                                   height: size.height * 0.07,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         SizedBox(width: size.width * 0.04),
  //                         GestureDetector(
  //                           onTap: () async {
  //                             vehiclesType.clear();
  //                             selectedVehicle = null;
  //                             getVehiclesByServiceType(otherId);
  //                             setState(() {
  //                               isSelectedBus = true;
  //                               isSelectedCourier = false;
  //                               debugPrint("otherId: $otherId");
  //                             });
  //                           },
  //                           child: Stack(
  //                             children: [
  //                               Container(
  //                                 color: transparentColor,
  //                                 width:
  //                                     MediaQuery.of(context).size.width * 0.43,
  //                                 height:
  //                                     MediaQuery.of(context).size.height * 0.14,
  //                               ),
  //                               Positioned(
  //                                 bottom: 0,
  //                                 child: Container(
  //                                   width: MediaQuery.of(context).size.width *
  //                                       0.43,
  //                                   height: MediaQuery.of(context).size.height *
  //                                       0.1,
  //                                   decoration: BoxDecoration(
  //                                     gradient: LinearGradient(
  //                                       begin: Alignment.centerRight,
  //                                       end: Alignment.centerLeft,
  //                                       stops: const [0.1, 1.5],
  //                                       colors: [
  //                                         isSelectedBus == true
  //                                             ? orangeColor
  //                                             : const Color(0xFFEBEBEB),
  //                                         isSelectedBus == true
  //                                             ? yellowColor
  //                                             : const Color(0xFFEBEBEB),
  //                                       ],
  //                                     ),
  //                                     borderRadius: BorderRadius.circular(15),
  //                                   ),
  //                                 ),
  //                               ),
  //                               Positioned(
  //                                 bottom: 20,
  //                                 left: 0,
  //                                 right: 0,
  //                                 child: Text(
  //                                   "Book a Van",
  //                                   textAlign: TextAlign.center,
  //                                   style: TextStyle(
  //                                     color: isSelectedBus == true
  //                                         ? whiteColor
  //                                         : drawerTextColor,
  //                                     fontSize: fontSize,
  //                                     fontFamily: 'Syne-Bold',
  //                                   ),
  //                                 ),
  //                               ),
  //                               Positioned(
  //                                 top: 5,
  //                                 left: 0,
  //                                 right: 0,
  //                                 child: SvgPicture.asset(
  //                                   "assets/images/login-truck-icon.svg",
  //                                   width: size.width * 0.07,
  //                                   height: size.height * 0.07,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     SizedBox(height: size.height * 0.03),
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 20),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           GestureDetector(
  //                             onTap: () {
  //                               setState(() {
  //                                 for (int i = 0;
  //                                     i < 5 && i < distanceDurationList.length;
  //                                     i++) {
  //                                   final entry = distanceDurationList[i];
  //                                   debugPrint(
  //                                       "distanceDurationList[$i]: $entry");
  //                                 }
  //                               });
  //                             },
  //                             child: Text(
  //                               "Find best rider?",
  //                               textAlign: TextAlign.left,
  //                               style: TextStyle(
  //                                 color: drawerTextColor,
  //                                 fontSize: 20,
  //                                 fontFamily: 'Syne-Bold',
  //                               ),
  //                             ),
  //                           ),
  //                           if (selectedRadio == 1)
  //                             Row(
  //                               children: [
  //                                 GestureDetector(
  //                                   onTap: () {
  //                                     setState(() {
  //                                       isSelectedAddress = true;
  //                                     });
  //                                   },
  //                                   child: isSelectedAddress == true
  //                                       ? GestureDetector(
  //                                           onTap: () {
  //                                             setState(() {
  //                                               isSelectedAddress = false;
  //                                             });
  //                                           },
  //                                           child: SvgPicture.asset(
  //                                             'assets/images/checkmark-icon.svg',
  //                                           ),
  //                                         )
  //                                       : SvgPicture.asset(
  //                                           'assets/images/uncheckmark-icon.svg',
  //                                         ),
  //                                 ),
  //                                 SizedBox(width: size.width * 0.01),
  //                                 Text(
  //                                   "Saved Addresses",
  //                                   textAlign: TextAlign.left,
  //                                   style: TextStyle(
  //                                     color: drawerTextColor,
  //                                     fontSize: 12,
  //                                     fontFamily: 'Syne-Bold',
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           if (selectedRadio == 2)
  //                             Row(
  //                               children: [
  //                                 // GestureDetector(
  //                                 //   onTap: () {
  //                                 //     removePage();
  //                                 //     setState(() {});
  //                                 //   },
  //                                 //   child: SvgPicture.asset(
  //                                 //     'assets/images/minus-icon.svg',
  //                                 //   ),
  //                                 // ),
  //                                 // SizedBox(width: size.width * 0.02),
  //                                 // GestureDetector(
  //                                 //   onTap: () {
  //                                 //     addPage();
  //                                 //     setState(() {});
  //                                 //   },
  //                                 //   child: SvgPicture.asset(
  //                                 //     'assets/images/add-icon.svg',
  //                                 //   ),
  //                                 // ),
  //                                 // SizedBox(width: size.width * 0.03),
  //                                 GestureDetector(
  //                                   onTap: () {
  //                                     setState(() {
  //                                       isSelectedAddress = true;
  //                                     });
  //                                   },
  //                                   child: isSelectedAddress == true
  //                                       ? GestureDetector(
  //                                           onTap: () {
  //                                             setState(() {
  //                                               isSelectedAddress = false;
  //                                             });
  //                                           },
  //                                           child: SvgPicture.asset(
  //                                             'assets/images/checkmark-icon.svg',
  //                                           ),
  //                                         )
  //                                       : SvgPicture.asset(
  //                                           'assets/images/uncheckmark-icon.svg',
  //                                         ),
  //                                 ),
  //                                 SizedBox(width: size.width * 0.01),
  //                                 Text(
  //                                   "Saved\nAddresses",
  //                                   textAlign: TextAlign.left,
  //                                   style: TextStyle(
  //                                     color: drawerTextColor,
  //                                     fontSize: 10,
  //                                     fontFamily: 'Syne-Bold',
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: size.height * 0.005),
  //                     Theme(
  //                       data: ThemeData(
  //                         unselectedWidgetColor: orangeColor,
  //                       ),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Row(
  //                             children: [
  //                               Radio(
  //                                 value: 1,
  //                                 groupValue: selectedRadio,
  //                                 activeColor: orangeColor,
  //                                 visualDensity: VisualDensity.compact,
  //                                 onChanged: (value) {
  //                                   setState(() {
  //                                     selectedRadio = value!;
  //                                   });
  //                                 },
  //                               ),
  //                               Text(
  //                                 "Single Delivery",
  //                                 textAlign: TextAlign.left,
  //                                 style: TextStyle(
  //                                   color: drawerTextColor,
  //                                   fontSize: 14,
  //                                   fontFamily: 'Syne-Bold',
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                           Row(
  //                             children: [
  //                               Radio(
  //                                 value: 2,
  //                                 groupValue: selectedRadio,
  //                                 activeColor: orangeColor,
  //                                 visualDensity: VisualDensity.compact,
  //                                 onChanged: (value) {
  //                                   setState(() {
  //                                     selectedRadio = value!;
  //                                   });
  //                                 },
  //                               ),
  //                               Text(
  //                                 "Multiple Delivery",
  //                                 textAlign: TextAlign.left,
  //                                 style: TextStyle(
  //                                   color: drawerTextColor,
  //                                   fontSize: 14,
  //                                   fontFamily: 'Syne-Bold',
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: size.height * 0.015),
  //                     if (selectedRadio == 1) singleTextField(),
  //                     if (selectedRadio == 2) multiPageView(),
  //                     SizedBox(height: size.height * 0.012),
  //                     Padding(
  //                       padding: const EdgeInsets.only(left: 10, right: 10),
  //                       child: Row(
  //                         children: [
  //                           SvgPicture.asset(
  //                             "assets/images/info-icon.svg",
  //                           ),
  //                           SizedBox(width: size.width * 0.02),
  //                           Expanded(
  //                             child: ButtonTheme(
  //                               alignedDropdown: true,
  //                               child: DropdownButtonHideUnderline(
  //                                 child: DropdownButtonFormField(
  //                                   icon: Padding(
  //                                     padding: const EdgeInsets.only(top: 3),
  //                                     child: SvgPicture.asset(
  //                                       'assets/images/dropdown-icon.svg',
  //                                       width: 5,
  //                                       height: 5,
  //                                       fit: BoxFit.scaleDown,
  //                                     ),
  //                                   ),
  //                                   decoration: InputDecoration(
  //                                     filled: true,
  //                                     fillColor: filledColor,
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
  //                                     errorBorder: OutlineInputBorder(
  //                                       borderRadius: const BorderRadius.all(
  //                                         Radius.circular(10),
  //                                       ),
  //                                       borderSide: BorderSide(
  //                                         color: redColor,
  //                                         width: 1,
  //                                       ),
  //                                     ),
  //                                     contentPadding:
  //                                         const EdgeInsets.symmetric(
  //                                             horizontal: 20, vertical: 10),
  //                                     hintText: 'Select Vehicle',
  //                                     hintStyle: TextStyle(
  //                                       color: hintColor,
  //                                       fontSize: 12,
  //                                       fontFamily: 'Inter-Light',
  //                                     ),
  //                                     errorStyle: TextStyle(
  //                                       color: redColor,
  //                                       fontSize: 10,
  //                                       fontFamily: 'Inter-Bold',
  //                                     ),
  //                                   ),
  //                                   padding: const EdgeInsets.only(right: 5),
  //                                   borderRadius: BorderRadius.circular(10),
  //                                   items: vehiclesType
  //                                       .map(
  //                                         (item) => DropdownMenuItem<String>(
  //                                           value: item,
  //                                           child: Text(
  //                                             item,
  //                                             style: TextStyle(
  //                                               color: blackColor,
  //                                               fontSize: 14,
  //                                               fontFamily: 'Inter-Regular',
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       )
  //                                       .toList(),
  //                                   value: selectedVehicle,
  //                                   onChanged: (value) {
  //                                     setState(() {
  //                                       selectedVehicle = value;
  //                                       debugPrint("selectedVehicle: $value");
  //                                       if (getVehiclesByServiceTypeModel
  //                                               .data !=
  //                                           null) {
  //                                         for (int i = 0;
  //                                             i <
  //                                                 getVehiclesByServiceTypeModel
  //                                                     .data!.length;
  //                                             i++) {
  //                                           if (getVehiclesByServiceTypeModel
  //                                                   .data?[i].name ==
  //                                               value) {
  //                                             vehicleId =
  //                                                 getVehiclesByServiceTypeModel
  //                                                     .data?[i].vehiclesId
  //                                                     .toString();
  //                                             debugPrint(
  //                                                 'vehicleId: ${getVehiclesByServiceTypeModel.data?[i].vehiclesId.toString()}');
  //                                           }
  //                                         }
  //                                       }
  //                                     });
  //                                   },
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: size.height * 0.015),
  //                     Padding(
  //                       padding: const EdgeInsets.only(left: 10, right: 10),
  //                       child: Row(
  //                         children: [
  //                           SvgPicture.asset(
  //                             "assets/images/info-icon.svg",
  //                           ),
  //                           SizedBox(width: size.width * 0.02),
  //                           Expanded(
  //                             child: ButtonTheme(
  //                               alignedDropdown: true,
  //                               child: DropdownButtonHideUnderline(
  //                                 child: DropdownButtonFormField(
  //                                   icon: Padding(
  //                                     padding: const EdgeInsets.only(top: 3),
  //                                     child: SvgPicture.asset(
  //                                       'assets/images/dropdown-icon.svg',
  //                                       width: 5,
  //                                       height: 5,
  //                                       fit: BoxFit.scaleDown,
  //                                     ),
  //                                   ),
  //                                   decoration: InputDecoration(
  //                                     filled: true,
  //                                     fillColor: filledColor,
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
  //                                     errorBorder: OutlineInputBorder(
  //                                       borderRadius: const BorderRadius.all(
  //                                         Radius.circular(10),
  //                                       ),
  //                                       borderSide: BorderSide(
  //                                         color: redColor,
  //                                         width: 1,
  //                                       ),
  //                                     ),
  //                                     contentPadding:
  //                                         const EdgeInsets.symmetric(
  //                                             horizontal: 20, vertical: 10),
  //                                     hintText: 'Select Booking Type',
  //                                     hintStyle: TextStyle(
  //                                       color: hintColor,
  //                                       fontSize: 12,
  //                                       fontFamily: 'Inter-Light',
  //                                     ),
  //                                     errorStyle: TextStyle(
  //                                       color: redColor,
  //                                       fontSize: 10,
  //                                       fontFamily: 'Inter-Bold',
  //                                     ),
  //                                   ),
  //                                   padding: const EdgeInsets.only(right: 5),
  //                                   borderRadius: BorderRadius.circular(10),
  //                                   items: bookingType
  //                                       .map(
  //                                         (item) => DropdownMenuItem<String>(
  //                                           value: item,
  //                                           child: Text(
  //                                             item,
  //                                             style: TextStyle(
  //                                               color: blackColor,
  //                                               fontSize: 14,
  //                                               fontFamily: 'Inter-Regular',
  //                                             ),
  //                                           ),
  //                                         ),
  //                                       )
  //                                       .toList(),
  //                                   value: selectedBookingType,
  //                                   onChanged: (value) async {
  //                                     selectedBookingType = value;
  //                                     debugPrint("selectedBookingType: $value");
  //                                     if (getBookingsTypeModel.data != null) {
  //                                       for (int i = 0;
  //                                           i <
  //                                               getBookingsTypeModel
  //                                                   .data!.length;
  //                                           i++) {
  //                                         if ("${getBookingsTypeModel.data?[i].name}" ==
  //                                             value) {
  //                                           bookingsTypeId =
  //                                               getBookingsTypeModel
  //                                                   .data?[i].bookingsTypesId
  //                                                   .toString();
  //                                           debugPrint(
  //                                               'bookingsTypeId: $bookingsTypeId');
  //                                         }
  //                                       }
  //                                     }
  //                                     setState(() {});
  //                                   },
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     if (selectedRadio == 2)
  //                       Column(
  //                         children: [
  //                           SizedBox(height: size.height * 0.025),
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   if (pageController.page!.toInt() > 0) {
  //                                     pageController.previousPage(
  //                                       duration: const Duration(
  //                                         milliseconds: 500,
  //                                       ),
  //                                       curve: Curves.easeInOut,
  //                                     );
  //                                   }
  //                                 },
  //                                 child: SvgPicture.asset(
  //                                   'assets/images/orange-left-arrow-icon.svg',
  //                                 ),
  //                               ),
  //                               SizedBox(width: size.width * 0.02),
  //                               DotsIndicator(
  //                                 dotsCount: pages.length,
  //                                 position: currentIndex,
  //                                 decorator: DotsDecorator(
  //                                   color: dotsColor, // Inactive color
  //                                   activeColor: orangeColor,
  //                                   spacing: const EdgeInsets.symmetric(
  //                                       horizontal: 3),
  //                                 ),
  //                                 onTap: (index) {
  //                                   pageController.animateToPage(
  //                                     currentIndex = index,
  //                                     duration: const Duration(
  //                                       milliseconds: 500,
  //                                     ),
  //                                     curve: Curves.linear,
  //                                   );
  //                                 },
  //                               ),
  //                               SizedBox(width: size.width * 0.02),
  //                               GestureDetector(
  //                                 onTap: () {
  //                                   if (pageController.page!.toInt() <
  //                                       pages.length - 1) {
  //                                     pageController.nextPage(
  //                                       duration: const Duration(
  //                                         milliseconds: 500,
  //                                       ),
  //                                       curve: Curves.easeInOut,
  //                                     );
  //                                   }
  //                                 },
  //                                 child: SvgPicture.asset(
  //                                   'assets/images/orange-right-arrow-icon.svg',
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     SizedBox(height: size.height * 0.025),
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 20),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           GestureDetector(
  //                             onTap: () async {
  //                               if (selectedRadio == 1) {
  //                                 if (pickupController.text.isEmpty &&
  //                                     destinationController.text.isEmpty &&
  //                                     receiversNameController.text.isEmpty &&
  //                                     receiversNumberController.text.isEmpty &&
  //                                     selectedVehicle == null &&
  //                                     selectedBookingType == null) {
  //                                   if (pickupController.text.isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please fill pickup address!",
  //                                     );
  //                                   } else if (destinationController
  //                                       .text.isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message:
  //                                           "Please fill destination address!",
  //                                     );
  //                                   } else if (receiversNameController
  //                                       .text.isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please fill receiver's name!",
  //                                     );
  //                                   } else if (receiversNumberController
  //                                       .text.isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message:
  //                                           "Please fill receiver's number!",
  //                                     );
  //                                   } else if (selectedVehicle == null) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please select a vehicle!",
  //                                     );
  //                                   } else if (selectedBookingType == null) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please select booking type!",
  //                                     );
  //                                   }
  //                                 } else {
  //                                   setState(() {
  //                                     isLoading2 = true;
  //                                   });
  //                                   await getDistanceAddress(
  //                                       bookingsTypeId, vehicleId);
  //                                   if (double.parse(distance0!) <= 1.0) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message:
  //                                           "Distance should be greater than 1.0 Km!",
  //                                     );
  //                                     setState(() {
  //                                       isLoading2 = false;
  //                                     });
  //                                   } else {
  //                                     // await getDistanceAddress(bookingsTypeId);

  //                                     addSingleData = {
  //                                       "type": "schedule",
  //                                       "vehicles_id": vehicleId,
  //                                       "delivery_charges":
  //                                           totalDeliveryAmount0,
  //                                       "service_running": serviceRunning,
  //                                       "total_svc_running_charges":
  //                                           totalServiceCharges,
  //                                       "total_tollgate_charges":
  //                                           totalTollGateCharges ?? "0",
  //                                       "svc_running_charges0": serviceCharges0,
  //                                       "tollgate_charges0":
  //                                           tollGateCharges0 ?? "0",
  //                                       "bookings_types_id": bookingsTypeId,
  //                                       "delivery_type": selectedRadio == 1
  //                                           ? "Single"
  //                                           : "Multiple",
  //                                       "pickup_address": pickupController.text,
  //                                       "pickup_latitude": pickupLat0,
  //                                       "pickup_longitude": pickupLng0,
  //                                       "destin_address":
  //                                           destinationController.text,
  //                                       "destin_latitude": destinLat0,
  //                                       "destin_longitude": destinLng0,
  //                                       "destin_distance": distance0,
  //                                       "destin_time": duration0,
  //                                       "destin_delivery_charges":
  //                                           totalDeliveryAmount0,
  //                                       "destin_vat_charges": totalVatCharges0,
  //                                       "destin_total_charges":
  //                                           roundedTotalAmount0 ?? "0.00",
  //                                       "destin_discount": "0.00",
  //                                       "destin_discounted_charges": "0.00",
  //                                       "receiver_name":
  //                                           receiversNameController.text,
  //                                       "receiver_phone":
  //                                           receiversNumberController.text,
  //                                     };
  //                                     setState(() {
  //                                       isLoading2 = false;
  //                                     });
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                         builder: (context) =>
  //                                             ScheduleRideScreen(
  //                                           selectedRadio: selectedRadio,
  //                                           scheduledSingleData: addSingleData,
  //                                         ),
  //                                       ),
  //                                     );
  //                                   }
  //                                 }
  //                               }
  //                               if (selectedRadio == 2) {
  //                                 if (pickupControllers.isEmpty) {
  //                                   CustomToast.showToast(
  //                                     fontSize: 12,
  //                                     message: "Please fill the all fields",
  //                                   );
  //                                 }
  //                                 showDialog(
  //                                   context: context,
  //                                   // barrierDismissible:
  //                                   //     false, // Prevents dialog from closing when tapping outside
  //                                   builder: (context) {
  //                                     return Dialog(
  //                                       backgroundColor: Colors
  //                                           .transparent, // Make dialog transparent
  //                                       elevation: 0, // Remove shadow
  //                                       child: Container(
  //                                         padding: const EdgeInsets.all(20),
  //                                         decoration: BoxDecoration(
  //                                           color: Colors.white,
  //                                           borderRadius:
  //                                               BorderRadius.circular(10),
  //                                         ),
  //                                         child: Column(
  //                                           mainAxisSize: MainAxisSize.min,
  //                                           children: [
  //                                             CircularProgressIndicator(
  //                                               color: orangeColor,
  //                                               strokeWidth: 2,
  //                                             ), // Your progress indicator
  //                                             const SizedBox(height: 20),
  //                                             const Text(
  //                                               'Loading Data...',
  //                                               style: TextStyle(
  //                                                 color: Colors.black,
  //                                                 fontSize: 20,
  //                                                 fontFamily: 'Inter-Bold',
  //                                               ),
  //                                             ),
  //                                             const SizedBox(height: 10),
  //                                             const Text(
  //                                               'Please wait while data is being loaded.',
  //                                               textAlign: TextAlign.center,
  //                                               style: TextStyle(
  //                                                 color: Colors.black,
  //                                                 fontSize: 14,
  //                                                 fontFamily: 'Inter-Regular',
  //                                               ),
  //                                             ),
  //                                           ],
  //                                         ),
  //                                       ),
  //                                     );
  //                                   },
  //                                 );
  //                                 await getDistanceAddress(
  //                                     bookingsTypeId, vehicleId);
  //                                 // Add a delay to ensure data is populated in allDataForIndexes1
  //                                 Future.delayed(const Duration(seconds: 1),
  //                                     () async {
  //                                   // Close the loading dialog

  //                                   if (filteredData.isNotEmpty) {
  //                                     if (distance0 != null &&
  //                                             double.parse(distance0!) <= 1.0 ||
  //                                         distance1 != null &&
  //                                             double.parse(distance1!) <= 1.0 ||
  //                                         distance2 != null &&
  //                                             double.parse(distance2!) <= 1.0 ||
  //                                         distance3 != null &&
  //                                             double.parse(distance3!) <= 1.0 ||
  //                                         distance4 != null &&
  //                                             double.parse(distance4!) <= 1.0) {
  //                                       CustomToast.showToast(
  //                                         fontSize: 12,
  //                                         message:
  //                                             "Distance should be greater than 1.0 Km!",
  //                                       );
  //                                     } else {
  //                                       // await getDistanceAddress(
  //                                       //     bookingsTypeId);
  //                                       addMultipleData = {
  //                                         "type": "schedule",
  //                                         "vehicles_id": vehicleId,
  //                                         "totalChargesM": totalChargesM,
  //                                         "totalVatM": totalVatM,
  //                                         "service_running": serviceRunning,
  //                                         "total_svc_running_charges":
  //                                             totalServiceCharges,
  //                                         "total_tollgate_charges":
  //                                             totalTollGateCharges ?? "0",
  //                                         "svc_running_charges0":
  //                                             serviceCharges0,
  //                                         "tollgate_charges0":
  //                                             tollGateCharges0 ?? "0",
  //                                         "svc_running_charges1":
  //                                             serviceCharges1,
  //                                         "tollgate_charges1":
  //                                             tollGateCharges1 ?? "0",
  //                                         "svc_running_charges2":
  //                                             serviceCharges2,
  //                                         "tollgate_charges2":
  //                                             tollGateCharges2 ?? "0",
  //                                         "svc_running_charges3":
  //                                             serviceCharges3,
  //                                         "tollgate_charges3":
  //                                             tollGateCharges3 ?? "0",
  //                                         "svc_running_charges4":
  //                                             serviceCharges4,
  //                                         "tollgate_charges4":
  //                                             tollGateCharges4 ?? "0",
  //                                         "bookings_types_id": bookingsTypeId,
  //                                         "delivery_type": selectedRadio == 1
  //                                             ? "Single"
  //                                             : "Multiple",
  //                                         "pickup_latitude0":
  //                                             "$pickupLat0" != 'null'
  //                                                 ? "$pickupLat0"
  //                                                 : "0",
  //                                         "pickup_longitude0":
  //                                             "$pickupLng0" != 'null'
  //                                                 ? "$pickupLng0"
  //                                                 : "0",
  //                                         "destin_latitude0":
  //                                             "$destinLat0" != 'null'
  //                                                 ? "$destinLat0"
  //                                                 : "0",
  //                                         "destin_longitude0":
  //                                             "$destinLng0" != 'null'
  //                                                 ? "$destinLng0"
  //                                                 : "0",
  //                                         "pickup_latitude1":
  //                                             "$pickupLat1" != 'null'
  //                                                 ? "$pickupLat1"
  //                                                 : "0",
  //                                         "pickup_longitude1":
  //                                             "$pickupLng1" != 'null'
  //                                                 ? "$pickupLng1"
  //                                                 : "0",
  //                                         "destin_latitude1":
  //                                             "$destinLat1" != 'null'
  //                                                 ? "$destinLat1"
  //                                                 : "0",
  //                                         "destin_longitude1":
  //                                             "$destinLng1" != 'null'
  //                                                 ? "$destinLng1"
  //                                                 : "0",
  //                                         "pickup_latitude2":
  //                                             "$pickupLat2" != 'null'
  //                                                 ? "$pickupLat2"
  //                                                 : "0",
  //                                         "pickup_longitude2":
  //                                             "$pickupLat2" != 'null'
  //                                                 ? "$pickupLat2"
  //                                                 : "0",
  //                                         "destin_latitude2":
  //                                             "$destinLat2" != 'null'
  //                                                 ? "$destinLat2"
  //                                                 : "0",
  //                                         "destin_longitude2":
  //                                             "$destinLng2" != 'null'
  //                                                 ? "$destinLng2"
  //                                                 : "0",
  //                                         "pickup_latitude3":
  //                                             "$pickupLat3" != 'null'
  //                                                 ? "$pickupLat3"
  //                                                 : "0",
  //                                         "pickup_longitude3":
  //                                             "$pickupLng3" != 'null'
  //                                                 ? "$pickupLng3"
  //                                                 : "0",
  //                                         "destin_latitude3":
  //                                             "$destinLat3" != 'null'
  //                                                 ? "$destinLat3"
  //                                                 : "0",
  //                                         "destin_longitude3":
  //                                             "$destinLng3" != 'null'
  //                                                 ? "$destinLng3"
  //                                                 : "0",
  //                                         "pickup_latitude4":
  //                                             "$pickupLng4" != 'null'
  //                                                 ? "$pickupLng4"
  //                                                 : "0",
  //                                         "pickup_longitude4":
  //                                             "$pickupLng4" != 'null'
  //                                                 ? "$pickupLng4"
  //                                                 : "0",
  //                                         "destin_latitude4":
  //                                             "$destinLat4" != 'null'
  //                                                 ? "$destinLat4"
  //                                                 : "0",
  //                                         "destin_longitude4":
  //                                             "$destinLng4" != 'null'
  //                                                 ? "$destinLng4"
  //                                                 : "0",
  //                                         "destin_distance0": distance0,
  //                                         "destin_time0": duration0,
  //                                         "destin_delivery_charges0":
  //                                             totalDeliveryAmount0 ?? "0.00",
  //                                         "destin_vat_charges0":
  //                                             totalVatCharges0,
  //                                         "destin_total_charges0":
  //                                             roundedTotalAmount0,
  //                                         "destin_discount0": "0.00",
  //                                         "destin_discounted_charges0": "0.00",
  //                                         "destin_distance1": distance1,
  //                                         "destin_time1": duration1,
  //                                         "destin_delivery_charges1":
  //                                             totalDeliveryAmount1 ?? "0.00",
  //                                         "destin_vat_charges1":
  //                                             totalVatCharges1 ?? "0.00",
  //                                         "destin_total_charges1":
  //                                             roundedTotalAmount1 ?? "0.00",
  //                                         "destin_discount1": "0.00",
  //                                         "destin_discounted_charges1": "0.00",
  //                                         "destin_distance2":
  //                                             distance2 ?? "0.00",
  //                                         "destin_time2": duration2,
  //                                         "destin_delivery_charges2":
  //                                             totalDeliveryAmount2 ?? "0.00",
  //                                         "destin_vat_charges2":
  //                                             totalVatCharges2 ?? "0.00",
  //                                         "destin_total_charges2":
  //                                             roundedTotalAmount2 ?? "0.00",
  //                                         "destin_discount2": "0.00",
  //                                         "destin_discounted_charges2": "0.00",
  //                                         "destin_distance3":
  //                                             distance3 ?? "0.00",
  //                                         "destin_time3": duration3,
  //                                         "destin_delivery_charges3":
  //                                             totalDeliveryAmount3 ?? "0.00",
  //                                         "destin_vat_charges3":
  //                                             totalVatCharges3 ?? "0.00",
  //                                         "destin_total_charges3":
  //                                             roundedTotalAmount3 ?? "0.00",
  //                                         "destin_discount3": "0.00",
  //                                         "destin_discounted_charges3": "0.00",
  //                                         "destin_distance4":
  //                                             distance4 ?? "0.00",
  //                                         "destin_time4": duration4,
  //                                         "destin_delivery_charges4":
  //                                             totalDeliveryAmount4 ?? "0.00",
  //                                         "destin_vat_charges4":
  //                                             totalVatCharges4 ?? "0.00",
  //                                         "destin_total_charges4":
  //                                             roundedTotalAmount4 ?? "0.00",
  //                                         "destin_discount4": "0.00",
  //                                         "destin_discounted_charges4": "0.00",
  //                                       };

  //                                       List<Map<int, dynamic>> indexData =
  //                                           List.filled(5, {});

  //                                       for (var i = 0;
  //                                           i < filteredData.length;
  //                                           i++) {
  //                                         final dataForIndex = filteredData[i];
  //                                         final dataIndexString = dataForIndex
  //                                             .keys
  //                                             .first; // Get the index as a String
  //                                         final dataIndex =
  //                                             int.tryParse(dataIndexString);

  //                                         if (dataIndex != null &&
  //                                             dataIndex >= 0 &&
  //                                             dataIndex <= 4) {
  //                                           indexData[dataIndex] = dataForIndex
  //                                               .map((key, value) => MapEntry(
  //                                                   int.parse(key), value));
  //                                         } else {
  //                                           debugPrint(
  //                                               "Invalid or out of bounds index: $dataIndexString");
  //                                         }
  //                                       }
  //                                       latLongData = {
  //                                         "pickup_latitude":
  //                                             "$pickupLat0" != 'null'
  //                                                 ? "$pickupLat0"
  //                                                 : "0",
  //                                         "pickup_longitude":
  //                                             "$pickupLng0" != 'null'
  //                                                 ? "$pickupLng0"
  //                                                 : "0",
  //                                       };
  //                                       print(
  //                                           "latLongData in Screen: $latLongData");
  //                                       // Separate the data into different lists based on their indices
  //                                       Map<int, dynamic> indexData0 =
  //                                           indexData[0];
  //                                       Map<int, dynamic> indexData1 =
  //                                           indexData[1];
  //                                       Map<int, dynamic> indexData2 =
  //                                           indexData[2];
  //                                       Map<int, dynamic> indexData3 =
  //                                           indexData[3];
  //                                       Map<int, dynamic> indexData4 =
  //                                           indexData[4];

  //                                       Navigator.push(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                           builder: (context) =>
  //                                               ScheduleRideScreen(
  //                                             indexData0: indexData0,
  //                                             indexData1: indexData1,
  //                                             indexData2: indexData2,
  //                                             indexData3: indexData3,
  //                                             indexData4: indexData4,
  //                                             selectedRadio: selectedRadio,
  //                                             scheduledMultipleData:
  //                                                 addMultipleData,
  //                                           ),
  //                                         ),
  //                                       );
  //                                     }
  //                                   } else {
  //                                     showDialog(
  //                                       context: context,
  //                                       builder: (context) {
  //                                         return Dialog(
  //                                           backgroundColor: Colors.white,
  //                                           shape: RoundedRectangleBorder(
  //                                             borderRadius:
  //                                                 BorderRadius.circular(40),
  //                                           ),
  //                                           insetPadding: const EdgeInsets.only(
  //                                               left: 20, right: 20),
  //                                           child: SizedBox(
  //                                             width: size.width,
  //                                             height: size.height * 0.25,
  //                                             child: Column(
  //                                               children: [
  //                                                 Padding(
  //                                                   padding: const EdgeInsets
  //                                                       .symmetric(
  //                                                       horizontal: 20,
  //                                                       vertical: 10),
  //                                                   child: Column(
  //                                                     children: [
  //                                                       SizedBox(
  //                                                           height:
  //                                                               size.height *
  //                                                                   0.02),
  //                                                       Align(
  //                                                         alignment:
  //                                                             Alignment.topLeft,
  //                                                         child: Text(
  //                                                           "Just a moment...",
  //                                                           textAlign:
  //                                                               TextAlign.left,
  //                                                           style: TextStyle(
  //                                                             color:
  //                                                                 orangeColor,
  //                                                             fontSize: 20,
  //                                                             fontFamily:
  //                                                                 'Inter-Bold',
  //                                                           ),
  //                                                         ),
  //                                                       ),
  //                                                       SizedBox(
  //                                                           height:
  //                                                               size.height *
  //                                                                   0.03),
  //                                                       Text(
  //                                                         'Please make sure data is available before proceeding.',
  //                                                         textAlign:
  //                                                             TextAlign.left,
  //                                                         style: TextStyle(
  //                                                           color: blackColor,
  //                                                           fontSize: 14,
  //                                                           fontFamily:
  //                                                               'Inter-Regular',
  //                                                         ),
  //                                                       ),
  //                                                       SizedBox(
  //                                                           height:
  //                                                               size.height *
  //                                                                   0.02),
  //                                                     ],
  //                                                   ),
  //                                                 ),
  //                                                 GestureDetector(
  //                                                   onTap: () {
  //                                                     Navigator.pop(context);
  //                                                   },
  //                                                   child: Padding(
  //                                                     padding:
  //                                                         const EdgeInsets.only(
  //                                                             left: 140),
  //                                                     child:
  //                                                         dialogButtonGradientSmall(
  //                                                             "OK", context),
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         );
  //                                       },
  //                                     );
  //                                   }
  //                                 });
  //                               }
  //                             },
  //                             child: isLoading2
  //                                 ? buttonTransparentGradientSmallWithLoader(
  //                                     "Please Wait...", context)
  //                                 : buttonTransparentGradientSmall(
  //                                     "SCHEDULE RIDE",
  //                                     context,
  //                                   ),
  //                           ),
  //                           GestureDetector(
  //                             onTap: () async {
  //                               if (selectedRadio == 1) {
  //                                 if (pickupController.text.isEmpty &&
  //                                     destinationController.text.isEmpty &&
  //                                     receiversNameController.text.isEmpty &&
  //                                     receiversNumberController.text.isEmpty &&
  //                                     selectedVehicle == null &&
  //                                     selectedBookingType == null) {
  //                                   if (pickupController.text.isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please fill pickup address!",
  //                                     );
  //                                   } else if (destinationController
  //                                       .text.isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message:
  //                                           "Please fill destination address!",
  //                                     );
  //                                   } else if (receiversNameController
  //                                       .text.isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please fill receiver's name!",
  //                                     );
  //                                   } else if (receiversNumberController
  //                                       .text.isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message:
  //                                           "Please fill receiver's number!",
  //                                     );
  //                                   } else if (selectedVehicle == null) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please select a vehicle!",
  //                                     );
  //                                   } else if (selectedBookingType == null) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please select booking type!",
  //                                     );
  //                                   }
  //                                 } else {
  //                                   setState(() {
  //                                     isLoading = true;
  //                                   });
  //                                   await getDistanceAddress(
  //                                       bookingsTypeId, vehicleId!);
  //                                   if (double.parse(distance0!) <= 1.0) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message:
  //                                           "Distance should be greater than 1.0 Km!",
  //                                     );
  //                                     setState(() {
  //                                       isLoading = false;
  //                                     });
  //                                   } else {
  //                                     // await getDistanceAddress(bookingsTypeId);
  //                                     addSingleData = {
  //                                       "type": "booking",
  //                                       "vehicles_id": vehicleId,
  //                                       "delivery_charges":
  //                                           totalDeliveryAmount0,
  //                                       "service_running": serviceRunning,
  //                                       "total_svc_running_charges":
  //                                           totalServiceCharges,
  //                                       "total_tollgate_charges":
  //                                           totalTollGateCharges ?? "0",
  //                                       "svc_running_charges0": serviceCharges0,
  //                                       "tollgate_charges0":
  //                                           tollGateCharges0 ?? "0",
  //                                       "bookings_types_id": bookingsTypeId,
  //                                       "delivery_type": selectedRadio == 1
  //                                           ? "Single"
  //                                           : "Multiple",
  //                                       "pickup_address": pickupController.text,
  //                                       "pickup_latitude": pickupLat0,
  //                                       "pickup_longitude": pickupLng0,
  //                                       "destin_address":
  //                                           destinationController.text,
  //                                       "destin_latitude": destinLat0,
  //                                       "destin_longitude": destinLng0,
  //                                       "destin_distance": distance0,
  //                                       "destin_time": duration0,
  //                                       "destin_delivery_charges":
  //                                           totalDeliveryAmount0,
  //                                       "destin_vat_charges": totalVatCharges0,
  //                                       "destin_total_charges":
  //                                           roundedTotalAmount0 ?? "0.00",
  //                                       "destin_discount": "0.00",
  //                                       "destin_discounted_charges": "0.00",
  //                                       "receiver_name":
  //                                           receiversNameController.text,
  //                                       "receiver_phone":
  //                                           receiversNumberController.text,
  //                                     };
  //                                     setState(() {
  //                                       isLoading = false;
  //                                     });
  //                                     Navigator.push(
  //                                       context,
  //                                       MaterialPageRoute(
  //                                         builder: (context) =>
  //                                             ConfirmSingleDetailsScreen(
  //                                           singleData: addSingleData,
  //                                         ),
  //                                       ),
  //                                     );
  //                                   }
  //                                 }
  //                               }
  //                               if (selectedRadio == 2) {
  //                                 print("Zainnnnnnnnnn");
  //                                 if (pickupControllers[0].text.isEmpty &&
  //                                     destinationControllers[0].text.isEmpty &&
  //                                     receiversNameControllers[0]
  //                                         .text
  //                                         .isEmpty &&
  //                                     receiversNumberControllers[0]
  //                                         .text
  //                                         .isEmpty &&
  //                                     selectedVehicle == null &&
  //                                     selectedBookingType == null) {
  //                                   if (pickupControllers.isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please fill pickup address!",
  //                                     );
  //                                   } else if (destinationControllers.isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message:
  //                                           "Please fill destination address!",
  //                                     );
  //                                   } else if (receiversNameControllers
  //                                       .isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please fill receiver's name!",
  //                                     );
  //                                   } else if (receiversNumberControllers
  //                                       .isEmpty) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message:
  //                                           "Please fill receiver's number!",
  //                                     );
  //                                   } else if (selectedVehicle == null) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please select a vehicle!",
  //                                     );
  //                                   } else if (selectedBookingType == null) {
  //                                     CustomToast.showToast(
  //                                       fontSize: 12,
  //                                       message: "Please select booking type!",
  //                                     );
  //                                   }
  //                                 } else {
  //                                   setState(() {
  //                                     isLoading = true;
  //                                   });
  //                                   showDialog(
  //                                     context: context,
  //                                     // barrierDismissible:
  //                                     //     false, // Prevents dialog from closing when tapping outside
  //                                     builder: (context) {
  //                                       return Dialog(
  //                                         backgroundColor: Colors
  //                                             .transparent, // Make dialog transparent
  //                                         elevation: 0, // Remove shadow
  //                                         child: Container(
  //                                           padding: const EdgeInsets.all(20),
  //                                           decoration: BoxDecoration(
  //                                             color: Colors.white,
  //                                             borderRadius:
  //                                                 BorderRadius.circular(10),
  //                                           ),
  //                                           child: Column(
  //                                             mainAxisSize: MainAxisSize.min,
  //                                             children: [
  //                                               CircularProgressIndicator(
  //                                                 color: orangeColor,
  //                                                 strokeWidth: 2,
  //                                               ), // Your progress indicator
  //                                               const SizedBox(height: 20),
  //                                               const Text(
  //                                                 'Loading Data...',
  //                                                 style: TextStyle(
  //                                                   color: Colors.black,
  //                                                   fontSize: 20,
  //                                                   fontFamily: 'Inter-Bold',
  //                                                 ),
  //                                               ),
  //                                               const SizedBox(height: 10),
  //                                               const Text(
  //                                                 'Please wait while data is being loaded.',
  //                                                 textAlign: TextAlign.center,
  //                                                 style: TextStyle(
  //                                                   color: Colors.black,
  //                                                   fontSize: 14,
  //                                                   fontFamily: 'Inter-Regular',
  //                                                 ),
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       );
  //                                     },
  //                                   );

  //                                   await getDistanceAddress(
  //                                       bookingsTypeId, vehicleId!);
  //                                   // Add a delay to ensure data is populated in allDataForIndexes1
  //                                   Future.delayed(const Duration(seconds: 2),
  //                                       () async {
  //                                     // Close the loading dialog
  //                                     // Navigator.of(context).pop();

  //                                     if (filteredData.isNotEmpty) {
  //                                       // await getDistanceAddress(bookingsTypeId);
  //                                       addMultipleData = {
  //                                         "type": "booking",
  //                                         "vehicles_id": vehicleId,
  //                                         "totalChargesM": totalChargesM,
  //                                         "totalVatM": totalVatM,
  //                                         "service_running": serviceRunning,
  //                                         "total_svc_running_charges":
  //                                             totalServiceCharges,
  //                                         "total_tollgate_charges":
  //                                             totalTollGateCharges ?? "0",
  //                                         "svc_running_charges0":
  //                                             serviceCharges0,
  //                                         "tollgate_charges0":
  //                                             tollGateCharges0 ?? "0",
  //                                         "svc_running_charges1":
  //                                             serviceCharges1,
  //                                         "tollgate_charges1":
  //                                             tollGateCharges1 ?? "0",
  //                                         "svc_running_charges2":
  //                                             serviceCharges2,
  //                                         "tollgate_charges2":
  //                                             tollGateCharges2 ?? "0",
  //                                         "svc_running_charges3":
  //                                             serviceCharges3,
  //                                         "tollgate_charges3":
  //                                             tollGateCharges3 ?? "0",
  //                                         "svc_running_charges4":
  //                                             serviceCharges4,
  //                                         "tollgate_charges4":
  //                                             tollGateCharges4 ?? "0",
  //                                         "bookings_types_id": bookingsTypeId,
  //                                         "delivery_type": selectedRadio == 1
  //                                             ? "Single"
  //                                             : "Multiple",
  //                                         "pickup_latitude0":
  //                                             "$pickupLat0" != 'null'
  //                                                 ? "$pickupLat0"
  //                                                 : "0",
  //                                         "pickup_longitude0":
  //                                             "$pickupLng0" != 'null'
  //                                                 ? "$pickupLng0"
  //                                                 : "0",
  //                                         "destin_latitude0":
  //                                             "$destinLat0" != 'null'
  //                                                 ? "$destinLat0"
  //                                                 : "0",
  //                                         "destin_longitude0":
  //                                             "$destinLng0" != 'null'
  //                                                 ? "$destinLng0"
  //                                                 : "0",
  //                                         "pickup_latitude1":
  //                                             "$pickupLat1" != 'null'
  //                                                 ? "$pickupLat1"
  //                                                 : "0",
  //                                         "pickup_longitude1":
  //                                             "$pickupLng1" != 'null'
  //                                                 ? "$pickupLng1"
  //                                                 : "0",
  //                                         "destin_latitude1":
  //                                             "$destinLat1" != 'null'
  //                                                 ? "$destinLat1"
  //                                                 : "0",
  //                                         "destin_longitude1":
  //                                             "$destinLng1" != 'null'
  //                                                 ? "$destinLng1"
  //                                                 : "0",
  //                                         "pickup_latitude2":
  //                                             "$pickupLat2" != 'null'
  //                                                 ? "$pickupLat2"
  //                                                 : "0",
  //                                         "pickup_longitude2":
  //                                             "$pickupLat2" != 'null'
  //                                                 ? "$pickupLat2"
  //                                                 : "0",
  //                                         "destin_latitude2":
  //                                             "$destinLat2" != 'null'
  //                                                 ? "$destinLat2"
  //                                                 : "0",
  //                                         "destin_longitude2":
  //                                             "$destinLng2" != 'null'
  //                                                 ? "$destinLng2"
  //                                                 : "0",
  //                                         "pickup_latitude3":
  //                                             "$pickupLat3" != 'null'
  //                                                 ? "$pickupLat3"
  //                                                 : "0",
  //                                         "pickup_longitude3":
  //                                             "$pickupLng3" != 'null'
  //                                                 ? "$pickupLng3"
  //                                                 : "0",
  //                                         "destin_latitude3":
  //                                             "$destinLat3" != 'null'
  //                                                 ? "$destinLat3"
  //                                                 : "0",
  //                                         "destin_longitude3":
  //                                             "$destinLng3" != 'null'
  //                                                 ? "$destinLng3"
  //                                                 : "0",
  //                                         "pickup_latitude4":
  //                                             "$pickupLng4" != 'null'
  //                                                 ? "$pickupLng4"
  //                                                 : "0",
  //                                         "pickup_longitude4":
  //                                             "$pickupLng4" != 'null'
  //                                                 ? "$pickupLng4"
  //                                                 : "0",
  //                                         "destin_latitude4":
  //                                             "$destinLat4" != 'null'
  //                                                 ? "$destinLat4"
  //                                                 : "0",
  //                                         "destin_longitude4":
  //                                             "$destinLng4" != 'null'
  //                                                 ? "$destinLng4"
  //                                                 : "0",
  //                                         "destin_distance0": distance0,
  //                                         "destin_time0": duration0,
  //                                         "destin_delivery_charges0":
  //                                             totalDeliveryAmount0 ?? "0.00",
  //                                         "destin_vat_charges0":
  //                                             totalVatCharges0,
  //                                         "destin_total_charges0":
  //                                             roundedTotalAmount0,
  //                                         "destin_discount0": "0.00",
  //                                         "destin_discounted_charges0": "0.00",
  //                                         "destin_distance1": distance1,
  //                                         "destin_time1": duration1,
  //                                         "destin_delivery_charges1":
  //                                             totalDeliveryAmount1 ?? "0.00",
  //                                         "destin_vat_charges1":
  //                                             totalVatCharges1 ?? "0.00",
  //                                         "destin_total_charges1":
  //                                             roundedTotalAmount1 ?? "0.00",
  //                                         "destin_discount1": "0.00",
  //                                         "destin_discounted_charges1": "0.00",
  //                                         "destin_distance2":
  //                                             distance2 ?? "0.00",
  //                                         "destin_time2": duration2,
  //                                         "destin_delivery_charges2":
  //                                             totalDeliveryAmount2 ?? "0.00",
  //                                         "destin_vat_charges2":
  //                                             totalVatCharges2 ?? "0.00",
  //                                         "destin_total_charges2":
  //                                             roundedTotalAmount2 ?? "0.00",
  //                                         "destin_discount2": "0.00",
  //                                         "destin_discounted_charges2": "0.00",
  //                                         "destin_distance3":
  //                                             distance3 ?? "0.00",
  //                                         "destin_time3": duration3,
  //                                         "destin_delivery_charges3":
  //                                             totalDeliveryAmount3 ?? "0.00",
  //                                         "destin_vat_charges3":
  //                                             totalVatCharges3 ?? "0.00",
  //                                         "destin_total_charges3":
  //                                             roundedTotalAmount3 ?? "0.00",
  //                                         "destin_discount3": "0.00",
  //                                         "destin_discounted_charges3": "0.00",
  //                                         "destin_distance4":
  //                                             distance4 ?? "0.00",
  //                                         "destin_time4": duration4,
  //                                         "destin_delivery_charges4":
  //                                             totalDeliveryAmount4 ?? "0.00",
  //                                         "destin_vat_charges4":
  //                                             totalVatCharges4 ?? "0.00",
  //                                         "destin_total_charges4":
  //                                             roundedTotalAmount4 ?? "0.00",
  //                                         "destin_discount4": "0.00",
  //                                         "destin_discounted_charges4": "0.00",
  //                                       };

  //                                       debugPrint(
  //                                           "filteredData: $filteredData");

  //                                       List<Map<int, dynamic>> indexData =
  //                                           List.filled(5, {});

  //                                       for (var i = 0;
  //                                           i < filteredData.length;
  //                                           i++) {
  //                                         final dataForIndex = filteredData[i];
  //                                         final dataIndexString = dataForIndex
  //                                             .keys
  //                                             .first; // Get the index as a String
  //                                         final dataIndex =
  //                                             int.tryParse(dataIndexString);

  //                                         if (dataIndex != null &&
  //                                             dataIndex >= 0 &&
  //                                             dataIndex <= 4) {
  //                                           indexData[dataIndex] = dataForIndex
  //                                               .map((key, value) => MapEntry(
  //                                                   int.parse(key), value));
  //                                         } else {
  //                                           debugPrint(
  //                                               "Invalid or out of bounds index: $dataIndexString");
  //                                         }
  //                                       }

  //                                       // Separate the data into different lists based on their indices
  //                                       Map<int, dynamic> indexData0 =
  //                                           indexData[0];
  //                                       Map<int, dynamic> indexData1 =
  //                                           indexData[1];
  //                                       Map<int, dynamic> indexData2 =
  //                                           indexData[2];
  //                                       Map<int, dynamic> indexData3 =
  //                                           indexData[3];
  //                                       Map<int, dynamic> indexData4 =
  //                                           indexData[4];
  //                                       latLongData = {
  //                                         "pickup_latitude":
  //                                             "$pickupLat0" != 'null'
  //                                                 ? "$pickupLat0"
  //                                                 : "0",
  //                                         "pickup_longitude":
  //                                             "$pickupLng0" != 'null'
  //                                                 ? "$pickupLng0"
  //                                                 : "0",
  //                                       };
  //                                       print(
  //                                           "latLongData in Screen: $latLongData");
  //                                       debugPrint("indexData0: $indexData0");
  //                                       debugPrint("indexData1: $indexData1");
  //                                       debugPrint("indexData2: $indexData2");
  //                                       debugPrint("indexData3: $indexData3");
  //                                       debugPrint("indexData4: $indexData4");
  //                                       print(
  //                                           "addMultipleData: $addMultipleData");
  //                                       setState(() {
  //                                         isLoading = false;
  //                                       });
  //                                       Navigator.push(
  //                                         context,
  //                                         MaterialPageRoute(
  //                                           builder: (context) =>
  //                                               ConfirmMultipleDetailsScreen(
  //                                             indexData0: indexData0,
  //                                             indexData1: indexData1,
  //                                             indexData2: indexData2,
  //                                             indexData3: indexData3,
  //                                             indexData4: indexData4,
  //                                             multipleData: addMultipleData,
  //                                           ),
  //                                         ),
  //                                       );
  //                                     }
  //                                   });
  //                                 }
  //                               }
  //                             },
  //                             child: isLoading
  //                                 ? buttonGradientSmallWithLoader(
  //                                     "Please Wait...",
  //                                     context,
  //                                   )
  //                                 : buttonGradientSmall(
  //                                     "FIND RIDER",
  //                                     context,
  //                                   ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: size.height * 0.02),
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 20),
  //                       child: Row(
  //                         children: [
  //                           SvgPicture.asset(
  //                             "assets/images/info-icon.svg",
  //                           ),
  //                           SizedBox(width: size.width * 0.02),
  //                           Text(
  //                             'Note: Distance must be grater than 1KM',
  //                             style: TextStyle(
  //                               color: blackColor,
  //                               fontSize: 10,
  //                               fontFamily: 'Inter-Bold',
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: size.height * 0.02),
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(horizontal: 20),
  //                       child: Row(
  //                         children: [
  //                           SvgPicture.asset(
  //                             "assets/images/info-icon.svg",
  //                           ),
  //                           SizedBox(width: size.width * 0.02),
  //                           Text(
  //                             'Note: Please drag down to see your location on the map.',
  //                             style: TextStyle(
  //                               color: blackColor,
  //                               fontSize: 10,
  //                               fontFamily: 'Inter-Bold',
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     SizedBox(height: size.height * 0.12),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
