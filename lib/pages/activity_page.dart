// @dart=2.9
import 'package:papaya/services/initialize_sqlite.dart';
import 'package:papaya/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:papaya/widgets/heading.dart';
import 'package:papaya/widgets/dashed_rect.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../main.dart';
import 'package:flushbar/flushbar.dart';

class ActivityPage extends StatefulWidget {

  //ActivityPage() : super();

//  final FirebaseUser user;

  //ActivityPage({this.user}) : super();

  @override
  ListViewActivity createState() {
    return new ListViewActivity();
  }
}

class ListViewActivity extends State<ActivityPage> {
  String _message = '';

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _register() {
    _firebaseMessaging.getToken().then((token) => print(token));
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  // }

  void getMessage(){
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          setState(() => _message = message["notification"]["title"]);
        }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      setState(() => _message = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => _message = message["notification"]["title"]);
    });
  }



/////////////////////////////////////////////////
  var isLoading = false;
  //final FirebaseUser user;

//  ListViewActivity({this.user});
  FirebaseAuth _auth = FirebaseAuth.instance;

  signOut() async {
    await _auth.signOut();
    // Provider.of<Auth>(context).signOut();
  }
  Future<void> _logout() async {
    await _auth.signOut().catchError((error){
      print(error.toString());
    });
    final db = await SqliteDB().db;
    db.delete("loginUser");
    Navigator.pushAndRemoveUntil<dynamic>(
      context,
      MaterialPageRoute<dynamic>(
        builder: (BuildContext context) => MyApp(),
      ),
          (route) => false,//if you want to disable back feature set to false
    );
  }
  // Future<void> _logout() async {
  //   try {
  //     await FirebaseAuth.instance.signOut();
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
  // AboutListTile(
  // icon: Icon(Icons.info,),
  // child: Text('About app'),
  // applicationIcon: Icon(Icons.local_play,),
  // applicationName: 'My Cool App',
  // applicationVersion: '1.0.25',
  // applicationLegalese: '© 2019 Company',
  // aboutBoxChildren: [
  // ///Content goes here...
  // ],
  // )
  //
  final titles = ["Laundry ticket", "First ticket", "Welcome to Homlie"];
  final subtitles = [
    "Hi, you created a laundry ticket 10 minutes ago, currently all our workers are engaged and will be ready to work on your order after 20 minutes, please bear with us as we currently have a high volume of inflows",
    "You can create your first ticket by opening the + button and just wait for the service to begin",
    "Homlie provides you with home based services curated for a cool home experience"
  ];

  ///////////////////////////////////back button
  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm action!'),
            content: Text('Are you sure you want to exit the application?'),
            actions: <Widget>[
              FlatButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  final lstNotificationTitles = [
    "HM2563CD55",
    "HM6527LY33",
    "HM3965LY87",
    "Easter Holiday",
    "HM9978LY12",
    "New service",
    "App Update",
    "HM0165CN00",
    "HM7841CG99"
  ];
  final lstNotificationSubtitles = [
    "You have created a new laundry order",
    "Your laundry order has been completed successfully, please proceed to the tickets page and complete payment",
    "Your invoice for this order has been generated successfully click on the more button to see the detailed break down",
    "Greetings from Homlie, We sincerely wish you a merry easter holiday as we celebrate the salvatio  of our Lord Jesus",
    "A service request has been generated for this order.",
    "Our esteemed client, we are happy to introduce to you the new integrated carpet cleaning as a service for your home cleaning.",
    "Hello there, we have a new update to our app version 4.1.2, feel motivated to access more features visible through this new update from playstore",
    "The ticket above was successfully edited, and a number of items added",
    "This is your first ticket, If you experience any challenges, please let us know or you can directly call us via the folliwing phone numnbers: +254713593916 or +254775961581"
  ];
  final lstNotificationColors = [
    Colors.lightBlue,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.purple
  ];
  final lstNotifMoreVisibility = [
    true,
    true,
    true,
    false,
    true,
    false,
    false,
    true,
    true
  ];
/////////////////////////////sglite functions

  ////////////////////////////////
  /// Get all users using raw query
  Future getAll() async {
    var dbClient = await SqliteDB().db;
    final res = await dbClient.rawQuery("SELECT * FROM User2 ORDER BY notif_id DESC");
    return res;
  }
  String strLUUserEmail="";
  /// Simple query with WHERE raw query
  Future getLoginUserData() async {
    var dbClient = await SqliteDB().db;
    //final res = await dbClient.rawQuery("SELECT fuid,email FROM loginUser");
    final res = await dbClient.rawQuery("SELECT fuid,email, phonenumber,generallocation,latlongaddress FROM loginUser");
    List<Map> result = await dbClient.rawQuery("SELECT fuid,email, phonenumber,generallocation,latlongaddress FROM loginUser");
    debugPrint("|||Logged in user" + result[0]["latlongaddress"].toString());
    strLUUserEmail=result[0]["email"].toString();
    return result;
  }

  // Map<List, dynamic> _loggedinuserdetails = {
  // "responseBody": [
  // {
  //   "svc_id": 107,
  //   "svc_article": "Curtain blinder",
  //   "svc_demographic": "misc",
  //   "svc_type": "Laundry",
  // }
  // ],
  // };
  // [
  //   {
  //     fuid: eZkylUGfTWuFCjPD6AzIVU:APA91bEihci2qZC4AZeB3mwiOSrSrlw05JRUT3JkCCjwq67kGY6NoDttUOh0XRfCD2nwVWGUW4zHSBqwGRk9AGczljTRwiUS5Zrhi0yUa2LBEBCp0yNpHWnJ9fcXK3LhbhWhL5yDmZum,
  //     email: clarenznet@gmail.com,
  //     phonenumber: +254713593916,
  //     generallocation: Kiambu County,Ruiru,A2,,A2,,Embu - Nairobi Highway,Embu - Nairobi Highway,
  //     latlongaddress: LatLng(-1.132274809333934, 36.97678327560425)
  //   }
  //   ]
  // Future getLoginUserData() async {
  //   var dbClient = await SqliteDB().db;
  //   final res = await dbClient.rawQuery("SELECT * FROM loginUser");
  //   Flushbar(
  //     title: "Logged In User Info",
  //     message: ""+res.toString(),
  //     duration: Duration(seconds: 10),
  //     isDismissible: false,
  //   )
  //     ..show(context);
  //   return res;
  // }

  /// Simple query with WHERE raw query
  Future getAdults() async {
    var dbClient = await SqliteDB().db;
    final res = await dbClient.rawQuery("SELECT id, name FROM User WHERE age > 18");
    Flushbar(
      title: "Logged In User Info",
      message: ""+res.toString(),
      duration: Duration(seconds: 10),
      isDismissible: false,
    )
      ..show(context);
    return res;
  }


  /// Get all using sqflite helper
  Future getAllUsingHelper() async{
    var dbClient = await SqliteDB().db;
    final res = await dbClient.query('User');
    return res;
  }


  /// Simple query with sqflite helper
  // Future getAdultsUsingHelper() async {
  //   var dbClient = await SqliteDB().db;
  //   final res = await dbClient.query('User',
  //       columns: ['id', 'name'],
  //       where: '$age > ?',
  //       whereArgs: [18]);
  //   return res;
  // }
//////////
  /// Update using raw query
  /// example :-
  /// var newAge = 28
  /// var id = "johndoe"

  /// Update using sqflite helper
  /// newData example :-
  /// var newData = {"id": "johndoe92", "name": "John Doe", "email":"abc@example.com", "age": 28}
  // Future updateUsingHelper(newData) async {
  //   var dbClient = await SqliteDB().db;
  //   var res = await dbClient.update('User',newData,
  //       where: '$id = ?', whereArgs: [newData['id']]);
  //   return res;
  // }
  ///////

  /// Delete data using raw query
  Future delete(id) async {
    var dbClient = await SqliteDB().db;
    var res = await dbClient.rawQuery("""DELETE FROM User 
                    WHERE id = '$id'; """);
    return res;
  }

  /// Delete data using sqflite helper
  Future deleteUsingHelper(id) async {
    var dbClient = await SqliteDB().db;
    var res = await dbClient.delete('User', where: 'id = ?', whereArgs: [id]);
    return res;
  }
  /////////////////////
  /// Batch insert data
  /// example:-
  /// var users = [{"id": "johndoe92", "name": "", "email": "", "age": 25}, {"id": "paul", "name": "", "email": "", "age": 22}]
  Future putUsers(users) async {
    final dbClient = await SqliteDB().db;

    /// Initialize batch
    final batch = dbClient.batch();

    /// Batch insert
    for (var i = 0; i < users.length; i++) {
      batch.insert("User2", users[i]);
    }

    /// Commit
    await batch.commit(noResult: true);

    return "success";
  }

  //////////////////////////////////////////notifs items
  Future getData() async {
    setState(() {
      isLoading = true;
    });
   var url = 'https://homlie.co.ke/malakane_init/hml_getnotifications.php?struseremail=';
   var response = await http.get(Uri.parse(url+strLUUserEmail));

//    var url = 'https://homlie.co.ke/malakane_init/hml_getnotifications.php';
  //  var response = await http.get(url);
    debugPrint("RESULTNET>>" + response.body);
    ///////////
    //return json.decode(response.body);
    final db = await SqliteDB().db;
    db.delete("User2");
    createUserTable();
    var notifs = json.decode(response.body);
    putUsers(notifs);

    setState(() {
      isLoading = false;
//      setState(() => user = _user);
    });
  }

  /// Creates user Table
  Future createUserTable() async {
    var dbClient = await SqliteDB().db;
    var res = await dbClient.execute("""
      CREATE TABLE User2(
        notif_id INTEGER PRIMARY KEY,
        user_phonenumber TEXT,
        user_email TEXT,
        notif_title TEXT,
        notif_body TEXT,
        notif_metadata TEXT,
        notif_requestid TEXT,
        notif_color INTEGER,
        notif_time TEXT
      )""");
    return res;
  }


// void test = SqliteDB().test();
  String strNoOfNotifs="";
  @override
  void initState() {
    super.initState();
    getLoginUserData();
    getData();
//    update("Murera","5090","1");
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
    getMessage();
    final fbm = FirebaseMessaging();
    fbm.requestNotificationPermissions();
    fbm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print(msg);
      return;
    }, onResume: (msg) {
      print(msg);
      return;
    });
    // var users = [{"id": "1", "name": "johndoe", "email": "johndoe@gmail.com", "age": 25}, {"id": "2", "name": "Paul", "email": "paul2@gmail.com", "age": 22}];
    // putUsers(users);
    // var notifs =[{"notif_id":590,"user_phonenumber":254775961581,"user_email":"clarenznet@gmail.com","notif_title":"New ticket created.","notif_body":"Laundry request uploaded","notif_metadata":null,"notif_requestid":"AREIPPH","notif_color":0,"notif_time":"2021-05-29 18:17:02"}];
    //debugPrint("sqlite" + users.toString());
  }

  //////////////////////////////////////////
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  //
  @override
  Widget build(BuildContext context) {
    var rng = new math.Random.secure();
    return Scaffold(
        body :WillPopScope(
            onWillPop: _onBackPressed,

            child:  RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: getData,
                child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 10.0),
                    scrollDirection: Axis.vertical,
                    //height: double.infinity,
                    child:ConstrainedBox(
                      constraints: BoxConstraints(
                        //    minHeight: viewportConstraints.maxHeight
                      ),
                      child: Column(children: [
                        SizedBox(
                          height: 22,
                        ),
                        Heading(
                          text: Text(
                            "Homlie",
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600),
                          ),
                          button: DottedBorder(
                              borderType: BorderType.RRect,
                              radius: Radius.circular(8),
                              color: Colors.lightBlue,
                              child: Center(
                                child: PopupMenuButton(
                                  //Icons.more_vert,
                                  // size: 28,
                                  //color: Colors.lightBlue,

                                    onSelected: (value) {
                                      if (value==3)  _logout();
                                      debugPrint("RPressed>>" + value.toString());
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                          value: 2,
                                          child: Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: Icon(Icons.share),
                                              ),
                                              Text("Share")
                                            ],
                                          )),
                                      PopupMenuItem(
                                          value: 3,
                                          child: Row(
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.all(5),
                                                child: Icon(Icons.logout),
                                              ),
                                              Text("Log out")
                                            ],
                                          )),
                                    ]),
                                // child: Icon(
                                //   Icons.more_vert,
                                //   size: 28,
                                //   color: Colors.lightBlue,
                                //
                                // ),

                              ),
                              strokeWidth: 1,
                              dashPattern: [3, 4]),
                        ),
                        Heading(
                          text: Text(
                            "You have "+strNoOfNotifs+" notifications",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500]),
                          ),
                        ),
                        FutureBuilder(
                            future: getAll(),//getData(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) print(snapshot.error);
                              return snapshot.hasData
                                  ? LayoutBuilder(
                                builder: (BuildContext context, BoxConstraints viewportConstraints) {
                                  List lstNotificationsData = snapshot.data;
                                  strNoOfNotifs=lstNotificationsData.length.toString();//setState(() => strNoOfNotifs=lstNotificationsData.length.toString());
                                  return Container(
                                      child: ListView.builder(
                                        itemCount: snapshot.data.length,
                                        // itemBuilder: (context,index){
                                        //   itemCount: lstNotificationTitles.length,
                                        shrinkWrap: true,
                                        //physics: PageScrollPhysics(), // this is what you are looking for
                                        scrollDirection: Axis.vertical,
                                        physics:NeverScrollableScrollPhysics(),
//                                        scrollDirection: Axis.vertical,
                                        //NeverScrollableScrollPhysics()                             //height: double.infinity,

                                        itemBuilder:
                                            (BuildContext context, int index) {
//                                          List lstNotificationsData = snapshot.data;
                                          return Card(
                                            //                        elevation: 5,
                                            //shape: Border(right: BorderSide(color: Colors.red, width: 5)),
                                            elevation: 2,
                                            child: ClipPath(
                                              child: Container(
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                      border: Border(
                                                          left: BorderSide(

                                                            //color:lstNotificationColors[rng.nextInt(4)],
                                                              color: lstNotificationColors[
                                                              lstNotificationsData[
                                                              index][
                                                              'notif_color']],
                                                              //color: lstNotificationsData[index]['notif_color']==null? Colors.blue[400]:
                                                              //lstNotificationsData[index]['notif_color']==2? Colors.blue[100]: Colors.grey,
                                                              width: 5))),
                                                  child: ListTile(
                                                    title: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        Text(
                                                          lstNotificationsData[index]
                                                          ['notif_requestid'],
                                                          style: TextStyle(
                                                              color: Colors.black54,
                                                              fontWeight:
                                                              FontWeight.w700,
                                                              fontSize: 18,
                                                              fontFamily: "SF"),
                                                          maxLines: 1,
                                                          overflow:
                                                          TextOverflow.ellipsis,
                                                        ),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        Container(
                                                          width: 2.0,
                                                          color: Colors.orange
                                                              .withOpacity(0.3),
                                                          height: 15,
                                                        ),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          lstNotificationsData[index]
                                                          ['notif_time'],
                                                          //"${rng.nextInt(30)} Apr 2021",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: lstNotificationColors[
                                                            lstNotificationsData[
                                                            index]
                                                            ['notif_color']],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: Text(
                                                      lstNotificationsData[index]
                                                      ['notif_body'],
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.grey[500],
                                                      ),
                                                    ),
                                                    //leading:
                                                    trailing: Wrap(
                                                      spacing: 12,
                                                      // space between two icons
                                                      children: <Widget>[
                                                        Visibility(
                                                            visible: lstNotificationsData[
                                                            index][
                                                            'notif_metadata'] ==
                                                                null
                                                                ? false
                                                                : true,
                                                            child: IconButton(
                                                              onPressed: () {},
                                                              icon: Icon(
                                                                  Icons.more_vert),
                                                              color: lstNotificationColors[
                                                              lstNotificationsData[
                                                              index][
                                                              'notif_color']],
                                                            )),
                                                      ],
                                                    ),
                                                    isThreeLine: true,
                                                  )),
                                              clipper: ShapeBorderClipper(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(3))),
                                            ),
                                          );
                                        },
                                      )

                                    //////////////////////swiperefesg closses

                                  );
                                  //////////
                                  /////
                                },
                              )
                                  : Center(
                                  child: CircularProgressIndicator());


                            }
                        )

                        ///////////////redfgvvvv

                        ///////////





                      ]),
                    )

                  ////////////////////////////////////

                )

            )
        )


    );

  }
}
