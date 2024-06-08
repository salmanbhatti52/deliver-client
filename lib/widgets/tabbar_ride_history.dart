import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/screens/home/drawer/ride_history/tabbar_items/cancelled_screen.dart';
import 'package:deliver_client/screens/home/drawer/ride_history/tabbar_items/completed_screen.dart';
import 'package:deliver_client/screens/home/drawer/ride_history/tabbar_items/inprogress_screen.dart';

class TabbarRideHistory extends StatefulWidget {
  final int? index;
  final Map? singleData;
  final Map? multipleData;
  final String? passCode;
  final String? currentBookingId;
  final UpdateBookingStatusModel? riderData;
  final String? bookingDestinationId;
  const TabbarRideHistory({
    super.key,
    this.index,
    this.singleData,
    this.multipleData,
    this.passCode,
    this.currentBookingId,
    this.riderData,
    this.bookingDestinationId,
});

  @override
  State<TabbarRideHistory> createState() => _TabbarRideHistoryState();
}

class _TabbarRideHistoryState extends State<TabbarRideHistory>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 3, vsync: this);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                child: TabBar(
                  controller: tabController,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      stops: const [0.1, 1.5],
                      colors: [
                        orangeColor,
                        yellowColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 14),
                  labelColor: whiteColor,
                  labelStyle: TextStyle(
                    color: whiteColor,
                    fontSize: 14,
                    fontFamily: 'Syne-Medium',
                  ),
                  unselectedLabelColor: const Color(0xFF929292),
                  unselectedLabelStyle: const TextStyle(
                    color: Color(0xFF929292),
                    fontSize: 14,
                    fontFamily: 'Syne-Regular',
                  ),
                  tabs: const [
                    Tab(text: "In Progress"),
                    Tab(text: "Completed"),
                    Tab(text: "Cancelled"),
                  ],
                ),
              )),
        ),
        Container(
          color: transparentColor,
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.80,
          child: TabBarView(
            controller: tabController,
            children: [
              InProgressHistoryScreen(
                singleData: widget.singleData,
                passCode: widget.passCode,
                multipleData: widget.multipleData,
                currentBookingId: widget.currentBookingId,
                riderData: widget.riderData,
                bookingDestinationId: widget.bookingDestinationId,
              ),
              const CompletedHistoryScreen(),
              const CancelledHistoryScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
