

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
      'section': 'Sections',
      'device_name': 'Device name',
      'device_id': 'Device ID',
      'open_in_browser': 'Open in browser',
      'share_via': 'Share via...',
      'use_browser': 'Use browser',
      'auto': 'Auto',
      'not_set': 'Not set',
      'yes': 'Yes',
      'no': 'No',
      'cancel': 'Cancel',
      'set': 'Set',
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
      'section': '论坛板块',
      'device_name': '设备名称',
      'device_id': '设备标识/论坛',
      'open_in_browser': '在浏览器中打开',
      'share_via': '分享到...',
      'use_browser': '使用浏览器',
      'auto': '自动',
      'not_set': '未设置',
      'yes': '是',
      'no': '否',
      'cancel': '取消',
      'set': '设置',
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
