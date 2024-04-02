// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_webservice_ex/places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/utils/distance_matrix_api.dart';
import 'package:deliver_client/models/get_addresses_model.dart';

String? userId;

class HomeTextFields extends StatefulWidget {
  final int? currentIndex;
  final bool? isSelectedAddress;
  final PageController pageController;
  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final TextEditingController receiversNameController;
  final TextEditingController receiversNumberController;

  const HomeTextFields({
    Key? key,
    this.currentIndex,
    this.isSelectedAddress,
    required this.pageController,
    required this.pickupController,
    required this.destinationController,
    required this.receiversNameController,
    required this.receiversNumberController, // Correct location
  }) : super(key: key);

  @override
  State<HomeTextFields> createState() => _HomeTextFieldsState();
}

class _HomeTextFieldsState extends State<HomeTextFields> {
  List<TextEditingController> pickupControllers = [];
  List<TextEditingController> destinationControllers = [];
  List<TextEditingController> receiversNameControllers = [];
  List<TextEditingController> receiversNumberControllers = [];
  late TextEditingController selectedPickupController =
      pickupControllers[widget.currentIndex!];
  late TextEditingController selectedDestinationController =
      destinationControllers[widget.currentIndex!];
  late TextEditingController selectedReceiversNameController =
      receiversNameControllers[widget.currentIndex!];
  late TextEditingController selectedReceiversNumberController =
      receiversNumberControllers[widget.currentIndex!];

  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? mapsKey = dotenv.env['MAPS_KEY'];

  String? distance;
  String? duration;
  String? pickupLat;
  String? pickupLng;
  String? addressLat;
  String? addressLng;
  String? currentLat;
  String? currentLng;
  String? destinationLat;
  String? destinationLng;
  List<String> addresses = [];
  bool addressesVisible = false;

  var places;
  int apiHitCount = 0;
  List<PlacesSearchResult> pickUpPredictions = [];
  List<PlacesSearchResult> destinationPredictions = [];
  GoogleMapController? mapController;
  MarkerId? selectedMarker;
  LatLng? currentLocation;
  LatLng? selectedLocation;
  LatLng? selectedAddressLocation;
  BitmapDescriptor? customMarkerIcon;
  Future<void> googleAnalytics(String input) async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
      'Content-Type': 'application/json'
    };
    var url = Uri.parse('https://deliver.eigix.net/api/add_google_api_hit');

    var body = {"url": input};

    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print(resBody);
    } else {
      print(res.reasonPhrase);
    }
  }

  Timer? _debounceTimer;
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
        await googleAnalytics(input);

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
        await googleAnalytics(input);

        if (response.isOkay) {
          setState(() {
            destinationPredictions = response.results;
          });
        }
      });
    }
  }

  String currentAddress = "";

  Future<void> getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    final List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      final Placemark currentPlace = placemarks.first;
      currentAddress =
          "${currentPlace.name}, ${currentPlace.locality}, ${currentPlace.country}";
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation = null; // Clear selected location
        selectedAddressLocation = null; // Clear address location
        selectedMarker = const MarkerId('currentLocation');
        currentLat = position.latitude.toString();
        currentLng = position.longitude.toString();
        debugPrint("currentLat: $currentLat");
        debugPrint("currentLng: $currentLng");
        // widget.currentLats = position.latitude.toString();
        // widget.currentLngs = position.longitude.toString();
        // debugPrint("currentLat: ${widget.currentLats}");
        // debugPrint("currentLng: ${widget.currentLngs}");
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

  var api;

  GetAddressesModel getAddressesModel = GetAddressesModel();

  getAddresses() async {
    try {
      setState(() {
        isLoading = true;
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
        debugPrint('getAddressesModel status: ${getAddressesModel.status}');
        for (int i = 0; i < getAddressesModel.data!.length; i++) {
          addresses.add("${getAddressesModel.data?[i]}");
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getAddresses();
    api = DistanceMatrixAPI("$mapsKey");
    places = GoogleMapsPlaces(apiKey: mapsKey);
    print("placesssssssssssssssssssssssssssssss: $places");
    for (int i = 0; i < 5; i++) {
      pickupControllers.add(TextEditingController());
      destinationControllers.add(TextEditingController());
      receiversNameControllers.add(TextEditingController());
      receiversNumberControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
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
                // Text('API Hits: $apiHitCount'),
                widget.isSelectedAddress == true
                    ? Container(
                        color: transparentColor,
                        width: size.width * 0.8,
                        child: Stack(
                          children: [
                            TextFormField(
                              controller: widget.pickupController,
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
                                          widget.pickupController.text =
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
                                                "addressLat Multiple: $addressLat");
                                            debugPrint(
                                                "addressLng Multiple: $addressLng");
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
                        width: size.width * 0.8,
                        child: Stack(
                          children: [
                            TextFormField(
                              controller: widget.pickupController,
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
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                hintText: "Pickup Location",
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    getCurrentLocation();
                                    debugPrint("index: ${widget.currentIndex}");
                                    widget.pickupController.text =
                                        currentAddress;
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
                                          widget.pickupController.text =
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
                                            debugPrint(
                                                "pickupLat Mutlipe: $pickupLat");
                                            debugPrint(
                                                "pickupLng Mutiple: $pickupLng");
                                            debugPrint(
                                                "pickupLocation: ${prediction.formattedAddress}");
                                          });
                                          // Move the map camera to the selected location
                                          mapController?.animateCamera(
                                            CameraUpdate.newLatLng(
                                                selectedLocation!),
                                          );
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
                        controller: widget.destinationController,
                        onChanged: (value) {
                          searchDestinationPlaces(value);
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
                            horizontal: 20,
                            vertical: 10,
                          ),
                          hintText: "Destination",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 12,
                            fontFamily: 'Inter-Light',
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a destination';
                          }
                          // You can add more complex validation logic here if needed
                          return null; // Return null if validation succeeds
                        },
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
                                    widget.destinationController.text =
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
                                          "destinationLat Multiple: $destinationLat");
                                      debugPrint(
                                          "destinationLng Multiple: $destinationLng");
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
                  width: size.width * 0.8,
                  child: TextFormField(
                    controller: widget.receiversNameController,
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
                    controller: widget.receiversNumberController,
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
    );
  }
}
