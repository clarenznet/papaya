
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/main_screen.dart';
import 'package:papaya/homePage.dart';
import 'signUpPage.dart';
import 'package:mpesa_flutter_plugin/mpesa_flutter_plugin.dart';
//void main() => runApp(MyApp());
void main() async {
  MpesaFlutterPlugin.setConsumerKey("GmF0l26wLvGHA0wDwTeZSoNdVp8VZQmU");
  MpesaFlutterPlugin.setConsumerSecret("AFIrVoUgIvSMlRv7");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
//      debugShowCheckedModeBanner: false,
//      title: 'Homlie',
      //home: MainScreen(),
//      home: MyHomePage(title: 'Phone Authentication'),
      //home: SignUpPage(),
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData) {
              return HomePage();
            } else if (userSnapshot.hasError) {
              return CircularProgressIndicator();
            }
            return MainScreen();
          },
        )

    );
  }
}
