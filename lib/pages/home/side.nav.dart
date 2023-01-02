import 'dart:async';

import 'package:app/core/utils/utils.dart';
import 'package:app/providers/providers.dart';
import 'package:app/widget/widget/change_theme_button.dart';
import 'package:flutter/material.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';

class SideNav extends StatefulWidget {
  final int selectedMainWidgetIndex;

  SideNav({this.selectedMainWidgetIndex});
  @override
  _SideNavState createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  bool isAuthenticated = false;
  String updateStock;
  hideTotalAmountF() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    this.updateStock = _prefs.getString('hide_total_amount');
  }

  @override
  void initState() {
    super.initState();
    hideTotalAmountF();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10),
      width: 74,
      height: double.infinity,
      color: themeColor,
      child: Column(
        children: [
          button('assets/side-menu/logo.png', index: 0),
          // SizedBox(height: 50),
          // button('assets/side-menu/home.png', index: 0),
          SizedBox(height: 50),
          button('assets/side-menu/invoice.png', index: 1),
          SizedBox(height: 50),
          button('assets/side-menu/table.png', index: 7),
          SizedBox(height: 50),
          // updateStock == '0'
          //     ? Container()
          button('assets/side-menu/stock.png', index: 6),
          // SizedBox(height: 50),
          // button('assets/side-menu/lock.png', index: 9),
          SizedBox(height: 50),
          ThemeButton(),
        ],
      ),
    );
  }

  // button
  Widget button(String iconPath, {int index}) {
    return InkWell(
      child: Container(
        // color: Colors.red,
        width: 25,
        height: 50,
        child: Image.asset(iconPath,
            scale: index == 9 ? 5 : 0.5,
            color: index == widget.selectedMainWidgetIndex
                ? orangeColor
                : Colors.white),
      ),
      onTap: () {
        if (index == 9) {
          showLockScreen(
            context,
            opaque: false,
            cancelButton: Text(
              '',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              semanticsLabel: '',
            ),
          );
        } else
          context.read<HomeProvider>().setMainIndex(index);
      },
    );
  }

  lockScreenButton(BuildContext context) => MaterialButton(
        padding: EdgeInsets.only(left: 50, right: 50),
        color: Theme.of(context).primaryColor,
        child: Text(
          'Lock Screen',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        onPressed: () {
          showLockScreen(
            context,
            opaque: false,
            cancelButton: Text(
              'Cancel',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              semanticsLabel: 'Cancel',
            ),
          );
        },
      );

  showLockScreen(BuildContext context,
      {bool opaque,
      CircleUIConfig circleUIConfig,
      KeyboardUIConfig keyboardUIConfig,
      Widget cancelButton,
      List<String> digits}) {
    Navigator.push(
        context,
        PageRouteBuilder(
          opaque: opaque,
          pageBuilder: (context, animation, secondaryAnimation) =>
              PasscodeScreen(
            title: Text(
              'Enter Passcode',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
            circleUIConfig: circleUIConfig,
            keyboardUIConfig: keyboardUIConfig,
            passwordEnteredCallback: _passcodeEntered,
            cancelButton: cancelButton,
            deleteButton: Text(
              'Delete',
              style: const TextStyle(fontSize: 16, color: Colors.white),
              semanticsLabel: 'Delete',
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Colors.black.withOpacity(0.8),
            cancelCallback: _passcodeCancelled,
            digits: digits,
            passwordDigits: 4,
            bottomWidget: _passcodeRestoreButton(),
          ),
        ));
  }

  _passcodeEntered(String enteredPasscode) {
    bool isValid = storedPasscode == enteredPasscode;
    _verificationNotifier.add(isValid);
    if (isValid) {
      setState(() {
        this.isAuthenticated = isValid;
      });
    }
  }

  _passcodeCancelled() {
    // Navigator.maybePop(context);
  }

  _passcodeRestoreButton() => Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10.0, top: 20.0),
          // child: FlatButton(
          //   child: Text(
          //     "Reset passcode",
          //     textAlign: TextAlign.center,
          //     style: const TextStyle(
          //         fontSize: 16,
          //         color: Colors.white,
          //         fontWeight: FontWeight.w300),
          //   ),
          //   splashColor: Colors.white.withOpacity(0.4),
          //   highlightColor: Colors.white.withOpacity(0.2),
          //   onPressed: _resetApplicationPassword,
          // ),
        ),
      );

  _resetApplicationPassword() {
    Navigator.maybePop(context).then((result) {
      if (!result) {
        return;
      }
      _restoreDialog(() {
        Navigator.maybePop(context);
      });
    });
  }

  _restoreDialog(VoidCallback onAccepted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.teal[50],
          title: Text(
            "Reset passcode",
            style: const TextStyle(color: Colors.black87),
          ),
          content: Text(
            "Passcode reset is a non-secure operation!\nAre you sure want to reset?",
            style: const TextStyle(color: Colors.black87),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            TextButton(
              child: Text(
                "Cancel",
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.maybePop(context);
              },
            ),
            TextButton(
              child: Text(
                "I proceed",
                style: const TextStyle(fontSize: 18),
              ),
              onPressed: onAccepted,
            ),
          ],
        );
      },
    );
  }
}
