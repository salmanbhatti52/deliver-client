import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  bool isExpanded = false;
  bool isExpanded2 = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePageScreen()),
            (Route<dynamic> route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: SvgPicture.asset(
                'assets/images/back-icon.svg',
                width: 22,
                height: 22,
                fit: BoxFit.scaleDown,
              ),
            ),
          ),
          title: Text(
            "Legel",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: blackColor,
              fontSize: 20,
              fontFamily: 'Syne-Bold',
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Container(
                      width: size.width,
                      height: isExpanded ? size.height * 0.6 : size.height * 0.06,
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: Border.all(
                          color: borderColor.withOpacity(0.1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: blackColor.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: isExpanded
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    SizedBox(height: size.height * 0.02),
                                    Text(
                                      "Terms & Conditions",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: blackColor,
                                        fontFamily: 'Syne-Bold',
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    Text(
                                      "Tacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaav",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: blackColor,
                                        fontFamily: 'Syne-Regular',
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.02),
                                    Icon(
                                      Icons.keyboard_arrow_up_rounded,
                                      color: blackColor.withOpacity(0.5),
                                    ),
                                    SizedBox(height: size.height * 0.01),
                                  ],
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 20, right: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Terms & Conditions",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: blackColor,
                                      fontFamily: 'Syne-Medium',
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    color: blackColor.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            )),
                ),
                SizedBox(height: size.height * 0.02),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded2 = !isExpanded2;
                    });
                  },
                  child: Container(
                      width: size.width,
                      height: isExpanded2 ? size.height * 0.6 : size.height * 0.06,
                      decoration: BoxDecoration(
                        color: bgColor,
                        border: Border.all(
                          color: borderColor.withOpacity(0.1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: blackColor.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: isExpanded2
                          ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.02),
                              Text(
                                "Privacy Policy",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: blackColor,
                                  fontFamily: 'Syne-Bold',
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Text(
                                "Tacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaavTacjasjs;ojocas;;;;;;jca;c;s;mas;cm;amc;ca;ca;s;ac;asc;l;lac;lac;ldlnvsvivaiuaguifuieguiarviusbivu;aaaaav",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: blackColor,
                                  fontFamily: 'Syne-Regular',
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Icon(
                                Icons.keyboard_arrow_up_rounded,
                                color: blackColor.withOpacity(0.5),
                              ),
                              SizedBox(height: size.height * 0.01),
                            ],
                          ),
                        ),
                      )
                          : Padding(
                        padding: const EdgeInsets.only(left: 20, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Privacy Policy",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                                color: blackColor,
                                fontFamily: 'Syne-Medium',
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: blackColor.withOpacity(0.5),
                            ),
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
