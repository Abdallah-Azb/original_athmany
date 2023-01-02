import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingAnimation extends StatelessWidget {
  final String typeOfAnimation;
  final Color color;
  final double size;
  const LoadingAnimation({this.typeOfAnimation, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    switch (typeOfAnimation) {
      case "horizontalRotatingDots":
        return LoadingAnimationWidget.horizontalRotatingDots(
          color: color,
          size: size,
        );
        break;
      case "staggeredDotsWave":
        return LoadingAnimationWidget.staggeredDotsWave(
          color: color,
          size: size,
        );
        break;
      case "hexagonDots":
        return LoadingAnimationWidget.hexagonDots(
          color: color,
          size: size,
        );
        break;
      case "threeArchedCircle":
        return LoadingAnimationWidget.threeArchedCircle(
          color: color,
          size: size,
        );
        break;
    }
    ;
  }
}
