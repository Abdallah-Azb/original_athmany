import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enums/type_mobile.dart';
import '../../core/utils/const.dart';
import '../../localization/localization.dart';
import '../../providers/type_mobile_provider.dart';

class EmptyList extends StatelessWidget {
  final String headline;
  final String message;
  final String image;
  const EmptyList({
    Key key,
    this.headline,
    this.message,
    this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image ?? 'assets/empty_green1.png',
          ),
          Text(
            headline ?? Localization.of(context).tr('empty_headline'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkerThemeColor,
              fontSize: typeMobile == TYPEMOBILE.TABLET ? 24 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(message ?? Localization.of(context).tr('empty_message'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: typeMobile == TYPEMOBILE.TABLET ? 22 : 18,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}
