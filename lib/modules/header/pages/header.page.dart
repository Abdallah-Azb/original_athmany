import 'dart:async';

import 'package:app/core/enums/type_mobile.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/localization/localization.dart';
import 'package:app/models/models.dart';
import 'package:app/modules/auth/auth.dart';
import 'package:app/modules/header/widgets/opening.header.data.dart';
import 'package:app/modules/header/widgets/search.item.dart';
import 'package:app/modules/header/widgets/settings_dropdown.dart';
import 'package:app/modules/invoice/repositories/invoice.repository.refactor.dart';
import 'package:app/modules/opening/opening.dart';
import 'package:app/modules/opening/repositories/opening.repository.refactor.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/services/auth.service.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:app/widget/svgImage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:data_connection_checker_tv/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../res.dart';
import '../header.dart';
import '../widgets/sync.data.dialog.dart';
import '../../../core/extensions/widget_extension.dart';

class Header extends StatelessWidget {
  final ProfileDetails posProfileDetails;
  final User user;
  final OpeningDetails openingDetails;
  final Function setClosingData;
  final Function updatePageLoadingValue;
  GlobalKey<ScaffoldState> keyScaffold;
  Header({
    Key key,
    this.posProfileDetails,
    this.user,
    this.openingDetails,
    this.setClosingData,
    this.updatePageLoadingValue,
    this.keyScaffold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _HeaderPage(
      posProfileDetails: posProfileDetails,
      user: user,
      openingDetails: openingDetails,
      setClosingData: setClosingData,
      updatePageLoadingValue: updatePageLoadingValue,
    );
  }
}

class _HeaderPage extends StatefulWidget {
  final ProfileDetails posProfileDetails;
  final User user;
  final OpeningDetails openingDetails;
  final Function setClosingData;
  final Function updatePageLoadingValue;

  _HeaderPage(
      {Key key,
      this.posProfileDetails,
      this.user,
      this.openingDetails,
      this.setClosingData,
      this.updatePageLoadingValue})
      : super(key: key);

  @override
  _HeaderPageState createState() => _HeaderPageState();
}

class _HeaderPageState extends State<_HeaderPage> {
  Color _statusColor;
  Timer checkNotSyncedInvoicesTimer;

  @override
  void initState() {
    super.initState();
    print("HEADER ###########");
    timer();
    _internetConnectionStream();
  }

  timer() {
    checkNotSyncedInvoicesTimer = Timer.periodic(
        Duration(seconds: 2), (Timer t) => _internetConnectionStream());
  }

  bool hasConnection;

  StreamSubscription<ConnectivityResult> _streamSubscription;
  Future<void> _internetConnectionStream() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    _toggleStatusColor(connectivityResult);
    _streamSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      _toggleStatusColor(result);
    });
  }

  void _toggleStatusColor(ConnectivityResult result) {
    setState(() {
      _statusColor =
          result != ConnectivityResult.none ? themeColor : Colors.red;
    });
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TYPEMOBILE typeMobile =
        Provider.of<TypeMobileProvider>(context, listen: false).TypePhone;
    bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return typeMobile == TYPEMOBILE.MOBILE
        // MOBILE
        ? AppBar(
            backgroundColor: appBarColor,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SettingsDropdown(),
                SizedBox(
                  width: 15,
                ),
                Container(
                  height: 40,
                  width: 40,
                  child: SvgImage(
                    path: Res.logoSvg,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                internetIndicator(),
                SizedBox(
                  width: 5,
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              Row(
                children: [
                  // todo back to original code => tolba
                  UserDropdown(
                    fullName: widget.user.fullName,
                    updatePageLoading: widget.updatePageLoadingValue,
                  ),
                  IconButton(
                    icon: Icon(Icons.sync, color: Colors.white),
                    onPressed: () {
                      syncConfirmDialog();
                    },
                  ),
                  // SizedBox(width: 10),

                  // Container(
                  //   height: 20,
                  //   width: 20,
                  //   decoration: BoxDecoration(
                  //     color: onLine,
                  //     borderRadius: BorderRadius.circular(100),
                  //   ),
                  // ),
                ],
              ),
            ],
          )
        // TABLET
        : Container(
            width: double.infinity,
            color: isDarkMode == false ? mainBlueColor : Color(0xff1F1F1F),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          internetIndicator(),
                          OpeningHeaderData(
                            profileName: widget.posProfileDetails.name,
                            openingDetailsName: widget.openingDetails.name,
                          ),
                          SizedBox(width: 100),
                        ],
                      ),
                      // SearchItem(),
                      Row(
                        children: [
                          SettingsDropdown(),
                          SizedBox(
                            width: 40,
                          ),
                          IconButton(
                            icon: Icon(Icons.sync, color: Colors.white),
                            onPressed: () {
                              syncConfirmDialog();
                            },
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Language(),
                          SizedBox(width: 30),
                          UserDropdown(
                            fullName: widget.user.fullName,
                            updatePageLoading: widget.updatePageLoadingValue,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SearchItem(),
                ],
              ),
            ).paddingAll(10),
          );
  }

  // syncConfirmDialog() async {
  //   List<bool> result = await showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (context) => SyncConfirmDialog());
  //   if (result[0] == true) {
  //     widget.updatePageLoadingValue(true);
  //     try {
  //       await OpeningRepositoryRefactor().syncOpening();
  //     } on Failure catch (e) {
  //       toast(e.toString(), Colors.red);
  //     } finally {
  //       widget.updatePageLoadingValue(false);
  //     }
  //   }
  // }

  // show sync confirm dialog
  syncConfirmDialog() async {
    List<bool> result = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => SyncConfirmDialog());
    if (result[0] == true) {
      // widget.updatePageLoadingValue(true);
      await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => SyncDataDialog(
                cachItmesImages: result[1],
              ));
      // widget.updatePageLoadingValue(false);

      // try {
      //   await OpeningRepositoryRefactor()
      //       .syncOpening(cachItmesImages: result[1]);
      //   Phoenix.rebirth(context);
      // } on Failure catch (e) {
      //   toast(e.toString(), Colors.red);
      // } finally {
      //   widget.updatePageLoadingValue(false);
      // }
    }
    // .then((value) async => {
    //       if (value == true)
    //         await context.read<HeaderProvider>().syncWithBackend(
    //               context,
    //               widget.updatePageLoadingValue,
    //             )
    //     });
  }

  // language
  Widget language() {
    return InkWell(
      child: Localization.of(context).locale == Locale('ar', 'SA')
          ? english()
          : arabic(),
      onTap: () {
        // ? MyApp.setLocale(context, Locale('en', 'US'))
        print("💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰💰");
        Localization.of(context).locale == Locale('ar', 'SA')
            ? HeaderProvider().setLocale(context, Locale('en', 'US'), "en")
            : HeaderProvider().setLocale(context, Locale('ar', 'SA'), "ar");
        Phoenix.rebirth(context);
      },
    );
  }

  // Arabic
  Widget arabic() {
    return Row(children: [
      Text('عربي', style: TextStyle(color: Colors.white, fontSize: 16)),
      SizedBox(width: 20),
      Image.asset(
        'assets/ksa.png',
        height: 20,
      ),
    ]);
  }

  // English
  Widget english() {
    return Row(children: [
      Text('English', style: TextStyle(color: Colors.white, fontSize: 16)),
      SizedBox(width: 10),
      Image.asset(
        'assets/usa.png',
        height: 20,
      ),
    ]);
  }

  // internect connection indicator
  Widget internetIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
    );
  }
}
