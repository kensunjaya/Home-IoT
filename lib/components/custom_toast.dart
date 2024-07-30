import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class CustomToast {
  FToast _fToast = FToast();

  CustomToast(BuildContext context) {
    _fToast = FToast();
    _fToast.init(context);
  }

  showToast(String text, IconData icon, {Color backgroundColor = const Color.fromRGBO(102, 85, 164, 0.2), Duration duration = const Duration(seconds: 2)}) {
    Widget toast = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(_fToast.context!).size.width * 0.8), // Set a max width
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: backgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(width: 12.0),
          Flexible(
            child: Text(
              text,
              style: TextStyle(overflow: TextOverflow.ellipsis), // Add ellipsis if text overflows
            ),
          ),
        ],
      ),
    );

    _fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: duration,
    );
  }
}
