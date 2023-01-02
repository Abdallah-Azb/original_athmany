import 'package:app/core/utils/utils.dart';
import 'package:app/providers.dart';
import 'package:app/providers/type_mobile_provider.dart';
import 'package:app/route.generator.dart';
import 'package:app/services/services.dart';
import 'package:app/widget/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'constant.dart';
import 'core/version_check.dart';
import 'localization/localization.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:new_version/new_version.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService().initDatabase();
  await EasyLoading.init();
  navigatorObservers:
  [SentryNavigatorObserver()];
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://d598ef92d21046efaf81ad3b9fce6db2@o1139530.ingest.sentry.io/6195216';
      options.tracesSampleRate = 1.0;
      // options.tracesSampler = ((samplingContext) {});
      options.attachStacktrace = true;
      options.enableAutoSessionTracking = true;
      options.reportSilentFlutterErrors = true;
    },
    appRunner: () => runApp(Phoenix(child: MyApp())),
  );
  // WidgetsFlutterBinding.ensureInitialized();
  // await DBService().initDatabase();
  // runApp(Phoenix(child: MyApp()));
  //
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale locale) {
    MyAppState state = context.findAncestorStateOfType<MyAppState>();
    state.setAndSaveLocale(locale);
  }

  @override
  MyAppState createState() => MyAppState();
}

// theme data
// ThemeData themeData = ThemeData(
//     fontFamily: 'Cairo', primaryColor: themeColor, accentColor: themeColor);

class MyAppState extends State<MyApp> {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  Locale _locale;

  bool newVersionAvailable = false;
  String shouldUpdateVersion;
  NewVersion newVersion;
  _clearCache() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setStringList('invoice_id', []);
    // sharedPreferences.remove('invoice_id');
  }

  void setAndSaveLocale(Locale locale) async {
    if (locale == _locale) return;

    await Preference.setItem('lang', locale.languageCode);

    setState(() {
      _locale = locale;
    });
  }

  static const String title = 'Light & Dark Theme';
  @override
  void initState() {
    _clearCache();
    super.initState();
    newVersion = NewVersion(
      iOSId: appId,
      androidId: appId,
      iOSAppStoreCountry: 'SA',
      // this should came from api to specify force app version
      // forceAppVersion: shouldUpdateVersion
    );

    _updateDialog();
  }

  void _updateDialog() {
    newVersion.showAlertIfNecessary(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: Providers().providers,
      child: FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            Provider.of<TypeMobileProvider>(context, listen: false)
                .getDeviceType();
            final themeProvider = Provider.of<ThemeProvider>(context);
            if (snapshot.hasData) {
              return MaterialApp(
                navigatorKey: navigatorKey,
                supportedLocales: [
                  Locale("en", "US"),
                  Locale("ar", "SA"),
                ],
                localizationsDelegates: [
                  Localization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                localeResolutionCallback:
                    (Locale deviceLocale, Iterable<Locale> supportedLocales) {
                  var lang = snapshot.data.get('lang');

                  if (lang != null && lang == 'en') {
                    return Locale('en', 'US');
                  } else if (lang == 'ar') {
                    return Locale('ar', 'SA');
                  }

                  for (var locale in supportedLocales) {
                    if (locale.languageCode == deviceLocale.languageCode &&
                        locale.countryCode == deviceLocale.countryCode) {
                      return deviceLocale;
                    }
                  }

                  return supportedLocales.first;
                },
                debugShowCheckedModeBanner: false,
                navigatorObservers: [],
                initialRoute: '/',
                onGenerateRoute: RouteGenerator.generateRoute,
                theme: MyThemes.lightTheme,
                themeMode: themeProvider.themeMode,
                darkTheme: MyThemes.darkTheme,
              );
            }

            return Container();
          }),
    );
  }

}
