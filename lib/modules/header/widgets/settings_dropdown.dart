import 'package:app/main.dart';
import 'package:app/modules/accessories/accessories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:app/core/enums/type_mobile.dart';
import 'package:app/localization/localization.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';

import '../../../res.dart';
import '../../../core/extensions/widget_extension.dart';
class SettingsDropdown extends StatelessWidget {
  final String fullName;
  final VoidCallback onClosing;

  const SettingsDropdown({
    Key key,
    this.fullName,
    this.onClosing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    return typeMobile == TYPEMOBILE.TABLET
        ? Container(
            child: PopupMenuButton<String>(
              child: Image.asset(Res.settings),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              onSelected: (String selected) async {
                if (selected == "ar-sa") {
                  MyApp.setLocale(
                    context,
                    Locale("ar", "SA"),
                  );
                  Phoenix.rebirth(context);
                }

                if (selected == "en-us") {
                  MyApp.setLocale(
                    context,
                    Locale("en", "US"),
                  );
                  Phoenix.rebirth(context);
                }

                if (selected == "General") {}

                if (selected == "Devices") {
                  showAnimatedDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AccessoryDialog();
                      },
                      animationType: DialogTransitionType.slideFromTop,
                      curve: Curves.ease,
                      duration: Duration(milliseconds: 400),
                      barrierDismissible: true);
                  // showDialog(
                  //     barrierDismissible: false,
                  //     useSafeArea: false,
                  //     context: context,
                  //     builder: (context) => AccessoryDialog());
                }
                // if (selected == "Devices") {
                //   await context.read<HeaderProvider>().syncWithBackend(
                //         context,
                //         widget.updatePageLoadingValue,
                //       );
                // }
              },
              itemBuilder: (context) => [
                // PopupMenuItem<String>(
                //   child: popupMenuItem('General', "assets/icons/sign-out-option.png"),
                //   textStyle: Theme.of(context).textTheme.headline6,
                //   value: "General",
                // ),
                // PopupMenuItem(
                //   enabled: false,
                //   height: 5,
                //   child: Divider(
                //     height: 1,
                //     thickness: 2,
                //     color: Colors.black12,
                //   ),
                // ),
                PopupMenuItem<String>(
                  child: popupMenuItem(
                      "Devices", "assets/icons/sign-out-option.png", context),
                  textStyle: Theme.of(context).textTheme.headline6,
                  value: "Devices",
                ),
                // PopupMenuItem(
                //   enabled: false,
                //   height: 5,
                //   child: Divider(
                //     height: 1,
                //     thickness: 2,
                //     color: Colors.black12,
                //   ),
                // ),
                // PopupMenuItem<String>(
                //   child: popupMenuItem("Devices", "assets/icons/sign-out-option.png"),
                //   textStyle: Theme.of(context).textTheme.headline6,
                //   value: "sync",
                // ),
              ],
            ),
          )
        // === Mobile ====
        : Container(
            child: PopupMenuButton<String>(
              child: Image.asset(
                Res.settings,
                width: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              onSelected: (String selected) async {
                if (selected == "ar-sa") {
                  MyApp.setLocale(
                    context,
                    Locale("ar", "SA"),
                  );
                  Phoenix.rebirth(context);
                }

                if (selected == "en-us") {
                  MyApp.setLocale(
                    context,
                    Locale("en", "US"),
                  );
                  Phoenix.rebirth(context);
                }

                if (selected == "General") {}

                if (selected == "Devices") {
                  showDialog(
                      context: context,
                      builder: (context) => AccessoryDialog());
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  height: 30,
                  child: popupMenuItem("Devices", Res.sign_out_option, context),
                  textStyle: Theme.of(context).textTheme.headline6,
                  value: "Devices",
                ),
              ],
            ).paddingHorizontally(10),
          );
  }

  Row popupMenuItem(String title, String icon, context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return typeMobile == TYPEMOBILE.TABLET
        ? Row(
            children: [
              Image.asset(
                icon,
                width: 24,
                color: isDarkMode == false ? Colors.black87 : Colors.white,
              ),
              SizedBox(width: 10.0),
              Text(
                title,
                style: TextStyle(
                  color: isDarkMode == false ? Colors.black : Colors.white,
                ),
              ),
            ],
          )
        // === Mobile ==
        : Row(
            children: [
              Image.asset(
                icon,
                width: 18,
                color: isDarkMode == false ? Colors.black87 : Colors.white,
              ),
              SizedBox(width: 4.0),
              Text(
                Localization.of(context).tr('devices'),
                style: TextStyle(
                  color: isDarkMode == false ? Colors.black : Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          );
  }
}
