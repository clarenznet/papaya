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
import 'package:papaya/services/initialize_sqlite.dart';
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

  Future<void> lipaNaMpesa(double _Amount,String strPhonenumber,String strAccRefer,String strTransDesc) async {
    dynamic transactionInitialisation;
    debugPrint("RES__>" + transactionInitialisation.toString());
    try {
      const CustomerBuyGoodsOnline = "CustomerBuyGoodsOnline";
      transactionInitialisation =
          await MpesaFlutterPlugin.initializeMpesaSTKPush(
              businessShortCode: "504628",
              //transactionType: TransactionType.CustomerBuyGoodsOnline,
              amount: _Amount,
              partyA: strPhonenumber,
              partyB: "507984",
              callBackURL: Uri.parse(
                  ""),
              accountReference: strAccRefer,
              phoneNumber: strPhonenumber,
              baseUri: Uri.parse("https://api.safaricom.co.ke"),
              //baseUrl: "https://sandbox.safaricom.co.ke/",
              transactionDesc: strTransDesc,
              passKey:
                  "");
      print("TRANSACTION RESULT: " + transactionInitialisation.toString());
      /*Update your db with the init data received from initialization response,
      * Remaining bit will be sent via callback url*/
      return transactionInitialisation;
    } catch (e) {
      //lets print the error to console for this sample demo
      print("CAUGHT EXCEPTION: " + e.toString());
    }
  }

  Future getDetailsData(String strTcktCode) async {
    debugPrint("started detals !!!!");

    var url =
        'https://homlie.co.ke/malakane_init/hml_getticketdetails.php?strtcktcode=';
    var response = await http.get(Uri.parse(url + strTcktCode));
    debugPrint("detals !!!!" + response.body);
    return json.decode(response.body);
  }
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());

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
  refr(){
    getDetailsData(widget.strTcktCode);
  }

  var lstItemsDetails = new Map();
String strTotalAmountUpl="",strUserPhoneNoUpl="",strUserEmailUpl="",strRatingUpl="";
TextEditingController _paymentPhonenumberController = TextEditingController();
  bool _isTextFieldPhonenumberEnable = false;
  bool blVerificationCode=true;

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
//                 if (
//                 lstDetails[0]["fr_status"].toString().trim()=="Waiting") {
//
//                   const oneSec = const Duration(seconds:30);
//                   new Timer.periodic(oneSec, (t) => getDetailsData(widget.strTcktCode));
//
//                 }
//                 if (t != null && lstDetails[0]["fr_status"].toString().trim()!="Waiting")t.cancel();


//                       Flushbar(
//                         title: "Agent matching.",
//                         message:
//                         "please wait a moment for us to assign an agent to your work.",
//                         duration: Duration(seconds: 3),
//                         isDismissible: false,
//                       )..show(context);
//                 }
                markers.add(resultMarker);
                // lstItemsDetails=lstDetails[0]["fr_taskdetail"] as Map;
//      lstDetails[0]["fr_taskdetail"]
                      //  List lstItems=lstDetails[0]["fr_taskdetail"];
                      debugPrint(
                          "taskdetailitems" + lstItemsDetails.toString());
                      return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 10.0),
                scrollDirection: Axis.vertical,


                child:  Column(
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
                          Visibility(
                            //blVerificationCode == true

                          visible: lstDetails[0]["fr_status"].toString().trim()=="Waiting" ? false
                                : true,
                          child: Column(
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
                              ]),            ),
                          Visibility(
                            //blVerificationCode == true

                            visible: lstDetails[0]["fr_status"].toString().trim()=="Waiting" ? false
                                : true,

                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: new MaterialButton(
                               child: Text(
                                  " Complete Ticket ",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),
                                ),
                                onPressed: () async {
                                getLoginUserData();
                              },
                              elevation: 4.0,
                              minWidth: double.infinity,
                              height: 48.0,
                              color: Colors.cyan,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),),
                        ],
                )
                      );

              })
                  : Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }

  Future getLoginUserData() async {
    var dbClient = await SqliteDB().db;
    //final res = await dbClient.rawQuery("SELECT fuid,email FROM loginUser");
    final res = await dbClient.rawQuery(
        "SELECT fuid,email, phonenumber,generallocation,latlongaddress FROM loginUser");
    List<Map> result = await dbClient.rawQuery(
        "SELECT fuid,email, phonenumber,generallocation,latlongaddress FROM loginUser");
    debugPrint("|||Logged in user" + result[0]["latlongaddress"].toString());
/////
    setState(() {
      strUserEmailUpl = result[0]["email"].toString();
      strUserPhoneNoUpl = result[0]["phonenumber"].toString();
      _paymentPhonenumberController.text=strUserPhoneNoUpl.replaceAll(new RegExp(r'[^\w\s]+'),'');//replaceAll("[^0-9]+","");//replaceAll("[\\D]", "");

    });
    _show(context);
  }

  void _show(BuildContext ctx) {
    int intTotalPrice = 0;
    int _state = 0;
    String strReturn = "";
///////////////////////
    /////////
    Future<String> completeTicket() async {
      if (_paymentPhonenumberController.text.isEmpty ||_paymentPhonenumberController.text.length<10 || _paymentPhonenumberController.text.length>12) {
        Flushbar(
          title: "Invalid phonenumber use formart: 254XXXXXXXXX",
          message:
          "Please check your payment phone number and try again.",
          duration: Duration(seconds: 3),
          isDismissible: false,
        )..show(context);
      }

      if ( _paymentPhonenumberController.text.isNotEmpty &&
          _paymentPhonenumberController.text != ""
          ) {
        var urlPost = 'https://homlie.co.ke/malakane_init/hml_completeticket.php';
        final strResponse = await http.post(Uri.parse(urlPost), body: {
          // "fr_useremail": strUserEmailUpl, //fr_useremail,
          // "fr_userphone": strUserPhoneNoUpl, //fr_userphone",
          "uppymnt_rating": strRatingUpl, //fr_funditype",
          "uppymnt_phonenumber": _paymentPhonenumberController.text,
          "uppymnt_ticketno": widget.strTcktCode,
          "uppymnt_invoicetotal": strTotalAmountUpl,
        });
        print(strResponse.body.toString());
        if (strResponse.body.toString() == "Error") {
          Flushbar(
            title: "Ticket",
            message: "Error. Please try again.",
            duration: Duration(seconds: 3),
            isDismissible: false,
          )..show(context);
        } else if(strResponse.body.toString().trim()=="Success") {
          Navigator.pop(context);
          Flushbar(
            title: "Ticket",
            message:
            "please wait for mpesa STK pop up and enter your pin to complete payment.",
            duration: Duration(seconds: 3),
            isDismissible: false,
          )..show(context);
          double _Amount=double.parse(strTotalAmountUpl);
          lipaNaMpesa(_Amount,_paymentPhonenumberController.text, widget.strTcktCode, "Homlie ticket");

        }
        else{
          Flushbar(
            title: "Error",
            message:
            "please try again later or contact support desk.",
            duration: Duration(seconds: 3),
            isDismissible: false,
          )..show(context);

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
    void enableTextField(){

      setState(() { _isTextFieldPhonenumberEnable = true; });
      Navigator.of(context).pop();
      _show(context);

    }

////////////////////////////////////////////////////////////////

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
                    title:
                    TextField(
                      enabled: _isTextFieldPhonenumberEnable,
                      // focusNode: FocusNode(),
                      // enableInteractiveSelection: false,
                      controller: _paymentPhonenumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: "lipa na mpesa phonenumber",
                          border: new OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10),
                            ),
                          ),
                          filled: true,
                          hintStyle: new TextStyle(fontSize: 14, color: Colors.grey[800]),
                          hintText: "formart: 254X XXXX XXXX",
                          fillColor: Colors.white70),
                    ),
                    trailing:
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                      ),
                      iconSize: 30,
                      color: Colors.lightBlue,
                      splashColor: Colors.purple,
                      onPressed: () {
                        enableTextField();

                      },

                    ),

                  ),
                  ListTile(
                    leading:Text(
                      "Take a moment and rate our agent ",
                      style: TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w500,color: Colors.grey[500]),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
            RatingBar.builder(
              initialRating: 3,
              minRating: 0.5,
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
                  strRatingUpl=rating.toString();
                  // Flushbar(
                  //   title: "Rating",
                  //   message:
                  //   strRatingUpl,
                  //   duration: Duration(seconds: 1),
                  //   isDismissible: false,
                  // )..show(context);
                  //

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
                              completeTicket();
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
