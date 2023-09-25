import 'package:flutter/material.dart';
import 'package:deliver_client/utils/colors.dart';

bool isSelected1 = false;
bool isSelected2 = false;
bool isSelected3 = false;
bool isSelected4 = false;

Widget payTipsBoxes({title1, title2, title3, title4, context}) {
  var size = MediaQuery.of(context).size;
  return StatefulBuilder(
    builder: (context, setState) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isSelected1 = true;
                isSelected2 = false;
                isSelected3 = false;
                isSelected4 = false;
              });
            },
            child: Card(
              color: isSelected1 == true ? orangeColor : whiteColor,
              elevation: isSelected1 == true ? 1 : 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: transparentColor,
                  width: size.width * 0.18,
                  height: size.height * 0.05,
                  child: Center(
                    child: Text(
                      title1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected1 == true
                            ? whiteColor
                            : textHaveAccountColor,
                        fontSize: 16,
                        fontFamily: 'Inter-Medium',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isSelected1 = false;
                isSelected2 = true;
                isSelected3 = false;
                isSelected4 = false;
              });
            },
            child: Card(
              color: isSelected2 == true ? orangeColor : whiteColor,
              elevation: isSelected2 == true ? 1 : 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                color: transparentColor,
                width: size.width * 0.18,
                height: size.height * 0.05,
                child: Center(
                  child: Text(
                    title2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected2 == true
                          ? whiteColor
                          : textHaveAccountColor,
                      fontSize: 16,
                      fontFamily: 'Inter-Medium',
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isSelected1 = false;
                isSelected2 = false;
                isSelected3 = true;
                isSelected4 = false;
              });
            },
            child: Card(
              color: isSelected3 == true ? orangeColor : whiteColor,
              elevation: isSelected3 == true ? 1 : 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                color: transparentColor,
                width: size.width * 0.18,
                height: size.height * 0.05,
                child: Center(
                  child: Text(
                    title3,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected3 == true
                          ? whiteColor
                          : textHaveAccountColor,
                      fontSize: 16,
                      fontFamily: 'Inter-Medium',
                    ),
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isSelected1 = false;
                isSelected2 = false;
                isSelected3 = false;
                isSelected4 = true;
              });
            },
            child: Card(
              color: isSelected4 == true ? orangeColor : whiteColor,
              elevation: isSelected4 == true ? 1 : 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                color: transparentColor,
                width: size.width * 0.18,
                height: size.height * 0.05,
                child: Center(
                  child: Text(
                    title4,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected4 == true
                          ? whiteColor
                          : textHaveAccountColor,
                      fontSize: 16,
                      fontFamily: 'Inter-Medium',
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
