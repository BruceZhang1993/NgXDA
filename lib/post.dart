import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:ngxda/feed/latest.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ngxda/models.dart';
import 'package:html/dom.dart' as dom;
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

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
        document.localName == 'tr') {
      if (document.localName == 'h1' || document.localName == 'style') {
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
        return [
          new Text(
            document.text.trim().replaceAll("\n", "     "),
            style: TextStyle(
                fontSize: 15.0,
                color: new Color(0xFF666666),
                fontWeight: FontWeight.w300,
                height: 1.3),
          )
        ];
      }
      if (document.localName == 'img') {
        return [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: new FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: document.attributes['src']),
          )
        ];
      }
      String allText = document.text.trim();
      if (document.children.length > 0) {
        for (dom.Element ele in document.children) {
          if (ele.localName == 'a' && ele.text.length > 0) {
            allText = allText.replaceFirst(ele.text, ele.text + '[ '+ ele.attributes['href'] +' ]');
          }
        }
      }
      return [
        new Container(
          padding: EdgeInsets.symmetric(vertical: 4.0),
          child: Linkify(
            text: allText,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              color: new Color(0xFF444444),
              height: 1.1
            ),
            linkStyle: TextStyle(
              color: Colors.blueAccent
            ),
            onOpen: (url) async {
              if (await canLaunch(url)) {
                await launch(url, forceWebView: false);
              } else {
                throw 'Cannot launch URL: $url';
              }
            },
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

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Cannot launch $url';
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
                      contentPadding: EdgeInsets.all(0.0),
                      leading: new Icon(choice.icon,
                        color: new Color(0xFF666666),
                        size: 26.0,
                      ),
                      title: Text(choice.title, style: TextStyle(
                        fontSize: 16.0,
                        color: new Color(0xFF666666)
                      )),
                    )
                  );
                }).toList();
              },
              onSelected: (choice) {
                if (choice.name == 'browser') {
                  _launchUrl(detail.link);
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
