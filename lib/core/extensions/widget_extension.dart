import 'package:flutter/material.dart';

extension ExtendedText on Widget {
  alignAtStart() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: this,
    );
  }

  Widget paddingAll(double padding) => Padding(
    padding: EdgeInsets.all(padding),
    child: this,
  );

  Widget paddingAllNormal() => Padding(
    padding: EdgeInsets.all(8),
    child: this,
  );


  Widget paddingHorizontally(double padding) => Padding(
    padding: EdgeInsets.symmetric(horizontal: padding),
    child: this,
  );

  Widget paddingHorizontallyAndVertical(double h , double v) => Padding(
    padding: EdgeInsets.symmetric(horizontal: h,vertical:v ),
    child: this,
  );

  Widget paddingVertical(double padding) => Padding(
    padding: EdgeInsets.symmetric(horizontal: padding),
    child: this,
  );

  alignAtEnd() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: this,
    );
  }
}