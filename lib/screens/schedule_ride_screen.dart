// ignore_for_file: must_be_immutable

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/screens/confirm_single_details_screen.dart';
import 'package:deliver_client/screens/confirm_multiple_details_screen.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class ScheduleRideScreen extends StatefulWidget {
  final int? selectedRadio;
  Map<int, dynamic>? indexData0;
  Map<int, dynamic>? indexData1;
  Map<int, dynamic>? indexData2;
  Map<int, dynamic>? indexData3;
  Map<int, dynamic>? indexData4;
  final Map? scheduledSingleData;
  final Map? scheduledMultipleData;

  ScheduleRideScreen({
    super.key,
    this.indexData0,
    this.indexData1,
    this.indexData2,
    this.indexData3,
    this.indexData4,
    this.selectedRadio,
    this.scheduledSingleData,
    this.scheduledMultipleData,
  });

  @override
  State<ScheduleRideScreen> createState() => _ScheduleRideScreenState();
}

class _ScheduleRideScreenState extends State<ScheduleRideScreen> {
  @override
  initState() {
    super.initState();
    debugPrint("Schedule indexData0: ${widget.indexData0}");
    debugPrint("Schedule indexData1: ${widget.indexData1}");
    debugPrint("Schedule indexData2: ${widget.indexData2}");
    debugPrint("Schedule indexData3: ${widget.indexData3}");
    debugPrint("Schedule indexData4: ${widget.indexData4}");
    debugPrint("mapData Single: ${widget.scheduledSingleData}");
    debugPrint("mapData Multiple: ${widget.scheduledMultipleData}");
  }

  DateTime? selectedDate;
  DateTime? selectedTime;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
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
            left: 20,
            right: 20,
            bottom: 85,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: size.width * 0.6,
                height: size.height * 0.28,
                color: whiteColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: size.height * 0.04),
                      Text(
                        "Schedule Ride",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 22,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      Container(
                        width: size.width,
                        height: size.height * 0.06,
                        decoration: BoxDecoration(
                          color: filledColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate != null
                                    ? DateFormat('dd-MM-yyyy')
                                        .format(selectedDate!)
                                    : 'Select Date',
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDatePicker(
                                    context: context,
                                    initialDate: selectedDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  ).then((date) {
                                    if (date != null) {
                                      setState(() {
                                        selectedDate =
                                            date; // Update selectedDate with the chosen date
                                      });
                                    }
                                  });
                                  // picker.DatePicker.showDatePicker(
                                  //   context,
                                  //   showTitleActions: true,
                                  //   minTime: DateTime.now(),
                                  //   maxTime: DateTime(2050, 12, 31),
                                  //   theme: picker.DatePickerTheme(
                                  //     headerColor: bgColor,
                                  //     backgroundColor: bgColor,
                                  //     itemStyle: TextStyle(
                                  //       color: blackColor,
                                  //       fontSize: 16,
                                  //       fontFamily: 'Syne-Medium',
                                  //     ),
                                  //     doneStyle: TextStyle(
                                  //       color: orangeColor,
                                  //       fontSize: 16,
                                  //       fontFamily: 'Syne-Bold',
                                  //     ),
                                  //     cancelStyle: TextStyle(
                                  //       color: borderColor,
                                  //       fontSize: 16,
                                  //       fontFamily: 'Syne-Bold',
                                  //     ),
                                  //   ),
                                  //   onChanged: (date) {
                                  //     setState(() {
                                  //       selectedDate = date;
                                  //     });
                                  //   },
                                  //   onConfirm: (date) {
                                  //     setState(() {
                                  //       selectedDate = date;
                                  //     });
                                  //     debugPrint("selectedDate: $selectedDate");
                                  //   },
                                  //   currentTime: DateTime.now(),
                                  //   locale: picker.LocaleType.en,
                                  // );
                                },
                                child: Container(
                                  color: transparentColor,
                                  width: size.width * 0.08,
                                  height: size.height * 0.04,
                                  child: SvgPicture.asset(
                                    'assets/images/date-picker-icon.svg',
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Container(
                        width: size.width,
                        height: size.height * 0.06,
                        decoration: BoxDecoration(
                          color: filledColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedTime != null
                                    ? DateFormat('h:mm').format(selectedTime!)
                                    : 'Select Time',
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  picker.DatePicker.showTime12hPicker(
                                    context,
                                    showTitleActions: true,
                                    theme: picker.DatePickerTheme(
                                      headerColor: bgColor,
                                      backgroundColor: bgColor,
                                      itemStyle: TextStyle(
                                        color: blackColor,
                                        fontSize: 16,
                                        fontFamily: 'Syne-Medium',
                                      ),
                                      doneStyle: TextStyle(
                                        color: orangeColor,
                                        fontSize: 16,
                                        fontFamily: 'Syne-Bold',
                                      ),
                                      cancelStyle: TextStyle(
                                        color: borderColor,
                                        fontSize: 16,
                                        fontFamily: 'Syne-Bold',
                                      ),
                                    ),
                                    onChanged: (time) {
                                      setState(() {
                                        selectedTime = time;
                                      });
                                    },
                                    onConfirm: (time) {
                                      setState(() {
                                        selectedTime = time;
                                      });
                                      debugPrint("selectedTime: $selectedTime");
                                    },
                                    currentTime: DateTime.now(),
                                    locale: picker.LocaleType.en,
                                  );
                                },
                                child: Container(
                                  color: transparentColor,
                                  width: size.width * 0.08,
                                  height: size.height * 0.04,
                                  child: SvgPicture.asset(
                                    'assets/images/time-picker-icon.svg',
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
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
                if (selectedDate == null || selectedTime == null) {
                  Fluttertoast.showToast(
                    msg: "Please select date and time!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 2,
                    backgroundColor: toastColor,
                    textColor: whiteColor,
                    fontSize: 12,
                  );
                } else {
                  if (widget.selectedRadio == 1) {
                    Map? updatedSingleScheduledData =
                        Map.from(widget.scheduledSingleData!);
                    updatedSingleScheduledData.addAll({
                      "delivery_date": DateFormat('yyyy-MM-dd')
                          .format(selectedDate!)
                          .toString(),
                      "delivery_time":
                          DateFormat('h:mm').format(selectedTime!).toString(),
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmSingleDetailsScreen(
                          singleData: updatedSingleScheduledData,
                        ),
                      ),
                    );
                  }
                  if (widget.selectedRadio == 2) {
                    Map? updatedMultipleScheduledData =
                        Map.from(widget.scheduledMultipleData!);
                    updatedMultipleScheduledData.addAll({
                      "delivery_date": DateFormat('yyyy-MM-dd')
                          .format(selectedDate!)
                          .toString(),
                      "delivery_time":
                          DateFormat('h:mm').format(selectedTime!).toString(),
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfirmMultipleDetailsScreen(
                          indexData0: widget.indexData0,
                          indexData1: widget.indexData1,
                          indexData2: widget.indexData2,
                          indexData3: widget.indexData3,
                          indexData4: widget.indexData4,
                          multipleData: updatedMultipleScheduledData,
                        ),
                      ),
                    );
                  }
                }
              },
              child: buttonGradient("CONFIRM", context),
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
        ],
      ),
    );
  }
}
