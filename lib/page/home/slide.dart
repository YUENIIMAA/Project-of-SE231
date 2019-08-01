import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class SlidePage extends StatefulWidget {

  @override
  _SlidePageState createState() => new _SlidePageState();
}

class _SlidePageState extends State<SlidePage> {

  @override
  Widget build(BuildContext context) {
    return new Material(
        child:
        new Swiper(
          itemBuilder: (BuildContext context,int index){

            return new Image.asset("assets/slide$index.jpg",fit: BoxFit.fill,);

          },
          itemCount: 3,
          pagination: new SwiperPagination(),
          control: new SwiperControl(),

        )
    );
  }
}
