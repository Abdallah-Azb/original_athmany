// ignore_for_file: must_be_immutable

import 'package:app/localization/localization.dart';
import 'package:app/modules/auth/repositories/auth.repository.refactor.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:app/widget/widget/change_theme_button.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../../core/enums/type_mobile.dart';
import '../../../core/utils/const.dart';
import '../../../providers/type_mobile_provider.dart';
import '../../../widget/widget/loading_animation_widget.dart';
import '../provider/login.provider.dart';
import '../widgets/logo.login.dart';
import '../widgets/phone_otp.dart';
import '../../../core/extensions/widget_extension.dart';

class OtpPage extends StatefulWidget {
  var dataOTP;

  var username;

  var accountNumber;

  OtpPage({Key key, this.dataOTP, this.username, this.accountNumber})
      : super(key: key);

  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode == true;
    return ChangeNotifierProvider<LoginProvider>(
      create: (context) => LoginProvider(),
      child: Consumer<LoginProvider>(
        builder: (context, model, child) {
          LoginProvider loginProvider = context.watch<LoginProvider>();

          return LoadingOverlay(
            opacity: 0.3,
            color: themeColor,
            isLoading: model.loadingOTP,
            progressIndicator: LoadingAnimation(
              typeOfAnimation: "staggeredDotsWave",
              color: themeColor,
              size: 100,
            ),
            child: Scaffold(
              body: Container(
                alignment: Alignment.center,
                child: Container(
                  width: typeMobile == TYPEMOBILE.TABLET ? 600 : 300,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Align(
                          alignment: AlignmentDirectional.topEnd,
                          child: ThemeButton()).paddingAllNormal(),

                      Logo(),

                      Text(
                        '${Localization.of(context).tr('otp_number') + ' : ' + method} ',
                        // " ADDRESS METHOD : " + method,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ).paddingAllNormal(),
                      OtpNumber(),
                      SizedBox(
                        height: 10,
                      ),
                      // Submit(),
                      InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              color: loginProvider.otpNumber == null
                                  ? isDarkMode
                                      ? Colors.white12
                                      : Colors.black38
                                  : themeColor,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: 56,
                          child: Text(
                            Localization.of(context).tr('login'),
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontFamily: 'CairoBold',
                            ),
                          ),
                        ),
                        onTap: () async {
                          try {
                            model.setLoadingValueOTP(true);

                            await AuthRepositoryRefactor().loginOTP(
                                int.parse(loginProvider.otpNumber.toString()),
                                widget.dataOTP['tmp_id'],
                                widget.username,
                                widget.accountNumber);
                            model.setLoadingValueOTP(false);

                            Navigator.pushNamed(
                              context,
                              '/opening-list',
                            );
                          } catch (e) {
                            model.setLoadingValueOTP(false);
                          }
                        },
                      ),
                      Text(
                        prompt ?? "",
                        textAlign: TextAlign.center,
                      ).paddingAllNormal(),
                      SizedBox(
                        height: typeMobile == TYPEMOBILE.TABLET ? 0 : 80,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setData();
  }

  var prompt;

  var method;

  setData() {
    setState(() {
      prompt = widget.dataOTP['verification']['prompt'];
      method = widget.dataOTP['verification']['method'];
    });
  }
}
