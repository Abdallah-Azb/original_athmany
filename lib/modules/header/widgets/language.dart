import 'package:app/localization/localization.dart';
import 'package:app/modules/header/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import '../../../main.dart';
import '../provider/header.provider.dart';

class Language extends StatelessWidget {
  const Language({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Localization.of(context).locale == Locale('ar', 'SA')
          ? English()
          : Arabic(),
      onTap: () {

        // ? MyApp.setLocale(context, Locale('en', 'US'))
        Localization.of(context).locale == Locale('ar', 'SA')
            ? HeaderProvider().setLocale(context, Locale('en', 'US'), "en")
            : HeaderProvider().setLocale(context, Locale('ar', 'SA'), "ar");

        Phoenix.rebirth(context);
      },
    );
  }
}
