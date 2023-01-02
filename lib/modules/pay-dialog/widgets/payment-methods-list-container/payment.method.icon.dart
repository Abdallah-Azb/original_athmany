import 'dart:io';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:provider/provider.dart';

import 'package:app/core/utils/const.dart';
import 'package:flutter/material.dart';

class PaymentMethodIcon extends StatefulWidget {
  final int index;
  final String localPath;
  final String icon;
  const PaymentMethodIcon({this.index, this.localPath, this.icon});

  @override
  _PaymentMethodIconState createState() => _PaymentMethodIconState();
}

class _PaymentMethodIconState extends State<PaymentMethodIcon> {
  getImageProvider() {
    File f = File(
        '${this.widget.localPath}/${widget.icon.replaceAll(new RegExp(r"\s+\b|\b\s"), "")}.png');
    return f.existsSync()
        ? Image.file(f)
        : Container(alignment: Alignment.center, child: Text(widget.icon));
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            width: 100,
            height: 56,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                border: Border.all(color: themeColor, width: 2)),
            child: getImageProvider())
        // === Mobile ===
        : Container(
            width: 100,
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                border: Border.all(color: themeColor, width: 1)),
            child: getImageProvider());
  }
}
