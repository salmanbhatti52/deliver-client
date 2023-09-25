import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';

Widget loyaltyPointList(BuildContext context) {
  var size = MediaQuery.of(context).size;
  return ListView.builder(
    physics: const BouncingScrollPhysics(),
    shrinkWrap: true,
    scrollDirection: Axis.vertical,
    itemCount: myList.length,
    itemBuilder: (BuildContext context, int index) {
      return Card(
        color: whiteColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(myList[index].image),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        myList[index].title,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: drawerTextColor,
                          fontSize: 16,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                      Container(
                        color: transparentColor,
                        width: size.width * 0.5,
                        child: AutoSizeText(
                          myList[index].subtitle,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: textHaveAccountColor,
                            fontSize: 12,
                            fontFamily: 'Inter-Regular',
                          ),
                          minFontSize: 12,
                          maxFontSize: 12,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '50pt',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: orangeColor,
                      fontSize: 20,
                      fontFamily: 'Inter-Bold',
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.02),
            ],
          ),
        ),
      );
    },
  );
}

List myList = [
  MyList("assets/images/loyalty-point-1.png", "Petrol Pump",
      "Lorem Ipsum is simply dummy text of the printing Lorem Ipsum is simply dummy text of the printing"),
  MyList("assets/images/loyalty-point-2.png", "Petrol Pump",
      "Lorem Ipsum is simply dummy text of the printing"),
  MyList("assets/images/loyalty-point-3.png", "Petrol Pump",
      "Lorem Ipsum is simply dummy text of the printing"),
  MyList("assets/images/loyalty-point-4.png", "Petrol Pump",
      "Lorem Ipsum is simply dummy text of the printing"),
  MyList("assets/images/loyalty-point-5.png", "Petrol Pump",
      "Lorem Ipsum is simply dummy text of the printing"),
];

class MyList {
  String? image;
  String? title;
  String? subtitle;

  MyList(this.image, this.title, this.subtitle);
}
