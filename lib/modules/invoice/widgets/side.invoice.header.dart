import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SideInvoiceHeader extends StatefulWidget {
  @override
  State<SideInvoiceHeader> createState() => _SideInvoiceHeaderState();
}

class _SideInvoiceHeaderState extends State<SideInvoiceHeader> {
  @override
  Widget build(BuildContext context) {
    return invoiceHeader();
  }

  Widget invoiceHeader() {
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Builder(
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(top: 4, bottom: 4),
          color: isDarkMode == false ? mainBlueColor : Color(0xff1F1F1F),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                      Localization.of(context).tr('item')
                      // getTranslated(context, 'item')
                      ,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ))),
              Expanded(
                  child: Text(
                      Localization.of(context).tr('qty')
                      // getTranslated(context, 'qty')
                      ,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ))),
              Expanded(
                  child: Text(
                      Localization.of(context).tr('price')
                      // getTranslated(context, 'price')
                      ,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ))),
            ],
          ),
        );
      },
    );
  }
}
