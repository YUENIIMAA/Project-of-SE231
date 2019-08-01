class Article{
  String title;
  String text;
  String image;

  Article.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        text = json['text'],
        image = json['image'];
}