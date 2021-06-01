// @dart=2.9
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert' show json;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';

class DetailsScreen extends StatefulWidget {
  @override
  _DetailsScreenState createState() {
    return new _DetailsScreenState();
  }
}

// class SecretLoader {
//   final String secretPath;
//
//   SecretLoader({this.secretPath});
//   Future<Secret> load() {
//     return rootBundle.loadStructuredData<Secret>(this.secretPath,
//             (jsonStr) async {
//           final secret = Secret.fromJson(json.decode(jsonStr));
//           return secret;
//         });
//   }
// }
// class Secret {
//   final String apiKey;
//   Secret({this.apiKey = ""});
//   factory Secret.fromJson(Map<String, dynamic> jsonMap) {
//     return new Secret(apiKey: jsonMap["api_key"]);
//   }
// }


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
      // transactionInitialisation =
      // await MpesaFlutterPlugin.initializeMpesaSTKPush(
      //     businessShortCode: "504628", //504628
      //     transactionType: TransactionType.CustomerPayBillOnline,//CustomerBuyGoodsOnline,//CustomerPayBillOnline,
      //     amount: 7,
      //     partyA: "254713593916",
      //     partyB: "504628",
      //     //Lipa na Mpesa Online ShortCode
      //     callBackURL: Uri(
      //         scheme: "https",
      //         host: "www.homlie.co.ke",
      //         path: "/aqim/callback_url.php?strticketcode=454"),
      //     //This url has been generated from http://mpesa-requestbin.herokuapp.com/?ref=hackernoon.com for test purposes
      //     accountReference: "504628",
      //     phoneNumber: "254713593916",
      //     baseUri: Uri(scheme: "https", host: "api.safaricom.co.ke"),
      //     transactionDesc: "HOMLIE tickets",
      //     passKey: "ba95f91d4c495092444e625821fb00cc5eec70f8a4d64c0fdc95f8c23b501283");
      // //This passkey has been generated from Test Credentials from Safaricom Portal
      // debugPrint("RES__>" +transactionInitialisation.toString());
      // print("TRANSACTION RESULT: " + transactionInitialisation.toString());
      // // print("TRANSACTION RESULT: " + transactionInitialisation.toString());
      // //lets print the transaction results to console at this step
      // return transactionInitialisation;
      //

      //////////////////////////////////////////////////////////////////////////////////////////////////////
      // var url = 'https://homlie.co.ke/malakane_init/hml_getmytickets.php';
      //
      // //Run it
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
                tooltip: 'Edit ticket',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                //style: ,
                onPressed: () {
                  lipaNaMpesa();
                  },
                child: Text('INITIATE PAYMENT'),
              ),
              // child: Text("widget"),
            ),

          ],
        ),
      ),
    );
  }
}