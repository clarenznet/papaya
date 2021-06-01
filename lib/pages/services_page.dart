// @dart=2.9

import 'package:flutter/material.dart';
import 'package:papaya/services_tabs/cleaning_tab.dart';
import 'package:papaya/services_tabs/cooking_tab.dart';
import 'package:papaya/services_tabs/laundry_tab.dart';
class ServicesPage extends StatelessWidget {

  final Function onNext;

  ServicesPage({ this.onNext});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,

          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,

            children: [
              TabBar(
                //indicator: BoxDecoration(
                  //  borderRadius: BorderRadius.circular(50), // Creates border
                    //color: Colors.greenAccent),
              //  tabs: [...],
                tabs: <Widget>[
                  Tab(
                    //icon: Icon(Icons.ac_unit),
                    child: Text('Laundry',
                        style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            fontFamily: "SF")),
                  ),
                  Tab(
                    //icon: Icon(Icons.wifi_tethering),
                    child: Text('Cooking',
                        style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            fontFamily: "SF")),
                  ),
                  Tab(
                    //icon: Icon(Icons.whatshot),
                    child: Text('Cleaning',
                        style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                            fontFamily: "SF")),
                  ),
                ],

              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LaundryTab(),
            CookingTab(),
            CleaningTab(),
          ],
        ),
      ),
    );
  }

}
class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({ Color color, double radius})
      : _painter = _CirclePainter(color, radius);


 @override
 ///////////changed stuff
 BoxPainter createBoxPainter([ onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
    ..color = color
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height - radius - 5);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}




//////////////////////////////


