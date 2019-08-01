class LatLngPoint {
  var latitude;
  var longitude;

  LatLngPoint({this.latitude, this.longitude});

  factory LatLngPoint.fromJson(Map<String, dynamic> json){
    return new LatLngPoint(
      latitude: json['latitude'],
      longitude: json['longitude']
    );
  }
}