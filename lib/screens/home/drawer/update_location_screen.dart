// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/update_location_model.dart';

String? userId;
String? firstName;

class UpdateLocationScreen extends StatefulWidget {
  const UpdateLocationScreen({super.key});

  @override
  State<UpdateLocationScreen> createState() => _UpdateLocationScreenState();
}

class _UpdateLocationScreenState extends State<UpdateLocationScreen> {
  String? currentLat;
  String? currentLng;
  bool isLoading = false;
  LatLng? currentLocation;
  String? baseUrl = dotenv.env['BASE_URL'];

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
        currentLat = position.latitude.toString();
        currentLng = position.longitude.toString();
        debugPrint("currentPickUpLocation: $currentAddress");
      });
    }
  }

  sharedPrefs() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString('userId');
    firstName = sharedPref.getString('firstName');
    debugPrint('sharedPrefs userId: $userId');
    debugPrint('sharedPrefs firstName: $firstName');
    setState(() {});
  }

  UpdateLocationModel updateLocationModel = UpdateLocationModel();

  updateLocation() async {
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$baseUrl/update_location_customers";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("latitude: $currentLat");
      debugPrint("longitude: $currentLng");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "users_customers_id": userId,
          "latitude": currentLat,
          "longitude": currentLng,
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        updateLocationModel = updateLocationModelFromJson(responseString);
        debugPrint('updateLocationModel status: ${updateLocationModel.status}');
        if (updateLocationModel.status == 'success') {
          Fluttertoast.showToast(
            msg: "Current Location Updated",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: toastColor,
            textColor: whiteColor,
            fontSize: 12,
          );
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
    sharedPrefs();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
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
        title: Text(
          "Update Location",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blackColor,
            fontSize: 20,
            fontFamily: 'Syne-Bold',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: size.height * 0.03),
            Text(
              "Hi, there! $firstName",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: orangeColor,
                fontSize: 20,
                fontFamily: 'Syne-SemiBold',
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              "Update your location to find nearby riders\nand ensure swift and convenient \ndeliveries.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackColor,
                fontSize: 16,
                fontFamily: 'Syne-Medium',
              ),
            ),
            SvgPicture.asset('assets/images/update-location-big-icon.svg'),
            GestureDetector(
              onTap: () async {
                await getCurrentLocation();
                await updateLocation();
              },
              child: isLoading
                  ? buttonGradientWithLoader("Please Wait...", context)
                  : buttonGradient('Update Location', context),
            ),
            SizedBox(height: size.height * 0.03),
          ],
        ),
      ),
    );
  }
}
