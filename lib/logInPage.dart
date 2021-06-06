import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:papaya/main.dart';
import 'package:papaya/screens/main_screen.dart';
import 'package:papaya/signUpPage.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LogInPage extends StatefulWidget {
  LogInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LogInPageState createState() => _LogInPageState();

}
final FirebaseAuth _auth = FirebaseAuth.instance;

final _scaffoldKey = GlobalKey<ScaffoldState>();

final TextEditingController _phoneNumberController = TextEditingController();
final TextEditingController _smsController = TextEditingController();
String _verificationId;
final SmsAutoFill _autoFill = SmsAutoFill();
class _LogInPageState extends State<LogInPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
 // String strPhoneNumber="";
bool blVerificationCode=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    key: _scaffoldKey,
    resizeToAvoidBottomInset: false,
    body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            Text(
              "Homlie Log In",
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
            Visibility(
              visible: blVerificationCode == true
                  ? false
                  : true,
              child:
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
                    hintText: "Enter your email address",
                    fillColor: Colors.white70),
                onChanged: (value) {
//                  strEmail = value;
                },
              ),

            ),),
            Visibility(
              visible: blVerificationCode == true
                  ? false
                  : true,
              child:ListTile(
              title: TextField(
                controller: _phoneNumberController,
//                decoration: const InputDecoration(labelText: 'Phone number (+xx xxx-xxx-xxxx)'),

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
                    hintText: "Enter your phone Number e.g +254xxxxxxxxx",
                    fillColor: Colors.white70),
               // onChanged: (value) {
                 // strPhoneNumber = value;
                //},
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_down_sharp,
                ),
                iconSize: 30,
                color: Colors.lightBlue,
                splashColor: Colors.purple,
                onPressed: () async => {
                  _phoneNumberController.text = await _autoFill.hint
                },
              ),
              ),
    ),

      Visibility(
        visible: blVerificationCode == true
            ? false
            : true,
        child:Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              alignment: Alignment.center,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                color: Colors.cyan,
                child: Text("Log in with Phone Number"),
                onPressed: () async {
                  verifyPhoneNumber();
                },
              ),
            ),),
            SizedBox(
              height: 10.0,
            ),
      Visibility(
        visible: blVerificationCode == true
            ? false
            : true,

             child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0),
                  child: Text(
                    "No Account?",
                  )),),
      Visibility(
        visible: blVerificationCode == true
            ? false
            : true,

    child: InkWell(
                child: Text(
                  'Sign up',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),

                ),
                onTap: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(),

                    ),
                  )
                },
              ),
      ),

            SizedBox(
              height: 20,
            ),
      Visibility(
        visible: blVerificationCode,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _smsController,
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(30),
                      ),
                    ),
                    filled: true,
                    prefixIcon: Icon(
                      Icons.keyboard,
                      color: Colors.cyan,
                    ),
                    hintStyle: new TextStyle(color: Colors.grey[800]),
                    hintText: "Verification code",
                    fillColor: Colors.white70),
              ),

            ),
      ),
            Visibility(
              visible: blVerificationCode,
             child: Container(
            padding: const EdgeInsets.only(top: 16.0),
            alignment: Alignment.center,
            child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                color: Colors.cyan,
            onPressed: () async {
            signInWithPhoneNumber();
            },
            child: Text("Verify")),
            ),
    ),

            // Text(
            //   authStatus == "" ? "" : authStatus,
            //   style: TextStyle(
            //       color: authStatus.contains("fail") ||
            //           authStatus.contains("TIMEOUT")
            //           ? Colors.red
            //           : Colors.green),
            // )
          ],
        ),
      ),
    );
  }

  void verifyPhoneNumber() async {

    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);
      showSnackbar("Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => MyApp(),
        ),
            (route) => false,//if you want to disable back feature set to false
      );
    };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      showSnackbar('Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}');
    };
    //Callback for when the code is sent
    PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      showSnackbar('Please check your phone for the verification code.');
      _verificationId = verificationId;
      setState(() {
        blVerificationCode = true;
      });
    };
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      showSnackbar("verification code: " + verificationId);
      _verificationId = verificationId;
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: _phoneNumberController.text,
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      showSnackbar("Failed to Verify Phone Number: ${e}");
    }
  }
  void signInWithPhoneNumber() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _smsController.text,
      );

      final User user = (await _auth.signInWithCredential(credential)).user;

      showSnackbar("Successfully signed in UID: ${user.uid}");
      debugPrint("PHONE>" + user.phoneNumber);
      debugPrint("UID>" + user.uid);

      if (user.uid!=null)
      Navigator.pushAndRemoveUntil<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => MyApp(),
        ),
            (route) => false,//if you want to disable back feature set to false
      );

    } catch (e) {
      showSnackbar("Failed to sign in: " + e.toString());
    }
  }
  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }
}