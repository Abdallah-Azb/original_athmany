import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../res.dart';

class Arabic extends StatelessWidget {
  const Arabic({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? Row(children: [
            Text('عربي', style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(width: 20),
            Image.asset(
              Res.ksa,
              height: 20,
            ),
          ])
        // ==== Mobile =====
        : Icon(
            Icons.language,
            color: Colors.white,
          );
  }
}
