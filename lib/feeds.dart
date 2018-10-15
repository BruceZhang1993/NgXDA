import 'package:flutter/material.dart';
import 'package:ngxda/feed/apps.dart';
import 'package:ngxda/feed/best.dart';
import 'package:ngxda/feed/device.dart';
import 'package:ngxda/feed/latest.dart';
import 'package:ngxda/localization.dart';

class Feeds extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new FeedsState();
}

class FeedsState extends State<Feeds> with SingleTickerProviderStateMixin {
  TabController _controller;

  void _tabHandler() {

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
                labelStyle: TextStyle(fontSize: 13.0, fontFamily: 'Poppins'),
                tabs: [
                  Tab(text: AppLocalizations.of(context).translate['device'].toUpperCase()),
                  Tab(text: AppLocalizations.of(context).translate['latest'].toUpperCase()),
                  Tab(text: AppLocalizations.of(context).translate['best'].toUpperCase()),
                  Tab(text: AppLocalizations.of(context).translate['apps'].toUpperCase()),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _controller,
            children: [
              new DeviceFeeds(),
              new LatestFeeds(),
              new BestFeeds(),
              new Apps(),
            ],
          ),
        ));
  }
}
