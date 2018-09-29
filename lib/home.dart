import 'package:flutter/material.dart';
import 'package:ngxda/donate.dart';
import 'package:ngxda/feeds.dart';
import 'package:device_info/device_info.dart';
import 'package:ngxda/forums.dart';
import 'package:ngxda/settings.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeState();
}

class HomeState extends State<HomePage> {
  var current = 'feeds';
  DeviceInfoPlugin deviceInfo;
  AndroidDeviceInfo androidInfo;

  Map<String, Widget> pages = new Map();

  @override
  void initState() {
    super.initState();
    deviceInfo = new DeviceInfoPlugin();
    deviceInfo.androidInfo.then((value) {
      setState(() {
        androidInfo = value;
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
          pages[current] = new Settings();
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
    if (androidInfo == null) {
      label = 'Make XDA great again.';
    } else {
      label = 'Make XDA great again / '+androidInfo.device;
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
                title: new Text('XDA Feeds'),
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
                title: new Text('Forums'),
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
                title: new Text('Settings'),
                onTap: () {
                  setState(() {
                    this.current = 'settings';
                  });
                  Navigator.of(context).pop();
                },
                selected: this.current == 'setings',
              ),
              ListTile(
                key: Key('donate'),
                leading: new Icon(Icons.attach_money),
                title: new Text('Donate'),
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
