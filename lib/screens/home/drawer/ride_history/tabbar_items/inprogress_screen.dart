import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/inprogress_list.dart';

class InProgressHistoryScreen extends StatefulWidget {
  const InProgressHistoryScreen({super.key});

  @override
  State<InProgressHistoryScreen> createState() =>
      _InProgressHistoryScreenState();
}

class _InProgressHistoryScreenState extends State<InProgressHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),
        Container(
          color: transparentColor,
          height: size.height * 0.78,
          child: const InProgressList(),
        ),
      ],
    );
  }
}
