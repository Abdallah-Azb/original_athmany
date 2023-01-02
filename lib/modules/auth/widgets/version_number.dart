import 'package:app/core/utils/const.dart';
import 'package:flutter/material.dart';

class VersionNumber extends StatelessWidget {
  const VersionNumber({
    Key key,
    @required this.versionNumber,
  }) : super(key: key);

  final String versionNumber;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      'Version Number : $versionNumber',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w600, color: themeColor),
    ));
  }
}
