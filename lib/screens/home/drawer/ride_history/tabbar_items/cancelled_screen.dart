import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/cancelled_list.dart';

class CancelledHistoryScreen extends StatefulWidget {
  const CancelledHistoryScreen({super.key});

  @override
  State<CancelledHistoryScreen> createState() => _CancelledHistoryScreenState();
}

class _CancelledHistoryScreenState extends State<CancelledHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),
        Container(
          color: transparentColor,
          height: size.height * 0.78,
          child: const CancelledList(),
        ),
      ],
    );
  }
}
