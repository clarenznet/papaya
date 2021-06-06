import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:papaya/onboarding/pageOne.dart';
import 'package:papaya/screens/main_screen.dart';
import 'package:sms_autofill/sms_autofill.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StreamBuilder(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (ctx, userSnapshot) {
            if (userSnapshot.hasData) {
              debugPrint("USERSNAPSHOT>" + userSnapshot.toString());
            return MainScreen();
            } else if (userSnapshot.hasError) {
              return CircularProgressIndicator();
            }
            return  PageOne();
          },
        )
    );
  }
}

