// @dart=2.9

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:flushbar/flushbar.dart';
import 'package:papaya/services/initialize_sqlite.dart';

class GetPlacePin extends StatefulWidget {
  @override
  _GetPlacePinState createState() {
    return new _GetPlacePinState();
  }
}

class _GetPlacePinState extends State<GetPlacePin> {
  Future update(generallocation,latlongaddress, id) async {
    var dbClient = await SqliteDB().db;
    var res = await dbClient.rawQuery(""" UPDATE loginUser 
        SET generallocation = '$generallocation',latlongaddress = '$latlongaddress' WHERE id = '$id'; """);
    return res;
  }

  GoogleMapController mapController;
  static final LatLng _center = const LatLng(-1.28893, 35.8421);
  final Set<Marker> _markers = {};
  LatLng _currentMapPosition = _center;
  LatLng geoloc=null;
  MapType _currentMapType = MapType.hybrid;
  String strLoc="";
  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.hybrid
          ? MapType.satellite
          : _currentMapType == MapType.satellite
          ? MapType.normal
          : MapType.hybrid;
    });
  }
  void _onAddMarkerButtonPressed (LatLng latlang) async{
    //loadAddress(latlang);
    List<geocode.Placemark> placemarks = await geocode.placemarkFromCoordinates(latlang.latitude, latlang.longitude);
    debugPrint("addreesee:>" + placemarks.toString());
    strLoc=placemarks.first.administrativeArea+","+placemarks.first.locality+","+placemarks.first.street+","+placemarks.first.subLocality+","+placemarks.first.street+","+placemarks.first.subThoroughfare+","+placemarks.first.thoroughfare+","+placemarks.first.name;

    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(latlang.toString()),
        position: latlang,
        infoWindow:
            InfoWindow(title: strLoc, snippet: "Address"),

        //title:address,
        icon: BitmapDescriptor.defaultMarker,
      ));
      update(strLoc,latlang.latitude.toString()+","+latlang.longitude.toString(),"1");
    });
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(latlang.latitude, latlang.longitude),zoom: 15),
      ),
    );
    // final snackBar = SnackBar(
    //   content: Text(strLoc),
    //   duration: Duration(days: 365),
    //   action: SnackBarAction(
    //     label: 'USE THIS LOCATION?',
    //     onPressed: () {
    //       // Some code to undo the change.
    //     },
    //   ),
    // );
    // Scaffold.of(context).showSnackBar(snackBar);
    Flushbar(
      title: "Location Changed!",
      message: "new location selected",
      duration: Duration(seconds: 3),
      isDismissible: false,

    )
      ..show(context);


  }

  void _onCameraMove(CameraPosition position) {
    _currentMapPosition = position.target;
  }
  Location _location = Location();
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  mapController.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(target: LatLng(-1.28893, 35.8421),zoom: 15),
    ),
  );
  }
double lat=-1.28893,long=35.8421;
  void showCurrentMarker(){
    getMyLoc();
    if(_markers.length>=1)
    {
      _markers.clear();
    }
    if (geoloc!=null){
      _onAddMarkerButtonPressed(geoloc);
    //}else{
      ///CircularProgressIndicator();
    }

  }
  String strRawLatLong="0.0,0.0";
  void getMyLoc()async{
    Flushbar(
      title: "Getting your location!",
      message: "please wait",
      duration: Duration(seconds: 5),
      isDismissible: false,

    )
      ..show(context);

    _location.onLocationChanged.listen((LocationData currentLocation) {
      print(currentLocation.latitude);
      print(currentLocation.longitude);
      lat=currentLocation.latitude;
      long=currentLocation.longitude;

      strRawLatLong=currentLocation.latitude.toString()+","+currentLocation.longitude.toString();
      geoloc = new LatLng(currentLocation.latitude, currentLocation.longitude);
      debugPrint("geoloc:" + geoloc.toString());
    });
    update(strLoc,strRawLatLong,"1");

  }
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mark location:'),
          backgroundColor: Colors.lightBlue,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 15.0,
                ),
                markers: _markers,
                onCameraMove: _onCameraMove,
                mapType: _currentMapType,
              compassEnabled: true,
              onTap: (latlang){
                if(_markers.length>=1)
                {
                  _markers.clear();
                }

                _onAddMarkerButtonPressed(latlang);
              },
              myLocationEnabled: true,
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child:Align(
                alignment: Alignment.topRight,
                child: Column(
                children: <Widget>[
                 FloatingActionButton(
                  onPressed: _onMapTypeButtonPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.lightBlue,
                  child: const Icon(Icons.map, size: 30.0),
                ),
                  SizedBox(
                    height: 20,),

                 FloatingActionButton(
                  onPressed: showCurrentMarker,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.lightBlue,
                  child: const Icon(Icons.location_searching, size: 30.0),
                    // my_location_sharp
                ),

                ],),
        ),),

          ],
  ),
      );
  }
}
