import 'package:app/core/utils/const.dart';
import 'package:app/core/version_check.dart';
import 'package:app/modules/auth/auth.dart';
import 'package:app/modules/auth/widgets/widgets.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:app/widget/widget/change_theme_button.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/type_mobile.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../widget/widget/loading_animation_widget.dart';
import '../widgets/version_number.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    VersionCheck.checkForNewVersion(context);
    super.didChangeDependencies();
  }

  String versionNumber = '';
  checkPlatformVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    versionNumber = packageInfo.version;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkPlatformVersion();
  }

  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return ChangeNotifierProvider<LoginProvider>(
      create: (context) => LoginProvider(),
      child: Consumer<LoginProvider>(
        builder: (context, model, child) => LoadingOverlay(
          opacity: 0.3,
          color: themeColor,
          isLoading: model.loading,
          progressIndicator: LoadingAnimation(
            typeOfAnimation: "staggeredDotsWave",
            color: themeColor,
            size: 100,
          ),
          child: Scaffold(
            body: Container(
              color: isDarkMode == false ? Colors.white30 : appBarColor,
              alignment: Alignment.center,
              child: Container(
                width: typeMobile == TYPEMOBILE.TABLET ? 600 : 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListView(
                      shrinkWrap: true,
                      children: [
                        Row(
                          children: [
                            SelectLanguage(),
                            Expanded(child: SizedBox()),
                            ThemeButton(),
                          ],
                        ),
                        Logo(),
                        AccountNumberTextField(),
                        UserNameTextField(),
                        PasswordTextField(),
                        const SizedBox(
                          height: 5,
                        ),
                        Submit(),
                        // Subscribe()
                      ],
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    versionNumber.isNotEmpty
                        ? VersionNumber(versionNumber: versionNumber)
                        : SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
