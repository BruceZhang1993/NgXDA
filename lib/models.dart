import 'package:flutter/cupertino.dart';

class Post {
  final String title;
  final String date;
  final String author;
  final String link;
  final String image;

  Post(this.title, this.date, this.author, this.link, this.image);

  @override
  String toString() {
    return "Post<title: " + this.title + ">";
  }
}

class PostDetail {
  final String title;
  final String date;
  final String author;
  final String link;
  String image;
  dynamic content;

  PostDetail(
      this.title, this.date, this.author, this.link, this.image, this.content);

  @override
  String toString() {
    return "PostDetail<title: " + this.title + ">";
  }
}

class App {
  final String name;
  final String link;
  final String image;
  final String id;
  final String detail;

  App(this.name, this.link, this.image, this.id, this.detail);

  @override
  String toString() {
    return "App<name: " + this.name + ">";
  }
}

class Choice {
  const Choice({this.name, this.title, this.icon});

  final String name;
  final String title;
  final IconData icon;
}

class SettingItem {
  final String id;
  final String title;
  String value;
  final String default_;
  final String hint;

  SettingItem(this.id, this.title, this.value, this.default_, this.hint);
}
