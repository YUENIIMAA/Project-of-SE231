class PoiPhoto {
  final String title;
  final String url;

  PoiPhoto({this.title, this.url});

  factory PoiPhoto.fromJson(Map<String,dynamic> json) {
    return new PoiPhoto(
      title: json['title'],
      url:  json['url']
    );
  }
}

class PoiPhotos {
  final List<PoiPhoto> photoList;

  PoiPhotos({this.photoList});

  factory PoiPhotos.fromJson(List<dynamic> parsedJson) {
    List<PoiPhoto> photoList = new List<PoiPhoto>();
    return PoiPhotos(
      photoList: parsedJson.map((i) => PoiPhoto.fromJson(i)).toList(),
    );
  }
}