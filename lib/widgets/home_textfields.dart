// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:google_maps_webservice_ex/places.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/utils/distance_matrix_api.dart';
import 'package:deliver_client/models/get_addresses_model.dart';

String? userId;

class HomeTextFields extends StatefulWidget {
  final int? currentIndex;
  // String? distances;
  // String? durations;
  // String? pickupLats;
  // String? pickupLngs;
  // String? addressLats;
  // String? addressLngs;
  // String? currentLats;
  // String? currentLngs;
  // String? destinationLats;
  // String? destinationLngs;
  final bool? isSelectedAddress;
  final PageController pageController;
  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final TextEditingController receiversNameController;
  final TextEditingController receiversNumberController;

  const HomeTextFields({
    super.key,
    this.currentIndex,
    this.isSelectedAddress,
    // this.distances,
    // this.durations,
    // this.pickupLats,
    // this.pickupLngs,
    // this.addressLats,
    // this.addressLngs,
    // this.currentLats,
    // this.currentLngs,
    // this.destinationLats,
    // this.destinationLngs,
    required this.pageController,
    required this.pickupController,
    required this.destinationController,
    required this.receiversNameController,
    required this.receiversNumberController,
  });

  @override
  State<HomeTextFields> createState() => _HomeTextFieldsState();
}

class _HomeTextFieldsState extends State<HomeTextFields> {
  bool isLoading = false;

  // List<String> distances = [];
  // List<String> durations = [];
  // List<String> pickupLats = [];
  // List<String> pickupLngs = [];
  // List<String> addressLats = [];
  // List<String> addressLngs = [];
  // List<String> currentLats = [];
  // List<String> currentLngs = [];
  // List<String> destinationLats = [];
  // List<String> destinationLngs = [];
  List<TextEditingController> pickupControllers = [];
  List<TextEditingController> destinationControllers = [];
  List<TextEditingController> receiversNameControllers = [];
  List<TextEditingController> receiversNumberControllers = [];

  // late String? selectedPickupLat = pickupLats[widget.currentIndex!];
  // late String? selectedPickupLng = pickupLngs[widget.currentIndex!];
  // late String? selectedAddressLat = addressLats[widget.currentIndex!];
  // late String? selectedAddressLng = addressLngs[widget.currentIndex!];
  // late String? selectedCurrentLat = currentLats[widget.currentIndex!];
  // late String? selectedCurrentLng = currentLngs[widget.currentIndex!];
  // late String? selectedDestinationLat = destinationLats[widget.currentIndex!];
  // late String? selectedDestinationLng = destinationLngs[widget.currentIndex!];
  late TextEditingController selectedPickupController = pickupControllers[widget.currentIndex!];
  late TextEditingController selectedDestinationController = destinationControllers[widget.currentIndex!];
  late TextEditingController selectedReceiversNameController = receiversNameControllers[widget.currentIndex!];
  late TextEditingController selectedReceiversNumberController = receiversNumberControllers[widget.currentIndex!];

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
  final api = DistanceMatrixAPI(mapsKey);

  List<PlacesSearchResult> pickUpPredictions = [];
  List<PlacesSearchResult> destinationPredictions = [];
  final places = GoogleMapsPlaces(apiKey: mapsKey);
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

  String currentAddress = "";

  Future<void> getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    final List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      final Placemark currentPlace = placemarks.first;
      currentAddress = "${currentPlace.name}, ${currentPlace.locality}, ${currentPlace.country}";
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation = null; // Clear selected location
        selectedAddressLocation = null; // Clear address location
        selectedMarker = const MarkerId('currentLocation');
        currentLat = position.latitude.toString();
        currentLng = position.longitude.toString();
        print("currentLat: $currentLat");
        print("currentLng: $currentLng");
        // widget.currentLats = position.latitude.toString();
        // widget.currentLngs = position.longitude.toString();
        // print("currentLat: ${widget.currentLats}");
        // print("currentLng: ${widget.currentLngs}");
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

  calculateDistanceTime() async {
    final origin =
        '${pickupLat ?? currentLat ?? addressLat},${pickupLng ?? currentLng ?? addressLng}'; // Format coordinates as "latitude,longitude"
        // '${widget.pickupLats ?? widget.currentLats ?? widget.addressLats},${widget.pickupLngs ?? widget.currentLngs ?? widget.addressLngs}'; // Format coordinates as "latitude,longitude"
    final destination =
        '$destinationLat,$destinationLng'; // Format coordinates as "latitude,longitude"
        // '${widget.destinationLats},${widget.destinationLngs}'; // Format coordinates as "latitude,longitude"
    try {
      final data = await api.getDistanceAndTime(origin, destination);
      distance = data['rows'][0]['elements'][0]['distance']['text'];
      duration = data['rows'][0]['elements'][0]['duration']['text'];
      print("distance: $distance");
      print("duration: $duration");
      // widget.distances = data['rows'][0]['elements'][0]['distance']['text'];
      // widget.durations = data['rows'][0]['elements'][0]['duration']['text'];
      // print("distance: ${widget.distances}");
      // print("duration: ${widget.durations}");
    } catch (e) {
      print("Error: $e");
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

  @override
  void initState() {
    super.initState();
    getAddresses();
    for (int i = 0; i < 5; i++) {
      // distances.add("");
      // durations.add("");
      // pickupLats.add("");
      // pickupLngs.add("");
      // addressLats.add("");
      // addressLngs.add("");
      // currentLats.add("");
      // currentLngs.add("");
      // destinationLats.add(widget.destinationLngs ?? "");
      // destinationLngs.add(widget.destinationLngs ?? "");
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
                                          // widget.addressLats = savedLat.toString();
                                          // widget.addressLngs = savedLng.toString();
                                          setState(() {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            print("addressLat: $addressLat");
                                            print("addressLng $addressLng");
                                            // print("addressLat: ${widget.addressLats}");
                                            // print("addressLng ${widget.addressLngs}");
                                            print("addressLocation: ${addresses.address}");
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
                                    print("index: ${widget.currentIndex}");
                                    widget.pickupController.text = currentAddress;
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
                                      final prediction = pickUpPredictions[index];
                                      return ListTile(
                                        title: Text(prediction.name),
                                        subtitle: Text(prediction.formattedAddress ?? ''),
                                        onTap: () {
                                          widget.pickupController.text = prediction.formattedAddress!;
                                          final double lat = prediction.geometry!.location.lat;
                                          final double lng = prediction.geometry!.location.lng;
                                          const double zoomLevel = 15.0;
                                          onPickUpLocationSelected(LatLng(lat, lng), zoomLevel);
                                          pickupLat = lat.toString();
                                          pickupLng = lng.toString();
                                          // widget.pickupLats = lat.toString();
                                          // widget.pickupLngs = lng.toString();
                                          setState(() {
                                            pickUpPredictions.clear();
                                            FocusManager.instance.primaryFocus?.unfocus();
                                            print("pickupLat: $pickupLat");
                                            print("pickupLng $pickupLng");
                                            // print("pickupLat: ${widget.pickupLats}");
                                            // print("pickupLng ${widget.pickupLngs}");
                                            print("pickupLocation: ${prediction.formattedAddress}");
                                          });
                                          // Move the map camera to the selected location
                                          mapController?.animateCamera(CameraUpdate.newLatLng(selectedLocation!),
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
                                final prediction = destinationPredictions[index];
                                return ListTile(
                                  title: Text(prediction.name),
                                  subtitle: Text(prediction.formattedAddress ?? ''),
                                  onTap: () {
                                    widget.destinationController.text = prediction.formattedAddress!;
                                    final double lat = prediction.geometry!.location.lat;
                                    final double lng = prediction.geometry!.location.lng;
                                    destinationLat = lat.toString();
                                    destinationLng = lng.toString();
                                    // widget.destinationLats = lat.toString();
                                    // widget.destinationLngs = lng.toString();
                                    setState(() {
                                      destinationPredictions.clear();
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      print("destinationLat: $destinationLat");
                                      print("destinationLng $destinationLng");
                                      // print("destinationLat: ${widget.destinationLats}");
                                      // print("destinationLng ${widget.destinationLngs}");
                                      print("destinationLocation: ${prediction.formattedAddress}");
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
