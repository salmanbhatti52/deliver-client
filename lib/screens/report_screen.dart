import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/widgets/report_boxes.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

class ReportScreen extends StatefulWidget {
  final SearchRiderData? riderData;
  final String? currentBookingId;
  const ReportScreen({
    super.key,
    this.riderData,
    this.currentBookingId,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: SvgPicture.asset(
                'assets/images/back-icon.svg',
                width: 22,
                height: 22,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          title: Text(
            "Report Driver",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: blackColor,
              fontSize: 20,
              fontFamily: 'Syne-Bold',
            ),
          ),
          centerTitle: true,
        ),
        body: widget.riderData != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.03),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: size.width * 0.4,
                            height: size.height * 0.2,
                            decoration: BoxDecoration(
                              color: transparentColor,
                            ),
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
                      ),
                      SizedBox(height: size.height * 0.03),
                      Text(
                        '${widget.riderData!.firstName} ${widget.riderData!.lastName}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: drawerTextColor,
                          fontSize: 17,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Card(
                        color: whiteColor,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                      'assets/images/star-icon.svg'),
                                  SizedBox(width: size.width * 0.02),
                                  Text(
                                    '${widget.riderData!.bookingsRatings}',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: drawerTextColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter-Medium',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                      'assets/images/car-icon.svg'),
                                  SizedBox(width: size.width * 0.02),
                                  Text(
                                    '120 Trips',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: drawerTextColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter-Medium',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  SvgPicture.asset(
                                      'assets/images/arrival-time-icon.svg'),
                                  SizedBox(width: size.width * 0.02),
                                  Text(
                                    '3 Years',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: drawerTextColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter-Medium',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Select Reason',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: drawerTextColor,
                            fontSize: 16,
                            fontFamily: 'Syne-Bold',
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      reportBoxes(
                          context,
                          'Lorem ipsum dolor sit amet.',
                          'Lorem ipsum dolor sit amet.',
                          'Lorem ipsum dolor sit amet.',
                          'Lorem ipsum dolor sit amet.',
                          'Any Other Reason'),
                      SizedBox(height: size.height * 0.02),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Upload Evidence',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: drawerTextColor,
                            fontSize: 16,
                            fontFamily: 'Syne-Bold',
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            color: whiteColor,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              color: transparentColor,
                              width: size.width * 0.25,
                              height: size.height * 0.12,
                              child: SvgPicture.asset(
                                'assets/images/evidence-picture-icon.svg',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                          Card(
                            color: whiteColor,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              color: transparentColor,
                              width: size.width * 0.25,
                              height: size.height * 0.12,
                              child: SvgPicture.asset(
                                'assets/images/evidence-video-icon.svg',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                          Card(
                            color: whiteColor,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              color: transparentColor,
                              width: size.width * 0.25,
                              height: size.height * 0.12,
                              child: SvgPicture.asset(
                                'assets/images/evidence-recording-icon.svg',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.04),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            // barrierColor: sheetBarrierColor,
                            builder: (context) => confirmDialog(),
                          );
                        },
                        child: buttonGradient("SUBMIT", context),
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
                  ),
                ),
              )
            : Center(
                child: Container(
                  width: 100,
                  height: 100,
                  color: transparentColor,
                  child: Lottie.asset(
                    'assets/images/loading-icon.json',
                    fit: BoxFit.cover,
                  ),
                ),
              ));
  }

  Widget confirmDialog() {
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
            height: size.height * 0.59,
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
                        padding: const EdgeInsets.only(top: 10),
                        child: SvgPicture.asset("assets/images/close-icon.svg"),
                      ),
                    ),
                  ),
                  SvgPicture.asset("assets/images/customer-notice-icon.svg"),
                  Text(
                    'Customer Notice!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: orangeColor,
                      fontSize: 24,
                      fontFamily: 'Syne-Bold',
                    ),
                  ),
                  Text(
                    'Lorem ipsum dolor sit amet,\nconsetetur sadipscing elitr, sed\ndiam nonumy eirmod tempor\ninvidunt ut labore et dolore',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 18,
                      fontFamily: 'Syne-Regular',
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const HomePageScreen()),
                          (Route<dynamic> route) => false);
                    },
                    child: buttonGradient('OK', context),
                  ),
                  SizedBox(height: size.height * 0.01),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
