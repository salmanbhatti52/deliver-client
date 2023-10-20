// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/screens/rate_driver_screen.dart';

class AmountToPayScreen extends StatefulWidget {
  final String? currentBookingId;
  final SearchRiderData? riderData;
  final String? bookingDestinationId;

  const AmountToPayScreen({
    super.key,
    this.riderData,
    this.currentBookingId,
    this.bookingDestinationId,
  });

  @override
  State<AmountToPayScreen> createState() => _AmountToPayScreenState();
}

class _AmountToPayScreenState extends State<AmountToPayScreen> {

  final int amount = 100000;
  final String reference = "unique_transaction_ref_${Random().nextInt(1000000)}";
  final payStackClient = PaystackPlugin();

  void startPayStack () {
    String? publicKey = dotenv.env['PAYSTACK_PUBLIC_KEY'];
    payStackClient.initialize(publicKey: publicKey!);
  }

  void makePayment() async {
    final Charge charge = Charge()
      ..email = 'paystackcustomer@qa.team'
      ..amount = amount
      ..reference = reference;

    final CheckoutResponse response = await payStackClient.checkout(context,
        charge: charge, method: CheckoutMethod.card);

    if (response.status && response.reference == reference) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RateDriverScreen(
            riderData: widget.riderData!,
            currentBookingId: widget.currentBookingId,
            bookingDestinationId:
                widget.bookingDestinationId,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: orangeColor,
          content: const Text('Transaction Successful!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: orangeColor,
          content: const Text('Transaction Failed!'),
        ),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    startPayStack();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: transparentColor,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/payment-location-background.png',
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Text(
              "Arrived at Destination",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackColor,
                fontSize: 18,
                fontFamily: 'Syne-Bold',
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
              child: Container(
                width: size.width,
                height: size.height * 0.36,
                decoration: BoxDecoration(
                  color: whiteColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.04),
                        Text(
                          "Amount to Pay",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 22,
                            fontFamily: 'Syne-Bold',
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        RichText(
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "2600",
                            style: TextStyle(
                              color: orangeColor,
                              fontSize: 26,
                              fontFamily: 'Inter-Bold',
                            ),
                            children: [
                              TextSpan(
                                text: '₦',
                                style: TextStyle(
                                  color: orangeColor,
                                  fontSize: 20,
                                  fontFamily: 'Inter-Regular',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: size.height * 0.04),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "Payment Status",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 18,
                                    fontFamily: 'Syne-Medium',
                                  ),
                                ),
                                SizedBox(width: size.width * 0.12),
                                Text(
                                  "Paid",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: orangeColor,
                                    fontSize: 18,
                                    fontFamily: 'Syne-Medium',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.02),
                            Row(
                              children: [
                                Text(
                                  "Payment Method",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: blackColor,
                                    fontSize: 18,
                                    fontFamily: 'Syne-Medium',
                                  ),
                                ),
                                SizedBox(width: size.width * 0.085),
                                Text(
                                  "Card",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: orangeColor,
                                    fontSize: 18,
                                    fontFamily: 'Syne-Medium',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.04),
                        GestureDetector(
                          onTap: () {
                            makePayment();
                          },
                          child: buttonGradient("NEXT", context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: SvgPicture.asset(
                'assets/images/back-icon.svg',
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
