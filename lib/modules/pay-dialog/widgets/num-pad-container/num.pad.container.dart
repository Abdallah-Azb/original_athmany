import 'package:app/modules/pay-dialog/widgets/widgets.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';

import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:provider/provider.dart';

class NumPadContainer extends StatefulWidget {
  final double totalAfterDiscount;
  final int isReturn;
  const NumPadContainer({Key key, this.totalAfterDiscount, this.isReturn})
      : super(key: key);

  @override
  _NumPadContainerState createState() => _NumPadContainerState();
}

class _NumPadContainerState extends State<NumPadContainer> {
  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Container(
        padding:
            EdgeInsets.only(bottom: typeMobile == TYPEMOBILE.TABLET ? 26 : 10),
        color: isDarkMode == false ? Colors.black12 : Color(0xff1F1F1F),
        child: Column(
          children: [
            Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Total(
                    totalAfterDiscount: widget.totalAfterDiscount,
                    isReturn: widget.isReturn),
              ],
            )),
            PayDialogNumPad()
          ],
        ));
  }
}
