import 'package:flutter/material.dart';
import 'package:ngxda/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ngxda/localization.dart';

void main() => runApp(new Main());

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('zh', 'CN'), // Simplified Chinese
      ],
      debugShowCheckedModeBanner: false,
      title: 'ngXDA',
      theme: new ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: new HomePage(),
    );
  }
}
