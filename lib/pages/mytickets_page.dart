// @dart=2.9
import 'package:papaya/services/initialize_sqlite.dart';
import 'package:flutter/material.dart';
import 'package:papaya/screens/details_screen.dart';
import 'package:papaya/widgets/heading.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'package:papaya/widgets/progress_indicator.dart';

import 'dart:math' as math;

import 'package:papaya/widgets/progress_indicator.dart';

class MyTicketsPage extends StatefulWidget {
  MyTicketsPage() : super();

  @override
  ListViewActivity createState() {
    return new ListViewActivity();
  }
}

class ListViewActivity extends State<MyTicketsPage> {
  /////////////////////////////////back button
  Future<bool> _onWillPop() async {

    // This dialog will exit your app on saying yes
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
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
      ),
    )) ??
        false;
  }

  final List colors = [
    Colors.lightBlueAccent,
    Colors.deepPurpleAccent,
    Colors.lightGreen
  ];

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

  //////////////////////////////////////////mytickets items
  Future getData() async {
    var url = 'https://homlie.co.ke/malakane_init/hml_getmytickets.php?struseremail=';
    var response = await http.get(Uri.parse(url+strLUUserEmail));
    debugPrint("getres" + response.body);
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    getLoginUserData();
  }
  //////////////////////////////////////////notifsa items
  @override
  Widget build(BuildContext context) {
    var rng = new math.Random.secure();
    return Scaffold(
        body: WillPopScope(
            onWillPop: _onWillPop,
            child: FutureBuilder(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                    List lstMyTicketsData = snapshot.data;
                    return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 10.0),
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight),
                    child: Column(children: [
                      SizedBox(
                        height: 22,
                      ),
                      Heading(
                        text: Text(
                          "My Tickets",
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Heading(
                        text: Text(
                          "You have ${lstMyTicketsData.length} tickets",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500]),
                        ),
                      ),
                      Container(
                          child: ListView.builder(
                                        itemCount:snapshot.data.length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Padding(
                                              padding: EdgeInsets.only(
                                                  left: 8.0,
                                                  right: 8.0,
                                                  top: 0.0,
                                                  bottom: 4.0),
                                              child: Card(
                                                elevation: 1.0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0, bottom: 8),
                                                  child: ListTile(
                                                    leading: Container(
                                                      child: Center(
                                                        child: Text(
                                                          lstMyTicketsData[
                                                                      index][
                                                                  'fr_funditype']
                                                              .split(" ")[0][0],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              fontSize: 24),
                                                        ),
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(8.0),
                                                        color: lstMyTicketsData[
                                                                        index][
                                                                    'fr_funditype'] ==
                                                                "Laundry"
                                                            ? Colors
                                                                .lightBlueAccent
                                                            : lstMyTicketsData[
                                                                            index]
                                                                        [
                                                                        'fr_funditype'] ==
                                                                    "Cooking"
                                                                ? Colors
                                                                    .deepPurpleAccent
                                                                :lstMyTicketsData[
                                                        index]
                                                        [
                                                        'fr_funditype'] ==
                                                            "Cleaning"
                                                            ? Colors
                                                            .lightGreen
                                                            : Colors
                                                                    .cyan,
                                                      ),
                                                      width: 70.0,
                                                      height: 80.0,
                                                    ),
                                                    title: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Text(
                                                              lstMyTicketsData[
                                                                      index][
                                                                  'fr_funditype'],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black54,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  fontSize: 18,
                                                                  fontFamily:
                                                                      "SF"),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            // IconButton(
                                                            //   onPressed: () {},
                                                            //   icon: Icon(Icons
                                                            //       .more_vert),
                                                            // ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(

                                                              lstMyTicketsData[index]['fr_pymnt_status']=="paid"? "PAID": "NOT PAID",

//                                                              lstMyTicketsData[index]['fr_pymnt_status'],
                                                              //"${rng.nextInt(40)} items",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Container(
                                                              width: 2.0,
                                                              color: Colors
                                                                  .orange
                                                                  .withOpacity(
                                                                      0.3),
                                                              height: 15,
                                                            ),
                                                            SizedBox(
                                                              width: 8,
                                                            ),
                                                            Text(
                                                                lstMyTicketsData[
                                                                index][
                                                                'fr_createdat'],
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 18,
                                                        ),
                                                        Text(
                                                          "Ticket ID:"+ lstMyTicketsData[index]['fr_tcktcode'],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .grey[500],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 18,
                                                        ),
                                                        Text(
                                                          "Total Cost: KSh "+ lstMyTicketsData[index]['fr_strtotalprice'].toString(),
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .grey[500],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 18,
                                                        ),
                                                        Text(
                                                            lstMyTicketsData[index]['fr_fundiemail']==null? "Worker Id: Not yet assigned": "Worker Id: "+lstMyTicketsData[index]['fr_fundiemail'],

//                                                          "Worker Id: "+ lstMyTicketsData[index]['fr_fundiemail'],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors
                                                                .grey[500],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 14,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Text(
                                                             "Status: "+ lstMyTicketsData[index]['fr_status'],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      500],
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              lstMyTicketsData[index]['fr_status']=="completed"? "100 %":
                                                            lstMyTicketsData[index]['fr_status']=="waiting"? "${rng.nextInt(2)} %": "${rng.nextInt(63)} %",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .lightBlue,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 12,
                                                        ),
                                                        FAProgressBar(
                                                          size: 4,
                                                          currentValue:
                                                          lstMyTicketsData[index]['fr_status']=="completed"? 100:
                                                          lstMyTicketsData[index]['fr_status']=="waiting"? rng.nextInt(2): rng.nextInt(63),

//                                                          rng.nextInt(96),
                                                          progressColor:
                                                              Colors.lightBlue,
                                                          backgroundColor:
                                                              Color(0xffF0F0F0), changeColorValue:90,
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                      ],
                                                    ),
                                                      onTap: () => detailScreen(lstMyTicketsData[index]['fr_tcktcode'].toString()),
                                                  ),
                                                ),
                                              ));

                                          //return ProjectDetailCard();
                                        },
                                      )
                                    )
                    ]),
                  ),
                );
              },
            )
                    : Center(
                    child: CircularProgressIndicator());
              })
    )
    );
  }
  void detailScreen(String strTckCode){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailsScreen(strTckCode)));
  }

}

class _onBackPressed {
}
