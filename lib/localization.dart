

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'donate': 'Donate',
      'forums': 'Forums',
      'feeds': 'Feeds',
      'device': 'Device',
      'newhot': 'New&Hot',
      'general': 'General',
      'best': 'Best',
      'most_active': 'Most Active Topics',
      'latest': 'Latest',
      'apps': 'Apps',
      'section': 'Sections'
    },
    'zh': {
      'settings': '设置',
      'donate': '捐赠',
      'forums': '论坛',
      'feeds': '新闻',
      'device': '本机',
      'newhot': '最新热帖',
      'general': '通用',
      'best': '优质',
      'most_active': '近期活跃热帖',
      'latest': '最新',
      'apps': '推荐应用',
      'section': '论坛板块'
    },
  };

  Map<String, String> get translate {
    return _localizedValues[locale.languageCode];
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
