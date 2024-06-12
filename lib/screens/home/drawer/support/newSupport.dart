import 'dart:convert';
import 'package:deliver_client/screens/home/drawer/support/support_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';

class NewSupportPage extends StatefulWidget {
  final String? getAdminId;
  final String? getAdminName;
  final String? getAdminImage;
  final String? getAdminAddress;
  const NewSupportPage({
    Key? key,
    this.getAdminId,
    this.getAdminName,
    this.getAdminImage,
    this.getAdminAddress,
  }) : super(key: key);

  @override
  _NewSupportPageState createState() => _NewSupportPageState();
}

class _NewSupportPageState extends State<NewSupportPage> {
  Future<List<Faq>> fetchFaqs() async {
    final response = await http.post(
      Uri.parse('https://cs.deliverbygfl.com/api/get_faqs'),
      body: {"user_type": "Customer"},
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      setState(() {});
      return jsonResponse.map((item) => Faq.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load FAQs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          "Support",
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Hi there 👋',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'How can we help?',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SupportScreen(
                            getAdminId: widget.getAdminId,
                            getAdminName: widget.getAdminName,
                            getAdminImage: widget.getAdminImage,
                            getAdminAddress: widget.getAdminAddress,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const ListTile(
                          leading: Icon(Icons.send),
                          title: Text('Send us a message'),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FutureBuilder<List<Faq>>(
                    future: fetchFaqs(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.57,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ExpansionTile(
                                  title: Text(
                                    snapshot.data![index].question,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(snapshot.data![index].answer),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Faq {
  final int faqsId;
  final String question;
  final String answer;

  Faq({required this.faqsId, required this.question, required this.answer});

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      faqsId: json['faqs_id'],
      question: json['question'],
      answer: json['answer'],
    );
  }
}
