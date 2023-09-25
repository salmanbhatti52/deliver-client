import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/completed_list.dart';

class CompletedHistoryScreen extends StatefulWidget {
  const CompletedHistoryScreen({super.key});

  @override
  State<CompletedHistoryScreen> createState() => _CompletedHistoryScreenState();
}

class _CompletedHistoryScreenState extends State<CompletedHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),
        Container(
          color: transparentColor,
          height: size.height * 0.78,
          child: const CompletedList(),
        ),
      ],
    );
  }
}
