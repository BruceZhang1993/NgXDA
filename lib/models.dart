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
  Choice({this.name, this.title, this.icon});

  final String name;
  String title;
  final IconData icon;
}

class SettingItem {
  final String id;
  String title;
  String value;
  String default_;
  final String hint;

  SettingItem(this.id, this.title, this.value, this.default_, this.hint);
}

// Threads Models

class MostActiveThread {
  final String title;
  final String date;
  final String author;
  final String heat;
  final String link;
  final String image;

  MostActiveThread(this.title, this.date, this.author, this.heat, this.link, this.image);
}

class ThreadMeta {
  final String title;
  final String time;
  final String replies;
  final String reviews;
  final String link;

  ThreadMeta(this.title, this.time, this.replies, this.reviews, this.link);
}

class DeviceMeta {
  final String deviceName;
  final String deviceId;
  final String threadLink;

  DeviceMeta(this.deviceName, this.deviceId, this.threadLink);
}

class User {
  final String name;
  final String link;
  final String thumb;
  final String description;
  final String thanks;
  final String posts;
  final String isp;
  final String city;
  final String country;
  final List<DeviceMeta> devices;
  final dynamic signature;

  User(this.name, this.link, this.thumb, this.description, this.thanks, this.posts, this.isp, this.city, this.country, this.devices, this.signature);
}

class UserMeta {
  final String name;
  final String link;
  final String thumb;
  final String description;
  final String thanks;
  final String posts;

  UserMeta(this.name, this.link, this.description, this.thanks, this.posts, this.thumb);
}

class Thread {
  final String title;
  final UserMeta author;
  final String datetime;
  final int totalPage;
  final int replyCount;
  List<dynamic> contents = [];

  Thread(this.title, this.author, this.datetime, this.totalPage, this.replyCount);
}

// Section
class SectionMeta {
  final String title;
  final String link;

  SectionMeta(this.title, this.link);
}
