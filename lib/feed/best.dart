import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:ngxda/post.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ngxda/models.dart';

class BestFeeds extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new BestState();
}

class BestState extends State<BestFeeds> with AutomaticKeepAliveClientMixin {
  List<Post> posts = [];
  http.Client client;
  var opacity_value = 0.0;

  void fetchBest() {
    setState(() {
      this.opacity_value = 1.0;
    });
    String uri = 'https://www.xda-developers.com';
    print('Fetching $uri');
    client.get(uri).then((response) {
      var document = parse(response.body);
      var posts = document.getElementsByClassName('tb_widget_posts_big')[0].getElementsByClassName('item');
      var new_posts = [];
      for (var post in posts) {
        Post new_post = new Post(
            post.getElementsByTagName('h4')[0].text.trim(),
            '',
            '',
            post.getElementsByTagName('h4')[0].getElementsByTagName('a')[0].attributes['href'],
            post.getElementsByClassName('thumb_hover')[0].getElementsByTagName('img')[0].attributes['src']
        );
        new_posts.add(new_post);
      }
      setState(() {
        this.posts.addAll(Iterable.castFrom(new_posts));
        this.opacity_value = 0.0;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    client = http.Client();
    this.fetchBest();
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
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

  _launchUrl(post) {
    Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (_, __, ___) => new PostPage(post: post)
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
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
                      EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                      leading: new Hero(tag: posts[index].link, child: FadeInImage.memoryNetwork(placeholder: kTransparentImage,
                        image: posts[index].image,
                        width: 100.0,
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
