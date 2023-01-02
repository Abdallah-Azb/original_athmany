import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/widget/provider/theme_provider.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth.dart';

class PasswordTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    LoginProvider loginModel =
        Provider.of<LoginProvider>(context, listen: false);
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          color: lightGrayColor,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: TextField(
        textInputAction: TextInputAction.go,
        obscureText: true,
        autofocus: true,
        onChanged: (value) {
          loginModel.setPassword(value);
        },
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(13.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: themeColor,
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
                color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(
              color: Colors.red.shade800,
              width: 1,
            ),
          ),
          filled: true,
          fillColor: isDarkMode ? darkContainerColor : Colors.white,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.grey,
          ),
          prefixIcon: Icon(
            Icons.lock,
            color: themeColor,
          ),
          border: InputBorder.none,
          hintText: Localization.of(context).tr('password'),
        ),
      ),
    );
  }
}
