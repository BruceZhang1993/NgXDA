import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:ngxda/localization.dart';
import 'package:ngxda/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart' as u;

class DeviceForums extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new DeviceState();
}

class DeviceState extends State<DeviceForums>
    with AutomaticKeepAliveClientMixin {
  String deviceid = 'oneplus-6';
  List<MostActiveThread> actives = [];
  http.Client client;

  @override
  void initState() {
    super.initState();
    client = http.Client();
    fetchPage();
  }

  @override
  void dispose() {
    super.dispose();
    client.close();
  }

  void fetchPage() {
    if (deviceid != null && deviceid != '') {
      String uri = 'https://forum.xda-developers.com/' + deviceid;
      client.get(uri).then((http.Response response) {
        var document = parse(response.body);
        // Most active threads
        List<MostActiveThread> newlist = [];
        var elements = document.querySelectorAll(
            '.topRankedThreadsForumDisplayCategory ul li .rankedThread');
        print(elements.length);
        for (var element in elements) {
          MostActiveThread thread = new MostActiveThread(
            element.querySelector('.rankedTitleLink').text.trim(),
            element.querySelector('.rankedDate').text.trim(),
            element.querySelector('.rankedAuthor a').text.trim(),
            element.querySelector('.rankedViews').text.trim(),
            'https://forum.xda-developers.com' +
                element.querySelector('.rankedTitleLink').attributes['href'],
            element.querySelector('.rankedThumb').attributes['src'],
          );
          newlist.add(thread);
        }
        setState(() {
          actives = newlist;
        });
      });
    }
  }

//  _launchUrl(url) async {
//    if (await canLaunch(url)) {
//      await launch(url, forceWebView: true);
//    } else {
//      Scaffold.of(context).hideCurrentSnackBar();
//      Scaffold.of(context).showSnackBar(new SnackBar(
//        content: new Text('Cannot launch browser.'),
//        duration: Duration(seconds: 2)
//      ));
//    }
//  }

  _launchUrl2(url, context) async {
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

  _launchUrl(Post post) {
    String browser = '';
    if (browser != null && browser.toLowerCase() == 'yes') {
      _launchUrl2(post.link, context);
    } else {
//      Navigator.of(context).push(new CupertinoPageRoute(
//          maintainState: true,
//          builder: (context) => new PostPage(post: post)
//      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Container(
          child: Text(AppLocalizations.of(context).translate['most_active'],
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500
            ),
          ),
          padding: EdgeInsets.symmetric(vertical:6.0)
        ),
        Expanded(
          child: ListView.builder(
              itemBuilder: (context, index) {
                return new GestureDetector(
                  onTap: () {
                    _launchUrl2(actives[index].link, context);
                  },
                  child: new Card(
                    elevation: 0.4,
                    child: new Column(
                      children: <Widget>[
                        new ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 6.0),
                            leading: new Hero(
                                tag: actives[index].link,
                                child: FadeInImage.memoryNetwork(
                                  placeholder: kTransparentImage,
                                  image: 'https:' + actives[index].image,
                                  height: 90.0,
                                )),
                            title: new Text(
                              actives[index].title,
                              style: TextStyle(
                                height: 1.2,
                                  fontWeight: FontWeight.w400, fontSize: 15.0),
                            ),
                            subtitle: new Text(
                              actives[index].author,
                              style: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 13.0),
                            )),
                        new Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 12.0),
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                new Icon(Icons.people,
                                  color: Colors.blueGrey,
                                  size: 18.0,
                                ),
                                new Text(
                                  ' ' + actives[index].heat + '    ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13.0,
                                      color: Colors.blueGrey),
                                  textAlign: TextAlign.left,
                                ),
                                new Text(
                                  actives[index].date,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 13.0,
                                      color: Colors.blueGrey),
                                  textAlign: TextAlign.right,
                                )
                              ],
                            ))
                      ],
                    ),
                  ),
                );
              },
              itemCount: actives.length),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
