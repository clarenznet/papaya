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
import 'package:share/share.dart';

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
 final lstNotificationColors = [
    Colors.lightBlue,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.purple
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
    debugPrint("RESULTNET>>" + response.body);
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
  Future getMenuData() async {
    setState(() {
      isLoading = true;
    });
    var url = 'https://homlie.co.ke/malakane_init/hml_getlaundryitems.php';
    var response = await http.get(Uri.parse(url));
    debugPrint("MainMenuy1" + response.body);
//    List<dynamic> ret = json.decode(response.body);
  //  List<Map<String, dynamic>> _servicesMenu = ret.map((value) => value as Map<String, dynamic>).toList();
    Map<String, dynamic> _servicesMenu = json.decode(response.body);//await http.get(Uri.parse(url));
 //   Map<String, dynamic> ret = json.decode(response.toString());
    debugPrint("MainMenuy2" + response.body);
    final db = await SqliteDB().db;
    db.delete("LaundryMenu");
    createLaundryMenuTable();
    var laundries = _servicesMenu['laundry'];
    debugPrint("MainMenuy3" + laundries.toString());
    putLaundryMenu(laundries);

    db.delete("CookingMenu");
    createCookingMenuTable();
    var cookings = _servicesMenu['cooking'];
    debugPrint("MainMenuy4" + cookings.toString());
    putCookingMenu(cookings);

    db.delete("CleaningMenu");
    createCleaningMenuTable();
    var cleanings = _servicesMenu['cleaning'];
    debugPrint("MainMenuy5" + cleanings.toString());
    putCleaningMenu(cleanings);

    setState(() {
      isLoading = false;
//      setState(() => user = _user);
    });
  }
  /// Creates user Table
  Future createLaundryMenuTable() async {
    var dbClient = await SqliteDB().db;
    var res = await dbClient.execute("""
      CREATE TABLE LaundryMenu(
        svc_id INTEGER PRIMARY KEY,
        svc_article TEXT,
        svc_demographic TEXT,
        svc_type TEXT,
        svc_price INTEGER,
        svc_noitemselected INTEGER,
        svc_articleiconurl TEXT,
        svc_status TEXT,
        svc_createdat TEXT,
        svc_updatedat TEXT
        
      )""");
    return res;
  }
  /////////////////////
  /// Batch insert data
  /// example:-
  /// var users = [{"id": "johndoe92", "name": "", "email": "", "age": 25}, {"id": "paul", "name": "", "email": "", "age": 22}]
  Future putLaundryMenu(laundries) async {
    final dbClient = await SqliteDB().db;
    /// Initialize batch
    final batch = dbClient.batch();
    /// Batch insert
    for (var i = 0; i < laundries.length; i++) {
      batch.insert("LaundryMenu", laundries[i]);
    }
    /// Commit
    await batch.commit(noResult: true);
    return "success";
  }
  /// Creates user Table
  Future createCookingMenuTable() async {
    var dbClient = await SqliteDB().db;
    var res = await dbClient.execute("""
      CREATE TABLE CookingMenu(
        ckng_id INTEGER PRIMARY KEY,
        svc_id TEXT,
        svc_article TEXT,
        svc_demographic TEXT,
        svc_type TEXT,
        svc_price INTEGER,
        svc_noitemselected INTEGER,
        svc_articleiconurl TEXT,
        svc_status TEXT,
        svc_createdat TEXT,
        svc_updatedat TEXT
        
      )""");
    return res;
  }
  /////////////////////
  Future putCookingMenu(cookings) async {
    final dbClient = await SqliteDB().db;
    /// Initialize batch
    final batch = dbClient.batch();
    /// Batch insert
    for (var i = 0; i < cookings.length; i++) {
      batch.insert("CookingMenu", cookings[i]);
    }
    /// Commit
    await batch.commit(noResult: true);
    return "success";
  }
  /// Creates user Table
  Future createCleaningMenuTable() async {
    var dbClient = await SqliteDB().db;
    var res = await dbClient.execute("""
      CREATE TABLE CleaningMenu(
        clng_id INTEGER PRIMARY KEY,
        svc_id TEXT,
        svc_article TEXT,
        svc_demographic TEXT,
        svc_type TEXT,
        svc_price INTEGER,
        svc_noitemselected INTEGER,
        svc_articleiconurl TEXT,
        svc_status TEXT,
        svc_createdat TEXT,
        svc_updatedat TEXT
        
      )""");
    return res;
  }
  /////////////////////
  Future putCleaningMenu(cleanings) async {
    final dbClient = await SqliteDB().db;
    /// Initialize batch
    final batch = dbClient.batch();
    /// Batch insert
    for (var i = 0; i < cleanings.length; i++) {
      batch.insert("CleaningMenu", cleanings[i]);
    }
    /// Commit
    await batch.commit(noResult: true);
    return "success";
  }
// void test = SqliteDB().test();
  String strNoOfNotifs="";
  @override
  void initState() {
    getLoginUserData();
    getData();
    getMenuData();
//    update("Murera","5090","1");
    super.initState();
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
  final String _content =
      'You can get you laundry done, food cooked and even house space cleaned using Homlie services app on play store.';
  void _shareContent() {
    Share.share(_content);
  }
  //////////////////////////////////////////
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
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
                                      if (value==3) _logout();
                                      debugPrint("RPressed>>" + value.toString());
                                      if (value==2) _shareContent();
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
                                            elevation: 1,
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

                      ]),
                    )

                )

            )
        )
    );

  }
}
