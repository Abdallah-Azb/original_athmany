import 'package:app/localization/localization.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../res.dart';
import '../header.dart';

class UserDropdown extends StatelessWidget {
  final Function updatePageLoading;
  final String fullName;

  const UserDropdown({
    Key key,
    this.fullName,
    this.updatePageLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Container(
      child: PopupMenuButton<String>(
        offset: Offset(0, -50),
        child: typeMobile == TYPEMOBILE.TABLET
            ? Row(
                children: [
                  // merge ix , why add container as parent ?
                  Container(
                    width: 60,
                    child: Text(
                      fullName,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: typeMobile == TYPEMOBILE.TABLET ? 15 : 12.5,
                      ),
                    ),
                  ),
                  SizedBox(width: 24.0),
                  Icon(Icons.arrow_drop_down_sharp, color: Colors.white),
                ],
              )
            // mobile
            : Row(
                children: [
                  SizedBox(width: 15.0),
                  Icon(
                    Icons.arrow_drop_down_sharp,
                    color: Colors.white,
                  ),
                ],
              ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        onSelected: (String selected) async {
          if (selected == "Signout") {
            updatePageLoading(true);
            try {
              await context.read<HeaderProvider>().confirmSignout(context);
              updatePageLoading(false);
            } catch (_) {
              updatePageLoading(false);
            }
          }
          if (selected == "Closing") {
            await context.read<HeaderProvider>().syncInvoices(context);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            height: typeMobile == TYPEMOBILE.TABLET ? 0 : 48,
            child: typeMobile == TYPEMOBILE.TABLET
                ? null
                : typeMobile == TYPEMOBILE.TABLET
                    ? SizedBox()
                    : popupMenuItem(
                        '$fullName',
                        Res.user,
                        context,
                      ),
            textStyle: TextStyle(
              fontSize: 16,
              fontFamily: 'Cairo',
              color: Colors.grey,
            ),
            value: "Name",
          ),
          typeMobile == TYPEMOBILE.TABLET
              ? null
              : PopupMenuItem(
                  enabled: false,
                  height: 3,
                  child: Divider(
                    height: 1,
                    thickness: 2,
                    color: Colors.black12,
                  ),
                ),
          PopupMenuItem<String>(
            child: popupMenuItem(
              Localization.of(context).tr('close_sales_point'),
              Res.flag,
              context,
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontFamily: 'Cairo',
              color: isDarkMode == false ? Colors.black87 : Colors.white,
            ),
            value: "Closing",
          ),
          PopupMenuItem(
            enabled: false,
            height: 3,
            child: Divider(
              height: 1,
              thickness: 2,
              color: Colors.black12,
            ),
          ),
          PopupMenuItem<String>(
            child: popupMenuItem(
              Localization.of(context).tr('signout'),
              Res.sign_out_option,
              context,
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontFamily: 'Cairo',
              color: isDarkMode == false ? Colors.black87 : Colors.white,
            ),
            value: "Signout",
          ),
        ],
      ),
    );
  }

  Row popupMenuItem(String title, String icon, context) {
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Row(
      children: [
        Image.asset(
          icon,
          width: 20,
          color: isDarkMode == false ? Colors.black87 : Colors.white,
        ),
        SizedBox(width: 10.0),
        Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}
