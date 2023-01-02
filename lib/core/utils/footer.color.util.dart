// get buttons color
import 'package:app/core/utils/utils.dart';
import 'package:flutter/material.dart';

Color getButtonColor(String title, Color color) {
  // new order
  if (title == 'New Order') return themeColor;
  // tables
  if (title == 'Tables' || title == 'Customer') {
    return themeColor;
  }
  if (title == 'Print') {
    return color;
  }
  if (title == 'Save' || title == 'Pay') {
    return color;
  }
  // save
  return color;
}
