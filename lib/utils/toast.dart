import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// function get text and shows a toast
void showToast(String text) {
  // ignore: avoid_print
  print(text);
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0);
}
