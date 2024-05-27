import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';

class CustomToast {
  static void showToast({
    required String message,
    double fontSize = 12,
  }) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        fontSize: fontSize,
        textColor: whiteColor,
        backgroundColor: toastColor,
        webPosition: "top");
  }
}
