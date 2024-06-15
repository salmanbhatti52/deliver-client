import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:device_preview/device_preview.dart';
import 'package:deliver_client/screens/splash_screen.dart';
import 'package:deliver_client/utils/remove_scroll_glow.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Remove this method to stop OneSignal Debugging
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  OneSignal.initialize(appID);
  String? token;
  var ID4 = OneSignal.User.pushSubscription.id;
  print("$ID4");

  token = OneSignal.User.pushSubscription.id;
  print("token: $token");
// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.Notifications.requestPermission(true);

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
  // await Firebase.initializeApp();
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