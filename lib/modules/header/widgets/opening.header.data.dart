import 'package:flutter/material.dart';

class OpeningHeaderData extends StatelessWidget {
  final String profileName;
  final String openingDetailsName;
  const OpeningHeaderData({
    Key key,
    this.profileName,
    this.openingDetailsName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$profileName',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            '$openingDetailsName',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
