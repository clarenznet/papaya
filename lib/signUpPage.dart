// @dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String strPhoneNumber="", strVerificationId="",strEmail="";
  String strOtp="", authStatus = "";

  Future<void> verifyPhoneNumber(BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: strPhoneNumber,
      timeout: const Duration(seconds: 15),
      verificationCompleted: (AuthCredential authCredential) {
        setState(() {
          authStatus = "Your account is successfully verified";
        });
      },
      verificationFailed: (AuthException authException) {
        setState(() {
          authStatus = "Authentication failed";
        });
      },
      codeSent: (String verId, [int forceCodeResent]) {
        strVerificationId = verId;
        setState(() {
          authStatus = "OTP has been successfully send";
        });
        otpDialogBox(context).then((value) {});
      },
      codeAutoRetrievalTimeout: (String verId) {
        strVerificationId = verId;
        setState(() {
          authStatus = "TIMEOUT";
        });
      },
    );
  }

  otpDialogBox(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter your OTP Code'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                decoration: InputDecoration(
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(30),
                    ),
                  ),
                ),
                onChanged: (value) {
                  strOtp = value;
                },
              ),
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  signIn(strOtp);
                },
                child: Text(
                  'Submit',
                ),
              ),
            ],
          );
        });
  }

  Future<void> signIn(String otp) async {
    await FirebaseAuth.instance
        .signInWithCredential(PhoneAuthProvider.getCredential(
      verificationId: strVerificationId,
      smsCode: otp,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            Text(
              "Homlie Signin 📱",
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Image.network(
              "https://homlie.co.ke/img/favicon.png",
              height: 150,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(30),
                      ),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.alternate_email,
                      color: Colors.cyan,
                    ),
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: "Enter Your Email Address...",
                    fillColor: Colors.white70),
                onChanged: (value) {
                  strEmail = value;
                },
              ),

            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                keyboardType: TextInputType.phone,
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(30),
                      ),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.phone_iphone,
                      color: Colors.cyan,
                    ),
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: "Enter Your Phone Number...",
                    fillColor: Colors.white70),
                onChanged: (value) {
                  strPhoneNumber = value;
                },
              ),

            ),

            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              onPressed: () =>
              strPhoneNumber == null ? null : verifyPhoneNumber(context),
              child: Text(
                "Next",
                style: TextStyle(color: Colors.white),
              ),
              elevation: 7.0,
              color: Colors.cyan,
            ),
            SizedBox(
              height: 20,
            ),
            Text("Need Help?"),
            SizedBox(
              height: 20,
            ),
            Text(
              "Please enter the phone number with country code e.g +254XXXXXXXXXX",
              style: TextStyle(color: Colors.green),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              authStatus == "" ? "" : authStatus,
              style: TextStyle(
                  color: authStatus.contains("fail") ||
                      authStatus.contains("TIMEOUT")
                      ? Colors.red
                      : Colors.green),
            )
          ],
        ),
      ),
    );
  }


}
