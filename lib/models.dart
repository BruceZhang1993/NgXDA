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
  String content;

  PostDetail(
      this.title, this.date, this.author, this.link, this.image, this.content);

  @override
  String toString() {
    return "PostDetail<title: " + this.title + ">";
  }
}
