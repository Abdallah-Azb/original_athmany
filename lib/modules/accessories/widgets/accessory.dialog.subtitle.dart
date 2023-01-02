import 'package:app/core/utils/const.dart';
import 'package:app/localization/localization.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/extensions/widget_extension.dart';
class Subtitle extends StatelessWidget {
  const Subtitle({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
      color: isDarkMode == false ? Colors.white : appBarColor,
      child: Text(
        Localization.of(context).tr('printers'),
        style: Theme.of(context).textTheme.headline6.copyWith(
            color: isDarkMode == false ? Colors.grey.shade800 : Colors.white,
            fontWeight: FontWeight.bold),
      ).paddingAll(16),
    );
  }
}
