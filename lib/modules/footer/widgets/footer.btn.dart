import 'package:app/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../res.dart';
import '../../../widget/widget/loading_animation_widget.dart';

class FooterBtn extends StatelessWidget {
  final Function onTap;
  final String path;
  final Color color;
  final bool isLoading;
  final bool isTablesButton;

  const FooterBtn(
      {Key key,
      this.onTap,
      this.path,
      this.color,
      this.isLoading,
      this.isTablesButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? InkWell(
            child: Container(
              margin: EdgeInsets.only(left: 3, right: 3),
              alignment: Alignment.center,
              width: 120,
              height: 55,
              decoration: BoxDecoration(
                  color:
                      onTap == null ? Colors.grey : getButtonColor(path, color),
                  borderRadius: BorderRadius.circular(12)),
              child: isLoading ?? false
                  ? SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: LoadingAnimationWidget.horizontalRotatingDots(
                        color: Colors.white,
                        size: 26,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isTablesButton == true
                            ? Container(
                                margin: EdgeInsets.all(10),
                                child: Image.asset(
                                  'assets/table.png',
                                  height: 30,
                                ),
                              )
                            : SizedBox.shrink(),
                        isTablesButton == true
                            ? Text(
                                path,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                              )
                            : SvgPicture.asset(
                                path,
                                color: Colors.white,
                                height: 40,
                              )
                      ],
                    ),
            ),
            onTap: onTap,
          )
        :
        // === Mobile ====
        InkWell(
            child: Container(
              margin: EdgeInsets.only(
                left: 2,
                right: 2,
              ),
              alignment: Alignment.center,
              width: (MediaQuery.of(context).size.width / 6) - 6,
              height: 40,
              decoration: BoxDecoration(
                color: onTap == null
                    ? Colors.grey
                    : getButtonColor(
                        path,
                        color,
                      ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isLoading ?? false
                  ? SizedBox(
                      width: 15.0,
                      height: 15.0,
                      child: LoadingAnimation(
                        typeOfAnimation: "horizontalRotatingDots",
                        color: Colors.white,
                        size: 70,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isTablesButton == true
                            ? Container(
                                margin: EdgeInsets.all(10),
                                child: Image.asset(
                                  Res.table,
                                  height: 20,
                                ),
                              )
                            : SizedBox.shrink(),
                        isTablesButton == true
                            ? Text(
                                path,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : SvgPicture.asset(
                                path,
                                color: Colors.white,
                                height: 30,
                              ),
                      ],
                    ),
            ),
            onTap: onTap,
          );
  }
}
