import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nil/nil.dart';
import '../auth.dart';

class UserNameTextField extends StatefulWidget {
  @override
  _UserNameTextFieldState createState() => _UserNameTextFieldState();
}

class _UserNameTextFieldState extends State<UserNameTextField> {
  setUserNameInititalValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("user_name") != null)
      context.read<LoginProvider>().setUserName(prefs.getString('user_name'));
    else
      context.read<LoginProvider>().setUserName('');
  }

  @override
  void initState() {
    super.initState();
    setUserNameInititalValue();
  }

  // development
  @override
  Widget build(BuildContext context) {
    LoginProvider loginModel =
        Provider.of<LoginProvider>(context, listen: false);
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return loginModel.userName == null
        ? const Nil()
        : Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                color: lightGrayColor,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: TextFormField(
              textInputAction: TextInputAction.next,
              autofocus: loginModel.autoFocused,
              initialValue: loginModel.userName,
              onChanged: (value) {
                loginModel.setUserName(value);
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
                  borderSide: BorderSide(color: themeColor, width: 1.5),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                      width: 1),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.red.shade800, width: 1),
                ),
                filled: true,
                fillColor: isDarkMode ? darkContainerColor : Colors.white,
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.account_circle_outlined,
                  color: themeColor,
                ),
                border: InputBorder.none,
                hintText: Localization.of(context).tr('user_name'),
              ),
            ),
          );
  }
}
