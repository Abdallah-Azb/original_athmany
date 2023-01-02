import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../localization/localization.dart';
import '../../../res.dart';
import '../const.dart';
import 'package:nil/nil.dart';
import '../../extensions/widget_extension.dart';


class ConfirmDialog extends StatefulWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String bodyText;
  final Widget icon;
  final double iconHeight;
  final bool showCancelBtn;
  final bool opengingWarningDialog;
  final List<String> messages;
  final String acceptText;
  final String cancelText;

  ConfirmDialog({
    Key key,
    @required this.onConfirm,
    this.bodyText,
    this.iconHeight,
    this.icon,
    this.showCancelBtn = true,
    this.opengingWarningDialog = false,
    this.messages,
    this.acceptText,
    this.cancelText,
    this.onCancel,
  }) : super(key: key);

  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  TextStyle cancelBtnTextStyle = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 20
  );

  TextStyle confirmBtnTextStyle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 20
  );

  bool isConfirmInProgress = false;

  void setConfirmProgress(bool state) {
    isConfirmInProgress = state;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode == false ? Colors.white : darkContainerColor,
            ),
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              children: [
                Container(
                  height: 180,
                  child: Column(
                    children: [
                      SizedBox(
                        height: widget.iconHeight ?? 50,
                        child: widget.icon ??
                            Image.asset(
                              Res.warning,
                            ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      widget.opengingWarningDialog
                          ? messagseColumn()
                          : Text(
                              widget.bodyText,
                              style: typeMobile == TYPEMOBILE.TABLET
                                  ? Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        height: 1,
                                        color: isDarkMode == false
                                            ? Colors.black
                                            : Colors.white,
                                      )
                                  : Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .copyWith(
                                        color: isDarkMode == false
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                            ),
                    ],
                  ).paddingAll(26),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _confirmBtn(),
                    Expanded(flex:widget.showCancelBtn ?1:0,child: SizedBox()),
                    widget.showCancelBtn ? _cancelBtn(context) : const SizedBox.shrink(),
                  ],
                ).paddingAllNormal(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Expanded _confirmBtn() {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return Expanded(
      flex:4,
      child: Container(
        decoration: boxDecorationButton(themeColor),
        child: TextButton(
          child: Text(
            widget.acceptText ?? Localization.of(context).tr('yes'),
            style: typeMobile == TYPEMOBILE.TABLET
                ? confirmBtnTextStyle
                : TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
          ),
          onPressed: isConfirmInProgress ?? false
              ? null
              : () async {
                  setConfirmProgress(true);
                  widget.onConfirm();
                },
        ),
      ),
    );
  }

  BoxDecoration boxDecorationButton(Color color) {
    return BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: color,
      );
  }

  Expanded _cancelBtn(BuildContext context) {
    return Expanded(
        flex:4,
      child: Container(
        decoration: boxDecorationButton(Colors.transparent),
        child: TextButton(
          child: Text(
            widget.cancelText ?? Localization.of(context).tr('cancel'),
            style: cancelBtnTextStyle,
          ),
          // onPressed: widget.onCancel ??
          //     () {
          //       Navigator.pop(context, false);
          //     },
          onPressed: () {
            widget.onCancel ?? Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // column messages
  Widget messagseColumn() {
    return Column(
      children: [
        for (int i = 0; i < widget.messages.length; i++)
          Text(
            widget.messages[i],
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}
