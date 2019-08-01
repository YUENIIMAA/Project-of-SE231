import 'package:intellispot/model/map/latlng_point.dart';
import 'package:intellispot/model/map/photos.dart';

class PoiResult {
  final String adName;
  final String cityName;
  final String provinceName;
  final String snippet;
  final String title;
  final LatLngPoint latLngPoint;
  final PoiPhotos photos;


  PoiResult({
    this.adName,
    this.cityName,
    this.provinceName,
    this.snippet,
    this.title,
    this.latLngPoint,
    this.photos
  });

  factory PoiResult.fromJson(Map<String, dynamic> json){
    return new PoiResult(
      adName: json['adName'].toString(),
      cityName: json['cityName'].toString(),
      provinceName: json['provinceName'].toString(),
      snippet: json['snippet'].toString(),
      title: json['title'].toString(),
      latLngPoint: LatLngPoint.fromJson(json['latLonPoint']),
      photos: PoiPhotos.fromJson(json['photos'])
    );
  }
}

class PoiResultList {
  final List<PoiResult> pois;

  PoiResultList({this.pois});

  factory PoiResultList.fromJson(List<dynamic> parsedJson) {
    List<PoiResult> pois = new List<PoiResult>();
    return new PoiResultList(
      pois: parsedJson.map((i) => PoiResult.fromJson(i)).toList()
    );
  }
}