import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';

class ScheduledList extends StatefulWidget {
  const ScheduledList({super.key});

  @override
  State<ScheduledList> createState() => _ScheduledListState();
}

class _ScheduledListState extends State<ScheduledList> {

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: 2,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "12 min ago",
              // '${completedRideModel.data![index].rideCompleted}',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: sheetBarrierColor,
                fontSize: 14,
                fontFamily: 'Inter-Medium',
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Card(
              color: whiteColor,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 10,
                  bottom: 15,
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.02),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                color: transparentColor,
                                width: 60,
                                height: 65,
                                child: Image.asset(
                                    "assets/images/user-profile.png",
                                    fit: BoxFit.cover,
                                ),
                                ),
                              ),
                            SizedBox(width: size.width * 0.02),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: transparentColor,
                                  width: size.width * 0.44,
                                  child: AutoSizeText(
                                    'Captain Jannie',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: drawerTextColor,
                                      fontSize: 16,
                                      fontFamily: 'Syne-Bold',
                                    ),
                                    minFontSize: 16,
                                    maxFontSize: 16,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.01),
                                Row(
                                  children: [
                                    Text(
                                      'Yellow ',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: textHaveAccountColor,
                                        fontSize: 12,
                                        fontFamily: 'Inter-Regular',
                                      ),
                                    ),
                                    Text(
                                      'Toyota',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: textHaveAccountColor,
                                        fontSize: 12,
                                        fontFamily: 'Inter-Regular',
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: size.height * 0.005),
                                Text(
                                  '(NHN-5638)',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: textHaveAccountColor,
                                    fontSize: 12,
                                    fontFamily: 'Inter-Regular',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.02),
                        Container(
                          color: transparentColor,
                          width: size.width * 0.54,
                          child: AutoSizeText(
                            'You Completed a ride\n12 min ago with this captain',
                            // 'You Completed a ride\n${completedRideModel.data![index].rideCompleted} with this captain',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: textHaveAccountColor,
                              fontSize: 14,
                              fontFamily: 'Inter-Regular',
                            ),
                            minFontSize: 14,
                            maxFontSize: 14,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
                    ),
                    Positioned(
                      top: 18,
                      right: 0,
                      child: SvgPicture.asset(
                        'assets/images/star-with-container-icon.svg',
                        width: 45,
                      ),
                    ),
                    Positioned(
                      top: 19,
                      right: 7,
                      child: Text(
                        '4.8',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 12,
                          fontFamily: 'Inter-Regular',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 52,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // showDialog(
                          //   context: context,
                          //   barrierDismissible: false,
                          //   // barrierColor: sheetBarrierColor,
                          //   builder: (context) => rebookRide(context),
                          // );
                        },
                        child: detailButtonTransparentGradientSmall(
                            'Cancel', context),
                      ),
                    ),
                    Positioned(
                      bottom: 13,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         RideHistoryCompletedDetailsScreen(
                          //           completedRideModel:
                          //           completedRideModel.data?[index],
                          //         ),
                          //   ),
                          // );
                        },
                        child: detailButtonGradientSmall(
                            'See detail', context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
          ],
        );
      },
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
