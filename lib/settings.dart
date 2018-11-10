import 'package:flutter/material.dart';
import 'package:ngxda/home.dart';
import 'package:ngxda/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ngxda/models.dart';

class Settings extends StatefulWidget {
  final HomeState parent;
  Settings(this.parent);
  @override
  State<StatefulWidget> createState() => new SettingsState(parent);
}

class SettingsState extends State<Settings> {
  List<SettingItem> items;
  SharedPreferences prefs;
  String currentInput = '';
  HomeState parent;

  SettingsState(this.parent);

  @override
  void initState() {
    super.initState();
    items = [
      new SettingItem('device', 'device_name', '', 'auto', 'Set your device name', null),
      new SettingItem('deviceid', 'device_id', '', 'not_set', 'Your device forum ID', null),
      new SettingItem('browser', 'use_browser', '', 'no', 'Yes/No', ['yes', 'no']),
    ];
    SharedPreferences.getInstance().then((pref) {
      this.prefs = pref;
      for (SettingItem i in items) {
        setState(() {
          i.value = this.prefs.getString(i.id);
        });
      }
    });
  }

  _buildActionSheet(context, index, current, choices) async {
    currentInput = '';
    await showModalBottomSheet(context: context, builder: (_) => new Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(choices.length, (i) {
        return new ListTile(
          leading: new Icon(Icons.music_note),
          title: new Text(''),
          onTap: () => {

          },
        );
      })
    ));
  }

  _buildDialog(context, index, current) async {
    currentInput = '';
    await showDialog<String>(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text(items[index].title),
        content: new TextField(
          autofocus: true,
          decoration: new InputDecoration(
            labelText: items[index].hint,
            hintText: current
          ),
          onChanged: (String text) {
            currentInput = text;
          },
        ),
        actions: <Widget>[
          new FlatButton(onPressed: () {
            Navigator.pop(context);
            currentInput = '';
          }, child: new Text('CANCEL')),
          new FlatButton(onPressed: () {
            Navigator.pop(context);
            prefs.setString(items[index].id, currentInput.trim());
            setState(() {
              items[index].value = currentInput.trim();
            });
            if (items[index].id == 'device') {
              parent.setState((){
                parent.deviceName = currentInput.trim();
                if (currentInput.trim() == '') {
                  parent.deviceName = parent.androidInfo.device;
                }
              });
            }
            currentInput = '';
          }, child: new Text('SET'))
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    for (SettingItem item in items) {
      String transText = AppLocalizations.of(context).translate[item.title];
      if (transText != null && transText.isNotEmpty) {
        item.title = transText;
      }
      String transText2 = AppLocalizations.of(context).translate[item.default_];
      if (transText2 != null && transText2.isNotEmpty) {
        item.default_ = transText2;
      }
    }
    return new Container(
        child: new ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            Text below;
            if (items[index].value == null || items[index].value.length == 0) {
              below = new Text(items[index].default_,
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 14.0,
                  height: 1.6
                ),
              );
            } else {
              below = new Text(items[index].value,
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 14.0,
                  height: 1.6
                ),
              );
            }
            return new DecoratedBox(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 0.5,
                          style: BorderStyle.solid,
                          color: Color(0xFFE0E0E0)
                      )
                  )
              ),
              child: new ListTile(
                  onTap: () {
                    if (items[index].choices == null) {
                      _buildDialog(context, index, below.data);
                    }

                  },
                  contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
                  title: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(items[index].title),
                          below
                        ],
                      )
                    ],
                  )
              ),
            );
          },

        )
    );
  }
}
