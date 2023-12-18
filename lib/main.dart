import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:device_preview/device_preview.dart';
import 'package:deliver_client/screens/splash_screen.dart';
import 'package:deliver_client/utils/remove_scroll_glow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: bgColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: bgColor,
      systemNavigationBarDividerColor: dividerColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: ".env");
  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode,
  //     builder: (context) => const MyApp(),
  //   ),
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deliver Client',
      debugShowCheckedModeBanner: false,
      // builder: DevicePreview.appBuilder,
      // locale: DevicePreview.locale(context),
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
