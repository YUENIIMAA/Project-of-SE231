import 'package:intellispot/model/map/poi_result.dart';

class PoiResponse {

  final PoiResultList poiResultList;

  PoiResponse({this.poiResultList});

  factory PoiResponse.fromJson(Map<String, dynamic> response) {
    return new PoiResponse(
      poiResultList: PoiResultList.fromJson(response['pois'])
    );
  }
}