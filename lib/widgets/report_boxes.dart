import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';

Widget reportBoxes(BuildContext context, title1, title2, title3, title4, title5) {
  var size = MediaQuery.of(context).size;
  bool isSelected1 = false;
  bool isSelected2 = false;
  bool isSelected3 = false;
  bool isSelected4 = false;
  bool isSelected5 = false;
  return StatefulBuilder(
    builder: (context, setState) => Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isSelected1 = true;
              isSelected2 = false;
              isSelected3 = false;
              isSelected4 = false;
              isSelected5 = false;
            });
          },
          child: Card(
            color: whiteColor,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              color: transparentColor,
              width: size.width,
              height: size.height * 0.07,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      color: transparentColor,
                      width: size.width * 0.65,
                      child: AutoSizeText(
                        title1,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: drawerTextColor,
                          fontSize: 16,
                          fontFamily: 'Syne-Medium',
                        ),
                        minFontSize: 16,
                        maxFontSize: 16,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    isSelected1 == true
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelected1 = false;
                              });
                            },
                            child: SvgPicture.asset(
                              'assets/images/round-checkmark-icon.svg',
                              fit: BoxFit.scaleDown,
                            ),
                          )
                        : const SizedBox(),
                  ],
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
              isSelected5 = false;
            });
          },
          child: Card(
            color: whiteColor,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              color: transparentColor,
              width: size.width,
              height: size.height * 0.07,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      color: transparentColor,
                      width: size.width * 0.65,
                      child: AutoSizeText(
                        title2,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: drawerTextColor,
                          fontSize: 16,
                          fontFamily: 'Syne-Medium',
                        ),
                        minFontSize: 16,
                        maxFontSize: 16,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    isSelected2 == true
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelected2 = false;
                              });
                            },
                            child: SvgPicture.asset(
                              'assets/images/round-checkmark-icon.svg',
                              fit: BoxFit.scaleDown,
                            ),
                          )
                        : const SizedBox(),
                  ],
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
              isSelected5 = false;
            });
          },
          child: Card(
            color: whiteColor,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              color: transparentColor,
              width: size.width,
              height: size.height * 0.07,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      color: transparentColor,
                      width: size.width * 0.65,
                      child: AutoSizeText(
                        title3,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: drawerTextColor,
                          fontSize: 16,
                          fontFamily: 'Syne-Medium',
                        ),
                        minFontSize: 16,
                        maxFontSize: 16,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    isSelected3 == true
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelected3 = false;
                              });
                            },
                            child: SvgPicture.asset(
                              'assets/images/round-checkmark-icon.svg',
                              fit: BoxFit.scaleDown,
                            ),
                          )
                        : const SizedBox(),
                  ],
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
              isSelected5 = false;
            });
          },
          child: Card(
            color: whiteColor,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              color: transparentColor,
              width: size.width,
              height: size.height * 0.07,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      color: transparentColor,
                      width: size.width * 0.65,
                      child: AutoSizeText(
                        title4,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: drawerTextColor,
                          fontSize: 16,
                          fontFamily: 'Syne-Medium',
                        ),
                        minFontSize: 16,
                        maxFontSize: 16,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    isSelected4 == true
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelected4 = false;
                              });
                            },
                            child: SvgPicture.asset(
                              'assets/images/round-checkmark-icon.svg',
                              fit: BoxFit.scaleDown,
                            ),
                          )
                        : const SizedBox(),
                  ],
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
              isSelected4 = false;
              isSelected5 = true;
            });
          },
          child: Card(
            color: whiteColor,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              color: transparentColor,
              width: size.width,
              height: size.height * 0.07,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      color: transparentColor,
                      width: size.width * 0.65,
                      child: AutoSizeText(
                        title5,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: drawerTextColor,
                          fontSize: 16,
                          fontFamily: 'Syne-Medium',
                        ),
                        minFontSize: 16,
                        maxFontSize: 16,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    isSelected5 == true
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelected5 = false;
                              });
                            },
                            child: SvgPicture.asset(
                              'assets/images/round-checkmark-icon.svg',
                              fit: BoxFit.scaleDown,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
