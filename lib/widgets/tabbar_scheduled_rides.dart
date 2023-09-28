import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/screens/home/drawer/scheduled_ride/tabbar_items/cancelled_screen.dart';
import 'package:deliver_client/screens/home/drawer/scheduled_ride/tabbar_items/scheduled_screen.dart';

class TabbarScheduledHistory extends StatefulWidget {
  const TabbarScheduledHistory({super.key});

  @override
  State<TabbarScheduledHistory> createState() => _TabbarScheduledHistoryState();
}

class _TabbarScheduledHistoryState extends State<TabbarScheduledHistory>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
              width: MediaQuery.of(context).size.width,
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
                  labelPadding: const EdgeInsets.symmetric(horizontal: 39.5),
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
                    Tab(text: "Scheduled"),
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
            children: const [
              ScheduledScreen(),
              CancelledScheduledScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
