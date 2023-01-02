import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:provider/provider.dart';

import '../../../res.dart';
import 'package:flutter/material.dart';

class English extends StatelessWidget {
  const English({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? Row(
            children: [
              Text(
                'English',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 10),
              Image.asset(
                Res.usa,
                height: 20,
              ),
            ],
          )
        // === Mobile ===
        : Icon(Icons.language);
  }
}
