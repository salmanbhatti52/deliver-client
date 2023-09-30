import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/cancelled_scheduled_list.dart';

class CancelledScheduledScreen extends StatefulWidget {
  const CancelledScheduledScreen({super.key});

  @override
  State<CancelledScheduledScreen> createState() => _CancelledScheduledScreenState();
}

class _CancelledScheduledScreenState extends State<CancelledScheduledScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),
        Container(
          color: transparentColor,
          height: size.height * 0.78,
          child: const CancelledScheduledList(),
        ),
      ],
    );
  }
}
