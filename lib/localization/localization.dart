import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Localization {
  final Locale locale;

  Localization(this.locale);

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization);
  }

  Map<String, String> _localizedValues;

  Future load() async {
    String jsonStringValues =
        await rootBundle.loadString('lib/lang/${locale.languageCode}.json');

    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);

    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String tr(String key) {
    return _localizedValues[key];
  }

  Locale get getLocale => locale;

  String getCurrentDirection() {
    return locale.languageCode == 'ar' ? 'rtl' : 'ltr';
  }

  static const LocalizationsDelegate<Localization> delegate =
      _DemoLocalizationDelegate();
}

class _DemoLocalizationDelegate extends LocalizationsDelegate<Localization> {
  const _DemoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<Localization> load(Locale locale) async {
    Localization localizations = new Localization(locale);

    await localizations.load();

    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<Localization> old) => false;
}
