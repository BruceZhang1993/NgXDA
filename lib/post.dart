import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:transparent_image/transparent_image.dart';
import 'package:ngxda/models.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:share/share.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:url_launcher/url_launcher.dart' as u;

class PostPage extends StatefulWidget {
  final Post post;

  const PostPage({Key key, this.post}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new PostState(post);
}

class PostState extends State<PostPage> {
  final Post post;
  http.Client client;
  PostDetail detail;
  var opacity_value = 0.0;
  List<Choice> choices = const <Choice> [
    const Choice(title: "Open in browser", icon: Icons.open_in_browser, name: 'browser'),
    const Choice(title: "Share via...", icon: Icons.share, name: 'share')
  ];

  PostState(this.post);

  @override
  void initState() {
    detail = new PostDetail(
        post.title, post.date, post.author, post.link, post.image, '');
    super.initState();
    client = http.Client();
    this._fetchDetail(this.detail.link);
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }

  void _fetchDetail(uri) {
    setState(() {
      this.opacity_value = 1.0;
    });
    client.get(uri).then((response) {
      var document = parse(response.body);
      var large_img = document
          .getElementsByClassName('entry_media')[0]
          .getElementsByTagName('img')[0]
          .attributes['src'];
      var content = document.getElementsByClassName('entry_content')[0];
      setState(() {
        this.detail.image = large_img;
        this.detail.content = content;
        this.opacity_value = 0.0;
      });
    });
  }

  Container _buildImage() {
    return new Container(
      child: new Hero(
          tag: detail.link,
          child: FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: detail.image,
            height: 260.0,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          )),
    );
  }

  Column _buildHtmlContent(dynamic document) {
    if (document.runtimeType == String) {
      return new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            document,
            style: TextStyle(
                fontSize: 18.0,
                color: new Color(0xFF444444),
                fontWeight: FontWeight.w300,
                height: 1.1),
          )
        ],
      );
    } else {
      List<Widget> items = _parseHtml(document);
      return new Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: items);
    }
  }

  List<Widget> _parseHtml(dom.Element document) {
    if (document.children.length == 0 ||
        document.classes.contains('dropcap') ||
        document.localName == 'p' ||
        document.localName == 'tr' || document.localName == 'ul' || document.localName == 'blockquote') {
      if (document.localName == 'h1' || document.localName == 'style' || document.classes.contains('et_social_icons_container')) {
        return [];
      }
      if (document.localName == 'h3') {
        return [
          new Container(
              child: new Text(
            document.text.trim(),
            style: TextStyle(
                fontSize: 18.0,
                color: new Color(0xFF666666),
                fontWeight: FontWeight.w600,
                height: 2.4),
          ))
        ];
      }
      if (document.localName == 'tr') {
        List<dom.Element> cells = document.querySelectorAll('td,th');
        List<Expanded> rowChildren = [];
        for (dom.Element cell in cells) {
          if (cell.localName == 'td') {
            rowChildren.add(Expanded(child: Container(child: new Text(cell.text.trim(),
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.black45,
                    fontSize: 12.0,
                    height: 1.1
                )
            ))));
          }
          if (cell.localName == 'th') {
            rowChildren.add(Expanded(child: Container(child: new Text(cell.text.trim(),
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                    fontSize: 13.0,
                    height: 1.2
                )
            ))));
          }
        }
        return [
          Container(child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: rowChildren
          ), margin: EdgeInsets.only(top: 4.0))
        ];
      }
      if (document.localName == 'ul') {
        var lis = document.getElementsByTagName('li');
        List<Container> uList = <Container>[];
        for (var li in lis) {
          uList.add(new Container(
            child: new Text('- ' + li.text.trim(),
              style: TextStyle(
                color: new Color(0xFF666666),
                fontSize: 13.0,
                height: 1.1
              ),
            )
          ));
        }
        return uList;
      }
      if (document.localName == 'blockquote') {
        return [
          new Container(
            child: new Text(
              document.text.trim(),
              style: TextStyle(
                  fontSize: 13.5,
                  color: new Color(0xFF888888),
                  fontWeight: FontWeight.w400,
                  height: 1.15),
            ),
            decoration: new BoxDecoration(color: Color(0x44C0C0C0)),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          )
        ];
      }
      if (document.localName == 'img') {
        String src = document.attributes['src'];
        return [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: new FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: src),
          )
        ];
      }
      String allText = document.outerHtml.trim();
      TextStyle linkStyle = new TextStyle(
        color: Colors.lightBlue,
        fontWeight: FontWeight.w400,
      );
      List<TextSpan> textSpans = [];
      if (document.children.length > 0) {
        RegExp re = new RegExp(r'<a\s+href="(.*?)".*?>(.*?)</a>', caseSensitive: false);
        allText.splitMapJoin(re,
          onMatch: (match) {
            String url = match.group(1);
            if (url.startsWith('/')) {
              url = "https://www.xda-developers.com/" + url;
            }
            LinkSpan span = new LinkSpan(
              style: linkStyle,
              text: match.group(2),
              url: url
            );
            textSpans.add(span);
          },
          onNonMatch: (nonmatch) {
            TextSpan span = new TextSpan(
              text: nonmatch.replaceAll(new RegExp(r'<p style="text-align: center;">|<p class="dropcap">|<p>|</p>'), '').replaceAll('&nbsp;', '')
            );
            textSpans.add(span);
          }
        );
      }
      return [
        new Container(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: RichText(
              text: TextSpan(
                children: textSpans,
                style: TextStyle(
                  color: Color(0xFF444444),
                  fontSize: 14.5,
                  height: 1.2
                )
              )
          )
        )
      ];
    } else {
      List<Widget> items = [];
      for (dom.Element ele in document.children) {
        items.addAll(Iterable.castFrom(_parseHtml(ele)));
      }
      return items;
    }
  }

  Container _buildContent() {
    return new Container(
      margin: new EdgeInsets.only(top: 210.0),
      padding: new EdgeInsets.only(left: 32.0, right: 32.0 , top: 0.0, bottom: 0.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            detail.author + ' | ' + detail.date,
            style: TextStyle(
              fontSize: 13.0,
              color: new Color(0xFF777777),
              fontWeight: FontWeight.w400,
              height: 2.8
            ),
            textAlign: TextAlign.left,
            overflow: TextOverflow.fade,
          ),
          new Text(
            detail.title,
            style: TextStyle(
                fontSize: 22.0,
                color: new Color(0xFF666666),
                fontWeight: FontWeight.w600,
                height: 1.2),
          ),
          new Separator(),
          _buildHtmlContent(detail.content),
          new Opacity(opacity: this.opacity_value, child: new Container(
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
      u.canLaunch(url).then((can) {
        if (can) {
          u.launch(url);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  _launchUrl(detail.link, context);
                }
                if (choice.name == 'share') {
                  Share.share(detail.title + ' ' + detail.link + ' -- Share from ngXDA.');
                }
              },
            ),
          ],
          elevation: 0.0,
          title: new Container(
              child: new Center(
            child: new Text(
              this.detail.title,
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
              _buildImage(),
              _buildGradient(),
              _buildContent()
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

class LinkSpan extends TextSpan {
  LinkSpan({ TextStyle style, String url, String text }) : super(
      style: style,
      text: text ?? url,
      recognizer: TapGestureRecognizer()..onTap = () {
        _launchUrl(url);
      }
  );

  static _launchUrl(url) async {
    try {
      await launch(
        url,
        option: new CustomTabsOption(
          toolbarColor: Colors.deepOrange,
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
}
