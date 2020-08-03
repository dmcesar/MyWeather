import 'package:flutter/material.dart';

class AppLocalizations {

  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'MyWeather',
      'today': 'TODAY',
      'tomorrow': 'TOMOROW',
      'overmorrow': 'OVERMORROW',
    },
    'pt': {
      'title': 'MyWeather',
      'today': 'HOJE',
      'tomorrow': 'AMANHÃ',
      'overmorrow': 'DEPAMANHÃ',
    },
  };

  String get title {
    return _localizedValues[locale.languageCode]['title'];
  }

  String get today {
    return _localizedValues[locale.languageCode]['today'];
  }

  String get tomorrow {
    return _localizedValues[locale.languageCode]['tomorrow'];
  }

  String get overmorrow {
    return _localizedValues[locale.languageCode]['overmorrow'];
  }
}