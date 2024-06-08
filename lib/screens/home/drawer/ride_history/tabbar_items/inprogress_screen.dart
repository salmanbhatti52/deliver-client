import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/widgets/inprogress_list.dart';

class InProgressHistoryScreen extends StatefulWidget {
  final int? index;
  final Map? singleData;
  final Map? multipleData;
  final String? passCode;
  final String? currentBookingId;
  final UpdateBookingStatusModel? riderData;
  final String? bookingDestinationId;
  const InProgressHistoryScreen({
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
          child: InProgressList(
            singleData: widget.singleData,
            passCode: widget.passCode,
            multipleData: widget.multipleData,
            currentBookingId: widget.currentBookingId,
            riderData: widget.riderData,
            bookingDestinationId: widget.bookingDestinationId,
          ),
        ),
      ],
    );
  }
}
