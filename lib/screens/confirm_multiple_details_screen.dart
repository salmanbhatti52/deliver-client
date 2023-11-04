// ignore_for_file: avoid_print,, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:speech_balloon/speech_balloon.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/widgets/who_will_pay_bottomsheet.dart';

class ConfirmMultipleDetailsScreen extends StatefulWidget {
  final Map? multipleData;
  final List<Map<String, dynamic>>? dataForIndexes;
  const ConfirmMultipleDetailsScreen(
      {super.key, this.multipleData, this.dataForIndexes});

  @override
  State<ConfirmMultipleDetailsScreen> createState() =>
      _ConfirmMultipleDetailsScreenState();
}

class _ConfirmMultipleDetailsScreenState
    extends State<ConfirmMultipleDetailsScreen> {
  List<Map<String, dynamic>>? dataList;
  var dataForIndex0;
  var dataForIndex1;
  var dataForIndex2;
  var dataForIndex3;
  var dataForIndex4;

  @override
  initState() {
    super.initState();
    print("multipleData:  ${widget.multipleData}");
    dataList = widget.dataForIndexes;
    // print("dataList:  $dataList");
    // print("dataList Length:  ${dataList!.length}");
    // print(
    //     "Data for 0: ${widget.dataForIndexes![0]['pickupLatLng']['latitude']}");
    if (widget.dataForIndexes != null) {
      for (var i = 0; i < widget.dataForIndexes!.length; i++) {
        final dataForIndex = widget.dataForIndexes![i];
        final dataIndex = dataForIndex.keys.first; // Get the index
        final data = dataForIndex[dataIndex];

        // Check if data contains null values
        if (data.containsValue(null)) {
          print("Data for Index $dataIndex: Data contains null values");
        } else {
          print("Data for Index $dataIndex: $data");
        }
      }
    }
    //  if (dataList != null) {
    //   for (var i = 0; i < dataList!.length; i++) {
    //     final dataForIndex = dataList![i];
    //     final dataIndex = dataForIndex.keys.first; // Get the index
    //     print("Data for Index $dataIndex: ${dataForIndex[dataIndex]}");
    //   }
    // }
    dataForIndex0 = dataList![0];
    print("Data for Index 0: $dataForIndex0");
    // print("pickupController for Index 0: ${dataForIndex0['0']['pickupController']}");

    dataForIndex1 = dataList![1];
    print("Data for Index 1: $dataForIndex1");
    // print("pickupController for Index 1: ${dataForIndex1['1']['pickupController']}");
    //
    dataForIndex2 = dataList![2];
    print("Data for Index 2: $dataForIndex2");
    // print("pickupController for Index 2: ${dataForIndex2['2']['pickupController']}");
    //
    dataForIndex3 = dataList![3];
    print("Data for Index 3: $dataForIndex3");
    // print("pickupController for Index 3: ${dataForIndex3['3']['pickupController']}");
    //
    dataForIndex4 = dataList![4];
    print("Data for Index 4: $dataForIndex4");
    // print("pickupController for Index 4: ${dataForIndex4['4']['pickupController']}");
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
        body: Stack(
          children: [
            Image.asset(
              'assets/images/home-location-background.png',
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 40,
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
              top: 240,
              right: 120,
              child: Image.asset(
                'assets/images/bike-icon.png',
                width: 100,
                height: 100,
              ),
            ),
            Positioned(
              top: 101,
              right: 4,
              child: SvgPicture.asset('assets/images/bike-path-icon.svg'),
            ),
            Positioned(
              top: 225,
              right: 135,
              child: SpeechBalloon(
                nipLocation: NipLocation.bottom,
                nipHeight: 12,
                color: orangeColor,
                borderColor: borderColor,
                width: size.width * 0.3,
                height: size.height * 0.05,
                borderRadius: 10,
                offset: const Offset(10, 0),
                child: Center(
                  child: Text(
                    "4 hours 5 mins",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 12,
                      fontFamily: 'Syne-SemiBold',
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 85,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: size.width * 0.6,
                  height: size.height * 0.45,
                  color: whiteColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.02),
                          Container(
                            color: transparentColor,
                            width: size.width * 0.75,
                            height: size.height * 0.09,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 13,
                                  left: 0,
                                  child: Text(
                                    "Fare",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: orangeColor,
                                      fontSize: 37,
                                      fontFamily: 'Syne-Bold',
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 18,
                                  left: 0,
                                  right: 35,
                                  child: SvgPicture.asset(
                                    'assets/images/naira-icon.svg',
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  child: Text(
                                    '80.0',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 56,
                                      fontFamily: 'Inter-Bold',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Discount: ',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                              SizedBox(width: size.width * 0.01),
                              Text(
                                '₦ ',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: orangeColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                              Text(
                                '6.03',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.005),
                          Row(
                            children: [
                              Text(
                                'Total Price: ',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                              SizedBox(width: size.width * 0.01),
                              Text(
                                '₦ ',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: orangeColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                              Text(
                                '80.03',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: blackColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter-Medium',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.03),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                'assets/images/orange-location-big-icon.svg',
                              ),
                              SizedBox(width: size.width * 0.04),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pickup',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: textHaveAccountColor,
                                      fontSize: 14,
                                      fontFamily: 'Syne-Regular',
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.54,
                                    child: AutoSizeText(
                                      "Neon Café, 23/A Park Avenue",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 14,
                                        fontFamily: 'Inter-Medium',
                                      ),
                                      minFontSize: 14,
                                      maxFontSize: 14,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          Divider(
                            thickness: 1,
                            color: dividerColor,
                            indent: 30,
                            endIndent: 30,
                          ),
                          SizedBox(height: size.height * 0.01),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                  'assets/images/send-small-icon.svg'),
                              SizedBox(width: size.width * 0.04),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Dropoff  1',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.35),
                                      Text(
                                        '₦ ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      Text(
                                        '46.03',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.54,
                                    child: AutoSizeText(
                                      "Rex House, 769 Isadore",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 14,
                                        fontFamily: 'Inter-Medium',
                                      ),
                                      minFontSize: 14,
                                      maxFontSize: 14,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          Divider(
                            thickness: 1,
                            color: dividerColor,
                            indent: 30,
                            endIndent: 30,
                          ),
                          SizedBox(height: size.height * 0.01),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                  'assets/images/send-small-icon.svg'),
                              SizedBox(width: size.width * 0.04),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Dropoff  2',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.35),
                                      Text(
                                        '₦ ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      Text(
                                        '20.00',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.54,
                                    child: AutoSizeText(
                                      "Rex House, 769 Isadore",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 14,
                                        fontFamily: 'Inter-Medium',
                                      ),
                                      minFontSize: 14,
                                      maxFontSize: 14,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.01),
                          Divider(
                            thickness: 1,
                            color: dividerColor,
                            indent: 30,
                            endIndent: 30,
                          ),
                          SizedBox(height: size.height * 0.01),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                  'assets/images/send-small-icon.svg'),
                              SizedBox(width: size.width * 0.04),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Dropoff  3',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 14,
                                          fontFamily: 'Syne-Regular',
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.35),
                                      Text(
                                        '₦ ',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: orangeColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                      Text(
                                        '20.00',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontFamily: 'Inter-Medium',
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  Container(
                                    color: transparentColor,
                                    width: size.width * 0.54,
                                    child: AutoSizeText(
                                      "Rex House, 769 Isadore",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 14,
                                        fontFamily: 'Inter-Medium',
                                      ),
                                      minFontSize: 14,
                                      maxFontSize: 14,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: size.height * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Map? updatedData2 = Map.from(widget.multipleData!);
                  updatedData2.addAll({
                    "pickup_address0": dataForIndex0['0']['pickupController'],
                    "pickup_latitude0": dataForIndex0['0']['pickupLatLng']
                        ['latitude'],
                    "pickup_longitude0": dataForIndex0['0']['pickupLatLng']
                        ['longitude'],
                    "destin_address0": dataForIndex0['0']
                        ['destinationController'],
                    "destin_latitude0": dataForIndex0['0']['destinationLatLng']
                        ['latitude'],
                    "destin_longitude0": dataForIndex0['0']['destinationLatLng']
                        ['longitude'],
                    "receiver_name0": dataForIndex0['0']
                        ['receiversNameController'],
                    "receiver_phone0": dataForIndex0['0']
                        ['receiversNumberController'],
                    "pickup_address1": dataForIndex1['1']['pickupController'],
                    "pickup_latitude1": dataForIndex1['1']['pickupLatLng']
                        ['latitude'],
                    "pickup_longitude1": dataForIndex1['1']['pickupLatLng']
                        ['longitude'],
                    "destin_address1": dataForIndex1['1']
                        ['destinationController'],
                    "destin_latitude1": dataForIndex1['1']['destinationLatLng']
                        ['latitude'],
                    "destin_longitude1": dataForIndex1['1']['destinationLatLng']
                        ['longitude'],
                    "receiver_name1": dataForIndex1['1']
                        ['receiversNameController'],
                    "receiver_phone1": dataForIndex1['1']
                        ['receiversNumberController'],
                    "pickup_address2":
                        dataForIndex2['2']['pickupController'] ?? "",
                    "pickup_latitude2":
                        dataForIndex2['2']['pickupLatLng'] != 'null'
                            ? dataForIndex2['2']['pickupLatLng']
                            : "null",
                    "pickup_longitude2":
                        dataForIndex2['2']['pickupLatLng'] != 'null'
                            ? dataForIndex2['2']['pickupLatLng']
                            : "null",
                    "destin_address2":
                        dataForIndex2['2']['destinationController'] ?? "",
                    "destin_latitude2":
                        dataForIndex2['2']['destinationLatLng'] != 'null'
                            ? dataForIndex2['2']['destinationLatLng']
                            : "null",
                    "destin_longitude2":
                        dataForIndex2['2']['destinationLatLng'] != 'null'
                            ? dataForIndex2['2']['destinationLatLng']
                            : "null",
                    "receiver_name2":
                        dataForIndex2['2']['receiversNameController'] ?? "",
                    "receiver_phone2":
                        dataForIndex2['2']['receiversNumberController'] ?? "",
                    "pickup_address3":
                        dataForIndex3['3']['pickupController'] ?? "",
                    "pickup_latitude3":
                        dataForIndex3['3']['pickupLatLng'] != 'null'
                            ? dataForIndex3['3']['pickupLatLng']
                            : "null",
                    "pickup_longitude3":
                        dataForIndex3['3']['pickupLatLng'] != 'null'
                            ? dataForIndex3['3']['pickupLatLng']
                            : "null",
                    "destin_address3":
                        dataForIndex3['3']['destinationController'] ?? "",
                    "destin_latitude3":
                        dataForIndex3['3']['destinationLatLng'] != 'null'
                            ? dataForIndex3['3']['destinationLatLng']
                            : "null",
                    "destin_longitude3":
                        dataForIndex3['3']['destinationLatLng'] != 'null'
                            ? dataForIndex3['3']['destinationLatLng']
                            : "null",
                    "receiver_name3":
                        dataForIndex3['3']['receiversNameController'] ?? "",
                    "receiver_phone3":
                        dataForIndex3['3']['receiversNumberController'] ?? "",
                    "pickup_address4":
                        dataForIndex4['4']['pickupController'] ?? "",
                    "pickup_latitude4":
                        dataForIndex4['4']['pickupLatLng'] != 'null'
                            ? dataForIndex4['4']['pickupLatLng']
                            : "null",
                    "pickup_longitude4":
                        dataForIndex4['4']['pickupLatLng'] != 'null'
                            ? dataForIndex4['4']['pickupLatLng']
                            : "null",
                    "destin_address4":
                        dataForIndex4['4']['destinationController'] ?? "",
                    "destin_latitude4":
                        dataForIndex4['4']['destinationLatLng'] != 'null'
                            ? dataForIndex4['4']['destinationLatLng']
                            : "null",
                    "destin_longitude4":
                        dataForIndex4['4']['destinationLatLng'] != 'null'
                            ? dataForIndex4['4']['destinationLatLng']
                            : "null",
                    "receiver_name4":
                        dataForIndex4['4']['receiversNameController'] ?? "",
                    "receiver_phone4":
                        dataForIndex4['4']['receiversNumberController'] ?? "",
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WhoWillPaySheet(
                        singleData: const {},
                        multipleData: updatedData2,
                      ),
                    ),
                  );
                },
                child: buttonGradient("CONFIRM", context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
