import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:ngxda/feed/latest.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ngxda/models.dart';

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

  PostState(this.post);

  @override
  void initState() {
    detail = new PostDetail(post.title, post.date, post.author, post.link, post.image, '');
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
    client.get(uri).then((response) {
      var document = parse(response.body);
      var large_img = document
          .getElementsByClassName('entry_media')[0]
          .getElementsByTagName('img')[0]
          .attributes['src'];
      var content = document
          .getElementsByClassName('entry_content')[0].text;
      setState(() {
        this.detail.image = large_img;
        this.detail.content = content;
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

  Container _buildContent() {
    return new Container(
      margin: new EdgeInsets.only(top: 230.0),
      padding: new EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            detail.title,
            style: TextStyle(
              fontSize: 21.0,
              color: new Color(0xFF666666),
              fontWeight: FontWeight.w600,
              height: 1.2
            ),
          ),
          new Separator(),
          new Text(
            detail.content,
            style: TextStyle(
              fontSize: 15.0,
              color: new Color(0xFF444444),
              fontWeight: FontWeight.w400,
              height: 1.15
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
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
      body: new ListView(children: <Widget>[
        new Stack(
          children: <Widget>[
            _buildImage(),
            _buildGradient(),
            _buildContent(),
          ],
        )
      ],),
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
