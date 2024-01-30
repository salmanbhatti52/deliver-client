// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/get_user_chat_model.dart';
import 'package:deliver_client/models/send_user_chat_model.dart';
import 'package:deliver_client/models/start_user_chat_model.dart';

String? userId;

class ChatScreen extends StatefulWidget {
  final Function()? callbackFunction;
  final String? riderId;
  final String? name;
  final String? image;
  final String? phone;
  final String? address;

  const ChatScreen({
    super.key,
    this.callbackFunction,
    this.riderId,
    this.name,
    this.image,
    this.phone,
    this.address,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();

  Timer? timer;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  StartUserChatModel startUserChatModel = StartUserChatModel();

  startUserChat() async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/user_chat";
      print("apiUrlStartChat: $apiUrl");
      print("userId: $userId");
      print("OtherUserId: ${widget.riderId}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "request_type": " startChat",
          "users_type": "Customers",
          "other_users_type": "Rider",
          "users_id": userId,
          "other_users_id": widget.riderId
        },
      );
      final responseString = jsonDecode(response.body);
      print("response: $responseString");
      print("status: ${responseString['status']}");
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  GetUserChatModel getUserChatModel = GetUserChatModel();

  getUserChat() async {
    try {
      setState(() {
        isLoading = true;
      });
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/user_chat";
      print("apiUrlGetChat: $apiUrl");
      print("userId: $userId");
      print("OtherUserId: ${widget.riderId}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Accept": "application/json",
        },
        body: {
          "request_type": "getMessages",
          "users_type": "Customers",
          "other_users_type": "Rider",
          "users_id": userId,
          "other_users_id": widget.riderId
        },
      );
      final responseString = response.body;
      print("response: ${response.body}");
      print("status Code getUserChatModel: ${response.statusCode}");
      if (response.statusCode == 200) {
        getUserChatModel = getUserChatModelFromJson(responseString);
        print('getUserChatModel status: ${getUserChatModel.status}');
        print('getUserChatModel message: ${getUserChatModel.data?[0].message}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  SendUserChatModel sendUserChatModel = SendUserChatModel();

  sendUserChat(String? msg) async {
    try {
      setState(() {
        isLoading = true;
      });
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/user_chat";
      print("apiUrlSend: $apiUrl");
      print("userId: $userId");
      print("OtherUserId: ${widget.riderId}");
      print("message: $msg");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "request_type": "sendMessage",
          "users_type": "Customers",
          "other_users_type": "Rider",
          "users_id": userId,
          "other_users_id": widget.riderId,
          "message_type": "text",
          "message": msg,
        },
      );
      final responseString = jsonDecode(response.body);
      print("response: $responseString");
      print("status: ${responseString['status']}");
      setState(() {
        isLoading = false;
        getUserChat();
      });
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  void startTimer() {
    // Start the timer and call getMessageApi() every 1 second
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      getUserChat();
    });
  }

  void cancelTimer() {
    // Cancel the timer if it's active
    timer?.cancel();
  }

  // Call this function when the user enters the page
  void onPageEnter() {
    // Start the timer to call getMessageApi() every 1 second
    startTimer();
  }

// Call this function when the user leaves the page
  void onPageExit() {
    // Cancel the timer to stop calling getMessageApi()
    cancelTimer();
  }

  @override
  void initState() {
    super.initState();
    startUserChat();
    getUserChat();
    onPageEnter();
  }

  @override
  void dispose() {
    onPageExit();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        widget.callbackFunction!();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
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
                widget.callbackFunction!();
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
              "Chat",
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
                  SizedBox(height: size.height * 0.01),
                  Container(
                    width: size.width,
                    height: size.height * 0.1,
                    color: transparentColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    width: size.width * 0.15,
                                    height: size.height * 0.07,
                                    decoration: BoxDecoration(
                                      color: transparentColor,
                                    ),
                                    child: widget.image != 'null' &&
                                            widget.image != null
                                        ? FadeInImage(
                                            placeholder: const AssetImage(
                                              "assets/images/user-profile.png",
                                            ),
                                            image: NetworkImage(
                                              '$imageUrl${widget.image}',
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            "assets/images/user-profile.png",
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 0,
                                  child: SvgPicture.asset(
                                    'assets/images/online-status-icon.svg',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: size.width * 0.03),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  color: transparentColor,
                                  width: size.width * 0.55,
                                  child: Text(
                                    widget.name != 'null' && widget.name != null
                                        ? "${widget.name}"
                                        : "Rider",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 16,
                                      fontFamily: 'Syne-SemiBold',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.005),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/orange-location-icon.svg',
                                    ),
                                    SizedBox(width: size.width * 0.01),
                                    Container(
                                      color: transparentColor,
                                      width: size.width * 0.5,
                                      child: AutoSizeText(
                                        widget.address != 'null' &&
                                                widget.address != null
                                            ? "${widget.address}"
                                            : "Unknown Location",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: supportTextColor,
                                          fontSize: 12,
                                          fontFamily: 'Inter-Regular',
                                        ),
                                        minFontSize: 12,
                                        maxFontSize: 12,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                makePhoneCall("${widget.phone}");
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => CallScreen(
                                //       name: widget.name,
                                //       image: widget.image,
                                //     ),
                                //   ),
                                // );
                              },
                              child: SvgPicture.asset(
                                'assets/images/call-icon.svg',
                              ),
                            ),
                          ],
                        ),
                        Divider(
                          thickness: 1,
                          color: dividerColor,
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        getUserChatModel.data != null
                            ? Container(
                                color: transparentColor,
                                height: size.height * 0.7,
                                child: ListView.builder(
                                  reverse: true,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: getUserChatModel.data?.length,
                                  padding: const EdgeInsets.only(bottom: 10),
                                  itemBuilder: (context, index) {
                                    int reverseIndex =
                                        getUserChatModel.data!.length -
                                            1 -
                                            index;
                                    String inputTime =
                                        "${getUserChatModel.data?[reverseIndex].sendTime}";
                                    DateFormat inputFormat =
                                        DateFormat("H:mm:ss");
                                    DateFormat outputFormat =
                                        DateFormat("h:mm a");
                                    DateTime dateTime =
                                        inputFormat.parse(inputTime);
                                    String formattedTime =
                                        outputFormat.format(dateTime);
                                    return getUserChatModel.data?[reverseIndex]
                                                    .receiverType !=
                                                "Customers" &&
                                            getUserChatModel.data?[reverseIndex]
                                                    .messageType ==
                                                "text"
                                        ? Column(
                                            children: [
                                              SizedBox(
                                                  height: size.height * 0.015),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 84),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                        topLeft:
                                                            Radius.circular(10),
                                                        topRight:
                                                            Radius.circular(10),
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                      ),
                                                      child: Container(
                                                        color: orangeColor,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Container(
                                                                color:
                                                                    transparentColor,
                                                                width:
                                                                    size.width *
                                                                        0.6,
                                                                child: Text(
                                                                  "${getUserChatModel.data?[reverseIndex].message}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        whiteColor,
                                                                    fontSize:
                                                                        12,
                                                                    fontFamily:
                                                                        'Inter-Regular',
                                                                  ),
                                                                ),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  SvgPicture
                                                                      .asset(
                                                                    'assets/images/clock-white-message-icon.svg',
                                                                  ),
                                                                  SizedBox(
                                                                      width: size
                                                                              .width *
                                                                          0.01),
                                                                  Text(
                                                                    formattedTime,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .left,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          whiteColor,
                                                                      fontSize:
                                                                          8,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              SizedBox(
                                                  height: size.height * 0.015),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: Container(
                                                      width: 25.6,
                                                      height: 25.5,
                                                      decoration: BoxDecoration(
                                                        color: transparentColor,
                                                      ),
                                                      child: widget.image !=
                                                                  'null' &&
                                                              widget.image !=
                                                                  null
                                                          ? FadeInImage(
                                                              placeholder:
                                                                  const AssetImage(
                                                                "assets/images/user-profile.png",
                                                              ),
                                                              image:
                                                                  NetworkImage(
                                                                '$imageUrl${widget.image}',
                                                              ),
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.asset(
                                                              "assets/images/user-profile.png",
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: size.width * 0.02),
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                    child: Container(
                                                      color: dividerColor,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              color:
                                                                  transparentColor,
                                                              width:
                                                                  size.width *
                                                                      0.6,
                                                              child: Text(
                                                                "${getUserChatModel.data?[reverseIndex].message}",
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      drawerTextColor,
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      'Inter-Regular',
                                                                ),
                                                              ),
                                                            ),
                                                            Row(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/clock-message-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    width: size
                                                                            .width *
                                                                        0.01),
                                                                Text(
                                                                  formattedTime,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        textHaveAccountColor,
                                                                    fontSize: 8,
                                                                    fontFamily:
                                                                        'Inter-Regular',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                  },
                                ),
                              )
                            : Container(
                                color: transparentColor,
                                height: size.height * 0.7,
                                // child: Column(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   crossAxisAlignment:
                                //       CrossAxisAlignment.center,
                                //   children: [
                                //     SvgPicture.asset(
                                //       'assets/images/no-chat-icon.svg',
                                //       width: 80,
                                //       height: 80,
                                //     ),
                                //     SizedBox(height: size.height * 0.04),
                                //     Text(
                                //       "No Chat History",
                                //       textAlign: TextAlign.center,
                                //       style: TextStyle(
                                //         color: textHaveAccountColor,
                                //         fontSize: 24,
                                //         fontFamily: 'Syne-SemiBold',
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Container(
                    width: size.width,
                    height: size.height * 0.06,
                    decoration: BoxDecoration(
                      color: dividerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: messageController,
                            cursorColor: orangeColor,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            minLines: 1,
                            maxLines: null,
                            style: TextStyle(
                              color: blackColor,
                              fontSize: 14,
                              fontFamily: 'Inter-Regular',
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: dividerColor,
                              errorStyle: TextStyle(
                                color: redColor,
                                fontSize: 10,
                                fontFamily: 'Inter-Bold',
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                borderSide: BorderSide(
                                  color: redColor,
                                  width: 1,
                                ),
                              ),
                              contentPadding: const EdgeInsets.only(
                                top: 5,
                                left: 20,
                                right: 0,
                                bottom: 5,
                              ),
                              hintText: "Write message here...",
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 12,
                                fontFamily: 'Inter-Light',
                              ),
                            ),
                          ),
                        ),
                        Theme(
                          data: ThemeData(
                            hoverColor: transparentColor,
                            splashColor: transparentColor,
                            highlightColor: transparentColor,
                          ),
                          child: FloatingActionButton(
                            onPressed: () async {
                              if (messageController.text.isNotEmpty) {
                                sendUserChat(messageController.text);
                                setState(() {
                                  messageController.clear();
                                  FocusManager.instance.primaryFocus?.unfocus();
                                });
                              } else {}
                            },
                            elevation: 0,
                            tooltip: 'Send',
                            hoverElevation: 0,
                            disabledElevation: 0,
                            highlightElevation: 0,
                            foregroundColor: transparentColor,
                            backgroundColor: transparentColor,
                            child: SvgPicture.asset(
                              'assets/images/send-icon.svg',
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
