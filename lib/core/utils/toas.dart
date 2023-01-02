import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future toast(String message, Color bgColor, {gravity, int time}) async {
  return await Fluttertoast.showToast(
      msg: "$message",
      toastLength: Toast.LENGTH_LONG,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: time != null ? time : 1,
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 18.0);
}
