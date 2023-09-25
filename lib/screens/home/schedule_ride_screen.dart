// ignore_for_file: avoid_print

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/screens/confirm_single_details_screen.dart';
import 'package:deliver_client/screens/confirm_multiple_details_screen.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

class ScheduleRideScreen extends StatefulWidget {
  final int? selectedRadio;
  const ScheduleRideScreen({super.key, this.selectedRadio});

  @override
  State<ScheduleRideScreen> createState() => _ScheduleRideScreenState();
}

class _ScheduleRideScreenState extends State<ScheduleRideScreen> {
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
                                  picker.DatePicker.showDatePicker(
                                    context,
                                    showTitleActions: true,
                                    minTime: DateTime.now(),
                                    maxTime: DateTime(2050, 12, 31),
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
                                    onChanged: (date) {
                                      setState(() {
                                        selectedDate = date;
                                      });
                                    },
                                    onConfirm: (date) {
                                      setState(() {
                                        selectedDate = date;
                                      });
                                      print("selectedDate: $selectedDate");
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
                                    ? DateFormat('h:mm a').format(selectedTime!)
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
                                      print("selectedTime: $selectedTime");
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
                if (widget.selectedRadio == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConfirmSingleDetailsScreen(),
                    ),
                  );
                }
                if (widget.selectedRadio == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ConfirmMultipleDetailsScreen(),
                    ),
                  );
                }
              },
              child: buttonGradient("CONFIRM", context),
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
