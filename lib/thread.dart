import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:ngxda/localization.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ngxda/models.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:share/share.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:url_launcher/url_launcher.dart' as u;

class ThreadPage extends StatefulWidget {
  final ThreadMeta meta;

  const ThreadPage({Key key, this.meta}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new ThreadState(meta);
}

class ThreadState extends State<ThreadPage> {
  final ThreadMeta meta;
  Thread thread;
  http.Client client;
  var opacityValue = 0.0;

  List<Choice> choices = <Choice> [
    Choice(title: "open_in_browser", icon: Icons.open_in_browser, name: 'browser'),
    Choice(title: "share_via", icon: Icons.share, name: 'share')
  ];

  ThreadState(this.meta);

  @override
  void initState() {
    super.initState();
    client = http.Client();
    this._fetchDetail(this.meta.link);
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }

  void _fetchDetail(uri) {
    setState(() {
      this.opacityValue = 1.0;
    });
    client.get(uri).then((response) {
      // TODO: Finish Thread Content Parsing
      var document = parse(response.body);
      var large_img = document
          .getElementsByClassName('entry_media')[0]
          .getElementsByTagName('img')[0]
          .attributes['src'];
      var content = document.getElementsByClassName('entry_content')[0];
      setState(() {
        this.opacityValue = 0.0;
      });
    });
  }

  Container _buildContent() {
    return new Container(
      margin: new EdgeInsets.only(top: 210.0),
      padding: new EdgeInsets.only(left: 32.0, right: 32.0 , top: 0.0, bottom: 0.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // TODO: Content Cards Here
          new Opacity(opacity: this.opacityValue, child: new Container(
              padding: EdgeInsets.symmetric(vertical: 6.0),
              child: new Image(
                image: new AssetImage('asset/static/loading.gif'),
                width: 35.0,
                height: 35.0,
              )
          ))
        ],
      ),
    );
  }

  Container _buildGradient() {
    return new Container(
      margin: new EdgeInsets.only(top: 182.0),
      height: 80.0,
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          colors: <Color>[new Color(0x00FAFAFA), new Color(0xFFFAFAFA)],
          stops: [0.0, 0.9],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.0),
        ),
      ),
    );
  }

  _launchUrl(url, context) async {
    try {
      await launch(
        url,
        option: new CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,
          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          animation: new CustomTabsAnimation.slideIn(),
          extraCustomTabs: <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],
        ),
      );
    } catch (e) {
      u.launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    for (Choice c in choices) {
      String transText = AppLocalizations.of(context).translate[c.title];
      if (transText != null && transText.isNotEmpty) {
        c.title = transText;
      }
    }
    return new Scaffold(
      appBar: new AppBar(
          actions: <Widget>[
            PopupMenuButton<Choice> (
              itemBuilder: (BuildContext context) {
                return choices.map((choice) {
                  return PopupMenuItem<Choice>(
                      value: choice,
                      child: new ListTile(
                        leading: new Icon(choice.icon,
                          color: new Color(0xFF666666),
                          size: 24.0,
                        ),
                        title: Text(choice.title, style: TextStyle(
                            fontSize: 14.0,
                            color: new Color(0xFF666666)
                        )),
                      )
                  );
                }).toList();
              },
              onSelected: (choice) {
                if (choice.name == 'browser') {
                  _launchUrl(meta.link, context);
                }
                if (choice.name == 'share') {
                  Share.share(meta.title + ' ' + meta.link + ' -- Share from ngXDA.');
                }
              },
            ),
          ],
          elevation: 0.0,
          title: new Container(
              child: new Center(
                child: new Text(
                  'Thread Page',
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0),
                ),
              ))),
      body: new ListView(
        children: <Widget>[
          new Stack(
            children: <Widget>[

            ],
          )
        ],
      ),
    );
  }
}

class Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: new EdgeInsets.symmetric(vertical: 12.0),
        height: 2.0,
        width: 60.0,
        color: new Color(0xff00c6ff));
  }
}
