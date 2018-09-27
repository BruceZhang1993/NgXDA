import 'package:flutter/material.dart';
import 'package:ngxda/feed/best.dart';
import 'package:ngxda/feed/latest.dart';

class Feeds extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new FeedsState();
}

class FeedsState extends State<Feeds> with SingleTickerProviderStateMixin {
  TabController _controller;

  void _tabHandler() {
//    Scaffold.of(context).hideCurrentSnackBar();
//    Scaffold.of(context).showSnackBar(new SnackBar(
//      duration: Duration(seconds: 1),
//      content: new Text(
//          'You switched to index ' + _controller.index.toString() + '.')));
  }

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 4, vsync: this);
    _controller.addListener(_tabHandler);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 4,
        child: new Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(45.0),
            child: AppBar(
              elevation: 1.5,
              title: TabBar(
                controller: _controller,
                labelStyle: TextStyle(fontSize: 14.0, fontFamily: 'Poppins'),
                tabs: [
                  Tab(text: 'LATEST'),
                  Tab(text: 'BEST'),
                  Tab(text: 'TAGS'),
                  Tab(text: 'APPS'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _controller,
            children: [
              new LatestFeeds(),
              new BestFeeds(),
              Icon(Icons.directions_bike),
              Icon(Icons.directions_bike),
            ],
          ),
        ));
  }
}
