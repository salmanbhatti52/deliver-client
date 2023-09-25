import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';

class HomeTextFeilds extends StatefulWidget {
  const HomeTextFeilds({super.key});

  @override
  State<HomeTextFeilds> createState() => _HomeTextFeildsState();
}

class _HomeTextFeildsState extends State<HomeTextFeilds> {
  TextEditingController pickupController1 = TextEditingController();
  TextEditingController destinationController1 = TextEditingController();
  TextEditingController receiversNameController1 = TextEditingController();
  TextEditingController receiversNumberController1 = TextEditingController();
  TextEditingController pickupController2 = TextEditingController();
  TextEditingController destinationController2 = TextEditingController();
  TextEditingController receiversNameController2 = TextEditingController();
  TextEditingController receiversNumberController2 = TextEditingController();
  TextEditingController pickupController3 = TextEditingController();
  TextEditingController destinationController3 = TextEditingController();
  TextEditingController receiversNameController3 = TextEditingController();
  TextEditingController receiversNumberController3 = TextEditingController();
  TextEditingController pickupController4 = TextEditingController();
  TextEditingController destinationController4 = TextEditingController();
  TextEditingController receiversNameController4 = TextEditingController();
  TextEditingController receiversNumberController4 = TextEditingController();
  TextEditingController pickupController5 = TextEditingController();
  TextEditingController destinationController5 = TextEditingController();
  TextEditingController receiversNameController5 = TextEditingController();
  TextEditingController receiversNumberController5 = TextEditingController();
  final GlobalKey<FormState> homeNewFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      color: transparentColor,
      height: size.height * 0.3,
      child: Stack(
        children: [
          Positioned(
            top: 13,
            child:
                SvgPicture.asset('assets/images/home-location-path-icon.svg'),
          ),
          Positioned(
            left: 30,
            child: Container(
              color: transparentColor,
              width: size.width * 0.8,
              child: TextFormField(
                controller: pickupController1,
                cursorColor: orangeColor,
                keyboardType: TextInputType.text,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Pickup Location field is required!';
                //   }
                //   return null;
                // },
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
                    fontSize: 12,
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  hintText: "Pickup Location",
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 12,
                    fontFamily: 'Inter-Light',
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () {},
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
            ),
          ),
          Positioned(
            top: 60,
            left: 30,
            child: Container(
              color: transparentColor,
              width: size.width * 0.8,
              child: TextFormField(
                controller: destinationController1,
                cursorColor: orangeColor,
                keyboardType: TextInputType.text,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Destination field is required!';
                //   }
                //   return null;
                // },
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
                    fontSize: 12,
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  hintText: "Destination",
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 12,
                    fontFamily: 'Inter-Light',
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 30,
            child: Container(
              color: transparentColor,
              width: size.width * 0.8,
              child: TextFormField(
                controller: receiversNameController1,
                cursorColor: orangeColor,
                keyboardType: TextInputType.text,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return "Receiver's Name field is required!";
                //   }
                //   return null;
                // },
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
                    fontSize: 12,
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  hintText: "Receiver's Name",
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 12,
                    fontFamily: 'Inter-Light',
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: 30,
            child: Container(
              color: transparentColor,
              width: size.width * 0.8,
              child: TextFormField(
                controller: receiversNumberController1,
                cursorColor: orangeColor,
                keyboardType: TextInputType.text,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return "Receiver's Phone Number field is required!";
                //   }
                //   return null;
                // },
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
                    fontSize: 12,
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
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  hintText: "Receiver's Phone Number",
                  hintStyle: TextStyle(
                    color: hintColor,
                    fontSize: 12,
                    fontFamily: 'Inter-Light',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
