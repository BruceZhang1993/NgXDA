import 'package:flutter/material.dart';
import 'package:ngxda/forums/device.dart';
import 'package:ngxda/localization.dart';

class Forums extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new ForumsState();
}

class ForumsState extends State<Forums> with SingleTickerProviderStateMixin {
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
                  Tab(text: AppLocalizations.of(context).translate['newhot'].toUpperCase()),
                  Tab(text: AppLocalizations.of(context).translate['general'].toUpperCase()),
                  Tab(text: AppLocalizations.of(context).translate['best'].toUpperCase()),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _controller,
            children: [
              DeviceForums(),
              Container(),
              Container(),
              Container(),
            ],
          ),
        ));
  }
}
