import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FToast fToast = FToast();
void initFToast(context) {
  fToast.init(context);
}

enum _ToastType { OK, ERROR, INFO }

void _showToastOfType(_ToastType type, String message) {
  Color backgroundColor;
  IconData icon;
  const opacity = 0.5;

  switch (type) {
    case _ToastType.OK:
      backgroundColor = Colors.green.withOpacity(opacity);
      icon = Icons.check_sharp;
      break;
    case _ToastType.ERROR:
      backgroundColor = Colors.red.withOpacity(opacity);
      icon = Icons.error_sharp;
      break;
    case _ToastType.INFO:
      backgroundColor = Colors.blue.withOpacity(opacity);
      icon = Icons.info_sharp;
      break;
  }

  fToast.showToast(
    toastDuration: const Duration(seconds: 2),
    child: Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(10.0),
      // padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 12.0),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    ),
    gravity: ToastGravity.TOP,
  );
}

void showOKToast(String message) {
  _showToastOfType(_ToastType.OK, message);
}

void showErrorToast(String message) {
  _showToastOfType(_ToastType.ERROR, message);
}

void showInfoToast(String message) {
  _showToastOfType(_ToastType.INFO, message);
}
