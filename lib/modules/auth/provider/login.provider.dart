import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  bool _loading = false;
  bool _loadingOTP = false;
  String _accountNumber;
  String _password;
  String _userName;
  bool _autoFocused = false;
  String _otpNumber;

  bool get loading => _loading;
  bool get loadingOTP => _loadingOTP;
  bool get autoFocused => _autoFocused;
  String get accountNumber => _accountNumber;
  String get userName => _userName;
  String get password => _password;
  String get otpNumber => _otpNumber;

  void setLoadingValue(bool loadingValue) async {
    this._loading = loadingValue;
    notifyListeners();
  }

  void setLoadingValueOTP(bool loadingValue) async {
    this._loadingOTP = loadingValue;
    notifyListeners();
  }

  void setAccountNumber(String value) {
    this._accountNumber = value;
    notifyListeners();
  }

  void setUserName(String value) {
    this._userName = value;
    notifyListeners();
  }

  void setPassword(String value) {
    this._password = value;
    notifyListeners();
  }

  void setAutoFocused() {
    print("lofi");
    if (this._accountNumber.isNotEmpty && this._userName.isNotEmpty)
      this._autoFocused = true;
  }

  void setOtpNumber(String value) {
    this._otpNumber = value;
    notifyListeners();
  }
}
