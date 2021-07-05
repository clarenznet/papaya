// @dart=2.9
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:papaya/widgets/heading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'package:flushbar/flushbar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
class DetailsScreen extends StatefulWidget {
  final String strTcktCode; //if you have multiple values add here
  DetailsScreen(this.strTcktCode, {Key key})
      : super(key: key); //add also..example this.abc,this...
  @override
  State<StatefulWidget> createState() => _DetailsScreenState();
// _DetailsScreenState createState() {
//   return new _DetailsScreenState();
// }
}

class _DetailsScreenState extends State<DetailsScreen> {
  ///////////////////////secrets
  //MpesaFlutterPlugin.setConsumerKey("GmF0l26wLvGHA0wDwTeZSoNdVp8VZQmU");
//  MpesaFlutterPlugin.setConsumerSecret("AFIrVoUgIvSMlRv7");

  //Future<Secret> secret = SecretLoader(secretPath: "secrets.json").load();

  void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> lipaNaMpesa() async {
    dynamic transactionInitialisation;
    debugPrint("RES__>" + transactionInitialisation.toString());
    try {
      const CustomerBuyGoodsOnline = "CustomerBuyGoodsOnline";
      transactionInitialisation =
          await MpesaFlutterPlugin.initializeMpesaSTKPush(
              businessShortCode: "504628",
              //transactionType: TransactionType.CustomerBuyGoodsOnline,
              amount: 7,
              partyA: "254713593916",
              partyB: "507984",
              callBackURL: Uri.parse(
                  "https://www.homlie.co.ke/aqim/callback_url.php?strticketcode=56"),
              accountReference: "HM8799",
              phoneNumber: "254713593916",
              baseUri: Uri.parse("https://api.safaricom.co.ke"),
              //baseUrl: "https://sandbox.safaricom.co.ke/",
              transactionDesc: "purchase",
              passKey:
                  "ba95f91d4c495092444e625821fb00cc5eec70f8a4d64c0fdc95f8c23b501283");
      print("TRANSACTION RESULT: " + transactionInitialisation.toString());
      /*Update your db with the init data received from initialization response,
      * Remaining bit will be sent via callback url*/
      return transactionInitialisation;
    } catch (e) {
      //lets print the error to console for this sample demo
      print("CAUGHT EXCEPTION: " + e.toString());
    }
  }

  int _button_state = 0;

  Future getDetailsData(String strTcktCode) async {
    var url =
        'https://homlie.co.ke/malakane_init/hml_getticketdetails.php?strtcktcode=';
    var response = await http.get(Uri.parse(url + strTcktCode));
    debugPrint("detals !!!!" + response.body);
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
  }
  LatLng _geoLocCoordinates; //LatLng(0.0,0.0);

  GoogleMapController mapController;
  final Set<Marker> _markers = {};
  final LatLng _center = const LatLng(-1.28893, 36.8421);
  // void _onAddMarkerButtonPressed(LatLng latlang)async {
  //   setState(() {
  //     _markers.add(Marker(
  //       markerId: MarkerId(latlang.toString()),
  //       position: latlang,
  //       infoWindow:
  //       InfoWindow(title: latlang.toString(), snippet: strLocAddress),
  //       icon: BitmapDescriptor.defaultMarker,
  //     ));
  //   });
  // }
  void _onAddMarkerButtonPressed(LatLng latlang) async {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(latlang.toString()),
        position: latlang,
        infoWindow: InfoWindow(title: "Location", snippet: "Address"),
        //title:address,
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(latlang.latitude, latlang.longitude), zoom: 15),
      ),
    );
  }

  Set<Marker> markers = Set();
  void _onCameraMove(CameraPosition position) {
      _onAddMarkerButtonPressed(_geoLocCoordinates);
    _geoLocCoordinates = position.target;
  }
  String strLocAddress = "";
  void geoAddress()async{
    List<geocode.Placemark> placemarks = await geocode
        .placemarkFromCoordinates(
        _geoLocCoordinates.latitude, _geoLocCoordinates.longitude);
    setState(() {
      strLocAddress = placemarks.first.administrativeArea +
          "," +
          placemarks.first.locality +
          "," +
          placemarks.first.street +
          "," +
          placemarks.first.subLocality +
          "," +
          placemarks.first.street +
          "," +
          placemarks.first.subThoroughfare +
          "," +
          placemarks.first.thoroughfare +
          "," +
          placemarks.first.name;
      debugPrint("addreesee111:>" + placemarks.toString());
    });
  }

  var lstItemsDetails = new Map();
String strTotalAmountUpl="";
  @override
  Widget build(BuildContext context) {
//    debugPrint("SECRET_API>>>>" +secret.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket details:'),
        backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'refresh',
              onPressed: () {
                getDetailsData(widget.strTcktCode);
                //_refreshIndicatorKey.currentState.show();
              }),
        ],
      ),
      body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: FutureBuilder(
            future: getDetailsData(widget.strTcktCode),
            builder: (context, snapshot) {
              if (snapshot.hasError) print(snapshot.error);
              return snapshot.hasData
                  ? LayoutBuilder(builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                      List lstDetails =
                          snapshot.data; // _laundries['responseBody'];
                      debugPrint("taskdetailitems" +
                          lstDetails[0]["fr_taskdetail"].toString());
                      _geoLocCoordinates = new LatLng(lstDetails[0]["fr_latitude"], lstDetails[0]["fr_longitude"]);
                      _onAddMarkerButtonPressed(_geoLocCoordinates);
                      var llat = double.parse(lstDetails[0]["fr_latitude"].toString());
                      var llong = double.parse(lstDetails[0]["fr_longitude"].toString());
                      if (llat!=0 && llong!=0) {
                        geoAddress();
                      }
                      strTotalAmountUpl=lstDetails[0]["fr_strtotalprice"].toString();

                      Marker resultMarker = Marker(
                        markerId: MarkerId(_geoLocCoordinates.toString()),
                        infoWindow:
                        InfoWindow(title: "Selected Location", snippet: strLocAddress),
                        icon: BitmapDescriptor.defaultMarker,
                        position: _geoLocCoordinates,
                      );
// Add it to Set
                markers.add(resultMarker);
                // lstItemsDetails=lstDetails[0]["fr_taskdetail"] as Map;
//      lstDetails[0]["fr_taskdetail"]
                      //  List lstItems=lstDetails[0]["fr_taskdetail"];
                      debugPrint(
                          "taskdetailitems" + lstItemsDetails.toString());
                      return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 10.0),
                scrollDirection: Axis.vertical,


                child:                Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Heading(
                            text: Text(
                              lstDetails[0]["fr_funditype"] +
                                  ":  " +
                                  lstDetails[0]["fr_tcktcode"].toString(),
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                              child: ListView.builder(
                                  itemCount: lstDetails.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      //height: 35,
                                      margin: EdgeInsets.all(2),
                                      child: ListTile(
                                        leading: Icon(Icons.add_circle,
                                            size: 15.0,
                                            color: Colors.lightBlue),
                                        subtitle: Text(
                                          lstDetails[0]["fr_taskdetail"].toString(),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[500],
                                              //maxLines: 10,
                                          ),
                                        ),

                                        trailing: Text(
                                          //                     '@ KSh: ${lstSelectedArticles[index]['svc_price']} x ${lstSelectedRawData[lstSelectedArticles[index]['svc_id']]}',
                                          "",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  })),
                          SizedBox(
                            height: 20,
                          ),
                          ListTile(
                            title: Text(
                              "Total Amount: KSh " +
                                  lstDetails[0]["fr_strtotalprice"].toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.monetization_on_rounded,
                                size: 30.0, color: Colors.lightBlue),
                          ),
                          ListTile(
                            title: Text(
                              "General Location address:" +
                                  lstDetails[0]["fr_generallocation"]
                                      .toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.location_on_outlined,
                                size: 30.0, color: Colors.lightBlue),
                          ),
                          ListTile(
                            title: Text(
                              "Specific address/house no: " +
                                  lstDetails[0]["fr_specificaddress"]
                                      .toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.location_city_sharp,
                                size: 30.0, color: Colors.lightBlue),
                          ),
                          SizedBox(
                              height: 200,
                              child: GoogleMap(
//                           onMapCreated: _onMapCreated,
//                           myLocationEnabled: true,
                                initialCameraPosition: CameraPosition(
                                    target: _geoLocCoordinates, zoom: 15.0),
                                markers: markers,
                                compassEnabled: true,
                                onCameraMove: _onCameraMove,
                              )
                          ),

                          ListTile(
                            title: Text(
                              "Start Time: " +
                                  lstDetails[0]["fr_taskdate"] +
                                  "  " +
                                  lstDetails[0]["fr_tasktime"].toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            trailing: Icon(Icons.timer,
                                size: 30.0, color: Colors.lightBlue),
                          ),
                          ListTile(
                            title: Text(
                              "Status: " +
                                  lstDetails[0]["fr_status"].toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),

                              trailing:
                            FadeInImage(
                              imageErrorBuilder:
                                  (BuildContext context,
                                  Object exception,
                                  StackTrace
                                  stackTrace) {
                                print('Error Handler');
                                return Container(
                                  //width: 60,
                                  //height:
                                  //double.infinity,
                                  child:
                                  Icon(Icons.wifi_protected_setup_sharp,
                                      size: 30.0, color: Colors.lightBlue
                                  ),
                                );
                              },
                              placeholder: AssetImage(
                                  'assets/images/dice_splash.gif'),
                              image: AssetImage(lstDetails[0]["fr_status"].toString() =="Waiting"?'assets/images/dice_splash.gif':
                                  ''),
                             // fit: BoxFit.cover,
                              //width: 60,
                              //height: double.infinity,
                            ),


                          ),

                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Heading(
                                  text: Text(
                                    "Assigned Worker Details",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[500]),
                                  ),
                                ),
                                Card(
                                    elevation: 2,
                                    child: ListTile(
                                      title: Text(lstDetails[0]["fr_fundiemail"].toString(),
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                            fontFamily: "SF"),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        "Worker ID: " +
                                            lstDetails[0]["fr_fundiemail"].toString()+
                                            "  " +
                                            lstDetails[0]["fr_fundiphone"]
                                                .toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: FadeInImage(
                                          imageErrorBuilder:
                                              (BuildContext context,
                                                  Object exception,
                                                  StackTrace stackTrace) {
                                            print('Error Handler');
                                            return Container(
                                              width: 60,
                                              height: double.infinity,
                                              child: Image.asset(
                                                  'assets/images/s1.jpg'),
                                            );
                                          },
                                          placeholder: AssetImage(
                                              'assets/images/dice_splash.gif'),
                                          image: NetworkImage(""),
                                          fit: BoxFit.cover,
                                          width: 60,
                                          height: double.infinity,
                                        ),
                                      ),
                                      isThreeLine: true,
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
                              ]),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            //alignment: Alignment.center,

                            child: new MaterialButton(
                              child: setUpButtonChild(),
                              onPressed: () async {
                                _show(context);
                                setState(() {
                                  _button_state = 0;
//                if (_state == 0) {
                                  animateButton();
                                  //            }
                                });
                              },
                              elevation: 4.0,
                              minWidth: double.infinity,
                              height: 48.0,
                              color: Colors.cyan,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ],
                )
                      );

              })
                  : Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }

  Widget setUpButtonChild() {
    if (_button_state == 0) {
      return new Text(
        " Complete Ticket ",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      );
    } else if (_button_state == 1) {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      );
    } else {
      return Text(
        "       Retry      ",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      );
    }
  }

  void animateButton() {
    setState(() {
      _button_state = 1;
    });

    Timer(Duration(milliseconds: 3300), () {
      setState(() {
        _button_state = 2;
      });
    });
    Timer(Duration(milliseconds: 15000), () {
      setState(() {
        _button_state = 0;
      });
    });
  }
  void _show(BuildContext ctx) {

    int intTotalPrice = 0;
    int _state = 0;
    String strReturn = "";
    String strRating="";
///////////////////////
    TextEditingController strHouseNameNo = new TextEditingController();
    /////////
    Future<String> senddata() async {
      if ( strHouseNameNo.text.isNotEmpty &&
          strHouseNameNo.text != "" &&
          strLocAddress.isNotEmpty) {
        var urlPost = 'https://homlie.co.ke/malakane_init/hml_uploadticket.php';
        final strResponse = await http.post(Uri.parse(urlPost), body: {
          "fr_useremail": "", //fr_useremail,
          "fr_userphone": "", //fr_userphone",
          "fr_rating": "Laundry", //fr_funditype",
          "fr_paymentphonenumber": strLocAddress,
          "fr_ticketno": "",
          // "fr_tasktime": time.hour.toString() + ":" + time.minute.toString(),
          // "fr_taskdetail": strSelArtBn,
          // "fr_strtotalprice": intTotalPrice.toString(),
        });
        print(strResponse.body.toString());
        if (strResponse.body.toString() == "ErrorRE101") {
          ////
     //     snackbarA("Error, please try again");
          Flushbar(
            title: "Ticket",
            message: "Error. Please try again.",
            duration: Duration(seconds: 3),
            isDismissible: false,
          )..show(context);
        } else {
          Navigator.pop(context);
          Flushbar(
            title: "Ticket",
            message:
            "Your ticket has been created successfully. You can find it in MyTickets tab",
            duration: Duration(seconds: 3),
            isDismissible: false,
          )..show(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailsScreen(strResponse.body.toString())));
        }
        debugPrint("|||" + strResponse.body.toString());
        strReturn = strResponse.body.toString();
      }
      return strReturn;
    }
    Widget setUpButtonChild() {
      if (_state == 0) {
        return new Text(
          " LIPA NA mPESA ",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        );
      } else if (_state == 1) {
        return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        );
      } else {
        return Text(
          "Retry",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
        );
      }
    }
    void animateButton() {
      setState(() {
        _state = 1;
      });
      Timer(Duration(milliseconds: 3300), () {
        setState(() {
          _state = 2;
        });
      });
      Timer(Duration(milliseconds: 15000), () {
        setState(() {
          _state = 0;
        });
      });
    }

////////////////////////////////////////////////////////////////
//   getLoginUserData();

    //  getLoginUserData();
    showModalBottomSheet(
        isScrollControlled: true,
//        height: 10,
        elevation: 5,
        context: ctx,
        //builder: (ctx) =>
        builder: (ctx) {
          //         getLoginUserData();
//          _onAddMarkerButtonPressed(_geoLocCoordinates);
          return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 10.0),
              scrollDirection: Axis.vertical,
              child: Wrap(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Heading(
                    text: Text(
                      "Payment Form:",
                      style:
                      TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Heading(
                    text: Text(
                      "Make payment by Mpesa to paybill number 504628 of Homlie Service.",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500]),
                    ),
                  ),
                  ListTile(
                    leading:Text(
                      "Ticket No: ",
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w500,
                        color: Colors.grey[500]),
                    ),
                    title: Text(
                      ""+widget.strTcktCode,
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w500),
                    ),
                  ),
                  ListTile(
                    leading:Text(
                      "Total Ksh: ",
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w500,color: Colors.grey[500]),
                    ),
                    title: Text(
                      strTotalAmountUpl,
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w500),
                    ),
                  ),
                  ListTile(
                    leading:Text(
                      "Phone number: ",
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w500,color: Colors.grey[500]),
                    ),
                    title: Text(
                      "+254713593916",
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w500),
                    ),
                  ),
                  ListTile(
                    leading:Text(
                      "Take a moment and rate our agent: ",
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w500,color: Colors.grey[500]),
                    ),
                    title:

                    Text(
                      strRating,
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
            RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
    //itemBuilder: (BuildContext context, int index) {
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.cyanAccent,
              ),
              onRatingUpdate: (rating) {
                print(rating);
                setState(() {
                  strRating=rating.toString();
                });

              },
            ),
                  SizedBox(
                    height: 40,
                  ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: new MaterialButton(
                            child: setUpButtonChild(),
                            onPressed: () async {
                              senddata();
//                              lipaNaMpesa();

                              setState(() {
                                _state = 0;
//                if (_state == 0) {
                                animateButton();
                                //            }
                              });
                            },
                            elevation: 4.0,
                            minWidth: double.infinity,
                            height: 48.0,
                            color: Colors.cyan,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
            ]
              ));
        });
  }
}
