import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:ngxda/post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:ngxda/models.dart';

class LatestFeeds extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new LatestState();
}

class LatestState extends State<LatestFeeds> {
  int currentPage = 1;
  List<Post> posts = [];
  http.Client client;
  ScrollController scroll;
  bool reachedBottom = false;

  void fetchPage() {
    String uri = 'https://www.xda-developers.com/page/$currentPage/';
    if (currentPage == 1) {
      uri = 'https://www.xda-developers.com';
    }
    print('Fetching $uri');
    currentPage ++;
    client.get(uri).then((response) {
      var document = parse(response.body);
      var posts = document.getElementsByClassName('layout_post_2');
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
        this.posts.addAll(Iterable.castFrom(new_posts));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    scroll = new ScrollController();
    scroll.addListener(_scrollHandler);
    client = http.Client();
    this.fetchPage();
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
        controller: this.scroll,
        itemBuilder: (context, index) {
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
                      EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
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
        itemCount: posts.length);
  }
}
