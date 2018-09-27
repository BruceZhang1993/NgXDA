import 'package:flutter/material.dart';
import 'package:ngxda/feeds.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeState();
}

class HomeState extends State<HomePage> {
  var current = 'feeds';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: new Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: new Center(
                  child: new Text('Make XDA great again.',
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
              padding: EdgeInsets.only(right: 55.0),
            )),
        body: new Feeds()
    );
  }
}
