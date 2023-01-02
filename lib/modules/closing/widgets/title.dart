import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/const.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:app/localization/localization.dart';
import 'package:flutter/material.dart';

class ClosingTitle extends StatelessWidget {
  const ClosingTitle({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            height: 60,
            alignment: Alignment.center,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: isDarkMode == false ? Colors.white : Color(0xff1F1F1F),
            ),
            child: Text(
              Localization.of(context).tr('close_sales_point'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )) // === Mobile ===
        : Container(
            height: 50,
            alignment: Alignment.center,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isDarkMode == false ? Colors.white : darkContainerColor,
            ),
            child: Text(
              Localization.of(context).tr('close_sales_point'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode == false ? Colors.black : Colors.white,
              ),
            ),
          );
  }
}
