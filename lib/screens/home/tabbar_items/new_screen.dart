// ignore_for_file: avoid_print, must_be_immutable, use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:google_maps_webservice_ex/places.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/widgets/home_textfields.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/get_charges_model.dart';
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

class NewScreen extends StatefulWidget {
  late double? location;

  NewScreen({super.key, this.location});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
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
  String? toKm;
  String? toKm0;
  String? toKm1;
  String? toKm2;
  String? toKm3;
  String? toKm4;
  String? fromKm;
  String? fromKm0;
  String? fromKm1;
  String? fromKm2;
  String? fromKm3;
  String? fromKm4;
  String? perKmAmount;
  String? perKmAmount0;
  String? perKmAmount1;
  String? perKmAmount2;
  String? perKmAmount3;
  String? perKmAmount4;
  double? totalAmount;
  double? totalAmount0;
  double? totalAmount1;
  double? totalAmount2;
  double? totalAmount3;
  double? totalAmount4;
  String? roundedTotalAmount;
  String? roundedTotalAmount0;
  String? roundedTotalAmount1;
  String? roundedTotalAmount2;
  String? roundedTotalAmount3;
  String? roundedTotalAmount4;
  LatLng? origin;
  LatLng? destination;
  String? distance;
  String? distance0;
  String? distance1;
  String? distance2;
  String? distance3;
  String? distance4;
  String? duration;
  String? duration0;
  String? duration1;
  String? duration2;
  String? duration3;
  String? duration4;
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

  bool isLoading = false;
  bool isLoading2 = false;

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

  getAllSystemData() async {
    try {
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
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

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
        for (int i = 0; i < getAddressesModel.data!.length; i++) {
          addresses.add("${getAddressesModel.data?[i]}");
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetServiceTypesModel getServiceTypesModel = GetServiceTypesModel();

  getServiceTypes() async {
    try {
      String apiUrl = "$baseUrl/get_service_types";
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
        getServiceTypesModel = getServiceTypesModelFromJson(responseString);
        print('getServiceTypesModel status: ${getServiceTypesModel.status}');
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
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  Timer? fetchDataTimer;

  GetVehiclesByServiceTypeModel getVehiclesByServiceTypeModel =
      GetVehiclesByServiceTypeModel();

  getVehiclesByServiceType(String? serviceId) async {
    try {
      String apiUrl = "$baseUrl/get_vehicles_by_service_type";
      print("apiUrl: $apiUrl");
      print("serviceTypesId: $serviceId");
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
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getVehiclesByServiceTypeModel =
            getVehiclesByServiceTypeModelFromJson(responseString);
        setState(() {});
        print(
            'getVehiclesByServiceTypeModel status: ${getVehiclesByServiceTypeModel.status}');
        for (int i = 0; i < getVehiclesByServiceTypeModel.data!.length; i++) {
          vehiclesType.add("${getVehiclesByServiceTypeModel.data?[i].name}");
        }
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetBookingsTypeModel getBookingsTypeModel = GetBookingsTypeModel();

  getBookingsType() async {
    try {
      String apiUrl = "$baseUrl/get_bookings_types";
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
        getBookingsTypeModel = getBookingsTypeModelFromJson(responseString);
        setState(() {});
        print('getBookingsTypeModel status: ${getBookingsTypeModel.status}');
        for (int i = 0; i < getBookingsTypeModel.data!.length; i++) {
          bookingName = getBookingsTypeModel.data?[i].name;
          bookingType.add("$bookingName");
        }
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetChargesModel getChargesModel = GetChargesModel();

  getChargesSingle(String? bTypeId) async {
    try {
      String apiUrl = "$baseUrl/get_charges_parameters";
      Map<String, String> distanceMap = {
        "0": distance!.split(" ")[0],
      };
      Map<String, dynamic> requestBody = {
        "bookings_types_id": bTypeId,
        "distance": distanceMap,
      };
      print("apiUrl: $apiUrl");
      print("bookingsTypeId: $bTypeId");
      print("requestBody: $requestBody");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getChargesModel = getChargesModelFromJson(responseString);
        print('getChargesModel status: ${getChargesModel.status}');
        print('getChargesModel length: ${getChargesModel.data!.length}');
        toKm = "${getChargesModel.data![0].firstMilesTo}";
        fromKm = "${getChargesModel.data![0].firstMilesFrom}";
        perKmAmount = "${getChargesModel.data![0].firstMilesAmount}";
        setState(() {});
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  getChargesMultiple(String? bTypeId) async {
    try {
      String apiUrl = "$baseUrl/get_charges_parameters";
      Map<String, String> distanceMap = {
        "0": distance0!.split(" ")[0],
        "1": distance1!.split(" ")[0],
        // "2": distance2!.split(" ")[0],
        // "3": distance3!.split(" ")[0],
        // "4": distance4!.split(" ")[0],
      };
      if (distance2 != null) distanceMap["2"] = distance2!.split(" ")[0];
      if (distance3 != null) distanceMap["3"] = distance3!.split(" ")[0];
      if (distance4 != null) distanceMap["4"] = distance4!.split(" ")[0];
      // Create the request body as a map
      Map<String, dynamic> requestBody = {
        "bookings_types_id": bTypeId,
        "distance": distanceMap,
      };
      print("apiUrl: $apiUrl");
      print("bookingsTypeId: $bTypeId");
      print("requestBody: $requestBody");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getChargesModel = getChargesModelFromJson(responseString);
        print('getChargesModel status: ${getChargesModel.status}');
        print('getChargesModel length: ${getChargesModel.data!.length}');
        // for (int i = 0; i < getChargesModel.data!.length; i++) {
        toKm0 = "${getChargesModel.data![0].firstMilesTo}";
        fromKm0 = "${getChargesModel.data![0].firstMilesFrom}";
        perKmAmount0 = "${getChargesModel.data![0].firstMilesAmount}";
        toKm1 = "${getChargesModel.data![1].firstMilesTo}";
        fromKm1 = "${getChargesModel.data![1].firstMilesFrom}";
        perKmAmount1 = "${getChargesModel.data![1].firstMilesAmount}";
        if (distance2 != null) {
          toKm2 = "${getChargesModel.data![2].firstMilesTo}";
          fromKm2 = "${getChargesModel.data![2].firstMilesFrom}";
          perKmAmount2 = "${getChargesModel.data![2].firstMilesAmount}";
        }
        if (distance3 != null) {
          toKm3 = "${getChargesModel.data![3].firstMilesTo}";
          fromKm3 = "${getChargesModel.data![3].firstMilesFrom}";
          perKmAmount3 = "${getChargesModel.data![3].firstMilesAmount}";
        }
        if (distance4 != null) {
          toKm4 = "${getChargesModel.data![4].firstMilesTo}";
          fromKm4 = "${getChargesModel.data![4].firstMilesFrom}";
          perKmAmount4 = "${getChargesModel.data![4].firstMilesAmount}";
        }
        // }
        setState(() {});
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  Future<Map<String, dynamic>> getDistanceAndTime(
    String origin,
    String destination,
  ) async {
    final apiKey = dotenv.env['MAPS_KEY'];
    final response = await http.get(
      Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=$origin'
        '&destinations=$destination'
        '&key=$apiKey',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load data');
    }
  }

  calculateStandardAmount(
      double from, double to, double perKm, double distance) {
    if (to < 16) {
      totalAmount = distance * perKm;
    } else if (from > 15.99 && to < 31) {
      totalAmount = distance * perKm;
    } else if (from > 30.99) {
      totalAmount = distance * perKm;
    }
    print("totalAmount: $totalAmount");
    roundedTotalAmount = totalAmount!.toStringAsFixed(2);
    print("roundedTotalAmount: $roundedTotalAmount");
  }

  calculateStandardAmount0(
      double from0, double to0, double perKm0, double distance0) {
    if (to0 < 16) {
      totalAmount0 = distance0 * perKm0;
    } else if (from0 > 15.99 && to0 < 31) {
      totalAmount0 = distance0 * perKm0;
    } else if (from0 > 30.99) {
      totalAmount0 = distance0 * perKm0;
    }
    print("totalAmount0: $totalAmount0");
    roundedTotalAmount0 = totalAmount0!.toStringAsFixed(2);
    print("roundedTotalAmount0: $roundedTotalAmount0");
  }

  calculateStandardAmount1(
      double from1, double to1, double perKm1, double distance1) {
    if (to1 < 16) {
      totalAmount1 = distance1 * perKm1;
    } else if (from1 > 15.99 && to1 < 31) {
      totalAmount1 = distance1 * perKm1;
    } else if (from1 > 30.99) {
      totalAmount1 = distance1 * perKm1;
    }
    print("totalAmount1: $totalAmount1");
    roundedTotalAmount1 = totalAmount1!.toStringAsFixed(2);
    print("roundedTotalAmount1: $roundedTotalAmount1");
  }

  calculateStandardAmount2(
      double from2, double to2, double perKm2, double distance2) {
    if (to2 < 16) {
      totalAmount2 = distance2 * perKm2;
    } else if (from2 > 15.99 && to2 < 31) {
      totalAmount2 = distance2 * perKm2;
    } else if (from2 > 30.99) {
      totalAmount2 = distance2 * perKm2;
    }
    print("totalAmount2: $totalAmount2");
    roundedTotalAmount2 = totalAmount2!.toStringAsFixed(2);
    print("roundedTotalAmount2: $roundedTotalAmount2");
  }

  calculateStandardAmount3(
      double from3, double to3, double perKm3, double distance3) {
    if (to3 < 16) {
      totalAmount3 = distance3 * perKm3;
    } else if (from3 > 15.99 && to3 < 31) {
      totalAmount3 = distance3 * perKm3;
    } else if (from3 > 30.99) {
      totalAmount3 = distance3 * perKm3;
    }
    print("totalAmount3: $totalAmount3");
    roundedTotalAmount3 = totalAmount3!.toStringAsFixed(2);
    print("roundedTotalAmount3: $roundedTotalAmount3");
  }

  calculateStandardAmount4(
      double from4, double to4, double perKm4, double distance4) {
    if (to4 < 16) {
      totalAmount4 = distance4 * perKm4;
    } else if (from4 > 15.99 && to4 < 31) {
      totalAmount4 = distance4 * perKm4;
    } else if (from4 > 30.99) {
      totalAmount4 = distance4 * perKm4;
    }
    print("totalAmount4: $totalAmount4");
    roundedTotalAmount4 = totalAmount4!.toStringAsFixed(2);
    print("roundedTotalAmount4: $roundedTotalAmount4");
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

  Future<void> searchPickUpPlaces(String input) async {
    if (input.isNotEmpty) {
      final response = await places.searchByText(input);

      if (response.isOkay) {
        setState(() {
          pickUpPredictions = response.results;
        });
      }
    }
  }

  Future<void> searchDestinationPlaces(String input) async {
    if (input.isNotEmpty) {
      final response = await places.searchByText(input);

      if (response.isOkay) {
        setState(() {
          destinationPredictions = response.results;
        });
      }
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
        print("currentLat: $currentLat");
        print("currentLng: $currentLng");
        print("currentPickupLocation: $currentAddress");
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

  calculateDistanceTimeSingle() async {
    final origin =
        '${pickupLat ?? currentLat ?? addressLat},${pickupLng ?? currentLng ?? addressLng}'; // Format coordinates as "latitude,longitude"
    final destination =
        '$destinationLat,$destinationLng'; // Format coordinates as "latitude,longitude"
    try {
      final data = await api.getDistanceAndTime(origin, destination);
      distance = data['rows'][0]['elements'][0]['distance']['text'];
      duration = data['rows'][0]['elements'][0]['duration']['text'];
      print("distance: $distance");
      print("duration: $duration");
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
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
    pageController.dispose(); // Don't forget to dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: doubleSystemLat != null
            ? Container(
                color: transparentColor,
                width: size.width,
                height: size.height,
                child: Stack(
                  children: [
                    Container(
                      color: transparentColor,
                      width: size.width,
                      height: size.height * 0.631,
                      child: GoogleMap(
                        onMapCreated: (controller) {
                          mapController = controller;
                        },
                        mapType: MapType.normal,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        padding: const EdgeInsets.only(top: 410, right: 10),
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            doubleSystemLat != null ? doubleSystemLat! : 0.0,
                            doubleSystemLng != null ? doubleSystemLng! : 0.0,
                          ),
                          zoom: 6,
                        ),
                        markers: {
                          if (currentLocation != null)
                            Marker(
                              markerId: const MarkerId('currentLocation'),
                              position: currentLocation!,
                              icon: customMarkerIcon ??
                                  BitmapDescriptor.defaultMarker,
                            ),
                          if (selectedLocation != null)
                            Marker(
                              markerId: const MarkerId('selectedLocation'),
                              position: selectedLocation!,
                              icon: customMarkerIcon ??
                                  BitmapDescriptor.defaultMarker,
                            ),
                          if (selectedAddressLocation != null)
                            Marker(
                              markerId:
                                  const MarkerId('selectedAddressLocation'),
                              position: selectedAddressLocation!,
                              icon: customMarkerIcon ??
                                  BitmapDescriptor.defaultMarker,
                            ),
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: bottomDetailsSheet(
                        context,
                      ), // Add the bottom sheet here
                    ),
                  ],
                ),
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
      ),
    );
  }

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        color: transparentColor,
        height: size.height * 0.3,
        child: Row(
          children: [
            SvgPicture.asset('assets/images/home-location-path-icon.svg'),
            SizedBox(width: size.width * 0.02),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  isSelectedAddress == true
                      ? Container(
                          color: transparentColor,
                          width: size.width * 0.8,
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
                                          subtitle:
                                              Text(addresses.address ?? ''),
                                          onTap: () {
                                            addressesVisible = false;
                                            pickupController.text =
                                                "${addresses.address}";
                                            final double savedLat =
                                                double.parse(
                                                    "${addresses.latitude}");
                                            final double savedLng =
                                                double.parse(
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
                                              print("addressLat: $addressLat");
                                              print("addressLng $addressLng");
                                              print(
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
                          width: size.width * 0.8,
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
                                              prediction.formattedAddress ??
                                                  ''),
                                          onTap: () {
                                            pickupController.text =
                                                prediction.formattedAddress!;
                                            final double lat = prediction
                                                .geometry!.location.lat;
                                            final double lng = prediction
                                                .geometry!.location.lng;
                                            const double zoomLevel = 15.0;
                                            onPickUpLocationSelected(
                                                LatLng(lat, lng), zoomLevel);
                                            pickupLat = lat.toString();
                                            pickupLng = lng.toString();
                                            setState(() {
                                              pickUpPredictions.clear();
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              print("pickupLat: $pickupLat");
                                              print("pickupLng $pickupLng");
                                              print(
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
                    width: size.width * 0.8,
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
                                        print(
                                            "destinationLat: $destinationLat");
                                        print("destinationLng $destinationLng");
                                        print(
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
                    width: size.width * 0.8,
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
                    width: size.width * 0.8,
                    child: TextFormField(
                      controller: receiversNumberController,
                      cursorColor: orangeColor,
                      keyboardType: TextInputType.phone,
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
                        hintText: "Receiver's Phone Number",
                        hintStyle: TextStyle(
                          color: hintColor,
                          fontSize: 12,
                          fontFamily: 'Inter-Light',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

//-----------------#################### IN USE FUNCTION ###############--------------------//
// Function to calculate distance and time for multiple deliveries

  Future<void> calculateDistanceTimeMultiple(
      List<Map<String, double>?> pickupCoordinates,
      List<Map<String, double>?> destinationCoordinates) async {
    for (int i = 0; i < pickupCoordinates.length; i++) {
      final pickupLatLng = pickupCoordinates[i];
      final destinationLatLng = destinationCoordinates[i];

      if (pickupLatLng != null && destinationLatLng != null) {
        final origin =
            '${pickupLatLng['latitude']},${pickupLatLng['longitude']}';
        final destination =
            '${destinationLatLng['latitude']},${destinationLatLng['longitude']}';

        try {
          final data = await getDistanceAndTime(origin, destination);

          String distance = data['rows'][0]['elements'][0]['distance']['text'];
          String duration = data['rows'][0]['elements'][0]['duration']['text'];

          distances.add(distance);
          durations.add(duration);

          // Store distances and durations in the list of maps
          distanceDurationList.add({
            i: {
              'distance': distance,
              'duration': duration,
            }
          });
          print("distanceDurationList $distanceDurationList");
          for (var i = 0; i < distanceDurationList.length; i++) {
            dataForIndex1 = distanceDurationList[i];
            dataIndex1 = dataForIndex1.keys.first; // Get the index
            distanceData = dataForIndex1[dataIndex1];
            // Check if data contains null values
            if (distanceData!.containsValue(null)) {
              print(
                  "Data for Index in distanceDurationList $dataIndex1: Data contains null values");
            } else {
              print(
                  "Data for Index in distanceDurationList $dataIndex1: $distanceData");
              // Store the data in the distanceDataMap
              distanceDataMap[dataIndex1!] = distanceData!;
            }
          }
          print("Delivery $i - Distance: $distance, Duration: $duration");
        } catch (e) {
          print("Error for Delivery $i: $e");
        }
      } else {
        print("Invalid coordinates for Delivery $i");
      }
    }
  }

  List<String> getAddressesFromControllers(
      List<TextEditingController> controllers) {
    List<String> addresses = [];
    for (TextEditingController controller in controllers) {
      addresses.add(controller.text);
    }
    return addresses;
  }

  Future<Map<String, double>?> getLatLongForAddress(String address) async {
    if (address.isNotEmpty) {
      try {
        final locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          return {
            'latitude': locations[0].latitude,
            'longitude': locations[0].longitude,
          };
        } else {
          print('No results for address: $address');
          return null;
        }
      } catch (e) {
        print('Error geocoding address: $address');
        print(e);
        return null;
      }
    } else {
      print('Empty address for geocoding');
      return null;
    }
  }

  var indexData0;
  var indexData1;
  var indexData2;
  var indexData3;
  var indexData4;
  List<Map<String, dynamic>> filteredData = [];
  List<Map<String, dynamic>> dataForIndexes = [];
  List<Map<String, dynamic>> allDataForIndexes1 = [];
  List<List<Map<String, dynamic>>> allDataForIndexes = [];

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
      List<Future<void>> geocodingFutures = [];
      List<Map<String, double>?> pickupLatLngList =
          List.filled(pickupAddresses.length, null);
      List<Map<String, double>?> destinationLatLngList =
          List.filled(destinationAddresses.length, null);
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
          'pickupLatLng': null,
          'destinationLatLng': null,
          'receiversNameController': receiverName,
          'receiversNumberController': receiverNumber,
        };

        var pickupLatLngFuture = getLatLongForAddress(pickupAddress);
        var destinationLatLngFuture = getLatLongForAddress(destinationAddress);

        geocodingFutures.add(pickupLatLngFuture.then((pickupLatLng) {
          if (pickupLatLng != null) {
            data['pickupLatLng'] = pickupLatLng;
            print('PickupLatLng for index $index: $pickupLatLng');
            pickupLatLngList[index] = pickupLatLng; // Store the pickupLatLng
          } else {
            print('Invalid PickupLatLng for index $index');
          }
        }));

        geocodingFutures.add(destinationLatLngFuture.then((destinationLatLng) {
          if (destinationLatLng != null) {
            data['destinationLatLng'] = destinationLatLng;
            print('DestinationLatLng for index $index: $destinationLatLng');
            destinationLatLngList[index] =
                destinationLatLng; // Store the destinationLatLng
          } else {
            print('Invalid DestinationLatLng for index $index');
          }
        }));

        await Future.wait([pickupLatLngFuture, destinationLatLngFuture]);

        print("pickupController: ${data['pickupController']}");
        print("destinationController: ${data['destinationController']}");
        print("Data for index $index: $data");
        allDataForIndexes1.add({'$index': data});
        print(" allDataForIndexes Big: $allDataForIndexes1");
      }

      // Wait for all geocoding operations to complete before calculating distances and durations
      await Future.wait(geocodingFutures);

      // Ensure that all geocoding has completed before calculating distances and durations
      await calculateDistanceTimeMultiple(
          pickupLatLngList, destinationLatLngList);
      filteredData = allDataForIndexes1
          .where((entry) => entry.values.every((value) => value != null))
          .toList();
      print("filteredData: $filteredData");
      if (dataIndex1 == 0) {
        distance0 = distanceDataMap[0]!['distance'];
        duration0 = distanceDataMap[0]!['duration'];
        print("distance 0: $distance0");
        print("duration 0: $duration0");
      } else if (dataIndex1 == 1) {
        distance1 = distanceDataMap[1]!['distance'];
        duration1 = distanceDataMap[1]!['duration'];
        print("distance 1: $distance1");
        print("duration 1: $duration1");
      } else if (dataIndex1 == 2) {
        distance2 = distanceDataMap[2]!['distance'];
        duration2 = distanceDataMap[2]!['duration'];
        print("distance 2: $distance2");
        print("duration 2: $duration2");
      } else if (dataIndex1 == 3) {
        distance3 = distanceDataMap[3]!['distance'];
        duration3 = distanceDataMap[3]!['duration'];
        print("distance 3: $distance3");
        print("duration 3: $duration3");
      } else if (dataIndex1 == 4) {
        distance4 = distanceDataMap[4]!['distance'];
        duration4 = distanceDataMap[4]!['duration'];
        print("distance 4: $distance4");
        print("duration 4: $duration4");
      }
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
              print('currentIndex: $currentIndex');
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

            print('pageIndex: $index');
            print('isSelectedAddress: $isSelectedAddress');
            print('pickupController: ${pickupController.text}');
            print('destinationController: ${destinationController.text}');
            print('receiversNameController: ${receiversNameController.text}');
            print(
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

  Widget bottomDetailsSheet(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return DraggableScrollableSheet(
      initialChildSize: .38,
      minChildSize: .38,
      maxChildSize: 1,
      controller: dragController,
      builder: (BuildContext context, ScrollController scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: size.width * 0.3,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dividerColor,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
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
                      SizedBox(height: size.height * 0.04),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                vehiclesType.clear();
                                selectedVehicle = null;
                                getVehiclesByServiceType(courierId);
                                setState(() {
                                  isSelectedBus = false;
                                  isSelectedCourier = true;
                                  print("courierId: $courierId");
                                });
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    color: transparentColor,
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.43,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      decoration: BoxDecoration(
                                        color: isSelectedCourier == true
                                            ? orangeColor
                                            : const Color(0xFFEBEBEB),
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
                                        fontSize: 14,
                                        fontFamily: 'Syne-Bold',
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: SvgPicture.asset(
                                      "assets/images/login-parcel-icon.svg",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                vehiclesType.clear();
                                selectedVehicle = null;
                                getVehiclesByServiceType(otherId);
                                setState(() {
                                  isSelectedBus = true;
                                  isSelectedCourier = false;
                                  print("otherId: $otherId");
                                });
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    color: transparentColor,
                                    width: MediaQuery.of(context).size.width *
                                        0.43,
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.43,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      decoration: BoxDecoration(
                                        color: isSelectedBus == true
                                            ? orangeColor
                                            : const Color(0xFFEBEBEB),
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
                                        fontSize: 14,
                                        fontFamily: 'Syne-Bold',
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: SvgPicture.asset(
                                      "assets/images/login-truck-icon.svg",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                                    print("distanceDurationList[$i]: $entry");
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
                                  GestureDetector(
                                    onTap: () {
                                      removePage();
                                      setState(() {});
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/minus-icon.svg',
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  GestureDetector(
                                    onTap: () {
                                      addPage();
                                      setState(() {});
                                    },
                                    child: SvgPicture.asset(
                                      'assets/images/add-icon.svg',
                                    ),
                                  ),
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
                                    "Saved\nAddresses",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: drawerTextColor,
                                      fontSize: 10,
                                      fontFamily: 'Syne-Bold',
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.005),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Theme(
                          data: ThemeData(
                            unselectedWidgetColor: orangeColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      if (selectedRadio == 1) singleTextField(),
                      if (selectedRadio == 2) multiPageView(),
                      SizedBox(height: size.height * 0.012),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 22),
                            child: SvgPicture.asset(
                              "assets/images/info-icon.svg",
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 1.5, right: 16),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                        print("selectedVehicle: $value");
                                        if (getVehiclesByServiceTypeModel
                                                .data !=
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
                                              print(
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
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.015),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 22),
                            child: SvgPicture.asset(
                              "assets/images/info-icon.svg",
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 1.5, right: 16),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                                      print("selectedBookingType: $value");
                                      if (getBookingsTypeModel.data != null) {
                                        for (int i = 0;
                                            i <
                                                getBookingsTypeModel
                                                    .data!.length;
                                            i++) {
                                          if ("${getBookingsTypeModel.data?[i].name}" ==
                                              value) {
                                            bookingsTypeId =
                                                getBookingsTypeModel
                                                    .data?[i].bookingsTypesId
                                                    .toString();
                                            print(
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
                          ),
                        ],
                      ),
                      if (selectedRadio == 2)
                        Column(
                          children: [
                            SizedBox(height: size.height * 0.025),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                    spacing: const EdgeInsets.symmetric(
                                        horizontal: 3),
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
                                  if (pickupController.text.isEmpty ||
                                      destinationController.text.isEmpty ||
                                      receiversNameController.text.isEmpty ||
                                      receiversNumberController.text.isEmpty ||
                                      selectedVehicle == null ||
                                      selectedBookingType == null) {
                                    if (pickupController.text.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Please fill pickup address!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    } else if (destinationController
                                        .text.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Please fill destination address!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    } else if (receiversNameController
                                        .text.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Please fill receiver's name!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    } else if (receiversNumberController
                                        .text.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Please fill receiver's number!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    } else if (selectedVehicle == null) {
                                      Fluttertoast.showToast(
                                        msg: "Please select a vehicle!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    } else if (selectedBookingType == null) {
                                      Fluttertoast.showToast(
                                        msg: "Please select booking type!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    }
                                  } else {
                                    setState(() {
                                      isLoading2 = true;
                                    });
                                    await calculateDistanceTimeSingle();
                                    if (double.parse(distance!.split(" ")[0]) <=
                                        1.0) {
                                      Fluttertoast.showToast(
                                        msg:
                                            "Distance should be greater than 1.0 Km!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                      setState(() {
                                        isLoading2 = false;
                                      });
                                    } else {
                                      await getChargesSingle(bookingsTypeId);
                                      if (bookingsTypeId == "1") {
                                        print("fromKm: $fromKm");
                                        print("toKm: $toKm");
                                        print("perKmAmount: $perKmAmount");
                                        print("totalDistance: $distance");
                                        calculateStandardAmount(
                                            double.parse(fromKm!),
                                            toKm != "null"
                                                ? double.parse(toKm!)
                                                : 0.0,
                                            double.parse(perKmAmount!),
                                            double.parse(
                                                distance!.split(" ")[0]));
                                      }
                                      addSingleData = {
                                        "type": "schedule",
                                        "vehicles_id": vehicleId,
                                        "bookings_types_id": bookingsTypeId,
                                        "delivery_type": selectedRadio == 1
                                            ? "Single"
                                            : "Multiple",
                                        "pickup_address": pickupController.text,
                                        "pickup_latitude": pickupLat ??
                                            currentLat ??
                                            addressLat,
                                        "pickup_longitude": pickupLng ??
                                            currentLng ??
                                            addressLng,
                                        "destin_address":
                                            destinationController.text,
                                        "destin_latitude": destinationLat,
                                        "destin_longitude": destinationLng,
                                        "destin_distance":
                                            distance!.split(" ")[0],
                                        "destin_time": duration,
                                        "destin_delivery_charges": "0.00",
                                        "destin_vat_charges": "0.00",
                                        "destin_total_charges":
                                            roundedTotalAmount ?? "0.00",
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
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Loading Data...',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: orangeColor,
                                            fontSize: 20,
                                            fontFamily: 'Inter-Bold',
                                          ),
                                        ),
                                        content: Text(
                                          'Please wait while data is being loaded.',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: blackColor,
                                            fontSize: 14,
                                            fontFamily: 'Inter-Regular',
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  // Add a delay to ensure data is populated in allDataForIndexes1
                                  Future.delayed(const Duration(seconds: 3),
                                      () async {
                                    // Close the loading dialog
                                    Navigator.of(context).pop();

                                    if (filteredData.isNotEmpty) {
                                      if (distance0 != null && double.parse(distance0!.split(" ")[0]) <= 1.0 ||
                                          distance1 != null && double.parse(distance1!.split(" ")[0]) <= 1.0 ||
                                          distance2 != null && double.parse(distance2!.split(" ")[0]) <= 1.0 ||
                                          distance3 != null && double.parse(distance3!.split(" ")[0]) <= 1.0 ||
                                          distance4 != null && double.parse(distance4!.split(" ")[0]) <= 1.0) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "Distance should be greater than 1.0 Km!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 2,
                                          backgroundColor: toastColor,
                                          textColor: whiteColor,
                                          fontSize: 12,
                                        );
                                      } else {
                                        await getChargesMultiple(
                                            bookingsTypeId);
                                        if (bookingsTypeId == "1") {
                                          print("fromKm0: $fromKm0");
                                          print("toKm0: $toKm0");
                                          print("perKmAmount0: $perKmAmount0");
                                          print("totalDistance0: $distance0");
                                          calculateStandardAmount0(
                                              double.parse(fromKm0!),
                                              toKm0 != "null"
                                                  ? double.parse(toKm0!)
                                                  : 0.0,
                                              double.parse(perKmAmount0!),
                                              double.parse(
                                                  distance0!.split(" ")[0]));
                                          print("fromKm1: $fromKm1");
                                          print("toKm1: $toKm1");
                                          print("perKmAmount1: $perKmAmount1");
                                          print("totalDistance1: $distance1");
                                          calculateStandardAmount1(
                                              double.parse(fromKm1!),
                                              toKm1 != "null"
                                                  ? double.parse(toKm1!)
                                                  : 0.0,
                                              double.parse(perKmAmount1!),
                                              double.parse(
                                                  distance1!.split(" ")[0]));
                                          if (distance2 != null) {
                                            print("fromKm2: $fromKm2");
                                            print("toKm2: $toKm2");
                                            print(
                                                "perKmAmount2: $perKmAmount2");
                                            print("totalDistance2: $distance2");
                                            calculateStandardAmount2(
                                                double.parse(fromKm2!),
                                                toKm2 != "null"
                                                    ? double.parse(toKm2!)
                                                    : 0.0,
                                                double.parse(perKmAmount2!),
                                                double.parse(
                                                    distance2!.split(" ")[0]));
                                          }
                                          if (distance3 != null) {
                                            print("fromKm3: $fromKm3");
                                            print("toKm3: $toKm3");
                                            print(
                                                "perKmAmount3: $perKmAmount3");
                                            print("totalDistance3: $distance3");
                                            calculateStandardAmount3(
                                                double.parse(fromKm3!),
                                                toKm3 != "null"
                                                    ? double.parse(toKm3!)
                                                    : 0.0,
                                                double.parse(perKmAmount3!),
                                                double.parse(
                                                    distance3!.split(" ")[0]));
                                          }
                                          if (distance4 != null) {
                                            print("fromKm4: $fromKm4");
                                            print("toKm4: $toKm4");
                                            print(
                                                "perKmAmount4: $perKmAmount4");
                                            print("totalDistance4: $distance4");
                                            calculateStandardAmount4(
                                                double.parse(fromKm4!),
                                                toKm3 != "null"
                                                    ? double.parse(toKm4!)
                                                    : 0.0,
                                                double.parse(perKmAmount4!),
                                                double.parse(
                                                    distance4!.split(" ")[0]));
                                          }
                                        }
                                        addMultipleData = {
                                          "type": "schedule",
                                          "vehicles_id": vehicleId,
                                          "bookings_types_id": bookingsTypeId,
                                          "delivery_type": selectedRadio == 1
                                              ? "Single"
                                              : "Multiple",
                                          "destin_distance0":
                                              distance0!.split(" ")[0],
                                          "destin_time0": duration0,
                                          "destin_delivery_charges0":
                                              roundedTotalAmount0 ?? "0.00",
                                          "destin_vat_charges0": "0.00",
                                          "destin_total_charges0": "0.00",
                                          "destin_discount0": "0.00",
                                          "destin_discounted_charges0": "0.00",
                                          "destin_distance1":
                                              distance1!.split(" ")[0],
                                          "destin_time1": duration1,
                                          "destin_delivery_charges1":
                                              roundedTotalAmount1 ?? "0.00",
                                          "destin_vat_charges1": "0.00",
                                          "destin_total_charges1": "0.00",
                                          "destin_discount1": "0.00",
                                          "destin_discounted_charges1": "0.00",
                                          "destin_distance2": distance2 != null
                                              ? distance2!.split(" ")[0]
                                              : "0.00",
                                          "destin_time2": duration2,
                                          "destin_delivery_charges2":
                                              roundedTotalAmount2 ?? "0.00",
                                          "destin_vat_charges2": "0.00",
                                          "destin_total_charges2": "0.00",
                                          "destin_discount2": "0.00",
                                          "destin_discounted_charges2": "0.00",
                                          "destin_distance3": distance3 != null
                                              ? distance3!.split(" ")[0]
                                              : "0.00",
                                          "destin_time3": duration3,
                                          "destin_delivery_charges3":
                                              roundedTotalAmount3 ?? "0.00",
                                          "destin_vat_charges3": "0.00",
                                          "destin_total_charges3": "0.00",
                                          "destin_discount3": "0.00",
                                          "destin_discounted_charges3": "0.00",
                                          "destin_distance4": distance4 != null
                                              ? distance4!.split(" ")[0]
                                              : "0.00",
                                          "destin_time4": duration4,
                                          "destin_delivery_charges4":
                                              roundedTotalAmount4 ?? "0.00",
                                          "destin_vat_charges4": "0.00",
                                          "destin_total_charges4": "0.00",
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
                                            print(
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
                                                            height:
                                                                size.height *
                                                                    0.02),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            "Just a moment",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color:
                                                                  orangeColor,
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Inter-Bold',
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                size.height *
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
                                                            height:
                                                                size.height *
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
                                      Fluttertoast.showToast(
                                        msg: "Please fill pickup address!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    } else if (destinationController
                                        .text.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Please fill destination address!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    } else if (receiversNameController
                                        .text.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Please fill receiver's name!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    } else if (receiversNumberController
                                        .text.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Please fill receiver's number!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    } else if (selectedVehicle == null) {
                                      Fluttertoast.showToast(
                                        msg: "Please select a vehicle!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    } else if (selectedBookingType == null) {
                                      Fluttertoast.showToast(
                                        msg: "Please select booking type!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                    }
                                  } else {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await calculateDistanceTimeSingle();
                                    if (double.parse(distance!.split(" ")[0]) <=
                                        1.0) {
                                      Fluttertoast.showToast(
                                        msg:
                                            "Distance should be greater than 1.0 Km!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: toastColor,
                                        textColor: whiteColor,
                                        fontSize: 12,
                                      );
                                      setState(() {
                                        isLoading = false;
                                      });
                                    } else {
                                      await getChargesSingle(bookingsTypeId);
                                      if (bookingsTypeId == "1") {
                                        print("fromKm: $fromKm");
                                        print("toKm: $toKm");
                                        print("perKmAmount: $perKmAmount");
                                        print("totalDistance: $distance");
                                        calculateStandardAmount(
                                            double.parse(fromKm!),
                                            toKm != "null"
                                                ? double.parse(toKm!)
                                                : 0.0,
                                            double.parse(perKmAmount!),
                                            double.parse(
                                                distance!.split(" ")[0]));
                                      }
                                      addSingleData = {
                                        "type": "booking",
                                        "vehicles_id": vehicleId,
                                        "bookings_types_id": bookingsTypeId,
                                        "delivery_type": selectedRadio == 1
                                            ? "Single"
                                            : "Multiple",
                                        "pickup_address": pickupController.text,
                                        "pickup_latitude": pickupLat ??
                                            currentLat ??
                                            addressLat,
                                        "pickup_longitude": pickupLng ??
                                            currentLng ??
                                            addressLng,
                                        "destin_address":
                                            destinationController.text,
                                        "destin_latitude": destinationLat,
                                        "destin_longitude": destinationLng,
                                        "destin_distance":
                                            distance!.split(" ")[0],
                                        "destin_time": duration,
                                        "destin_delivery_charges": "0.00",
                                        "destin_vat_charges": "0.00",
                                        "destin_total_charges":
                                            roundedTotalAmount ?? "0.00",
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
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Loading Data...',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: orangeColor,
                                            fontSize: 20,
                                            fontFamily: 'Inter-Bold',
                                          ),
                                        ),
                                        content: Text(
                                          'Please wait while data is being loaded.',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: blackColor,
                                            fontSize: 14,
                                            fontFamily: 'Inter-Regular',
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                  // Add a delay to ensure data is populated in allDataForIndexes1
                                  Future.delayed(const Duration(seconds: 1),
                                      () async {
                                    // Close the loading dialog
                                    Navigator.of(context).pop();

                                    if (filteredData.isNotEmpty) {
                                      if (distance0 != null && double.parse(distance0!.split(" ")[0]) <= 1.0 ||
                                          distance1 != null && double.parse(distance1!.split(" ")[0]) <= 1.0 ||
                                          distance2 != null && double.parse(distance2!.split(" ")[0]) <= 1.0 ||
                                          distance3 != null && double.parse(distance3!.split(" ")[0]) <= 1.0 ||
                                          distance4 != null && double.parse(distance4!.split(" ")[0]) <= 1.0) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "Distance should be greater than 1.0 Km!",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 2,
                                          backgroundColor: toastColor,
                                          textColor: whiteColor,
                                          fontSize: 12,
                                        );
                                      } else {
                                        await getChargesMultiple(
                                            bookingsTypeId);
                                        if (bookingsTypeId == "1") {
                                          print("fromKm0: $fromKm0");
                                          print("toKm0: $toKm0");
                                          print("perKmAmount0: $perKmAmount0");
                                          print("totalDistance0: $distance0");
                                          calculateStandardAmount0(
                                              double.parse(fromKm0!),
                                              toKm0 != "null"
                                                  ? double.parse(toKm0!)
                                                  : 0.0,
                                              double.parse(perKmAmount0!),
                                              double.parse(
                                                  distance0!.split(" ")[0]));
                                          print("fromKm1: $fromKm1");
                                          print("toKm1: $toKm1");
                                          print("perKmAmount1: $perKmAmount1");
                                          print("totalDistance1: $distance1");
                                          calculateStandardAmount1(
                                              double.parse(fromKm1!),
                                              toKm1 != "null"
                                                  ? double.parse(toKm1!)
                                                  : 0.0,
                                              double.parse(perKmAmount1!),
                                              double.parse(
                                                  distance1!.split(" ")[0]));
                                          if (distance2 != null) {
                                            print("fromKm2: $fromKm2");
                                            print("toKm2: $toKm2");
                                            print(
                                                "perKmAmount2: $perKmAmount2");
                                            print("totalDistance2: $distance2");
                                            calculateStandardAmount2(
                                                double.parse(fromKm2!),
                                                toKm2 != "null"
                                                    ? double.parse(toKm2!)
                                                    : 0.0,
                                                double.parse(perKmAmount2!),
                                                double.parse(
                                                    distance2!.split(" ")[0]));
                                          }
                                          if (distance3 != null) {
                                            print("fromKm3: $fromKm3");
                                            print("toKm3: $toKm3");
                                            print(
                                                "perKmAmount3: $perKmAmount3");
                                            print("totalDistance3: $distance3");
                                            calculateStandardAmount3(
                                                double.parse(fromKm3!),
                                                toKm3 != "null"
                                                    ? double.parse(toKm3!)
                                                    : 0.0,
                                                double.parse(perKmAmount3!),
                                                double.parse(
                                                    distance3!.split(" ")[0]));
                                          }
                                          if (distance4 != null) {
                                            print("fromKm4: $fromKm4");
                                            print("toKm4: $toKm4");
                                            print(
                                                "perKmAmount4: $perKmAmount4");
                                            print("totalDistance4: $distance4");
                                            calculateStandardAmount4(
                                                double.parse(fromKm4!),
                                                toKm3 != "null"
                                                    ? double.parse(toKm4!)
                                                    : 0.0,
                                                double.parse(perKmAmount4!),
                                                double.parse(
                                                    distance4!.split(" ")[0]));
                                          }
                                        }
                                        addMultipleData = {
                                          "type": "booking",
                                          "vehicles_id": vehicleId,
                                          "bookings_types_id": bookingsTypeId,
                                          "delivery_type": selectedRadio == 1
                                              ? "Single"
                                              : "Multiple",
                                          "destin_distance0":
                                              distance0!.split(" ")[0],
                                          "destin_time0": duration0,
                                          "destin_delivery_charges0":
                                              roundedTotalAmount0 ?? "0.00",
                                          "destin_vat_charges0": "0.00",
                                          "destin_total_charges0": "0.00",
                                          "destin_discount0": "0.00",
                                          "destin_discounted_charges0": "0.00",
                                          "destin_distance1":
                                              distance1!.split(" ")[0],
                                          "destin_time1": duration1,
                                          "destin_delivery_charges1":
                                              roundedTotalAmount1 ?? "0.00",
                                          "destin_vat_charges1": "0.00",
                                          "destin_total_charges1": "0.00",
                                          "destin_discount1": "0.00",
                                          "destin_discounted_charges1": "0.00",
                                          "destin_distance2": distance2 != null
                                              ? distance2!.split(" ")[0]
                                              : "0.00",
                                          "destin_time2": duration2,
                                          "destin_delivery_charges2":
                                              roundedTotalAmount2 ?? "0.00",
                                          "destin_vat_charges2": "0.00",
                                          "destin_total_charges2": "0.00",
                                          "destin_discount2": "0.00",
                                          "destin_discounted_charges2": "0.00",
                                          "destin_distance3": distance3 != null
                                              ? distance3!.split(" ")[0]
                                              : "0.00",
                                          "destin_time3": duration3,
                                          "destin_delivery_charges3":
                                              roundedTotalAmount3 ?? "0.00",
                                          "destin_vat_charges3": "0.00",
                                          "destin_total_charges3": "0.00",
                                          "destin_discount3": "0.00",
                                          "destin_discounted_charges3": "0.00",
                                          "destin_distance4": distance4 != null
                                              ? distance4!.split(" ")[0]
                                              : "0.00",
                                          "destin_time4": duration4,
                                          "destin_delivery_charges4":
                                              roundedTotalAmount4 ?? "0.00",
                                          "destin_vat_charges4": "0.00",
                                          "destin_total_charges4": "0.00",
                                          "destin_discount4": "0.00",
                                          "destin_discounted_charges4": "0.00",
                                        };

                                        print("filteredData: $filteredData");

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
                                            print(
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

                                        print("indexData0: $indexData0");
                                        print("indexData1: $indexData1");
                                        print("indexData2: $indexData2");
                                        print("indexData3: $indexData3");
                                        print("indexData4: $indexData4");

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
                                                            height:
                                                                size.height *
                                                                    0.02),
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                            "Just a moment...",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color:
                                                                  orangeColor,
                                                              fontSize: 20,
                                                              fontFamily:
                                                                  'Inter-Bold',
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                size.height *
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
                                                            height:
                                                                size.height *
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
                      SizedBox(height: size.height * 0.12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
