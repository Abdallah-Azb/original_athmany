import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 40),
      child: SvgPicture.asset('assets/icons/logo.svg', width: 140),
    );
  }
}
