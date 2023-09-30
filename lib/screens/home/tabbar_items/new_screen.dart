// ignore_for_file: avoid_print, must_be_immutable, use_build_context_synchronously, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:google_maps_webservice_ex/places.dart';
import 'package:deliver_client/widgets/home_textfields.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/get_charges_model.dart';
import 'package:deliver_client/models/get_vehicles_model.dart';
import 'package:deliver_client/models/get_services_type_model.dart';
import 'package:deliver_client/models/get_bookings_type_model.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/screens/home/schedule_ride_screen.dart';
import 'package:deliver_client/models/calculate_distance_model.dart';
import 'package:deliver_client/screens/confirm_single_details_screen.dart';
import 'package:deliver_client/screens/confirm_multiple_details_screen.dart';

class NewScreen extends StatefulWidget {
  late double? location;

  NewScreen({super.key, this.location});

  @override
  State<NewScreen> createState() => _NewScreenState();
}

class _NewScreenState extends State<NewScreen> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController receiversNameController = TextEditingController();
  TextEditingController receiversNumberController = TextEditingController();
  GlobalKey<FormState> singleDeliveryFormKey = GlobalKey<FormState>();
  final DraggableScrollableController dragController =
      DraggableScrollableController();
  Map addSingleData = {};
  Map addScheduledSingleData = {};
  bool isSelectedTruck = true;
  bool isSelectedFreight = false;
  bool isSelectedCourier = false;
  String? totalDistance;
  String? systemLat;
  String? systemLng;
  String? time;
  double? doubleSystemLat;
  double? doubleSystemLng;
  double? doubleTime;
  String? pickupLat;
  String? pickupLng;
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
  String? fromKm;
  String? toKm;
  String? perKmAmount;
  double? totalAmount;
  String? roundedTotalAmount;

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
        print(
            'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "system_latitude") {
            systemLat = "${getAllSystemDataModel.data?[i].description}";
            doubleSystemLat = double.parse(systemLat!);
          }
          if (getAllSystemDataModel.data?[i].type == "system_longitude") {
            systemLng = "${getAllSystemDataModel.data?[i].description}";
            doubleSystemLng = double.parse(systemLng!);
          }
          if (getAllSystemDataModel.data?[i].type == "per_km_time") {
            time = "${getAllSystemDataModel.data?[i].description}";
            doubleTime = double.parse(time!);
          }
          setState(() {});
        }
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
        setState(() {});
        print('getServiceTypesModel status: ${getServiceTypesModel.status}');
        print(
            'getServiceTypesModel length: ${getServiceTypesModel.data!.length}');
        for (int i = 0; i < getServiceTypesModel.data!.length; i++) {
          if (getServiceTypesModel.data?[i].name == "Couriers") {
            courierId = "${getServiceTypesModel.data?[i].serviceTypesId}";
            print("courierId: $courierId");
          }
          if (getServiceTypesModel.data?[i].name == "Others") {
            otherId = "${getServiceTypesModel.data?[i].serviceTypesId}";
            print("otherId: $otherId");
            getVehiclesByServiceType(otherId);
            setState(() {});
          }
        }
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetVehiclesByServiceTypeModel getVehiclesByServiceTypeModel =
      GetVehiclesByServiceTypeModel();

  getVehiclesByServiceType(String? serviceId) async {
    try {
      String apiUrl = "$baseUrl/get_vehicles_by_service_type";
      print("apiUrl: $apiUrl");
      // print("serviceTypesId: ");
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
        print(
            'getVehiclesByServiceTypeModel length: ${getVehiclesByServiceTypeModel.data!.length}');
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
        print(
            'getBookingsTypeModel length: ${getBookingsTypeModel.data!.length}');
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

  DistanceCalculatorModel distanceCalculatorModel = DistanceCalculatorModel();

  distanceCalculator() async {
    try {
      String apiUrl = "$baseUrl/calculate_distance_diff";
      print("apiUrl: $apiUrl");
      print("pickupLat: ${pickupLat ?? currentLat}");
      print("pickupLong: ${pickupLng ?? currentLng}");
      print("destin1Lat: $destinationLat");
      print("destin1Long: $destinationLng");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "from_lat": pickupLat ?? currentLat,
          "from_long": pickupLng ?? currentLng,
          "to_lat": destinationLat,
          "to_long": destinationLng,
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        distanceCalculatorModel =
            distanceCalculatorModelFromJson(responseString);
        print(
            'distanceCalculatorModel status: ${distanceCalculatorModel.status}');
        setState(() {});
      }
      totalDistance = "${distanceCalculatorModel.data?.distance}";
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetChargesModel getChargesModel = GetChargesModel();

  getCharges(String? bTypeId) async {
    try {
      String apiUrl = "$baseUrl/get_charges_parameters";
      print("apiUrl: $apiUrl");
      print("bookingsTypeId: $bTypeId");
      print("distance: $totalDistance");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "bookings_types_id": bTypeId,
          "distance": totalDistance,
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getChargesModel = getChargesModelFromJson(responseString);
        print('getChargesModel status: ${getChargesModel.status}');
        fromKm = "${getChargesModel.data?.firstMilesFrom}";
        toKm = "${getChargesModel.data?.firstMilesTo}";
        perKmAmount = "${getChargesModel.data?.firstMilesAmount}";
        print("fromKm: $fromKm");
        print("toKm: $toKm");
        print("perKmAmount: $perKmAmount");
        setState(() {});
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  calculateTime() {
    if (totalDistance != null) {
      double distance = double.parse(totalDistance!);
      double totalTime = distance * doubleTime!;
      print("totalTime: $totalTime");
      String formattedTime = formatDecimalAsTime(totalTime);
      print("formattedTime: $formattedTime");
      return formattedTime;
    }
  }

  String formatDecimalAsTime(double decimalValue) {
    int hours = decimalValue.toInt();
    int minutes = ((decimalValue - hours) * 60).toInt();
    String result = "";
    if (hours > 0) {
      result += "$hours hour";
      if (hours > 1) {
        result += "s";
      }
      result += " ";
    }
    if (minutes > 0) {
      result += "$minutes minute";
      if (minutes > 1) {
        result += "s";
      }
    }
    return result;
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

  int selectedRadio = 1;

  PageController pageController = PageController();
  int currentIndex = 0;
  List<Widget> pages = [
    const HomeTextFeilds(),
    const HomeTextFeilds(),
  ];

  void addPage() {
    if (pages.length >= 5) {
      return; // Limit reached, do not add more pages
    }
    setState(() {
      pages.add(
        const HomeTextFeilds(),
      );
    });
  }

  void removePage() {
    if (pages.length <= 2) {
      return; // Limit reached, do not add more pages
    }
    pages.removeAt(currentIndex);
    setState(() {
      pageController.jumpToPage(currentIndex - 1);
    });
  }

  List<PlacesSearchResult> pickUpPredictions = [];
  List<PlacesSearchResult> destinationPredictions = [];
  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyAk-CA4yYf-txNZvvwmCshykjpLiASEkcw');
  GoogleMapController? mapController;
  MarkerId? selectedMarker;
  LatLng? selectedLocation;
  LatLng? currentLocation;

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
        selectedMarker = const MarkerId('currentLocation');
        pickupController.text = currentAddress;
        currentLat = position.latitude.toString();
        currentLng = position.longitude.toString();
        print("currentLat: $currentLat");
        print("currentLng: $currentLng");
        print("currentpickupLocation: $currentAddress");
      });

      mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(currentLocation!, 12));
    }
  }

  void onPickUpLocationSelected(LatLng location, double zoomLevel) {
    setState(() {
      selectedLocation = location;
      currentLocation = null; // Clear current location
      selectedMarker = const MarkerId('selectedLocation');
    });

    mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation!, zoomLevel));
  }

  @override
  void initState() {
    super.initState();
    getAllSystemData();
    getServiceTypes();
    getBookingsType();
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
                      height:
                          size.height * 0.631, // Adjust the height accordingly
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
                              infoWindow:
                                  const InfoWindow(title: 'My Location'),
                            ),
                          if (selectedLocation != null)
                            Marker(
                              markerId: const MarkerId('selectedLocation'),
                              position: selectedLocation!,
                              infoWindow:
                                  const InfoWindow(title: 'My Location'),
                            ),
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: bottomDetailsSheet(), // Add the bottom sheet here
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

  Widget singleTextField() {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: singleDeliveryFormKey,
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
                    Container(
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
                                  itemCount: pickUpPredictions.length,
                                  itemBuilder: (context, index) {
                                    final prediction = pickUpPredictions[index];
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
                                        const double zoomLevel = 12.0;
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
                                  itemCount: destinationPredictions.length,
                                  itemBuilder: (context, index) {
                                    final prediction =
                                        destinationPredictions[index];
                                    return ListTile(
                                      title: Text(prediction.name),
                                      subtitle: Text(
                                          prediction.formattedAddress ?? ''),
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
                                          print(
                                              "destinationLng $destinationLng");
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
      ),
    );
  }

  Widget multiPageView() {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        color: transparentColor,
        height: size.height * 0.295,
        child: PageView(
          scrollDirection: Axis.horizontal,
          controller: pageController,
          onPageChanged: (value) {
            setState(() {
              currentIndex = value;
              print('currentIndex: $currentIndex');
            });
          },
          children: pages,
        ),
      ),
    );
  }

  Widget bottomDetailsSheet() {
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
                      SizedBox(height: size.height * 0.02),
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
                      SizedBox(height: size.height * 0.01),
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
                                getVehiclesByServiceType(otherId);
                                setState(() {
                                  isSelectedTruck = true;
                                  isSelectedFreight = false;
                                  isSelectedCourier = false;
                                });
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    color: transparentColor,
                                    width: MediaQuery.of(context).size.width *
                                        0.28,
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.28,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.08,
                                      decoration: BoxDecoration(
                                        color: isSelectedTruck == true
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
                                      "Haulage",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelectedTruck == true
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
                                      "assets/images/home-turck-icon.svg",
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 30,
                                    right: 8,
                                    child: SvgPicture.asset(
                                      "assets/images/help-icon.svg",
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
                                  isSelectedTruck = false;
                                  isSelectedFreight = true;
                                  isSelectedCourier = false;
                                });
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    color: transparentColor,
                                    width: MediaQuery.of(context).size.width *
                                        0.28,
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.28,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.08,
                                      decoration: BoxDecoration(
                                        color: isSelectedFreight == true
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
                                      "Freight",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSelectedFreight == true
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
                                      "assets/images/home-freight-icon.svg",
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 30,
                                    right: 8,
                                    child: SvgPicture.asset(
                                      "assets/images/help-icon.svg",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                vehiclesType.clear();
                                selectedVehicle = null;
                                getVehiclesByServiceType(courierId);
                                setState(() {
                                  isSelectedTruck = false;
                                  isSelectedFreight = false;
                                  isSelectedCourier = true;
                                });
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    color: transparentColor,
                                    width: MediaQuery.of(context).size.width *
                                        0.28,
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.28,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.08,
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
                                      "Courier",
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
                                      "assets/images/home-courier-icon.svg",
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 30,
                                    right: 8,
                                    child: SvgPicture.asset(
                                      "assets/images/help-icon.svg",
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
                            Text(
                              "Find best rider?",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: drawerTextColor,
                                fontSize: 20,
                                fontFamily: 'Syne-Bold',
                              ),
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
                      SizedBox(height: size.height * 0.01),
                      if (selectedRadio == 1) SizedBox(height: size.height * 0),
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
                                    // validator: (value) {
                                    //   if (value == null) {
                                    //     return 'Category is required!';
                                    //   }
                                    //   return null;
                                    // },
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
                      SizedBox(height: size.height * 0.01),
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
                                    // validator: (value) {
                                    //   if (value == null) {
                                    //     return 'Category is required!';
                                    //   }
                                    //   return null;
                                    // },
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
                                          if ("${getBookingsTypeModel.data?[i].name} (${getBookingsTypeModel.data?[i].sameDay})" ==
                                              value) {
                                            bookingsTypeId =
                                                getBookingsTypeModel
                                                    .data?[i].bookingsTypesId
                                                    .toString();
                                            await distanceCalculator();
                                            await getCharges(bookingsTypeId);
                                            print(
                                                'bookingsTypeId: $bookingsTypeId');
                                            if (bookingsTypeId == "1") {
                                              print("fromKm: $fromKm");
                                              print("toKm: $toKm");
                                              print(
                                                  "perKmAmount: $perKmAmount");
                                              print(
                                                  "totalDistance: $totalDistance");
                                              calculateStandardAmount(
                                                double.parse(fromKm!),
                                                toKm != "null"
                                                    ? double.parse(toKm!)
                                                    : 0.0,
                                                double.parse(perKmAmount!),
                                                double.parse(totalDistance!),
                                              );
                                            }
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
                                      horizontal: 3,
                                    ),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScheduleRideScreen(
                                      selectedRadio: selectedRadio,
                                    ),
                                  ),
                                );
                              },
                              child: buttonTransparentGradientSmall(
                                "SCHEDULE RIDE",
                                context,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (selectedRadio == 1) {
                                  calculateTime();
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
                                    await distanceCalculator();
                                    await getCharges(bookingsTypeId);
                                    print('bookingsTypeId: $bookingsTypeId');
                                    if (bookingsTypeId == "1") {
                                      print("fromKm: $fromKm");
                                      print("toKm: $toKm");
                                      print("perKmAmount: $perKmAmount");
                                      print("totalDistance: $totalDistance");
                                      calculateStandardAmount(
                                        double.parse(fromKm!),
                                        toKm != "null"
                                            ? double.parse(toKm!)
                                            : 0.0,
                                        double.parse(perKmAmount!),
                                        double.parse(totalDistance!),
                                      );
                                    }
                                    addSingleData = {
                                      "vehicles_id": vehicleId,
                                      "bookings_types_id": bookingsTypeId,
                                      "delivery_type": selectedRadio == 1
                                          ? "Single"
                                          : "Multiple",
                                      "pickup_address": pickupController.text,
                                      "pickup_latitude":
                                          pickupLat ?? currentLat,
                                      "pickup_longitude":
                                          pickupLng ?? currentLng,
                                      "destin_address":
                                          destinationController.text,
                                      "destin_latitude": destinationLat,
                                      "destin_longitude": destinationLng,
                                      "destin_distance": totalDistance,
                                      "destin_time": "2 hrs 44 mins",
                                      "destin_delivery_charges":
                                          roundedTotalAmount ?? "0.00",
                                      "destin_vat_charges": "0.00",
                                      "destin_total_charges": "0.00",
                                      "destin_discount": "0.00",
                                      "destin_discounted_charges": "0.00",
                                      "receiver_name":
                                          receiversNameController.text,
                                      "receiver_phone":
                                          receiversNumberController.text,
                                    };
                                    setState(() {});
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
                                if (selectedRadio == 2) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ConfirmMultipleDetailsScreen(),
                                    ),
                                  );
                                }
                              },
                              child: buttonGradientSmall(
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
