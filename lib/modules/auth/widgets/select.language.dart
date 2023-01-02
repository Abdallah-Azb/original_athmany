import 'package:app/core/utils/const.dart';
import 'package:app/localization/localization.dart';
import 'package:app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class SelectLanguage extends StatelessWidget {
  const SelectLanguage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.language,
            size: 30,
            color: themeColor,
          ),
          SizedBox(width: 10),
          DropdownButton<String>(
            value: Localization.of(context).locale == Locale('ar', 'SA')
                ? 'العربية'
                : 'English',
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.deepPurple),
            onChanged: (String newValue) async {
              if (newValue == 'العربية' &&
                  Localization.of(context).locale != Locale('ar', 'SA')) {
                MyApp.setLocale(context, Locale('ar', 'SA'));
                Phoenix.rebirth(context);
              }
              if (newValue == 'English' &&
                  Localization.of(context).locale != Locale('en', 'US')) {
                MyApp.setLocale(context, Locale('en', 'US'));
                Phoenix.rebirth(context);
              }
            },
            items: <String>['العربية', 'English']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                      fontFamily: 'CairoBold',
                      fontSize: 18,
                      color: Colors.black),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
