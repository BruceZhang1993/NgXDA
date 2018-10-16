import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:ngxda/post.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ngxda/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart' as u;

class DeviceFeeds extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new DeviceState();
}

class DeviceState extends State<DeviceFeeds> with AutomaticKeepAliveClientMixin {
  int currentPage = 1;
  List<Post> posts = [];
  http.Client client;
  ScrollController scroll;
  bool reachedBottom = false;
  var opacity_value = 0.0;
  DeviceInfoPlugin deviceInfo;
  AndroidDeviceInfo androidInfo;
  SharedPreferences prefs;
  String deviceName = '';

  @override
  void initState() {
    super.initState();
    scroll = new ScrollController();
    scroll.addListener(_scrollHandler);
    client = http.Client();
    deviceInfo = new DeviceInfoPlugin();
    deviceInfo.androidInfo.then((value) {
      setState(() {
        androidInfo = value;
        this.deviceName = androidInfo.device;
      });
      SharedPreferences.getInstance().then((pref) {
        this.prefs = pref;
        this.fetchPage();
      });
    });
  }

  void fetchPage() {
    setState(() {
      String dv = this.prefs.getString('device');
      if (dv != null && dv.isNotEmpty) {
        this.deviceName = dv.trim();
      }
    });
    setState(() {
      this.opacity_value = 1.0;
    });
    String uri = 'https://www.xda-developers.com/search/'+deviceName+'/page/$currentPage/';
    if (currentPage == 1) {
      uri = 'https://www.xda-developers.com/search/'+deviceName;
    }
    print('Fetching $uri');
    currentPage ++;
    client.get(uri).then((response) {
      var document = parse(response.body);
      var posts = document.getElementsByClassName('layout_post_1');
      var new_posts = [];
      for (var post in posts) {
        Post new_post = new Post(
            post.getElementsByTagName('h4')[0].text.trim(),
            post.getElementsByClassName('meta_date')[0].text.trim(),
            post.getElementsByClassName('meta_author')[0].text.trim(),
            post.getElementsByTagName('h4')[0].getElementsByTagName('a')[0].attributes['href'],
            post.getElementsByClassName('thumb_hover')[0].getElementsByTagName('img')[0].attributes['src']
        );
        new_posts.add(new_post);
      }
      setState(() {
        this.opacity_value = 0.0;
        this.posts.addAll(Iterable.castFrom(new_posts));
      });
    });
  }

  @override
  void dispose() {
    scroll.removeListener(_scrollHandler);
    client.close();
    super.dispose();
  }

  void _scrollHandler() {
    if (scroll.position.extentAfter <= 400 && !reachedBottom) {
      reachedBottom = true;
      fetchPage();
    }
    if (scroll.position.extentAfter > 400) {
      reachedBottom = false;
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
    String browser = this.prefs.getString('browser');
    if (browser != null && browser.isNotEmpty && browser.toLowerCase() == 'yes') {
      _launchUrl2(post.link, context);
    } else {
      Navigator.of(context).push(new CupertinoPageRoute(
          maintainState: true,
          builder: (context) => new PostPage(post: post)
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        controller: this.scroll,
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return new Opacity(opacity: this.opacity_value, child: new Container(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: new Image(
                  image: new AssetImage('asset/static/loading.gif'),
                  width: 35.0,
                  height: 35.0,
                )
            ));
          }
          return new GestureDetector(
            onTap: () {
              _launchUrl(posts[index]);
            },
            child: new Card(
              elevation: 0.6,
              child: new Column(
                children: <Widget>[
                  new ListTile(
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      leading: new Hero(tag: posts[index].link, child: FadeInImage.memoryNetwork(placeholder: kTransparentImage,
                        image: posts[index].image,
                        height: 80.0,
                      )),
                      title: new Text(
                        posts[index].title,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16.0),
                      ),
                      subtitle: new Text(
                        posts[index].author,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 14.0),
                      )),
                  new Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          new Text(
                            posts[index].date,
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
        itemCount: posts.length+1);
  }

  @override
  bool get wantKeepAlive => true;
}
