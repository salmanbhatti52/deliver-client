import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/screens/splash_screen.dart';
import 'package:deliver_client/utils/firebase_options.dart';
import 'package:deliver_client/utils/remove_scroll_glow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deliver Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: orangeColor,
        ),
        useMaterial3: false,
      ),
      scrollBehavior: MyBehavior(),
      home: const SplashScreen(),
    );
  }
}
