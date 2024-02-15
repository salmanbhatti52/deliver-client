// ignore_for_file: avoid_print, must_be_immutable, use_build_context_synchronously, implementation_imports, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_webservice_ex/places.dart';
import 'package:flutter/src/widgets/navigator.dart' as nav;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/add_addresses_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';

String? userId;

class DrawerSaveLocationScreen extends StatefulWidget {
  late double? location;
  DrawerSaveLocationScreen({super.key, this.location});

  @override
  State<DrawerSaveLocationScreen> createState() =>
      _DrawerSaveLocationScreenState();
}

class _DrawerSaveLocationScreenState extends State<DrawerSaveLocationScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> nameLocationFormKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? mapsKey = dotenv.env['MAPS_KEY'];

  String? systemLat;
  String? systemLng;
  String? currentLat;
  String? currentLng;
  String? addressLat;
  String? addressLng;
  double? doubleSystemLat;
  double? doubleSystemLng;

  var places;
  List<PlacesSearchResult> addressPredictions = [];
  BitmapDescriptor? customMarkerIcon;
  GoogleMapController? mapController;
  MarkerId? selectedMarker;
  LatLng? selectedLocation;
  LatLng? currentLocation;

  AddAddressesModel addAddressesModel = AddAddressesModel();

  addAddresses() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/add_address_customers";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("userId: $userId");
      debugPrint("name: ${nameController.text}");
      debugPrint("address: ${searchController.text}");
      debugPrint("latitude: ${addressLat ?? currentLat}");
      debugPrint("longitude: ${addressLng ?? currentLng}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "users_customers_id": userId,
          "name": nameController.text,
          "address": searchController.text,
          "latitude": addressLat ?? currentLat,
          "longitude": addressLng ?? currentLng
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        addAddressesModel = addAddressesModelFromJson(responseString);
        setState(() {});
        debugPrint('addAddressesModel status: ${addAddressesModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

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
        debugPrint('getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        debugPrint(
            'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "system_latitude") {
            systemLat = "${getAllSystemDataModel.data?[i].description}";
            doubleSystemLat = double.parse(systemLat!);
            debugPrint("doubleSystemLat: $doubleSystemLat");
          }
          if (getAllSystemDataModel.data?[i].type == "system_longitude") {
            systemLng = "${getAllSystemDataModel.data?[i].description}";
            doubleSystemLng = double.parse(systemLng!);
            debugPrint("doubleSystemLng: $doubleSystemLng");
          }
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  Future<void> searchAddressPlaces(String input) async {
    if (input.isNotEmpty) {
      final response = await places.searchByText(input);

      if (response.isOkay) {
        setState(() {
          addressPredictions = response.results;
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
        searchController.text = currentAddress;
        currentLat = position.latitude.toString();
        currentLng = position.longitude.toString();
        debugPrint("currentLat: $currentLat");
        debugPrint("currentLng: $currentLng");
        debugPrint("currentpickupLocation: $currentAddress");
      });

      mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(currentLocation!, 15.0));
    }
  }

  void onAddressLocationSelected(LatLng location, double zoomLevel) {
    setState(() {
      selectedLocation = location;
      currentLocation = null; // Clear current location
      selectedMarker = const MarkerId('selectedLocation');
    });

    mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation!, zoomLevel));
  }

  Future<void> loadCustomMarker() async {
    final ByteData bytes = await rootBundle.load(
      'assets/images/current-location-name-white-icon.png',
    );
    final Uint8List list = bytes.buffer.asUint8List();

    customMarkerIcon = BitmapDescriptor.fromBytes(list);

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadCustomMarker();
    getAllSystemData();
    places = GoogleMapsPlaces(apiKey: mapsKey);
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
            ? Stack(
                children: [
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                      mapType: MapType.normal,
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          // widget.location ?? 9.077751,
                          // widget.location ?? 8.6774567,
                          doubleSystemLat != null ? doubleSystemLat! : 6.077751,
                          doubleSystemLng != null
                              ? doubleSystemLng!
                              : -8.6774567,
                        ),
                        zoom: 6,
                      ),
                      markers: {
                        if (currentLocation != null)
                          Marker(
                            markerId: const MarkerId('currentLocation'),
                            position: currentLocation!,
                            infoWindow: const InfoWindow(title: 'My Location'),
                            icon: customMarkerIcon ??
                                BitmapDescriptor.defaultMarker,
                          ),
                        if (selectedLocation != null)
                          Marker(
                            markerId: const MarkerId('selectedLocation'),
                            position: selectedLocation!,
                            infoWindow: const InfoWindow(title: 'My Location'),
                            icon: customMarkerIcon ??
                                BitmapDescriptor.defaultMarker,
                          ),
                      },
                    ),
                  ),
                  Positioned(
                    top: 45,
                    left: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SvgPicture.asset(
                        'assets/images/back-icon.svg',
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 30,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40, right: 20),
                      child: Column(
                        children: [
                          Container(
                            color: transparentColor,
                            width: size.width * 0.85,
                            child: Stack(
                              children: [
                                TextFormField(
                                  controller: searchController,
                                  onChanged: (value) {
                                    searchAddressPlaces(value);
                                  },
                                  onTap: () {
                                    searchController.clear();
                                    addressPredictions.clear();
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
                                    fillColor: whiteColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: borderColor.withOpacity(0.25),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: borderColor.withOpacity(0.25),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: borderColor.withOpacity(0.25),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    hintText: "What is your location?",
                                    hintStyle: TextStyle(
                                      color: hintColor,
                                      fontSize: 12,
                                      fontFamily: 'Inter-Light',
                                    ),
                                    suffixIcon: Container(
                                      color: transparentColor,
                                      child: SvgPicture.asset(
                                        'assets/images/search-icon.svg',
                                        fit: BoxFit.scaleDown,
                                      ),
                                    ),
                                  ),
                                ),
                                if (addressPredictions.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 40),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      width: size.width * 0.8,
                                      height: size.height * 0.2,
                                      child: ListView.separated(
                                        itemCount: addressPredictions.length,
                                        itemBuilder: (context, index) {
                                          final prediction =
                                              addressPredictions[index];
                                          return ListTile(
                                            title: Text(prediction.name),
                                            subtitle: Text(
                                                prediction.formattedAddress ??
                                                    ''),
                                            onTap: () {
                                              searchController.text =
                                                  prediction.formattedAddress!;
                                              final double lat = prediction
                                                  .geometry!.location.lat;
                                              final double lng = prediction
                                                  .geometry!.location.lng;
                                              const double zoomLevel = 15.0;
                                              onAddressLocationSelected(
                                                  LatLng(lat, lng), zoomLevel);
                                              addressLat = lat.toString();
                                              addressLng = lng.toString();
                                              setState(() {
                                                addressPredictions.clear();
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                debugPrint("pickupLat: $addressLat");
                                                debugPrint("pickupLng $addressLng");
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
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 100,
                    right: 20,
                    child: GestureDetector(
                      onTap: () {
                        getCurrentLocation();
                      },
                      child: SvgPicture.asset(
                          'assets/images/current-location-icon.svg',
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => nameLocation(),
                        );
                      },
                      child: buttonGradient("SAVE", context),
                    ),
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
      ),
    );
  }

  Widget nameLocation() {
    var size = MediaQuery.of(context).size;
    return StatefulBuilder(
      builder: (context, setState) => GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: WillPopScope(
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
              height: size.height * 0.35,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: nameLocationFormKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SvgPicture.asset(
                                "assets/images/close-icon.svg"),
                          ),
                        ),
                      ),
                      Text(
                        'Name location'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: orangeColor,
                          fontSize: 24,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          controller: nameController,
                          cursorColor: orangeColor,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required!';
                            }
                            return null;
                          },
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
                            hintText: "Name",
                            hintStyle: TextStyle(
                              color: hintColor,
                              fontSize: 12,
                              fontFamily: 'Inter-Light',
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          if (nameLocationFormKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            await addAddresses();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const HomePageScreen()),
                                (nav.Route<dynamic> route) => false);
                          }
                          setState(() {
                            isLoading = false;
                            FocusManager.instance.primaryFocus?.unfocus();
                          });
                        },
                        child: isLoading
                            ? buttonGradientWithLoader(
                                "Please Wait...", context)
                            : buttonGradient('OK', context),
                      ),
                      SizedBox(height: size.height * 0.01),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
