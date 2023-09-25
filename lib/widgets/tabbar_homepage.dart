import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/screens/home/tabbar_items/new_screen.dart';
import 'package:deliver_client/screens/home/tabbar_items/inprogress_screen.dart';

class TabbarHomePage extends StatefulWidget {
  const TabbarHomePage({super.key});

  @override
  State<TabbarHomePage> createState() => _TabbarHomePageState();
}

class _TabbarHomePageState extends State<TabbarHomePage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    TabController tabController = TabController(length: 2, vsync: this);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
              width: MediaQuery.of(context).size.width * 0.49,
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
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                    Tab(text: "    New    "),
                    Tab(text: "In Progress"),
                  ],
                ),
              )),
        ),
        Container(
          color: transparentColor,
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height,
          child: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              NewScreen(),
              const InProgressHomeScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
