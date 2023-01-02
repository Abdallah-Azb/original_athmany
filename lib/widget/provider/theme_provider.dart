import 'package:app/core/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  // bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
  // isDarkMode == false ? Colors.white : darkContainerColor,
  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: darkBackGroundColor,
    brightness: Brightness.dark,
    indicatorColor: themeColor,
    primarySwatch: Colors.teal,

    // primaryColor: Colors.red,
    // colorScheme: ColorScheme.dark(),
    // iconTheme: IconThemeData(
    //   color: Colors.white,
    //   opacity: 0.8,
    // ),
    // accentColor: Colors.red,
    // textTheme: TextTheme(
    //   bodyText1: TextStyle(
    //     fontSize: 18.0,
    //     fontWeight: FontWeight.w600,
    //     color: Colors.white,
    //   ),
    // ),
  );

  static final lightTheme = ThemeData(
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    indicatorColor: themeColor,
    primarySwatch: Colors.teal,

    // primaryColor: Colors.red,
    // colorScheme: ColorScheme.light(),
    // iconTheme: IconThemeData(
    //   color: Colors.white,
    //   opacity: 0.8,
    // ),
    // accentColor: Colors.red,
    // primarySwatch: Colors.teal,
    // textTheme: TextTheme(
    //   bodyText1: TextStyle(
    //     fontSize: 18.0,
    //     fontWeight: FontWeight.w600,
    //     color: Colors.black,
    //   ),
    // ),
  );
}
