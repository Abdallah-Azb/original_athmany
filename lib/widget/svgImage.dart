// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgImage extends StatelessWidget {
  String path;

  SvgImage({
    Key key,
    this.path,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
    );
  }
}
