import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';

// function get text and shows a toast
void showToast(String text) {
  debugPrint(text);

  // ignore: avoid_print
  // print(text);
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color.fromARGB(255, 16, 215, 95),
      textColor: const Color.fromARGB(255, 21, 24, 215),
      fontSize: 16.0);
}
