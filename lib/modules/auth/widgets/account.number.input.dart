import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth.dart';
import 'package:nil/nil.dart';


class AccountNumberTextField extends StatefulWidget {
  @override
  _AccountNumberTextFieldState createState() => _AccountNumberTextFieldState();
}

class _AccountNumberTextFieldState extends State<AccountNumberTextField> {
  setAccountNumberInititalValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("account_number") != null)
      context
          .read<LoginProvider>()
          .setAccountNumber(prefs.getString('account_number'));
    else
      context.read<LoginProvider>().setAccountNumber('');
  }

  @override
  void initState() {
    super.initState();
    setAccountNumberInititalValue();
  }

  @override
  Widget build(BuildContext context) {
    LoginProvider loginModel =
        Provider.of<LoginProvider>(context, listen: false);
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    return loginModel.accountNumber == null
        ? const Nil()
        : Container(
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                color: lightGrayColor,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: TextFormField(
              textInputAction: TextInputAction.next,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              autofocus: loginModel.autoFocused,
              initialValue: loginModel.accountNumber,
              onChanged: (value) {
                loginModel.setAccountNumber(value);
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(13.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.white70 : Colors.grey.shade800,
                      width: 1),
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
                prefixIcon: Icon(
                  Icons.corporate_fare_outlined,
                  color: themeColor,
                ),
                hintText: Localization.of(context).tr('account_number'),
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
              ),
            ),
          );
  }
}
