// // // ignore_for_file: avoid_print

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:deliver_client/utils/colors.dart';
// import 'package:deliver_client/utils/baseurl.dart';
// import 'package:deliver_client/models/get_vehicles_model.dart';

// bool isSelectedTruck = true;
// bool isSelectedFreight = false;
// bool isSelectedCourier = false;
// List<String> vehiclesType1 = [];
// List<String> vehiclesType2 = [];

// Widget homeBoxes({
//   titleTruck,
//   imageTruck,
//   titleFreight,
//   imageFreight,
//   titleCourier,
//   imageCourier,
//   imageHelp,
//   String? courierId,
//   String? otherId,
//   Function(List<String>? value)? callback,
//   context,
// }) {
//   return StatefulBuilder(
//     builder: (context, setState) => Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           GestureDetector(
//             onTap: () async {
//               GetVehiclesByServiceTypeModel getVehiclesByServiceTypeModel =
//                   GetVehiclesByServiceTypeModel();
//               try {
//                 String apiUrl = "$baseUrl/get_vehicles_by_service_type";
//                 print("apiUrl: $apiUrl");
//                 print("serviceTypesId: $otherId");
//                 final response = await http.post(
//                   Uri.parse(apiUrl),
//                   headers: {
//                     'Accept': 'application/json',
//                   },
//                   body: {
//                     "service_types_id": otherId,
//                   },
//                 );
//                 final responseString = response.body;
//                 print("response: $responseString");
//                 print("statusCode: ${response.statusCode}");
//                 if (response.statusCode == 200) {
//                   getVehiclesByServiceTypeModel =
//                       getVehiclesByServiceTypeModelFromJson(responseString);

//                   print(
//                       'getVehiclesByServiceTypeModel status: ${getVehiclesByServiceTypeModel.status}');
//                   print(
//                       'getVehiclesByServiceTypeModel length: ${getVehiclesByServiceTypeModel.data!.length}');
//                   vehiclesType1.clear();
//                   for (int i = 0;
//                       i < getVehiclesByServiceTypeModel.data!.length;
//                       i++) {
//                     vehiclesType1
//                         .add("${getVehiclesByServiceTypeModel.data?[i].name}");
//                     callback!(vehiclesType1);
//                   }
//                   setState(() {});
//                 }
//               } catch (e) {
//                 print('Something went wrong = ${e.toString()}');
//               }
//               setState(() {
//                 isSelectedTruck = true;
//                 isSelectedFreight = false;
//                 isSelectedCourier = false;
//               });
//             },
//             child: Stack(
//               children: [
//                 Container(
//                   color: transparentColor,
//                   width: MediaQuery.of(context).size.width * 0.28,
//                   height: MediaQuery.of(context).size.height * 0.1,
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.28,
//                     height: MediaQuery.of(context).size.height * 0.08,
//                     decoration: BoxDecoration(
//                       color: isSelectedTruck == true
//                           ? orangeColor
//                           : const Color(0xFFEBEBEB),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 20,
//                   left: 0,
//                   right: 0,
//                   child: Text(
//                     titleTruck,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: isSelectedTruck == true
//                           ? whiteColor
//                           : drawerTextColor,
//                       fontSize: 14,
//                       fontFamily: 'Syne-Bold',
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: SvgPicture.asset(imageTruck),
//                 ),
//                 Positioned(
//                   bottom: 30,
//                   right: 8,
//                   child: SvgPicture.asset(imageHelp),
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () async {
//               GetVehiclesByServiceTypeModel getVehiclesByServiceTypeModel =
//                   GetVehiclesByServiceTypeModel();
//               try {
//                 String apiUrl = "$baseUrl/get_vehicles_by_service_type";
//                 print("apiUrl: $apiUrl");
//                 print("serviceTypesId: $otherId");
//                 final response = await http.post(
//                   Uri.parse(apiUrl),
//                   headers: {
//                     'Accept': 'application/json',
//                   },
//                   body: {
//                     "service_types_id": otherId,
//                   },
//                 );
//                 final responseString = response.body;
//                 print("response: $responseString");
//                 print("statusCode: ${response.statusCode}");
//                 if (response.statusCode == 200) {
//                   getVehiclesByServiceTypeModel =
//                       getVehiclesByServiceTypeModelFromJson(responseString);

//                   print(
//                       'getVehiclesByServiceTypeModel status: ${getVehiclesByServiceTypeModel.status}');
//                   print(
//                       'getVehiclesByServiceTypeModel length: ${getVehiclesByServiceTypeModel.data!.length}');
//                   vehiclesType1.clear();
//                   for (int i = 0;
//                       i < getVehiclesByServiceTypeModel.data!.length;
//                       i++) {
//                     vehiclesType1
//                         .add("${getVehiclesByServiceTypeModel.data?[i].name}");
//                   }
//                   setState(() {});
//                 }
//               } catch (e) {
//                 print('Something went wrong = ${e.toString()}');
//               }
//               setState(() {
//                 isSelectedTruck = false;
//                 isSelectedFreight = true;
//                 isSelectedCourier = false;
//               });
//             },
//             child: Stack(
//               children: [
//                 Container(
//                   color: transparentColor,
//                   width: MediaQuery.of(context).size.width * 0.28,
//                   height: MediaQuery.of(context).size.height * 0.1,
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.28,
//                     height: MediaQuery.of(context).size.height * 0.08,
//                     decoration: BoxDecoration(
//                       color: isSelectedFreight == true
//                           ? orangeColor
//                           : const Color(0xFFEBEBEB),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 20,
//                   left: 0,
//                   right: 0,
//                   child: Text(
//                     titleFreight,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: isSelectedFreight == true
//                           ? whiteColor
//                           : drawerTextColor,
//                       fontSize: 14,
//                       fontFamily: 'Syne-Bold',
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: SvgPicture.asset(imageFreight),
//                 ),
//                 Positioned(
//                   bottom: 30,
//                   right: 8,
//                   child: SvgPicture.asset(imageHelp),
//                 ),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () async {
//               GetVehiclesByServiceTypeModel getVehiclesByServiceTypeModel =
//                   GetVehiclesByServiceTypeModel();
//               try {
//                 String apiUrl = "$baseUrl/get_vehicles_by_service_type";
//                 print("apiUrl: $apiUrl");
//                 print("serviceTypesId: $courierId");
//                 final response = await http.post(
//                   Uri.parse(apiUrl),
//                   headers: {
//                     'Accept': 'application/json',
//                   },
//                   body: {
//                     "service_types_id": courierId,
//                   },
//                 );
//                 final responseString = response.body;
//                 print("response: $responseString");
//                 print("statusCode: ${response.statusCode}");
//                 if (response.statusCode == 200) {
//                   getVehiclesByServiceTypeModel =
//                       getVehiclesByServiceTypeModelFromJson(responseString);

//                   print(
//                       'getVehiclesByServiceTypeModel status: ${getVehiclesByServiceTypeModel.status}');
//                   print(
//                       'getVehiclesByServiceTypeModel length: ${getVehiclesByServiceTypeModel.data!.length}');
//                   vehiclesType2.clear();
//                   for (int i = 0;
//                       i < getVehiclesByServiceTypeModel.data!.length;
//                       i++) {
//                     vehiclesType2
//                         .add("${getVehiclesByServiceTypeModel.data?[i].name}");
//                     print("vehiclesType2: $vehiclesType2");
//                     callback!(vehiclesType2);
//                   }
//                   setState(() {});
//                 }
//               } catch (e) {
//                 print('Something went wrong = ${e.toString()}');
//               }
//               setState(() {
//                 isSelectedTruck = false;
//                 isSelectedFreight = false;
//                 isSelectedCourier = true;
//               });
//             },
//             child: Stack(
//               children: [
//                 Container(
//                   color: transparentColor,
//                   width: MediaQuery.of(context).size.width * 0.28,
//                   height: MediaQuery.of(context).size.height * 0.1,
//                 ),
//                 Positioned(
//                   bottom: 0,
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.28,
//                     height: MediaQuery.of(context).size.height * 0.08,
//                     decoration: BoxDecoration(
//                       color: isSelectedCourier == true
//                           ? orangeColor
//                           : const Color(0xFFEBEBEB),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 20,
//                   left: 0,
//                   right: 0,
//                   child: Text(
//                     titleCourier,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: isSelectedCourier == true
//                           ? whiteColor
//                           : drawerTextColor,
//                       fontSize: 14,
//                       fontFamily: 'Syne-Bold',
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   top: 0,
//                   left: 0,
//                   right: 0,
//                   child: SvgPicture.asset(imageCourier),
//                 ),
//                 Positioned(
//                   bottom: 30,
//                   right: 8,
//                   child: SvgPicture.asset(imageHelp),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
