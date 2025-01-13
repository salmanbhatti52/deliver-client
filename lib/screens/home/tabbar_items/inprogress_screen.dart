// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:deliver_client/screens/chat_screen.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
import 'package:deliver_client/screens/report_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:deliver_client/screens/payment/amount_to_pay_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class InProgressHomeScreen extends StatefulWidget {
  final Map? singleData;
  final String? passCode;
  final Map? multipleData;
  final String? currentBookingId;
  final UpdateBookingStatusModel? riderData;
  final String? bookingDestinationId;

  const InProgressHomeScreen({
    super.key,
    this.singleData,
    this.passCode,
    this.multipleData,
    this.currentBookingId,
    this.riderData,
    this.bookingDestinationId,
  });

  @override
  State<InProgressHomeScreen> createState() => _InProgressHomeScreenState();
}

class _InProgressHomeScreenState extends State<InProgressHomeScreen> {
  bool isLoading = false;
  String? distanceUnit;
  Timer? timer;
  String? latDest;
  String? lngDest;
  String? latRider;
  String? lngRider;
  double? destLat;
  double? destLng;
  double? riderLat;
  double? riderLng;
  LatLng? riderPosition;
  LatLng? destinationPosition;
  double? riderDestinLat;
  double? riderDestinLng;
  List<LatLng> polylineCoordinates = [];
  GoogleMapController? mapController;
  BitmapDescriptor? customMarkerIcon;
  BitmapDescriptor? customDestMarkerIcon;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? mapsKey = dotenv.env['MAPS_KEY'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

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
        getAllSystemDataModel = getAllSystemDataModelFromJson(responseString);
        await fetchSystemSettingsDescription28();
        await fetchSystemSettingsDescription397();
        debugPrint(
            'getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "distance_unit") {
            distanceUnit = "${getAllSystemDataModel.data?[i].description}";
            debugPrint("distanceUnit: $distanceUnit");
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  String? passcode0;
  String? passcode1;
  String? passcode2;
  String? passcode3;
  String? passcode4;
  String? phoneNumber0;
  String? phoneNumber1;
  String? phoneNumber2;
  String? phoneNumber3;
  String? phoneNumber4;
  String? charges0;
  String? charges1;
  String? charges2;
  String? charges3;
  String? charges4;
  String? riderName0;
  String? riderName1;
  String? riderName2;
  String? riderName3;
  String? riderName4;
  double? updatedLat;
  double? updatedLng;
  bool systemSettings = false;
  String? trackingPrefix;
  String? estimatedTime;
  String? distanceRemaining;
  String? mapRefreshTime;

  Future<String?> fetchSystemSettingsDescription28() async {
    const String apiUrl = 'https://deliverbygfl.com/api/get_all_system_data';
    setState(() {
      systemSettings = true;
    });
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        final Map<String, dynamic> data = json.decode(response.body);

        // Find the setting with system_settings_id equal to 26
        final setting395 = data['data'].firstWhere(
            (setting) => setting['system_settings_id'] == 395,
            orElse: () => null);
        final setting397 = data['data'].firstWhere(
            (setting) => setting['system_settings_id'] == 397,
            orElse: () => null);
        setState(() {
          systemSettings = false;
        });
        if (setting395 != null) {
          // Extract and return the description if setting 28 exists
          trackingPrefix = setting395['description'];
          print("trackingPrefix: $trackingPrefix");

          return trackingPrefix;
        } else {
          throw Exception('System setting with ID 40 not found');
        }
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to fetch system settings');
      }
    } catch (e) {
      // Catch any exception that might occur during the process
      print('Error fetching system settings: $e');
      return null;
    }
  }

  Future<String?> fetchSystemSettingsDescription397() async {
    const String apiUrl = 'https://deliverbygfl.com/api/get_all_system_data';
    setState(() {
      systemSettings = true;
    });
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        final Map<String, dynamic> data = json.decode(response.body);

        // Find the setting with system_settings_id equal to 26

        final setting397 = data['data'].firstWhere(
            (setting) => setting['system_settings_id'] == 397,
            orElse: () => null);
        setState(() {
          systemSettings = false;
        });
        if (setting397 != null) {
          // Extract and return the description if setting 28 exists
          mapRefreshTime = setting397['description'];
          print("mapRefreshTime: $mapRefreshTime");

          return mapRefreshTime;
        } else {
          throw Exception('System setting with ID 40 not found');
        }
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception.
        throw Exception('Failed to fetch system settings');
      }
    } catch (e) {
      // Catch any exception that might occur during the process
      print('Error fetching system settings: $e');
      return null;
    }
  }

  String? fleetId;
  var data0;
  getProfileData() async {
    var headersList = {
      'Accept': '*/*',
      'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
      'Content-Type': 'application/json'
    };
    var url = Uri.parse('https://deliverbygfl.com/api/get_profile_fleet');

    var body = {"users_fleet_id": "$fleetId"};

    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();
    data0 = jsonDecode(resBody);
    // Destination
    print("data0['latitude'] ${data0['latitude']}");
    print("data0['longitude'] ${data0['longitude']}");
    if (res.statusCode == 200) {
      data0 = jsonDecode(resBody);
      print(resBody);
      print("data is getting");
      print("data0['latitude'] ${data0['data']['latitude']}");
      print("data0['longitude'] ${data0['data']['longitude']}");
      updatedLat = double.parse(data0['data']['latitude']);
      updatedLng = double.parse(data0['data']['longitude']);
      riderPosition =
          LatLng(updatedLat!, updatedLng!); // Initial rider position
      destinationPosition = LatLng(riderDestinLat!, riderDestinLng!);
    } else {
      print(res.reasonPhrase);
    }
  }

  void updateRiderPosition() {
    setState(() {
      // Update rider position when new lat/lng are received
      riderPosition = LatLng(updatedLat!, updatedLng!);
      polylineCoordinates.add(riderPosition!); // Add to polyline
    });

    // Move the camera to the updated position
    mapController?.animateCamera(
      CameraUpdate.newLatLng(riderPosition!),
    );
  }

  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();

  updateBookingStatus() async {
    try {
      String apiUrl = "$baseUrl/get_updated_status_booking";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("currentBookingId: ${widget.currentBookingId}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "bookings_id": widget.currentBookingId,
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        updateBookingStatusModel =
            updateBookingStatusModelFromJson(responseString);
        fleetId = updateBookingStatusModel.data!.bookingsFleet![0].usersFleetId
            .toString();
        riderDestinLat = double.parse(updateBookingStatusModel
            .data!.bookingsFleet![0].bookingsDestinations!.destinLatitude
            .toString());

        riderDestinLng = double.parse(updateBookingStatusModel
            .data!.bookingsFleet![0].bookingsDestinations!.destinLongitude
            .toString());

        print(
            "${updateBookingStatusModel.data!.bookingsFleet![0].usersFleetId}");
        debugPrint(
            'updateBookingStatusModel status: ${updateBookingStatusModel.status}');
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        await getProfileData();
        // Access the passcode
        updateRiderPosition();
        getDirections();
        passcode0 = jsonResponse['data']['bookings_fleet'][0]
                ['bookings_destinations']['passcode'] ??
            "";
        debugPrint("Passcode0: $passcode0");
        phoneNumber0 = jsonResponse['data']['bookings_fleet'][0]
                ['bookings_destinations']['receiver_phone'] ??
            "";
        debugPrint("phoneNumber0: $phoneNumber0");
        charges0 = jsonResponse['data']['bookings_fleet'][0]
                ['bookings_destinations']['destin_total_charges'] ??
            "";
        debugPrint("charges0: $charges0");
        riderName0 = jsonResponse['data']['bookings_fleet'][0]['users_fleet']
                ['first_name'] ??
            "";
        debugPrint("riderName0: $riderName0");

        if (jsonResponse['data']['bookings_fleet'].length > 1) {
          passcode1 = jsonResponse['data']['bookings_fleet'][1]
                  ['bookings_destinations']['passcode'] ??
              "";
          debugPrint("Passcode1: $passcode1");
          phoneNumber1 = jsonResponse['data']['bookings_fleet'][1]
                  ['bookings_destinations']['receiver_phone'] ??
              "";
          debugPrint("phoneNumber1: $phoneNumber1");
          charges1 = jsonResponse['data']['bookings_fleet'][1]
                  ['bookings_destinations']['destin_total_charges'] ??
              "";
          debugPrint("charges1: $charges1");
          riderName1 = jsonResponse['data']['bookings_fleet'][1]['users_fleet']
                  ['first_name'] ??
              "";
          debugPrint("riderName1: $riderName1");
        }
        if (jsonResponse['data']['bookings_fleet'].length > 2) {
          passcode2 = jsonResponse['data']['bookings_fleet'][2]
                  ['bookings_destinations']['passcode'] ??
              "";
          debugPrint("Passcode2: $passcode2");
          phoneNumber2 = jsonResponse['data']['bookings_fleet'][2]
                  ['bookings_destinations']['receiver_phone'] ??
              "";
          debugPrint("phoneNumber2: $phoneNumber2");
          charges2 = jsonResponse['data']['bookings_fleet'][2]
                  ['bookings_destinations']['destin_total_charges'] ??
              "";
          debugPrint("charges2: $charges2");
          riderName2 = jsonResponse['data']['bookings_fleet'][2]['users_fleet']
                  ['first_name'] ??
              "";
          debugPrint("riderName2: $riderName2");
        }
        if (jsonResponse['data']['bookings_fleet'].length > 3) {
          passcode3 = jsonResponse['data']['bookings_fleet'][3]
                  ['bookings_destinations']['passcode'] ??
              "";
          debugPrint("Passcode3: $passcode3");
          phoneNumber3 = jsonResponse['data']['bookings_fleet'][3]
                  ['bookings_destinations']['receiver_phone'] ??
              "";
          debugPrint("phoneNumber3: $phoneNumber3");
          charges3 = jsonResponse['data']['bookings_fleet'][3]
                  ['bookings_destinations']['destin_total_charges'] ??
              "";
          debugPrint("charges3: $charges3");
          riderName3 = jsonResponse['data']['bookings_fleet'][3]['users_fleet']
                  ['first_name'] ??
              "";
          debugPrint("riderName3: $riderName3");
        }
        if (jsonResponse['data']['bookings_fleet'].length > 4) {
          passcode4 = jsonResponse['data']['bookings_fleet'][4]
                  ['bookings_destinations']['passcode'] ??
              "";
          debugPrint("Passcode4: $passcode4");
          phoneNumber4 = jsonResponse['data']['bookings_fleet'][4]
                  ['bookings_destinations']['receiver_phone'] ??
              "";
          debugPrint("phoneNumber4: $phoneNumber4");
          charges4 = jsonResponse['data']['bookings_fleet'][4]
                  ['bookings_destinations']['destin_total_charges'] ??
              "";
          debugPrint("charges4: $charges4");
          riderName4 = jsonResponse['data']['bookings_fleet'][4]['users_fleet']
                  ['first_name'] ??
              "";
          debugPrint("riderName4: $riderName4");
        }
        if (updateBookingStatusModel.data?.status == "Completed") {
          timer?.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AmountToPayScreen(
                riderData: widget.riderData!,
                singleData: widget.singleData,
                multipleData: widget.multipleData,
                currentBookingId: widget.currentBookingId,
                bookingDestinationId: widget.bookingDestinationId,
              ),
            ),
          );
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  getLocationSingle() {
    if (widget.singleData!.isNotEmpty) {
      latDest = "${widget.singleData!['destin_latitude']}";
      lngDest = "${widget.singleData!['destin_longitude']}";
      destLat = double.parse(latDest!);
      destLng = double.parse(lngDest!);
      debugPrint("destLat: $destLat");
      debugPrint("destLng: $destLng");
      latRider =
          "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.latitude}";
      lngRider =
          "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.longitude}";
      riderLat = double.parse(latRider!);
      riderLng = double.parse(lngRider!);
      debugPrint("riderLat: $riderLat");
      debugPrint("riderLng: $riderLng");
    } else {
      debugPrint("No LatLng Data");
    }
  }

  getLocationMultiple() {
    if (widget.multipleData?.isNotEmpty ?? false) {
      latDest = "${widget.multipleData!['destin_latitude0']}";
      lngDest = "${widget.multipleData!['destin_longitude0']}";
      destLat = double.parse(latDest!);
      destLng = double.parse(lngDest!);
      debugPrint("destLat: $destLat");
      debugPrint("destLng: $destLng");
      latRider =
          "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.latitude}";
      lngRider =
          "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.longitude}";
      riderLat = double.parse(latRider!);
      riderLng = double.parse(lngRider!);
      debugPrint("riderLat: $riderLat");
      debugPrint("riderLng: $riderLng");
    } else {
      debugPrint("No LatLng Data");
    }
  }

  Future<void> loadCustomMarker() async {
    final ByteData data = await rootBundle.load('assets/images/rider-marker-icon.png');
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 200,
      targetHeight: 200,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    final ByteData? resizedBytes = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    if (resizedBytes != null) {
      customMarkerIcon = BitmapDescriptor.fromBytes(resizedBytes.buffer.asUint8List());
      setState(() {});
    }
  }

  Future<void> loadCustomDestMarker() async {
    // Load the image from assets
    final ByteData data = await rootBundle.load('assets/images/custom-dest-icon.png');
    final Uint8List imageBytes = data.buffer.asUint8List();

    // Decode and resize the image
    final ui.Codec codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: 50, // Desired width
      targetHeight: 50, // Desired height
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();

    // Convert resized image to byte data
    final ByteData? resizedBytes = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    if (resizedBytes != null) {
      customDestMarkerIcon = BitmapDescriptor.fromBytes(resizedBytes.buffer.asUint8List());
      setState(() {});
    }
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    if (riderLat != null &&
        riderLng != null &&
        destLat != null &&
        destLng != null) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "$mapsKey",
        PointLatLng(riderLat!, riderLng!),
        PointLatLng(destLat!, destLng!),
      );
      if (result.points.isNotEmpty) {
        debugPrint("polylineCoordinates: $polylineCoordinates");
        for (var point in result.points) {
          polylineCoordinates.add(
            LatLng(point.latitude, point.longitude),
          );
        }
        setState(() {});
      }
    } else {
      debugPrint("No Polyline Data");
    }
  }

  startTimer() {
    timer = Timer.periodic(Duration(seconds: int.parse(mapRefreshTime ?? "30")),
        (timer) {
      if (widget.currentBookingId != null &&
          widget.currentBookingId!.isNotEmpty) {
        updateBookingStatus();
      }
    });
  }

  Future<void> getDirections() async {
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${riderPosition!.latitude},${riderPosition!.longitude}&destination=${destinationPosition!.latitude},${destinationPosition!.longitude}&key=$mapsKey";

    var response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);

    if (data["status"] == "OK") {
      // Get polyline coordinates
      var points = data["routes"][0]["overview_polyline"]["points"];
      polylineCoordinates = decodePolyline(points);

      // Get estimated time and distance
      var legs = data["routes"][0]["legs"][0];
      setState(() {
        distanceRemaining = legs["distance"]["text"]; // Example: "1.2 km"
        estimatedTime = _parseDuration(legs["duration"]);
      });
    }
  }

  String _parseDuration(Map<String, dynamic> duration) {
    int value = duration["value"]; // Duration in seconds
    if (value < 60) {
      return "$value sec"; // Less than a minute
    } else if (value < 3600) {
      int minutes = value ~/ 60;
      return "$minutes min"; // Less than an hour
    } else {
      int hours = value ~/ 3600;
      int minutes = (value % 3600) ~/ 60;
      return "$hours hr ${minutes > 0 ? "$minutes min" : ""}";
    }
  }


  // Method to decode polyline to LatLng list
  List<LatLng> decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      LatLng point = LatLng(lat / 1E5, lng / 1E5);
      polyline.add(point);
    }
    return polyline;
  }

  @override
  initState() {
    super.initState();
    getAllSystemData();
    loadCustomMarker();
    updateBookingStatus();
    print("Single Data: ${widget.singleData}");
    print("Multiple Data: ${widget.multipleData}");
    if (widget.singleData?.isNotEmpty ?? false) {
      // getPolyPoints();
      getLocationSingle();
      loadCustomDestMarker();
    } else {
      getLocationMultiple();
      debugPrint("Multiple data so no polyline will be shown!");
      debugPrint("Multiple data so no custom marker will be shown!");
    }
    startTimer();
  }

  @override
  dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: transparentColor,
      body: isLoading
          ? Center(
              child: Container(
                width: 100,
                height: 100,
                color: transparentColor,
                child: lottie.Lottie.asset(
                  'assets/images/loading-icon.json',
                  fit: BoxFit.cover,
                ),
              ),
            )
          : widget.singleData != null
              ? Stack(
                  children: [
                    Container(
                      color: Colors.transparent,
                      width: size.width,
                      height: size.height,
                      child: Column(
                      children: [
                        SizedBox(
                      height: size.height * 0.6,
                          child: GoogleMap(
                            onMapCreated: (controller) {
                              mapController = controller;
                            },
                            mapType: MapType.normal,
                            myLocationEnabled: true, // Show user's location
                            zoomControlsEnabled: false,
                            initialCameraPosition: CameraPosition(
                              target: riderPosition ?? const LatLng(0.0, 0.0),
                              zoom: 18,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId("riderMarker"),
                                position: riderPosition ?? const LatLng(0.0, 0.0),
                                icon: customMarkerIcon ??
                                    BitmapDescriptor.defaultMarker,
                              ),
                              Marker(
                                markerId: const MarkerId('destMarker'),
                                position:
                                destinationPosition ?? const LatLng(0.0, 0.0),
                                icon: customDestMarkerIcon ??
                                    BitmapDescriptor.defaultMarker,
                              ),
                            },
                            polylines: {
                              Polyline(
                                polylineId: const PolylineId("polyline"),
                                points: polylineCoordinates,
                                color: Colors.orange,
                                width: 6,
                              ),
                            },
                          ),
                        ),
                      ],
                      )
                    ),
                    Positioned(
                      bottom: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        child: Container(
                          width: size.width,
                          height: size.height * 0.60,
                          decoration: BoxDecoration(
                            color: whiteColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.01),
                                  Center(
                                    child: Text(
                                      'Estimated Time: $estimatedTime Distance Left: $distanceRemaining',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/small-black-send-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.03),
                                      // widget.singleData!.isNotEmpty
                                      if (widget.singleData != null &&
                                          widget.singleData!.isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Destination Address",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: textHaveAccountColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter-Regular',
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.005),
                                            Tooltip(
                                              message:
                                                  "${widget.singleData!['destin_address']}",
                                              child: Container(
                                                color: transparentColor,
                                                width: size.width * 0.79,
                                                child: Text(
                                                  "${widget.singleData!['destin_address']}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: "$passcode0"));
                                                CustomToast.showToast(
                                                  fontSize: 12,
                                                  message:
                                                      "$passcode0 copied to clipboard",
                                                );
                                              },
                                              child: Tooltip(
                                                message: "$passcode0",
                                                child: Text(
                                                  "Passcode ${passcode0 ?? '--'}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: orangeColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      else if (widget.multipleData != null &&
                                          widget.multipleData!.isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Destination Addresses",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: textHaveAccountColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter-Regular',
                                              ),
                                            ),

                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              children: [
                                                Text(
                                                  "1.",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 2.5),
                                                  child: Tooltip(
                                                    message:
                                                        "${widget.multipleData!['destin_address0']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.75,
                                                      child: Text(
                                                        "${widget.multipleData!['destin_address0']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                fetchSystemSettingsDescription28();
                                                Clipboard.setData(ClipboardData(
                                                    text: "$passcode0"));
                                                CustomToast.showToast(
                                                  fontSize: 12,
                                                  message:
                                                      "$passcode0 copied to clipboard",
                                                );
                                              },
                                              child: Tooltip(
                                                message: "$passcode0",
                                                child: Text(
                                                  "Passcode ${passcode0 ?? '--'}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: orangeColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              children: [
                                                Text(
                                                  "2.",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.multipleData!['destin_address1']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.75,
                                                    child: Text(
                                                      "${widget.multipleData!['destin_address1']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: "$passcode1"));
                                                CustomToast.showToast(
                                                  fontSize: 12,
                                                  message:
                                                      "$passcode1 copied to clipboard",
                                                );
                                              },
                                              child: Tooltip(
                                                message: "$passcode1",
                                                child: Text(
                                                  "Passcode ${passcode1 ?? '--'}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: orangeColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Medium',
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),

                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              Row(
                                                children: [
                                                  Text(
                                                    "3.",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['destin_address2']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.75,
                                                      child: Text(
                                                        "${widget.multipleData!['destin_address2']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: "$passcode2"));
                                                  CustomToast.showToast(
                                                    fontSize: 12,
                                                    message:
                                                        "$passcode2 copied to clipboard",
                                                  );
                                                },
                                                child: Tooltip(
                                                  message: "$passcode2",
                                                  child: Text(
                                                    "Passcode ${passcode2 ?? '--'}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: orangeColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            // SizedBox(
                                            //     height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              Row(
                                                children: [
                                                  Text(
                                                    "4.",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['destin_address3']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.75,
                                                      child: Text(
                                                        "${widget.multipleData!['destin_address3']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: "$passcode3"));
                                                  CustomToast.showToast(
                                                    fontSize: 12,
                                                    message:
                                                        "$passcode3 copied to clipboard",
                                                  );
                                                },
                                                child: Tooltip(
                                                  message: "$passcode3",
                                                  child: Text(
                                                    "Passcode ${passcode3 ?? '--'}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: orangeColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              Row(
                                                children: [
                                                  Text(
                                                    "5.",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['destin_address4']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.75,
                                                      child: Text(
                                                        "${widget.multipleData!['destin_address4']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text: "$passcode4"));
                                                  CustomToast.showToast(
                                                    fontSize: 12,
                                                    message:
                                                        "$passcode4 copied to clipboard",
                                                  );
                                                },
                                                child: Tooltip(
                                                  message: "$passcode4",
                                                  child: Text(
                                                    "Passcode ${passcode4 ?? '--'}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: orangeColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/orange-distance-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              "Tracking Number",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: textHaveAccountColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter-Regular',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: size.width * 0.04),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text:
                                                        "$trackingPrefix${updateBookingStatusModel.data!.bookingsId}"));
                                              },
                                              child: Text(
                                                "$trackingPrefix${updateBookingStatusModel.data!.bookingsId}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 14,
                                                  fontFamily: 'Inter-Regular',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/orange-distance-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              "Estimated Distance to Destination",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: textHaveAccountColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter-Regular',
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          widget.singleData!.isNotEmpty
                                              ? Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.25,
                                                  child: Text(
                                                    "$distanceRemaining",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    SizedBox(
                                                        height: size.height *
                                                            0.005),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "1.",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 2.5),
                                                          child: Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.25,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_distance0']} $distanceUnit",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "2.",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.25,
                                                          child: Text(
                                                            "${widget.multipleData!['destin_distance1']} $distanceUnit",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (widget.multipleData![
                                                                "destin_address2"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address2"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address2"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address2"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "3.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.25,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_distance2']} $distanceUnit",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (widget.multipleData![
                                                                "destin_address3"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address3"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address3"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address3"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "4.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.25,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_distance3']} $distanceUnit",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (widget.multipleData![
                                                                "destin_address4"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address4"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address4"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address4"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "5.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.25,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_distance4']} $distanceUnit",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/images/arrival-time-icon.svg',
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2),
                                            child: Text(
                                              "Estimated Time of Arrival",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: textHaveAccountColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter-Regular',
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          widget.singleData!.isNotEmpty
                                              ? Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.25,
                                                  child: Text(
                                                    "$estimatedTime",
                                                    // "${widget.singleData!['destin_time']}",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color: blackColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Inter-Medium',
                                                    ),
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    SizedBox(
                                                        height: size.height *
                                                            0.005),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "1.",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 2.5),
                                                          child: Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.4,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_time0']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "2.",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Inter-Medium',
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.02),
                                                        Container(
                                                          color:
                                                              transparentColor,
                                                          width:
                                                              size.width * 0.4,
                                                          child: Text(
                                                            "${widget.multipleData!['destin_time1']}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (widget.multipleData![
                                                                "destin_address2"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address2"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address2"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address2"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "3.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.4,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_time2']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (widget.multipleData![
                                                                "destin_address3"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address3"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address3"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address3"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "4.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.4,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_time3']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    if (widget.multipleData![
                                                                "destin_address4"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address4"]
                                                            .isNotEmpty)
                                                      SizedBox(
                                                          height: size.height *
                                                              0.01),
                                                    if (widget.multipleData![
                                                                "destin_address4"] !=
                                                            null &&
                                                        widget
                                                            .multipleData![
                                                                "destin_address4"]
                                                            .isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "5.",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  'Inter-Medium',
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  size.width *
                                                                      0.02),
                                                          Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.4,
                                                            child: Text(
                                                              "${widget.multipleData!['destin_time4']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Inter-Medium',
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                      SizedBox(width: size.width * 0.08),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.start,
                                      //   crossAxisAlignment:
                                      //       CrossAxisAlignment.start,
                                      //   children: [
                                      //     SvgPicture.asset(
                                      //       'assets/images/passcode-icon.svg',
                                      //     ),
                                      //     SizedBox(width: size.width * 0.02),
                                      //     Column(
                                      //       crossAxisAlignment:
                                      //           CrossAxisAlignment.center,
                                      //       children: [
                                      //         Padding(
                                      //           padding: const EdgeInsets.only(
                                      //               top: 2),
                                      //           child: Text(
                                      //             "Passcode",
                                      //             textAlign: TextAlign.left,
                                      //             style: TextStyle(
                                      //               color: textHaveAccountColor,
                                      //               fontSize: 14,
                                      //               fontFamily: 'Inter-Regular',
                                      //             ),
                                      //           ),
                                      //         ),
                                      //         SizedBox(
                                      //             height: size.height * 0.005),
                                      //         Text(
                                      //           "${widget.passCode}",
                                      //           textAlign: TextAlign.left,
                                      //           style: TextStyle(
                                      //             color: blackColor,
                                      //             fontSize: 14,
                                      //             fontFamily: 'Inter-Medium',
                                      //           ),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) =>
                                          //         const AmountToPayEditScreen(),
                                          //   ),
                                          // );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            color: transparentColor,
                                            width: 55,
                                            height: 55,
                                            child: widget.riderData?.data?.bookingsFleet?[0].usersFleet?.profilePic != null &&
                                                widget.riderData!.data!.bookingsFleet![0].usersFleet!.profilePic!.isNotEmpty
                                                ? FadeInImage(
                                              placeholder: const AssetImage("assets/images/user-profile.png"),
                                              image: NetworkImage(
                                                '$imageUrl${widget.riderData!.data!.bookingsFleet![0].usersFleet!.profilePic}',
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                                : Image.asset(
                                              "assets/images/user-profile.png", // Asset fallback image
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.03),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                color: transparentColor,
                                                width: size.width * 0.45,
                                                child: AutoSizeText(
                                                  "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.firstName} ${widget.riderData!.data!.bookingsFleet![0].usersFleet!.lastName}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: drawerTextColor,
                                                    fontSize: 16,
                                                    fontFamily: 'Syne-SemiBold',
                                                  ),
                                                  minFontSize: 16,
                                                  maxFontSize: 16,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      timer?.cancel();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatScreen(
                                                            callbackFunction:
                                                                startTimer,
                                                            riderId: widget
                                                                .riderData!
                                                                .data!
                                                                .bookingsFleet![
                                                                    0]
                                                                .usersFleet!
                                                                .usersFleetId
                                                                .toString(),
                                                            name:
                                                                "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.firstName} ${widget.riderData!.data!.bookingsFleet![0].usersFleet!.lastName}",
                                                            address: widget
                                                                .riderData!
                                                                .data!
                                                                .bookingsFleet![
                                                                    0]
                                                                .usersFleet!
                                                                .address,
                                                            phone: widget
                                                                .riderData!
                                                                .data!
                                                                .bookingsFleet![
                                                                    0]
                                                                .usersFleet!
                                                                .phone,
                                                            image: widget
                                                                .riderData!
                                                                .data!
                                                                .bookingsFleet![
                                                                    0]
                                                                .usersFleet!
                                                                .profilePic,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: SvgPicture.asset(
                                                      'assets/images/message-icon.svg',
                                                      height: 20,
                                                      width: 20,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  GestureDetector(
                                                    onTap: () {
                                                      makePhoneCall(
                                                          "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.phone}");
                                                    },
                                                    child: SvgPicture.asset(
                                                      'assets/images/call-icon.svg',
                                                      height: 20,
                                                      width: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              // Stack(
                                              //   children: [
                                              //     SvgPicture.asset(
                                              //       'assets/images/star-with-container-icon.svg',
                                              //     ),
                                              //     Padding(
                                              //       padding:
                                              //           const EdgeInsets.only(
                                              //               top: 1.5, left: 24),
                                              //       child: Text(
                                              //         "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.bookingsRatings}",
                                              //         textAlign:
                                              //             TextAlign.center,
                                              //         style: TextStyle(
                                              //           color: blackColor,
                                              //           fontSize: 14,
                                              //           fontFamily:
                                              //               'Inter-Regular',
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.005),
                                          // Container(
                                          //   color: transparentColor,
                                          //   width: size.width * 0.62,
                                          //   child: AutoSizeText(
                                          //     "${widget.riderData!.usersFleetVehicles!.color} ${widget.riderData!.usersFleetVehicles!.model} (${widget.riderData!.usersFleetVehicles!.vehicleRegistrationNo})",
                                          //     textAlign: TextAlign.left,
                                          //     style: TextStyle(
                                          //       color: textHaveAccountColor,
                                          //       fontSize: 14,
                                          //       fontFamily: 'Syne-Regular',
                                          //     ),
                                          //     maxFontSize: 14,
                                          //     minFontSize: 12,
                                          //     maxLines: 1,
                                          //     overflow: TextOverflow.ellipsis,
                                          //   ),
                                          // ),
                                          SizedBox(height: size.height * 0.002),
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-grey-location-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.01),
                                                  Tooltip(
                                                    message:
                                                        "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.address}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: widget.singleData!
                                                              .isNotEmpty
                                                          ? size.width * 0.3
                                                          : size.width * 0.4,
                                                      child: AutoSizeText(
                                                        widget.riderData!.data!.bookingsFleet![0].usersFleet!.address != null 
                                                            ? "${widget.riderData!.data!.bookingsFleet![0].usersFleet!.address}"
                                                            : "no location",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color:
                                                              textHaveAccountColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Syne-Regular',
                                                        ),
                                                        maxFontSize: 14,
                                                        minFontSize: 12,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  width: size.width * 0.01),
                                              widget.singleData!.isNotEmpty
                                                  ? Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          'assets/images/small-grey-arrival-time-icon.svg',
                                                        ),
                                                        SizedBox(
                                                            width: size.width *
                                                                0.01),
                                                        Tooltip(
                                                          message:
                                                              "ETA ${widget.singleData!['destin_time']}",
                                                          child: Container(
                                                            color:
                                                                transparentColor,
                                                            width: size.width *
                                                                0.23,
                                                            child: Text(
                                                              "ETA ${widget.singleData!['destin_time']}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    textHaveAccountColor,
                                                                fontSize: 14,
                                                                fontFamily:
                                                                    'Syne-Regular',
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox(
                                                      width: size.width * 0.16),
                                              SizedBox(
                                                  width: size.width * 0.02),
                                              GestureDetector(
                                                onTap: () {
                                                  timer?.cancel();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReportScreen(
                                                        callbackFunction:
                                                            startTimer,
                                                        riderData:
                                                            widget.riderData,
                                                        currentBookingId: widget
                                                            .currentBookingId,
                                                        bookingDestinationId: widget
                                                            .bookingDestinationId,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: SvgPicture.asset(
                                                  'assets/images/report-icon.svg',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  widget.singleData!.isNotEmpty
                                      ? Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Pickup",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.singleData!['pickup_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.6,
                                                    child: Text(
                                                      "${widget.singleData!['pickup_address']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Destination",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.singleData!['destin_address']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.53,
                                                    child: Text(
                                                      "${widget.singleData!['destin_address']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Pickup 1",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.multipleData!['pickup_address0']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.61,
                                                    child: Text(
                                                      "${widget.multipleData!['pickup_address0']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Destination 1",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.multipleData!['destin_address0']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.53,
                                                    child: Text(
                                                      "${widget.multipleData!['destin_address0']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Pickup 2",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.multipleData!['pickup_address1']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.61,
                                                    child: Text(
                                                      "${widget.multipleData!['pickup_address1']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/small-white-send-icon.svg',
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.03),
                                                Text(
                                                  "Destination 2",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: textHaveAccountColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Syne-Regular',
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.02),
                                                Tooltip(
                                                  message:
                                                      "${widget.multipleData!['destin_address1']}",
                                                  child: Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.53,
                                                    child: Text(
                                                      "${widget.multipleData!['destin_address1']}",
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        color: blackColor,
                                                        fontSize: 14,
                                                        fontFamily:
                                                            'Inter-Medium',
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Pickup 3",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color:
                                                          textHaveAccountColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Syne-Regular',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['pickup_address2']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.61,
                                                      child: Text(
                                                        "${widget.multipleData!['pickup_address2']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address2"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address2"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Destination 3",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color:
                                                          textHaveAccountColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Syne-Regular',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['destin_address2']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.53,
                                                      child: Text(
                                                        "${widget.multipleData!['destin_address2']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Pickup 4",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color:
                                                          textHaveAccountColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Syne-Regular',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['pickup_address3']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.61,
                                                      child: Text(
                                                        "${widget.multipleData!['pickup_address3']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address3"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address3"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Destination 4",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color:
                                                          textHaveAccountColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Syne-Regular',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['destin_address3']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.53,
                                                      child: Text(
                                                        "${widget.multipleData!['destin_address3']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Pickup 5",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color:
                                                          textHaveAccountColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Syne-Regular',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['pickup_address4']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.61,
                                                      child: Text(
                                                        "${widget.multipleData!['pickup_address4']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              SizedBox(
                                                  height: size.height * 0.01),
                                            if (widget.multipleData![
                                                        "destin_address4"] !=
                                                    null &&
                                                widget
                                                    .multipleData![
                                                        "destin_address4"]
                                                    .isNotEmpty)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/small-white-send-icon.svg',
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.03),
                                                  Text(
                                                    "Destination 5",
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      color:
                                                          textHaveAccountColor,
                                                      fontSize: 14,
                                                      fontFamily:
                                                          'Syne-Regular',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  Tooltip(
                                                    message:
                                                        "${widget.multipleData!['destin_address4']}",
                                                    child: Container(
                                                      color: transparentColor,
                                                      width: size.width * 0.53,
                                                      child: Text(
                                                        "${widget.multipleData!['destin_address4']}",
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          color: blackColor,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Inter-Medium',
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                  widget.singleData!.isNotEmpty
                                      ? const SizedBox()
                                      : SizedBox(height: size.height * 0.12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 180),
                  child: Column(
                    children: [
                      lottie.Lottie.asset('assets/images/no-data-icon.json'),
                      SizedBox(height: size.height * 0.04),
                      Text(
                        "No Ride In Progress",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textHaveAccountColor,
                          fontSize: 24,
                          fontFamily: 'Syne-SemiBold',
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}
