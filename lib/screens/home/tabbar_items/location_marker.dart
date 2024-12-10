// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/widgets/buttons.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class FullScreenMap extends StatefulWidget {
//   const FullScreenMap({super.key});
//
//   @override
//   _FullScreenMapState createState() => _FullScreenMapState();
// }
//
// class _FullScreenMapState extends State<FullScreenMap> {
//   late GoogleMapController _mapController;
//   LatLng _currentPosition = const LatLng(30.1863557, 71.4885808);
//   String _address = "Fetching address...";
//   Marker? _marker;
//
//   @override
//   void initState() {
//     super.initState();
//     _getCurrentLocation();
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         permission = await Geolocator.requestPermission();
//       }
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.best,
//       );
//       LatLng userLocation = LatLng(position.latitude, position.longitude);
//       _updateMarkerPosition(userLocation);
//       await _getAddressFromLatLng(userLocation);
//
//       setState(() {
//         _currentPosition = userLocation;
//       });
//
//       _mapController.animateCamera(
//         CameraUpdate.newLatLngZoom(userLocation, 15),
//       );
//     } catch (e) {
//       debugPrint("Error getting location: $e");
//     }
//   }
//
//   Future<void> _getAddressFromLatLng(LatLng position) async {
//     try {
//       List<Placemark> placemarks =
//       await placemarkFromCoordinates(position.latitude, position.longitude);
//
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks[0];
//         // setState(() {
//         //   _address = "${place.name} ${place.subLocality} ${place.locality} ${place.administrativeArea} ${place.country}";
//         //   debugPrint("_address :: $_address");
//         // });
//       // }
//         String fullAddress = [
//           // if (place.name != null && place.name!.isNotEmpty) place.name,
//           if (place.street != null && place.street!.isNotEmpty) place.street,
//           if (place.subLocality != null && place.subLocality!.isNotEmpty)
//             place.subLocality,
//           if (place.locality != null && place.locality!.isNotEmpty)
//             place.locality,
//           // if (place.postalCode != null && place.postalCode!.isNotEmpty)
//           //   place.postalCode,
//           if (place.administrativeArea != null &&
//               place.administrativeArea!.isNotEmpty)
//             place.administrativeArea,
//           if (place.country != null && place.country!.isNotEmpty) place.country,
//         ].join(', ');
//
//         setState(() {
//           _address = fullAddress;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _address = "Unable to fetch address";
//       });
//     }
//   }
//
//   void _updateMarkerPosition(LatLng newPosition) {
//     setState(() {
//       _marker = Marker(
//         markerId: const MarkerId('currentLocation'),
//         position: newPosition,
//         icon: BitmapDescriptor.defaultMarker, // Default Google Maps marker
//       );
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: (controller) => _mapController = controller,
//             initialCameraPosition: CameraPosition(
//               target: _currentPosition,
//               zoom: 12.5,
//             ),
//             mapType: MapType.normal,
//             markers: _marker != null ? {_marker!} : {},
//             compassEnabled: true,
//             scrollGesturesEnabled: true,
//             buildingsEnabled: true,
//             onCameraMove: (position) {
//               setState(() {
//                 _currentPosition = position.target;
//               });
//               _updateMarkerPosition(position.target);
//             },
//             onCameraIdle: () {
//               _getAddressFromLatLng(_currentPosition);
//             },
//             myLocationButtonEnabled: true,
//             myLocationEnabled: true,
//           ),
//
//           Positioned(
//             top: 40,
//             left: 10,
//             // right: 20,
//             child:  GestureDetector(
//               onTap: () {
//                 Navigator.pop(context);
//               },
//               child: SvgPicture.asset(
//                 'assets/images/back-icon.svg',
//                 // width: 22,
//                 // height: 22,
//                 fit: BoxFit.scaleDown,
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: 20,
//             left: 10,
//             right: 10,
//             child: Container(
//               padding: const EdgeInsets.all(12.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8.0),
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black26,
//                     blurRadius: 5.0,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 5),
//                     child: Text(
//                       "Address:",
//                       textAlign: TextAlign.left,
//                       style: TextStyle(
//                         color: drawerTextColor,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Inter-Regular',
//                       ),
//                     ),
//                   ),
//                   Text(
//                     _address,
//                     maxLines: 3,
//                     style: TextStyle(
//                       color: blackColor,
//                       fontSize: 16,
//                       fontFamily: 'Syne-Medium',
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10.0),
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context, _address);
//                       },
//                       child: buttonGradient("Confirm Address", context),
//                     ),
//                   ),
//                 ],
//               )
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }