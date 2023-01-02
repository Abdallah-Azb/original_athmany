import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  int selectedMainWidgetIndex = 0;

  void setMainIndex(int newIndex) {
    selectedMainWidgetIndex = newIndex;
    notifyListeners();
  }
}
