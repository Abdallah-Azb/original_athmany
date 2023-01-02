import 'package:app/core/utils/session.dart';
import 'package:app/db-operations/db.operations.dart';
import 'package:app/modules/auth/models/user.dart';
import 'package:app/services/api.service.dart';
import 'package:app/services/auth.service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryRefactor {
  AuthService _authService = AuthService();
  Future<SharedPreferences> _prefs() async =>
      await SharedPreferences.getInstance();
  Session _session = Session();
  DBUser _dbUser = DBUser();
  DBOpeningDetails _dbOpeningDetails = DBOpeningDetails();

  Future login(String accountNumber, String username, String password) async {
    try {
      print("AuthRepositoryRefactor-login function started");
      String baseUrl = await _authService.getApiBaseUrl(accountNumber);
      print("baseUrl is : $baseUrl");
      await _saveApiBaseUrl(baseUrl);
      SessionData sessionData =
          await _authService.getSessionId(username, password);
      await _session.setId(sessionData.sessionId);
      String userId = await _authService.getUserId();
      User user = User(
          sid: sessionData.sessionId,
          userId: userId,
          username: username,
          fullName: sessionData.fullName);
      print('⚡️⚡️ Session ID = ${sessionData.sessionId}');
      print('⚡️⚡️ Account ID = ${accountNumber}');
      Sentry.configureScope(
        (scope) => scope.user = SentryUser(
            id: accountNumber, email: userId, username: username),
      );
      await _saveLoginData(user, accountNumber);
      await _saveUserInfo(user, accountNumber);
    } on Failure catch (f, stackTrace) {
      await Sentry.captureException(
        f,
        stackTrace: stackTrace,
      );
      throw f;
    }
  }

  Future loginOTP(int otp, String tmpId, username, accountNumber) async {
    // print("Otp Devices ===  "+otp.toString());
    // print("tmpId Devices ===  "+tmpId.toString());
    // print("username Devices ===  "+username.toString());
    // print("accountNumber Devices ===  "+accountNumber.toString());
    try {
      // print(":::: Login OTP :::::");
      // print("Otp Devices therd ===  "+otp.toString());

      SessionData sessionData = await _authService.getSessionIdOTP(otp, tmpId);
      await _session.setId(sessionData.sessionId);
      String userId = await _authService.getUserId();
      print("userId OTP == : $userId");
      User user = User(
          sid: sessionData.sessionId,
          userId: userId,
          username: username,
          fullName: sessionData.fullName);
      await _saveLoginData(user, accountNumber);
      await _saveUserInfo(user, accountNumber);
      print("Otp Devices Second ===  " + otp.toString());
    } on Failure catch (f) {
      throw f;
    }
  }

  Future<void> logOut() {
    try {
      _authService.logOut();
    } on Failure catch (f) {
      print('logout catch : $f');
      throw f;
    }
  }

  Future<void> _setApiBaseUrl() async {
    SharedPreferences prefs = await _prefs();
    String baseUrl = prefs.getString('base_url');
    await ApiService().setApiBaseUrl(baseUrl);
  }

  Future<String> _getUserId() async {
    return await _authService.getUserId();
  }

  Future<String> validateSessionId() async {
    await _setApiBaseUrl();
    return _getUserId();
  }

  Future _saveApiBaseUrl(String baseUrl) async {
    SharedPreferences prefs = await _prefs();
    prefs.setString('base_url', baseUrl);
    await _setApiBaseUrl();
  }

  Future<void> _saveLoginData(User user, String accountNumber) async {
    SharedPreferences prefs = await _prefs();
    prefs.setString('account_number', accountNumber);
    prefs.setString('user_name', user.username);
  }

  Future<void> _saveUserInfo(User user, String accountNumber) async {
    await _dbUser.dropAndCreateSignedInUserTable();
    await _dbUser.add(user);
    await _dbOpeningDetails.dropAndCreateOpeningDetailsTable();
  }

  Future<void> signOut() async {
    await _dbOpeningDetails.dropOpeningDetailsTable();
    await _dbUser.dropUserTable();
    await _session.clear();
  }
}
