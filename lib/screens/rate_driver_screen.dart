// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_balloon/speech_balloon.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:deliver_client/models/rate_rider_model.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

String? userId;

class RateDriverScreen extends StatefulWidget {
  final String? currentBookingId;
  final SearchRiderData? riderData;
  final String? bookingDestinationId;

  const RateDriverScreen({
    super.key,
    this.riderData,
    this.currentBookingId,
    this.bookingDestinationId,
  });

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  TextEditingController additionalCommentsController = TextEditingController();
  final GlobalKey<FormState> ratingFormKey = GlobalKey<FormState>();

  double? ratingValue;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  RateRiderModel rateRiderModel = RateRiderModel();

  rateRider() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/rate_booking";
      print("apiUrl: $apiUrl");
      print("userId: $userId");
      print("fleetId: ${widget.riderData!.usersFleetId.toString()}");
      print("bookingId: ${widget.currentBookingId}");
      print("bookingDestinationId: ${widget.bookingDestinationId}");
      print("rating: ${ratingValue.toString()}");
      print("comment: ${additionalCommentsController.text}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "rated_by": "Customers",
          "users_customers_id": userId,
          "users_fleet_id": widget.riderData!.usersFleetId.toString(),
          "bookings_id": widget.currentBookingId,
          "bookings_destinations_id": widget.bookingDestinationId,
          "rating": ratingValue.toString(),
          "comment": additionalCommentsController.text,
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        rateRiderModel = rateRiderModelFromJson(responseString);
        print('rateRiderModel status: ${rateRiderModel.status}');
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    print("currentBookingId: ${widget.currentBookingId}");
    print("bookingDestinationId: ${widget.bookingDestinationId}");
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: transparentColor,
        body: Stack(
          children: [
            Image.asset(
              'assets/images/payment-location-background.png',
              width: size.width,
              height: size.height,
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 45,
              left: 0,
              right: 0,
              child: Text(
                "Rate Driver",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blackColor,
                  fontSize: 20,
                  fontFamily: 'Syne-Bold',
                ),
              ),
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
                  height: size.height * 0.7,
                  decoration: BoxDecoration(
                    color: whiteColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.04),
                          SpeechBalloon(
                            nipLocation: NipLocation.bottom,
                            nipHeight: 12,
                            borderColor: borderColor,
                            width: size.width * 0.4,
                            height: size.height * 0.07,
                            borderRadius: 10,
                            offset: const Offset(10, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    color: transparentColor,
                                    width: 40,
                                    height: 40,
                                    child: FadeInImage(
                                      placeholder: const AssetImage(
                                        "assets/images/user-profile.png",
                                      ),
                                      image: NetworkImage(
                                        '$imageUrl${widget.riderData!.profilePic}',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${widget.riderData!.firstName}",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: blackColor,
                                        fontSize: 14,
                                        fontFamily: 'Syne-SemiBold',
                                      ),
                                    ),
                                    Text(
                                      "Rider",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: textHaveAccountColor,
                                        fontSize: 12,
                                        fontFamily: 'Syne-Regular',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
                          Text(
                            "Thank you!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 16,
                              fontFamily: 'Syne-Bold',
                            ),
                          ),
                          SizedBox(height: size.height * 0.04),
                          Text(
                            "Your feedback will improve our service.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 16,
                              fontFamily: 'Syne-Regular',
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
                          RatingBar(
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            glowColor: orangeColor,
                            itemCount: 5,
                            initialRating: 0.0,
                            maxRating: 5.0,
                            minRating: 0.5,
                            ratingWidget: RatingWidget(
                              full: SvgPicture.asset(
                                  'assets/images/star-filled-icon.svg'),
                              half: SvgPicture.asset(
                                  'assets/images/star-half-filled-icon.svg'),
                              empty: SvgPicture.asset(
                                  'assets/images/star-empty-icon.svg'),
                            ),
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            onRatingUpdate: (rating) {
                              setState(() {
                                ratingValue = rating;
                              });
                              print('ratingValue: $ratingValue');
                            },
                          ),
                          SizedBox(height: size.height * 0.03),
                          Container(
                            height: size.height * 0.15,
                            decoration: BoxDecoration(
                              color: filledColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: filledColor,
                                width: 1.0,
                              ),
                            ),
                            child: TextFormField(
                              controller: additionalCommentsController,
                              cursorColor: orangeColor,
                              keyboardType: TextInputType.text,
                              maxLines: null,
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Additional Comments field is required!';
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
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                hintText: "Additional Comments",
                                hintStyle: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter-Light',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.04),
                          GestureDetector(
                            onTap: () async {
                              if (additionalCommentsController.text.isEmpty ||
                                  ratingValue == null) {
                                if (ratingValue == null) {
                                  Fluttertoast.showToast(
                                    msg: "Please rate the rider!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor: toastColor,
                                    textColor: whiteColor,
                                    fontSize: 12,
                                  );
                                } else if (additionalCommentsController
                                    .text.isEmpty) {
                                  Fluttertoast.showToast(
                                    msg: "Please add a comment!",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor: toastColor,
                                    textColor: whiteColor,
                                    fontSize: 12,
                                  );
                                }
                              } else {
                                await rateRider();
                                if (rateRiderModel.status == "success") {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomePageScreen()),
                                      (Route<dynamic> route) => false);
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(
                                  //     builder: (context) => PayTipScreen(
                                  //       riderData: widget.riderData!,
                                  //     ),
                                  //   ),
                                  // );
                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  print("Something went wrong!");
                                }
                              }
                            },
                            child: isLoading
                                ? buttonGradientWithLoader(
                                    "Please Wait...", context)
                                : buttonGradient("SUBMIT", context),
                          ),
                          SizedBox(height: size.height * 0.02),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => rebookRide(context),
                              );
                            },
                            child: buttonTransparentGradient("REBOOK", context),
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
          ],
        ),
      ),
    );
  }
}

Widget rebookRide(BuildContext context) {
  var size = MediaQuery.of(context).size;
  return GestureDetector(
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
          height: size.height * 0.45,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      padding: const EdgeInsets.only(top: 15),
                      child: SvgPicture.asset("assets/images/close-icon.svg"),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                SvgPicture.asset('assets/images/hourglass-icon.svg'),
                SizedBox(height: size.height * 0.03),
                Text(
                  'Time up',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: orangeColor,
                    fontSize: 20,
                    fontFamily: 'Syne-Bold',
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'You can not rebook this ride after 5\nmins of completing the ride.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 18,
                    fontFamily: 'Syne-Regular',
                  ),
                ),
                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
