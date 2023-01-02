import 'package:app/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Subscribe extends StatelessWidget {
  const Subscribe({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(26),
      alignment: Alignment.center,
      child: InkWell(
        child: Text(
          Localization.of(context).tr('subscribe'),
          style:
              TextStyle(color: Color(0xff008dde), fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          String url = 'http://athmanytec.com';
          if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        },
      ),
    );
  }
}
