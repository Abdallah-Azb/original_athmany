import 'package:app/core/enums/type_mobile.dart';
import 'package:app/localization/localization.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/const.dart';
import '../../../core/utils/utils.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import '../../../core/extensions/widget_extension.dart';
class DialogHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isTrailing;

  const DialogHeader({
    Key key,
    this.title,
    this.isTrailing,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var model = Provider.of<AccessoryModel>(context);
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            padding: const EdgeInsets.only(
                top: 16.0, right: 32.0, left: 16.0, bottom: 8.0),
            decoration: BoxDecoration(
              color: isDarkMode == false ? Colors.white : appBarColor,
              border: Border(
                bottom: BorderSide(
                  width: 3,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  iconSize: 30.0,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Row(
                  children: [
                    Text(
                      title ?? "",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline5.copyWith(
                            color: isDarkMode == false
                                ? Colors.grey.shade800
                                : Colors.white,
                          ),
                    ),
                    Visibility(
                        visible: subtitle != null,
                        child: Text(subtitle ?? "",
                            style: TextStyle(color: Colors.grey)))
                  ],
                ),
                isTrailing ?? true
                    ? TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          showAnimatedDialog(
                              context: context,
                              builder: (context) =>
                                  ChangeNotifierProvider.value(
                                    value: model,
                                    child: NewAccessoryDialog(),
                                  ),
                              animationType: DialogTransitionType.slideFromTop,
                              curve: Curves.ease,
                              duration: Duration(milliseconds: 400),
                              barrierDismissible: true);

                          // showDialog(
                          //   context: context,
                          //   builder: (context) => ChangeNotifierProvider.value(
                          //     value: model,
                          //     child: NewAccessoryDialog(),
                          //   ),
                          // );
                        },
                        child: Text(
                          Localization.of(context).tr('add'),
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Colors.white),
                        ).paddingHorizontally(32),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          )
        // === Mobile ====
        : Container(
            padding: const EdgeInsets.only(
                top: 16.0, right: 32.0, left: 16.0, bottom: 8.0),
            decoration: BoxDecoration(
              // color: Colors.red,
              color: isDarkMode == false ? Colors.white : darkContainerColor,
              border: Border(
                bottom: BorderSide(
                  width: 2,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  iconSize: 20.0,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Row(
                  children: [
                    Container(
                      width: 60,
                      child: Text(
                        title ?? "",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: Theme.of(context).textTheme.headline5.copyWith(
                              color: isDarkMode == false
                                  ? Colors.grey.shade800
                                  : Colors.white, //Colors.white
                              fontSize: 18,
                            ),
                      ),
                    ),
                    Visibility(
                      visible: subtitle != null,
                      child: Container(
                        width: 120,
                        child: Text(
                          subtitle ?? "",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            overflow: TextOverflow.clip,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                isTrailing ?? true
                    ? TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: themeColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => ChangeNotifierProvider.value(
                              value: model,
                              child: NewAccessoryDialog(),
                            ),
                          );
                        },
                        child: Text(
                          Localization.of(context).tr('add'),
                          style: Theme.of(context)
                              .textTheme
                              .headline6
                              .copyWith(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          );
  }
}
