import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:flutter/material.dart';

class StartSellingPointTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      margin: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Text(
        Localization.of(context).tr('start_sales_point'),
        style: TextStyle(
            fontSize: 26, color: themeColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
