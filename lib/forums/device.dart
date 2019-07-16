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
  List<MostActiveThread> actives = [];
  Map<SectionMeta, List<ThreadMeta>> entries = {};
  http.Client client;
  SharedPreferences prefs;
  String deviceid = 'oneplus-6';

  List<Tab> tabs = <Tab>[
    Tab(text: 'Overview'),
  ];

  @override
  void initState() {
    super.initState();
    client = http.Client();
    SharedPreferences.getInstance().then((pref) {
      this.prefs = pref;
      this.fetchPage();
    });
  }

  @override
  void dispose() {
    super.dispose();
    client.close();
  }

  void fetchPage() {
    setState(() {
      String did = this.prefs.getString('deviceid');
      if (did != null && did.isNotEmpty) {
        deviceid = did.trim();
      }
    });
    if (deviceid.isNotEmpty) {
      String uri = 'https://forum.xda-developers.com/' + deviceid;
      client.get(uri).then((http.Response response) {
        var document = parse(response.body);
        // Most active threads
        List<MostActiveThread> newlist = [];
        var elements = document.querySelectorAll(
            '.topRankedThreadsForumDisplayCategory ul li .rankedThread');
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
        Map<SectionMeta, List<ThreadMeta>> tmp_entries = {};
        elements = document.querySelectorAll('.forum-childforum .forumbox.box-shadow');
        for (var element in elements) {
          var captionElement = element.querySelector('a.flink');
          SectionMeta meta = new SectionMeta(
              captionElement.text.trim(),
              'https://forum.xda-developers.com' + captionElement.attributes['href']
          );
          List<ThreadMeta> tmpThreads = [];
          var elements2 = element.querySelectorAll('.thread-row.thread-row-unread');
          for (var element2 in elements2) {
            ThreadMeta meta2 = new ThreadMeta(
              element2.querySelector('.thread-title-cell a').text.trim(),
              element2.querySelector('.time-cell').text.trim(),
              element2.querySelector('.reply-cell').text.trim(),
              element2.querySelector('.count-cell').text.trim(),
              'https://forum.xda-developers.com' + element2.querySelector('.threadTitle').attributes['href'],
            );
            tmpThreads.add(meta2);
          }
          tmp_entries[meta] = tmpThreads;
        }
        setState(() {
          actives = newlist;
          entries = tmp_entries;
        });
      });
    }
  }

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
    return new ListView(
      shrinkWrap: true,
      children: <Widget>[
        new Container(
          child: Text(AppLocalizations.of(context).translate['most_active'],
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500
            ),
          ),
          padding: EdgeInsets.symmetric(vertical:10.0),
          alignment: Alignment.center,
        ),
        Column(
          children: List.generate(actives.length, (index) {
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
                            vertical: 2.0, horizontal: 6.0),
                        leading: new Hero(
                            tag: actives[index].link,
                            child: FadeInImage.memoryNetwork(
                              placeholder: kTransparentImage,
                              image: 'https:' + actives[index].image,
                              height: 65.0,
                            )),
                        title: new Text(
                          actives[index].title,
                          style: TextStyle(
                              height: 1.2,
                              fontWeight: FontWeight.w400, fontSize: 13.5),
                        ),
                        subtitle: new Text(
                          actives[index].author,
                          style: TextStyle(
                              height: 1.2,
                              fontWeight: FontWeight.w300, fontSize: 12.0),
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
          }),
        ),
        Column(
          children: List.generate(entries.length, (index) {
            return new GestureDetector(
                onTap: () {
                  _launchUrl2(entries.keys.elementAt(index).link, context);
                },
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: Text(entries.keys.elementAt(index).title,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical:10.0),
                      alignment: Alignment.center,
                    ),
                    Column(
                      children: List.generate(entries.values.elementAt(index).length, (i) {
                        ThreadMeta meta = entries.values.elementAt(index)[i];
                        return new GestureDetector(
                          onTap: () {
                            _launchUrl2(meta.link, context);
                          },
                          child: new Card(
                            elevation: 0.4,
                            child: new Column(
                              children: <Widget>[
                                new ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 12.0),
                                    title: new Text(
                                      meta.title,
                                      style: TextStyle(
                                          height: 0.8,
                                          fontWeight: FontWeight.w400, fontSize: 14.0),
                                    ),
                                ),
                                new Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 2.0, horizontal: 12.0),
                                    child: new Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        new Icon(Icons.reply_all,
                                          color: Colors.blueGrey,
                                          size: 18.0,
                                        ),
                                        new Text(
                                          ' ' + meta.replies + '    ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13.0,
                                              color: Colors.blueGrey),
                                          textAlign: TextAlign.left,
                                        ),
                                        new Icon(Icons.remove_red_eye,
                                          color: Colors.blueGrey,
                                          size: 18.0,
                                        ),
                                        new Text(
                                          ' ' + meta.reviews + '    ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13.0,
                                              color: Colors.blueGrey),
                                          textAlign: TextAlign.left,
                                        ),
                                        new Text(
                                          meta.time,
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
                      }),
                    ),
                  ],
                )
            );
          }),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
