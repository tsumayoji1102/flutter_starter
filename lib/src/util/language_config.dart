import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';

AppLocalizations? l10n(BuildContext context) => AppLocalizations.of(context);

class LanguageConfig {
  LanguageConfig._internal();

  static List<Locale> get locales => const [Locale('en'), Locale('ja')];

  static List<LocalizationsDelegate<dynamic>> get localizationDelegates => [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
