import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:papaya/main.dart';
import 'package:papaya/screens/main_screen.dart';
import 'package:papaya/logInPage.dart';
import 'package:papaya/signUpPage.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:flushbar/flushbar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:papaya/services/initialize_sqlite.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();

}
final FirebaseAuth _auth = FirebaseAuth.instance;

final _scaffoldKey = GlobalKey<ScaffoldState>();
final TextEditingController _nameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _phoneNumberController = TextEditingController();
final TextEditingController _smsController = TextEditingController();
String _verificationId;
final SmsAutoFill _autoFill = SmsAutoFill();
class _SignUpPageState extends State<SignUpPage> {
  int _state = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String strFuid="";
  bool blVerificationCode=false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  _register() async {
    String strToken ="";

    //    _firebaseMessaging.getToken().then(
    //          (token) =>print("TOKEN HERE >"+token));

    _firebaseMessaging.getToken().then((token) {
      strToken = token.toString();
      // do whatever you want with the token here
      // Flushbar(
      //   title: "FUID messaging",
      //   message: ""+strToken,
      //   duration: Duration(seconds: 3),
      //   isDismissible: false,
      // )
      //   ..show(context);
      setState(() {
        strFuid=strToken;
      });
      setUser();

    }
    );
  }
/////////////////////////////sglite functions
  //////login sAVE

  /// Creates user Table
  Future createLoginUserTable() async {
    var dbClient = await SqliteDB().db;
    var res = await dbClient.execute("""
      CREATE TABLE loginUser(
        id INTEGER PRIMARY KEY,
        fuid TEXT,
        email TEXT UNIQUE,
        phonenumber TEXT,
        generallocation TEXT,
        latlongaddress TEXT
      )""");
    return res;
  }
  /// Add user to the table
  Future putLoginUser(String strSfuid,String strSemail,String strSphonenumber,String strSgeneralLocation,String strSlatlongaddress) async {
    /// User data
    dynamic loginuser = {
      "fuid": strSfuid,
      "email": strSemail,
      "phonenumber": strSphonenumber,
      "generallocation": strSgeneralLocation,
      "latlongaddress": strSlatlongaddress
    };

    /// Adds user to table
    final dbClient = await SqliteDB().db;
    int res = await dbClient.insert("loginUser", loginuser);
    return res;
  }



  @override
  void initState() {
    super.initState();
    _register();

  }
  Future setUser() async {
    final db = await SqliteDB().db;
    db.delete("loginUser");
    createLoginUserTable();
  }

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
              "Homlie Sign Up",
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            Visibility(
              visible: blVerificationCode == true
                  ? false
                  : true,
              child:Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(30),
                        ),
                      ),
                      filled: true,
                      prefixIcon: Icon(
                        Icons.text_fields_sharp,
                        color: Colors.cyan,
                      ),
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "Enter your name",
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
              child:Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _emailController,
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
                  onPressed: autofillPhone,
                ),
              ),
            ),


            Visibility(
              visible: blVerificationCode == true
                  ? false
                  : true,

              child:new Padding(
                padding: const EdgeInsets.all(16.0),
                //alignment: Alignment.center,
                child: new MaterialButton(

                  child: setUpButtonChild(),
                  onPressed: () async {
                    sendSignInData();
                    setState(() {
                      _state = 0;
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
            ),

            SizedBox(
              height: 10.0,
            ),

            Visibility(
              visible: blVerificationCode == true
                  ? false
                  : true,
              child:Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0),
                  child: Text(
                    "Already have an account with us?",
                  )),),
            Visibility(
              visible: blVerificationCode == true
                  ? false
                  : true,
              child:InkWell(
                child: Text(
                  'Log in',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),

                ),
                onTap: () => {
                  Navigator.pushAndRemoveUntil<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => LogInPage(),
                    ),
                        (route) => false,//if you want to disable back feature set to false
                  )
                },
              ),),


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
              child:Container(
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
              ),),


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
  void autofillPhone ()async{
    try{
      _phoneNumberController.text = await _autoFill.hint;
    } catch (j) {  }

  }
  Widget setUpButtonChild() {
    if (_state == 0) {
      return new Text(
        "Sign up with Phone Number",
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
      return  Text(
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
  void verifyPhoneNumber() async {

    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      await _auth.signInWithCredential(phoneAuthCredential);
      showSnackbar("Phone number automatically verified and user signed in: ${_auth.currentUser.uid}");
      putLoginUser(strFuid,_emailController.text,_auth.currentUser.phoneNumber,"","0.0,0.0");
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

      if (user.uid!=null) {
        Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => MyApp(),
          ),
              (
              route) => false, //if you want to disable back feature set to false
        );
        putLoginUser(strFuid,_emailController.text,user.phoneNumber,"","0.0,0.0");
      }
    } catch (e) {
      showSnackbar("Failed to sign in: " + e.toString());
    }
  }
  void showSnackbar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
  }

  ///////////////////////////// send sign in data
  /////////
  Future<String> sendSignInData() async {
    String strReturn = "";
    String strUserSignName=_nameController.text;
    String strUserSignEmail=_emailController.text;
    String strUserSignPhoneNumber=_phoneNumberController.text;

    if (strUserSignName.length < 3 ||
        strUserSignName.isEmpty ||
        strUserSignName == "") {
      Flushbar(
        title: "Invalid Name",
        message:
        "Please enter your first and last name.",
        duration: Duration(seconds: 3),
        isDismissible: false,
      )..show(context);
    }

    if (strUserSignEmail.length < 6 ||
        strUserSignEmail.isEmpty ||
        strUserSignEmail == "") {
      Flushbar(
        title: "Invalid email.",
        message: "Please enter a valid email.",
        duration: Duration(seconds: 3),
        isDismissible: false,
      )..show(context);
    }
    if (strUserSignPhoneNumber.length < 13 ||
        strUserSignPhoneNumber.isEmpty ||
        strUserSignPhoneNumber == "") {
      Flushbar(
        title: "Invalid phonenumber.",
        message: "Please enter a valid phone number starting with +254XXXXXXXXX",
        duration: Duration(seconds: 3),
        isDismissible: false,
      )..show(context);
    }
    if (strUserSignName.isNotEmpty &&
        strUserSignPhoneNumber.isNotEmpty &&
        strUserSignEmail.isNotEmpty) {
      var urlPost = 'https://homlie.co.ke/malakane_init/hml_signup.php';
      final strResponse = await http.post(Uri.parse(urlPost), body: {
        "hml_username": strUserSignName,
        "hml_userphone": strUserSignPhoneNumber,
        "hml_email": strUserSignEmail,
        "hml_notiftoken": strFuid,
        "hml_rqsttype": "Signup",
      });
      print(strResponse.body.toString());
      if (strResponse.body.toString().trim() == 'Success') {
        Flushbar(
          title: "Sign Up",
          message:
          "Your sign up is successfull, proceeding to verify your account details.",
          duration: Duration(seconds: 3),
          isDismissible: false,
        )..show(context);
        verifyPhoneNumber();
      } else {
        Flushbar(
          title: "Sign up error: "+strResponse.body.toString(),
          message: "Error. Please try again or check your email address, if you already have an account use the login page.",
          duration: Duration(seconds: 5),
          isDismissible: false,
        )..show(context);

      }
      debugPrint("|||" + strResponse.body.toString());
      strReturn = strResponse.body.toString();
    }
    return strReturn;
  }

}