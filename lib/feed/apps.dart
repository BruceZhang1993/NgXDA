import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ngxda/models.dart';


class Apps extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AppsState();
}

class AppsState extends State<Apps> with AutomaticKeepAliveClientMixin {
  List<App> apps = [];
  http.Client client;
  var opacityValue = 0.0;

  void fetchApps() {
    setState(() {
      this.opacityValue = 1.0;
    });
    String uri = 'https://www.xda-developers.com';
    print('Fetching $uri');
    client.get(uri).then((response) {
      var document = parse(response.body);
      var ss = document.getElementsByClassName('widget_apps')[0].getElementsByClassName('widget_app');
      var newPosts = [];
      for (var aa in ss) {
        App newPost = new App(
          aa.getElementsByClassName('widget_item_content')[0].getElementsByTagName('h4')[0].text.trim(),
            aa.getElementsByClassName('widget_item_content')[0].getElementsByTagName('a')[0].attributes['href'],
            aa.getElementsByClassName('thumb_hover')[0].getElementsByTagName('img')[0].attributes['src'],
            aa.attributes['data-app-id'],
            aa.getElementsByClassName('widget_item_text')[0].text.trim()
        );
        newPosts.add(newPost);
      }
      setState(() {
        this.apps.addAll(Iterable.castFrom(newPosts));
        this.opacityValue = 0.0;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    client = http.Client();
    this.fetchApps();
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
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
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
        itemBuilder: (context, index) {
          if (index == apps.length) {
            return new Opacity(opacity: this.opacityValue, child: new Container(
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
              _launchUrl(apps[index].link, context);
            },
            child: new Card(
              elevation: 0.6,
              child: new Column(
                children: <Widget>[
                  new ListTile(
                      contentPadding:
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                      leading: new Hero(tag: apps[index].link, child: FadeInImage.memoryNetwork(placeholder: kTransparentImage,
                        image: apps[index].image,
                        width: 70.0,
                        height: 70.0,
                        fit: BoxFit.cover,
                      )),
                      title: new Text(
                        apps[index].name,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16.0),
                      ),
                      subtitle: new Text(
                        apps[index].detail,
                        style: TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 14.0),
                      )),
                ],
              ),
            ),
          );
        },
        itemCount: apps.length+1);
  }

  @override
  bool get wantKeepAlive => true;
}
