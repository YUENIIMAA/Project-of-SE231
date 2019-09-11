import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:intellispot/model/map/poi_response.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MapPage extends StatefulWidget {
  MapPage();

  factory MapPage.forDesignTime() =>
      MapPage();

  @override
  _MapPageState createState() =>
      _MapPageState();
}

class _MapPageState extends State<MapPage> {

  AMapController _controller;
  UiSettings _uiSettings = UiSettings();
  MyLocationStyle _Location = MyLocationStyle();
  List<LatLng> _MarkerList = [];
  PoiResponse poiResponse;
  var lat;
  var lng;

  @override
  void initState() {
    _updateLocation(context, showMyLocation: true, radiusFillColor: Colors.transparent.withOpacity(0.1),strokeWidth: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地图'),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: AMapView(
              onAMapViewCreated: (controller) {
                setState(() => _controller = controller);
                _controller.markerClickedEvent.listen((marker) {
                  var mylat = marker.position.latitude;
                  var mylng = marker.position.longitude;
                  for (int i = 0;i < poiResponse.poiResultList.pois.length;++i) {
                    var current = poiResponse.poiResultList.pois[i];
                    if (current.latLngPoint.latitude == mylat && current.latLngPoint.longitude == mylng) {
                      for (int j = 0; j < current.photos.photoList.length; ++j) {
                        print(current.photos.photoList[j].url.toString());
                      }
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(current.title),
                            content: Container(
                              width: double.maxFinite,
                              height: double.maxFinite,
                              child: Column(
                                children: <Widget>[
                                  Text('地址：' + current.cityName + current.provinceName + current.adName + current.snippet),
                                  Text('图片:'),
                                  Flexible(
                                    child: ListView.builder(
                                      itemCount: current.photos.photoList.length,
                                      itemBuilder: (context, index) {
                                        return Image.network(
                                          current.photos.photoList[index].url
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              new FlatButton(
                                child: new Text("返回"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              new FlatButton(
                                child: new Text("导航"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  AMapNavi().startNavi(
                                    lat: current.latLngPoint.latitude,
                                    lon: current.latLngPoint.longitude,
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                      break;
                    }
                  }
                });
                controller.addMarkers(
                  _MarkerList
                      .map((latLng) => MarkerOptions(
                    position: latLng,
                  ))
                      .toList(),
                );
                controller.setZoomLevel(15);
                controller.setUiSettings(
                    _uiSettings.copyWith(
                      isZoomControlsEnabled: true,
                      zoomPosition: ZOOM_POSITION_RIGHT_CENTER,
                      isMyLocationButtonEnabled: true,
                      isScaleControlsEnabled: true,
                    )
                );
              },
              amapOptions: AMapOptions(
                zoomControlsEnabled: true,
                compassEnabled: true,
                logoPosition: LOGO_POSITION_BOTTOM_LEFT,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          backgroundColor: Colors.cyan,
          label: Text("搜索"),
          onPressed:(){
            _showSeletPage(context);
          }
      ),
    );
  }

  void _showSeletPage(context){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(FontAwesomeIcons.restroom),
                    title: new Text('周围的厕所'),
                    onTap: () {
                      Navigator.pop(context);
                      _poiSearch('厕所');
                    }
                ),
                new ListTile(
                  leading: new Icon(Icons.restaurant),
                  title: new Text('周围的餐厅'),
                  onTap: () {
                    Navigator.pop(context);
                    _poiSearch('餐厅');
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.hotel),
                  title: new Text('周围的酒店'),
                  onTap: () {
                    Navigator.pop(context);
                    _poiSearch('酒店');
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  void _updateLocation(
      BuildContext context, {
        String myLocationIcon,
        double anchorU,
        double anchorV,
        Color radiusFillColor,
        Color strokeColor,
        double strokeWidth,
        int myLocationType,
        int interval,
        bool showMyLocation,
        bool showsAccuracyRing,
        bool showsHeadingIndicator,
        Color locationDotBgColor,
        Color locationDotFillColor,
        bool enablePulseAnnimation,
        String image,
      }) async {
    if (await Permissions().requestPermission()) {
      _Location = _Location.copyWith(
        myLocationIcon: myLocationIcon,
        anchorU: anchorU,
        anchorV: anchorV,
        radiusFillColor: radiusFillColor,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        myLocationType: myLocationType,
        interval: interval,
        showMyLocation: showMyLocation,
        showsAccuracyRing: showsAccuracyRing,
        showsHeadingIndicator: showsHeadingIndicator,
        locationDotBgColor: locationDotBgColor,
        locationDotFillColor: locationDotFillColor,
        enablePulseAnnimation: enablePulseAnnimation,
        image: image,
      );
      _controller.setMyLocationStyle(_Location);
    } else {
      print('权限不足');
    }
  }

  void _poiSearch(String keyword) async {
    final options = LocationClientOptions(
      isOnceLocation: true,
      locatingWithReGeocode: true,
    );
    final amapLocation = AMapLocation();
    amapLocation.init();
    amapLocation
        .getLocation(options)
        .then((location) => setState(() {
      lat = location.latitude;
      lng = location.longitude;
      print('<<<=====================Current Location=====================>>>');
      print ('(' + lat.toString() + ',' + lng.toString() + ')');
      print('<<<==========================================================>>>');
      /* Searching for keyword */
      loading(
        context,
        AMapSearch().searchPoiBound(
          PoiSearchQuery(
            query: keyword,
            location: LatLng(lat,lng),
            searchBound: SearchBound(
              center: LatLng(lat,lng),
              range: 1000,
            ),
          ),
        ),
      ).then((poiResult){
        final PoiResult = json.decode(poiResult.toString());
        poiResponse = PoiResponse.fromJson(PoiResult);
        setState(() async {
          //_MarkerList.clear();
          _controller.clearMap();
          for (int i = 0; i < poiResponse.poiResultList.pois.length; ++i) {
            //_MarkerList.add(LatLng(poiResponse.poiResultList.pois[i].latLngPoint.latitude, poiResponse.poiResultList.pois[i].latLngPoint.longitude));
            await _controller.addMarker(MarkerOptions(position: LatLng(poiResponse.poiResultList.pois[i].latLngPoint.latitude, poiResponse.poiResultList.pois[i].latLngPoint.longitude)));
          }
          _updateLocation(context);
        });
      }).catchError((e) => print(e.toString()));
    }));
  }

  Future<T> loading<T>(BuildContext context, Future<T> futureTask) {
    bool popByFuture = true;

    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        );
      },
      barrierDismissible: false,
    ).whenComplete(() {
      popByFuture = false;
    });
    return futureTask.whenComplete(() {
      if (popByFuture) {
        Navigator.of(context, rootNavigator: true).pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}