// ignore_for_file: non_constant_identifier_names

import 'package:app/core/enums/type_mobile.dart';
import 'package:flutter/material.dart';

class TypeMobileProvider extends ChangeNotifier {
  TYPEMOBILE TypePhone;

  getDeviceType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    TypePhone =
        data.size.shortestSide < 600 ? TYPEMOBILE.MOBILE : TYPEMOBILE.TABLET;
    print("=-=- Type Phone is =-=-:::: " + TypePhone.toString());
    // notifyListeners();
  }
}
