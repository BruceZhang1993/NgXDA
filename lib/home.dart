import 'package:flutter/material.dart';
import 'package:ngxda/donate.dart';
import 'package:ngxda/feeds.dart';
import 'package:device_info/device_info.dart';
import 'package:ngxda/forums.dart';
import 'package:ngxda/localization.dart';
import 'package:ngxda/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeState();
}

class HomeState extends State<HomePage> {
  var current = 'forums';
  DeviceInfoPlugin deviceInfo;
  AndroidDeviceInfo androidInfo;
  String deviceName = '';
  SharedPreferences prefs;

  Map<String, Widget> pages = new Map();

  @override
  void initState() {
    super.initState();
    deviceInfo = new DeviceInfoPlugin();
    deviceInfo.androidInfo.then((value) {
      setState(() {
        androidInfo = value;
        deviceName = androidInfo.device;
      });
    });
    SharedPreferences.getInstance().then((pref) {
      this.prefs = pref;
      setState(() {
        String dv = this.prefs.getString('device');
        if (dv != '' && dv != null) {
          this.deviceName = dv;
        }
      });
    });
  }

  Widget _findPage() {
    if (pages[current] == null) {
      switch (current) {
        case 'feeds':
          pages[current] = new Feeds();
          break;
        case 'forums':
          pages[current] = new Forums();
          break;
        case 'settings':
          pages[current] = new Settings(this);
          break;
        case 'donate':
          pages[current] = new Donate();
          break;
      }
    }
    return pages[current];
  }

  @override
  Widget build(BuildContext context) {
    String label;
    if (deviceName == '' || deviceName == null) {
      label = 'Make XDA great again.';
    } else {
      label = "Make XDA great again  \n\n"+deviceName;
    }
    return new Scaffold(
        drawer: new Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: new Center(
                  child: new Text(label,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                        fontSize: 18.0
                      )),
                ),
                decoration: BoxDecoration(
                  color: Theme
                      .of(context)
                      .primaryColor,
                ),
              ),
              ListTile(
                key: Key('feeds'),
                leading: new Icon(Icons.rss_feed),
                title: new Text(AppLocalizations.of(context).translate['feeds']),
                onTap: () {
                  setState(() {
                    this.current = 'feeds';
                  });
                  Navigator.of(context).pop();
                },
                selected: this.current == 'feeds',
              ),
              ListTile(
                key: Key('forums'),
                leading: new Icon(Icons.forum),
                title: new Text(AppLocalizations.of(context).translate['forums']),
                onTap: () {
                  setState(() {
                    this.current = 'forums';
                  });
                  Navigator.of(context).pop();
                },
                selected: this.current == 'forums',
              ),
              ListTile(
                key: Key('settings'),
                leading: new Icon(Icons.settings),
                title: new Text(AppLocalizations.of(context).translate['settings']),
                onTap: () {
                  setState(() {
                    this.current = 'settings';
                  });
                  Navigator.of(context).pop();
                },
                selected: this.current == 'settings',
              ),
              ListTile(
                key: Key('donate'),
                leading: new Icon(Icons.attach_money),
                title: new Text(AppLocalizations.of(context).translate['donate']),
                onTap: () {
                  setState(() {
                    this.current = 'donate';
                  });
                  Navigator.of(context).pop();
                },
                selected: this.current == 'donate',
              ),
            ],
          ),
        ),
        appBar: new AppBar(
            actions: <Widget>[
              Opacity(opacity: 0.0, child: new GestureDetector(
                child: new Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: new Icon(Icons.search, size: 26.0),
                  margin: EdgeInsets.only(top: 6.0),
                ),
                onTap: () {
                  print('Search Tapped.');
                },
              ))
            ],
            elevation: 0.0,
            title: new Container(
              child: new Center(
                child: new Text(
                  'ngXDA',
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600),
                ),
              ),
            )),
        body: _findPage()
    );
  }
}
