import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:launch_review/launch_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionCheck {
  static String _currentVersionNumber;
  static String _storeVersion;
  static String _id;
  static const _uri =
      'https://athmany.tech/api/method/bench_manager.bench_manager.doctype.athmany_pos.athmany_pos.get_version';

  static Future<void> checkForNewVersion(BuildContext context) async {
    log("====================================================================================");
    final packageInfo = await PackageInfo.fromPlatform();
    _currentVersionNumber ??= packageInfo.version;
    log(packageInfo.version);
    _id ??= packageInfo.packageName;

    final uri = Uri.parse(_uri);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Failed to query iOS App Store');
      return;
    }
    log(response.body);
    final jsonObj = json.decode(response.body)["message"];
    log(jsonObj.toString());
    final bool shouldUpdate = jsonObj['update_required'] == 1;
    _storeVersion = jsonObj['app_version'];
    log(_storeVersion);
    if (canUpdate) {
      _showUpdateDialog(context: context, allowDismissal: !shouldUpdate);
    }
  }

  static bool get canUpdate {
    if (_currentVersionNumber == null || _storeVersion == null) return false;

    final local = _currentVersionNumber
        .split('.')
        .map(int.parse)
        .toList(); //5.30.1=>[4,30,1]
    final store =
        _storeVersion.split('.').map(int.parse).toList(); //4.30.2 => [4,30,2]

    for (int i = 0; i < store.length; i++) {
      if (store[i] > local[i]) {
        return true;
      }
      if (local[i] > store[i]) {
        return false;
      }
    }

    return false;
  }

  static Future<void> _showUpdateDialog({
    BuildContext context,
    String dialogTitle = 'Update Available',
    String dialogText,
    String updateButtonText = 'Update',
    bool allowDismissal,
    String dismissButtonText = 'Maybe Later',
    VoidCallback dismissAction,
  }) async {
    final dialogTitleWidget = Text(dialogTitle);
    allowDismissal ??= true;
    final dialogTextWidget = Text(
      dialogText ?? 'Update Available',
    );

    final updateButtonTextWidget = Text(updateButtonText);

    Future<void> updateAction() async {
      await _launchStore();
      if (allowDismissal) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    List<Widget> actions = [
      if (Platform.isAndroid)
        TextButton(
          onPressed: updateAction,
          child: updateButtonTextWidget,
        )
      else
        CupertinoDialogAction(
          onPressed: updateAction,
          child: updateButtonTextWidget,
        ),
    ];

    if (allowDismissal) {
      final dismissButtonTextWidget = Text(dismissButtonText);
      dismissAction = dismissAction ??
          () => Navigator.of(context, rootNavigator: true).pop();
      actions.add(
        Platform.isAndroid
            ? TextButton(
                onPressed: dismissAction,
                child: dismissButtonTextWidget,
              )
            : CupertinoDialogAction(
                onPressed: dismissAction,
                child: dismissButtonTextWidget,
              ),
      );
    }

    await showDialog(
      context: context,
      barrierDismissible: allowDismissal,
      builder: (BuildContext context) {
        return WillPopScope(
          child: Platform.isAndroid
              ? AlertDialog(
                  title: dialogTitleWidget,
                  content: dialogTextWidget,
                  actions: actions,
                )
              : CupertinoAlertDialog(
                  title: dialogTitleWidget,
                  content: dialogTextWidget,
                  actions: actions,
                ),
          onWillPop: () => Future.value(allowDismissal),
        );
      },
    );
  }

  static Future<void> _launchStore() async {
    final appStoreLink =
        Uri.parse('https://apps.apple.com/sa/app/athmany-pos/id1583755282');
    final googlePlayLink =
        Uri.https("play.google.com", "/store/apps/details", {"id": _id});
    if (await canLaunchUrl(appStoreLink) && Platform.isIOS) {
      await LaunchReview.launch(writeReview: false, iOSAppId: "1583755282");
    } else if (await canLaunchUrl(googlePlayLink) && Platform.isAndroid) {
      await LaunchReview.launch(writeReview: false, androidAppId: _id);
    } else {
      throw 'Could not launch appStoreLink';
    }
  }
}
