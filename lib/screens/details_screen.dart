// @dart=2.9
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
import 'dart:async';
import 'package:http/http.dart' as http;


class DetailsScreen extends StatefulWidget {
  final String strTcktCode;//if you have multiple values add here
  DetailsScreen(this.strTcktCode, {Key key}): super(key: key);//add also..example this.abc,this...
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
    debugPrint("RES__>" +transactionInitialisation.toString());
    try {
      const CustomerBuyGoodsOnline="CustomerBuyGoodsOnline";
      transactionInitialisation =
      await MpesaFlutterPlugin.initializeMpesaSTKPush(
          businessShortCode: "504628",
          //transactionType: TransactionType.CustomerBuyGoodsOnline,
          amount: 7,
          partyA: "254713593916",
          partyB: "507984",
          callBackURL: Uri.parse("https://www.homlie.co.ke/aqim/callback_url.php?strticketcode=56"),
          accountReference: "HM8799",
          phoneNumber: "254713593916",
          baseUri: Uri.parse("https://api.safaricom.co.ke"),
          //baseUrl: "https://sandbox.safaricom.co.ke/",
          transactionDesc: "purchase",
          passKey: "ba95f91d4c495092444e625821fb00cc5eec70f8a4d64c0fdc95f8c23b501283");
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
  Future getData(String strTcktCode) async {
    var url = 'https://homlie.co.ke/malakane_init/hml_getticketdetails.php?strtcktcode=';
    var response = await http.get(Uri.parse(url+strTcktCode));
    debugPrint("getres" + response.body);
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    getData(widget.strTcktCode);  }
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
                  //_refreshIndicatorKey.currentState.show();
                }),
          ],
    ),
    body: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                'Screen 2',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                ),
              ),
              margin: EdgeInsets.all(16),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              //alignment: Alignment.center,

              child: new MaterialButton(

                child: setUpButtonChild(),
                onPressed: () async {
                  lipaNaMpesa();
                  setState(() {
                    _button_state = 0;
//                if (_state == 0) {
                    animateButton();
                    //            }

                  });
                },
                elevation: 4.0,
//                minWidth: double.infinity,
                height: 48.0,
                color: Colors.cyan,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),

              ),
            ),

          ],
        ),
      ),
    );
  }
  Widget setUpButtonChild() {

    if (_button_state == 0) {
      return new Text(
        "       Lipa Na Mpesa       ",
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
      return  Text(
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
}