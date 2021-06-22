// @dart=2.9

import 'dart:ffi';
import 'dart:ui';
import 'package:papaya/services/initialize_sqlite.dart';
import 'package:flutter/material.dart';
import 'package:papaya/const/_const.dart';
import 'package:papaya/screens/getplacepin.dart';
import 'package:papaya/widgets/heading.dart';
import 'package:papaya/widgets/dashed_rect.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart' as geocode;
import 'dart:async';
import 'package:flushbar/flushbar.dart';

class CookingTab extends StatefulWidget {
  @override
  ListViewActivity createState() {
    return new ListViewActivity();
  }
}

class ListViewActivity extends State<CookingTab> {
  ///////// add items to list
  //////////////////////////////////////////////////////////////////
  final lstNoOfItemsSelected = [];
  List lstNoItems = [];

  final icons = [Icons.ac_unit, Icons.access_alarm, Icons.access_time];
  String strSelectedVal = "All Items";

///////
  ////drop down menu
  List _itemcategory = ["all"];
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentItem = "";
  int _itemCount = 0;
  int a = 0;

  //////////////////////////////////////////laundry items data
  Future getData() async {
    var url = 'https://homlie.co.ke/malakane_init/hml_getlaundryitems.php';
    var response = await http.get(Uri.parse(url));
    debugPrint("getres" + response.body);
    return json.decode(response.body);
  }

  //////////////////////////////////////////laundry items data
  //String strNoCounter="";
  @override
  void initState() {
    _dropDownMenuItems = getDropDownMenuItems();
    _currentItem = _dropDownMenuItems[0].value.toString();
    getAll();
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String strItem in _itemcategory) {
      items.add(new DropdownMenuItem(value: strItem, child: new Text(strItem)));
    }
    return items;
  }

  List dts = [];

  Future getAll() async {
    var dbClient = await SqliteDB().db;
    final ret = await dbClient
        .rawQuery("SELECT * FROM CookingMenu ORDER BY ckng_id ASC");
    // dts=ret;
    // for (var i = 0; i < dts.length; i++) {
    //   //  lstRawData.add([i]['svc_noofitems']=5;
    //   lstSelectedRawData[dts[i]["svc_id"]] =
    //   dts[i]["svc_noitemselected"];
    // }
    return ret;
  }

  Map<String, dynamic> _laundries = {
    "responseCode": "1",
    "responseText": "List categories.",
    "responseBody": [
      {
        "svc_id": 107,
        "svc_article": "Curtain blinder",
        "svc_demographic": "misc",
        "svc_type": "Laundry",
        "svc_price": 20,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Curtainblindermisc.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:50:06",
        "svc_updatedat": "2020-11-26 12:50:06"
      },
      {
        "svc_id": 106,
        "svc_article": "Heavy curtain ",
        "svc_demographic": "misc",
        "svc_type": "Laundry",
        "svc_price": 30,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Heavycurtainmisc.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:49:03",
        "svc_updatedat": "2020-11-26 12:49:03"
      },
      {
        "svc_id": 104,
        "svc_article": "Blanket",
        "svc_demographic": "misc",
        "svc_type": "Laundry",
        "svc_price": 100,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Blanketmisc.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:46:57",
        "svc_updatedat": "2020-11-26 12:46:57"
      },
      {
        "svc_id": 103,
        "svc_article": "Pillow case",
        "svc_demographic": "misc",
        "svc_type": "Laundry",
        "svc_price": 5,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Pillowcasemisc.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:46:25",
        "svc_updatedat": "2020-11-26 12:46:25"
      },
      {
        "svc_id": 102,
        "svc_article": "Bed sheet",
        "svc_demographic": "misc",
        "svc_type": "Laundry",
        "svc_price": 30,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Bedsheetmisc.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:45:24",
        "svc_updatedat": "2020-11-26 12:45:24"
      },
      {
        "svc_id": 101,
        "svc_article": "Vest",
        "svc_demographic": "mens",
        "svc_type": "Laundry",
        "svc_price": 10,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Vestmens.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:44:28",
        "svc_updatedat": "2020-11-26 12:44:28"
      },
      {
        "svc_id": 100,
        "svc_article": "Pair of socks",
        "svc_demographic": "unisex",
        "svc_type": "Laundry",
        "svc_price": 5,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Pairofsocksunisex.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:42:15",
        "svc_updatedat": "2020-11-26 12:42:15"
      },
      {
        "svc_id": 99,
        "svc_article": "Heavy jacket",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 40,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Heavyjacketladies.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:41:01",
        "svc_updatedat": "2020-11-26 12:41:01"
      },
      {
        "svc_id": 98,
        "svc_article": "Heavy jacket",
        "svc_demographic": "mens",
        "svc_type": "Laundry",
        "svc_price": 40,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Heavyjacketmens.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:40:25",
        "svc_updatedat": "2020-11-26 12:40:25"
      },
      {
        "svc_id": 97,
        "svc_article": "Light jacket\/coat",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 25,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Lightjacket\/coatladies.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:39:18",
        "svc_updatedat": "2020-11-26 12:39:18"
      },
      {
        "svc_id": 96,
        "svc_article": "Light jacket\/coat",
        "svc_demographic": "mens",
        "svc_type": "Laundry",
        "svc_price": 25,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Lightjacket\/coatmens.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:38:23",
        "svc_updatedat": "2020-11-26 12:38:23"
      },
      {
        "svc_id": 95,
        "svc_article": "Jeans skirt",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 20,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Jeansskirtladies.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:37:25",
        "svc_updatedat": "2020-11-26 12:37:25"
      },
      {
        "svc_id": 94,
        "svc_article": "Jeans trouser",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 30,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Jeanstrouserladies.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:36:37",
        "svc_updatedat": "2020-11-26 12:36:37"
      },
      {
        "svc_id": 93,
        "svc_article": "Jeans trouser",
        "svc_demographic": "mens",
        "svc_type": "Laundry",
        "svc_price": 30,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Jeanstrousermens.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:35:30",
        "svc_updatedat": "2020-11-26 12:35:30"
      },
      {
        "svc_id": 92,
        "svc_article": "Jeans shirt",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 25,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Jeansshirtladies.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:34:14",
        "svc_updatedat": "2020-11-26 12:34:14"
      },
      {
        "svc_id": 91,
        "svc_article": "Jeans shirt",
        "svc_demographic": "mens",
        "svc_type": "Laundry",
        "svc_price": 25,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Jeansshirtmens.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:33:25",
        "svc_updatedat": "2020-11-26 12:33:25"
      },
      {
        "svc_id": 90,
        "svc_article": "Sweater",
        "svc_demographic": "mens",
        "svc_type": "Laundry",
        "svc_price": 25,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Sweatermens.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:30:28",
        "svc_updatedat": "2020-11-26 12:30:28"
      },
      {
        "svc_id": 89,
        "svc_article": "Sweater",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 25,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Sweaterladies.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:29:54",
        "svc_updatedat": "2020-11-26 12:29:54"
      },
      {
        "svc_id": 88,
        "svc_article": "Cotton shirt",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 15,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Cottonshirtladies.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:22:51",
        "svc_updatedat": "2020-11-26 12:22:51"
      },
      {
        "svc_id": 87,
        "svc_article": "Ankara trouser",
        "svc_demographic": "mens",
        "svc_type": "Laundry",
        "svc_price": 20,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Ankaratrousermens.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:21:39",
        "svc_updatedat": "2020-11-26 12:21:39"
      },
      {
        "svc_id": 86,
        "svc_article": "Ankara top",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 15,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Ankaratopladies.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:20:03",
        "svc_updatedat": "2020-11-26 12:20:03"
      },
      {
        "svc_id": 85,
        "svc_article": "Cotton trouser",
        "svc_demographic": "mens",
        "svc_type": "Laundry",
        "svc_price": 20,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Cottontrousermens.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:19:19",
        "svc_updatedat": "2020-11-26 12:19:19"
      },
      {
        "svc_id": 84,
        "svc_article": "Khaki trouser",
        "svc_demographic": "mens",
        "svc_type": "Laundry",
        "svc_price": 20,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Khakitrousermens.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:16:40",
        "svc_updatedat": "2020-11-26 12:16:40"
      },
      {
        "svc_id": 81,
        "svc_article": "Khaki trouser",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 20,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Khakitrouser.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 12:04:14",
        "svc_updatedat": "2020-11-26 12:04:14"
      },
      {
        "svc_id": 79,
        "svc_article": "Dress",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 20,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Dress.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 11:57:38",
        "svc_updatedat": "2020-11-26 11:57:38"
      },
      {
        "svc_id": 77,
        "svc_article": "Ankara trouser",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 20,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Ankaratrouser.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 11:54:00",
        "svc_updatedat": "2020-11-26 11:54:00"
      },
      {
        "svc_id": 75,
        "svc_article": "Cotton shirt",
        "svc_demographic": "mens",
        "svc_type": "Laundry",
        "svc_price": 15,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Cottonshirt.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 11:47:45",
        "svc_updatedat": "2020-11-26 11:47:45"
      },
      {
        "svc_id": 74,
        "svc_article": "Cotton trouser",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 20,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Cottontrouser.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 11:45:18",
        "svc_updatedat": "2020-11-26 11:45:18"
      },
      {
        "svc_id": 66,
        "svc_article": "Blouse",
        "svc_demographic": "ladies",
        "svc_type": "Laundry",
        "svc_price": 15,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Blouse.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 11:27:11",
        "svc_updatedat": "2020-11-26 11:27:11"
      },
      {
        "svc_id": 65,
        "svc_article": "T shirt",
        "svc_demographic": "unisex",
        "svc_type": "Laundry",
        "svc_price": 15,
        "svc_noitemselected": 0,
        "svc_articleiconurl":
        "https:\/\/www.homlie.instrov.com\/uploads\/serviceitem_icons\/Tshirt.png",
        "svc_status": 1,
        "svc_createdat": "2020-11-26 11:25:28",
        "svc_updatedat": "2020-11-26 11:25:28"
      }
    ],
    "responseTotalResult":
    3 // Total result is 3 here becasue we have 3 categories in responseBody.
  };

////////////////////////////////////////////////////////////////////////////////
  var lstSelectedRawData = new Map();
  List lstRawData = [];
  List lstLaundryData = [];
  List lstSelectedArticles = [];

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

  @override
  Widget build(BuildContext context) {
    var rng = new math.Random.secure();
    return Scaffold(
        body: Container(
            color: Colors.deepPurpleAccent,
            //padding: new EdgeInsets.all(10.0),
            padding:
            EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 4.0),
            child: FutureBuilder(
                future: getAll(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) print(snapshot.error);
                  return snapshot.hasData
                      ? LayoutBuilder(builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    //lstNoOfItemsSelected=[];
                    debugPrint("Selected item>>>>" + _currentItem);
                    lstRawData =
                        snapshot.data; // _laundries['responseBody'];
                    List lstFilteredLaundryData = [];
                    for (var i = 0; i < lstRawData.length; i++) {
                      //  lstRawData.add([i]['svc_noofitems']=5;
//                      lstSelectedRawData[lstRawData[i]["svc_id"]] = lstRawData[i]["svc_noitemselected"];

                      if (lstRawData[i]["svc_demographic"] ==
                          _currentItem)
                        lstFilteredLaundryData.add(lstRawData[i]);
                    }
                    debugPrint("Selected item>>>>" +
                        lstSelectedRawData.toString());

                    List sampleList = ["all"];
                    for (var i = 0; i < lstRawData.length; i++) {
                      sampleList.add(lstRawData[i]["svc_demographic"]);
                    }
                    _itemcategory = Set.of(sampleList).toList();
                    _dropDownMenuItems = getDropDownMenuItems();
                    //                        _currentItem = _dropDownMenuItems[0].value;
                    if (_currentItem == "all")
                      lstLaundryData = lstRawData;
                    else {
                      lstLaundryData = lstFilteredLaundryData;
                    }
                    debugPrint("Selct>>>>" +
                        lstLaundryData.length.toString() +
                        "" +
                        lstNoOfItemsSelected.toString());
                    debugPrint("Dropdown>>>>" + _itemcategory.toString());
                    debugPrint(_currentItem +
                        ">>>>" +
                        lstLaundryData.toString());

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Card(
                          child: Container(
                            padding: new EdgeInsets.all(10.0),
                            color: Colors.white,
                            // padding: new EdgeInsets.all(10.0),
                            child: Row(
                              // padding: new EdgeInsets.all(10.0),
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Filter by category: ",
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                        fontFamily: "SF"),
                                    textAlign: TextAlign.center),
                                // Row(
                                //   children: <Widget>[
                                //     Text(strSelectedVal),
                                //     _selectPopup(),
                                //   ],
                                // ),
                                new DropdownButton(
                                  value: _currentItem,
                                  items: _dropDownMenuItems,
                                  //onChanged: changedDropDownItem,
                                  onChanged: (newValue) {
                                    setState(() {
                                      _currentItem = newValue.toString();
                                    });
                                  },

                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 17,
                                      fontFamily: "SF"),
//                        textAlign: TextAlign.center),
                                ),
                                DottedBorder(
                                    borderType: BorderType.RRect,
                                    radius: Radius.circular(8),
                                    color: Colors.grey,
                                    child: Center(
                                      child: IconButton(
                                        icon: Icon(
                                          Icons
                                              .playlist_add_check_rounded,
                                          size: 28,
                                          color: Colors.lightBlue,
                                        ),
                                        splashColor: Colors.purple,
                                        onPressed: () =>
                                            getLoginUserData(),
                                      ),
                                    ),
                                    strokeWidth: 1,
                                    dashPattern: [3, 4]),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Expanded(
                          //height: 500.0,
                            child: ListView.builder(
                                shrinkWrap: true,
//                    padding: const EdgeInsets.all(20.0),
                                padding: EdgeInsets.only(
                                    left: 0.0,
                                    right: 0.0,
                                    top: 2.0,
                                    bottom: 4.0),
                                itemCount: lstLaundryData.length,
                                //itemCount: lstTitles.length,
                                //physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  //////////////////////////populating list view
                                  // int intCurrentNoOfItems = 0;
                                  // for (var i = 0; i < lstNoItems.length; i++) {
                                  //   List<String> strSplitSelectedValue =
                                  //       lstNoItems[i].split("|");
                                  //   if (strSplitSelectedValue[1] ==
                                  //       lstLaundryData[index]['svc_id'].toString())
                                  //     intCurrentNoOfItems =
                                  //         int.parse(strSplitSelectedValue[0]);
                                  // }
//                                        lstLaundryData[index]['svc_noitemselected']=lstNoOfItemsSelected[index];

                                  return Card(
                                      elevation: 2,
                                      child: ListTile(
                                        title: Text(
                                          lstLaundryData[index]
                                          ['svc_article'],
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                              fontFamily: "SF"),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text(
                                          "Category: " +
                                              lstLaundryData[index]
                                              ['svc_demographic'] +
                                              "\nPrice: KSh " +
                                              lstLaundryData[index]
                                              ['svc_price']
                                                  .toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                        leading: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                          child:  FadeInImage(
                                            imageErrorBuilder:
                                                (BuildContext context,
                                                Object exception,
                                                StackTrace
                                                stackTrace) {
                                              print('Error Handler');
                                              return Container(
                                                width: 60,
                                                height:
                                                double.infinity,
                                                child: Image.asset(
                                                    'assets/images/s1.jpg'),
                                              );
                                            },
                                            placeholder: AssetImage(
                                                'assets/images/dice_splash.gif'),
                                            image: NetworkImage(
                                                lstLaundryData[index][
                                                'svc_articleiconurl']),
                                            fit: BoxFit.cover,
                                            width: 60,
                                            height: double.infinity,
                                          ),
                                        ),
                                        trailing: Wrap(
                                          spacing: 12,
                                          // space between two icons
                                          children: <Widget>[
                                            IconButton(
                                                icon: Icon(
                                                  Icons
                                                      .indeterminate_check_box_outlined,
                                                  size: 40,
                                                  color: Colors.lightBlue,
                                                ),
                                                splashColor:
                                                Colors.purple,
                                                onPressed: () {
                                                  int f = 0;
                                                  if (lstSelectedRawData[
                                                  lstLaundryData[
                                                  index]
                                                  [
                                                  'svc_id']] !=
                                                      null &&
                                                      lstSelectedRawData[
                                                      lstLaundryData[
                                                      index]
                                                      [
                                                      'svc_id']] >
                                                          0) {
                                                    f = lstSelectedRawData[
                                                    lstLaundryData[
                                                    index]
                                                    ['svc_id']];
                                                    f--;
                                                    lstSelectedRawData
                                                        .removeWhere((key,
                                                        value) =>
                                                    key ==
                                                        lstLaundryData[
                                                        index]
                                                        [
                                                        'svc_id']);

                                                    setState(() =>
                                                    //lstSelectedRawData[lstLaundryData[index]['svc_id']]
                                                    lstSelectedRawData[
                                                    lstLaundryData[
                                                    index]
                                                    [
                                                    'svc_id']] = f);
                                                    debugPrint("###SUB" +
                                                        lstLaundryData[
                                                        index]
                                                        ['svc_id'] +
                                                        "||" +
                                                        lstSelectedRawData[
                                                        lstLaundryData[
                                                        index]
                                                        [
                                                        'svc_id']]
                                                            .toString());
                                                  }
                                                }),
                                            Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: <Widget>[
                                                  SizedBox(height: 20),
                                                  SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: Text(
                                                      lstSelectedRawData[lstLaundryData[
                                                      index]
                                                      [
                                                      'svc_id']] !=
                                                          null
                                                          ? lstSelectedRawData[
                                                      lstLaundryData[index]
                                                      [
                                                      'svc_id']]
                                                          .toString()
                                                          : 0.toString(),
////
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                          color: Colors
                                                              .black,
                                                          fontSize: 18,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                      //maxLines: 1,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      //maxLines: 1.floor(),
                                                    ),
                                                  )
                                                ]),
                                            IconButton(
                                                icon: Icon(
                                                  Icons.add_box_outlined,
                                                  size: 40,
                                                  color: Colors.lightBlue,
                                                ),
                                                splashColor:
                                                Colors.purple,
                                                onPressed: () {
                                                  int a = 0;
                                                  if (lstSelectedRawData[
                                                  lstLaundryData[
                                                  index][
                                                  'svc_id']] !=
                                                      null) {
                                                    a = lstSelectedRawData[
                                                    lstLaundryData[
                                                    index]
                                                    ['svc_id']];
                                                    lstSelectedRawData
                                                        .removeWhere((key,
                                                        value) =>
                                                    key ==
                                                        lstLaundryData[
                                                        index]
                                                        [
                                                        'svc_id']);
                                                  }
                                                  a++;
                                                  setState(() =>
                                                  //lstSelectedRawData[lstLaundryData[index]['svc_id']]
                                                  lstSelectedRawData[
                                                  lstLaundryData[
                                                  index][
                                                  'svc_id']] = a);
                                                  debugPrint("###ADD" +
                                                      lstLaundryData[
                                                      index]
                                                      ['svc_id'] +
                                                      "||" +
                                                      lstSelectedRawData[
                                                      lstLaundryData[
                                                      index]
                                                      [
                                                      'svc_id']]
                                                          .toString());
                                                  //}
//                         for (int x=0;x<lstRawData.length;x++){
//                             if (lstLaundryData[index]['svc_id']==lstRawData[x]['svc_id']) {
//                               lstSelectedRawData[lstLaundryData[index]['svc_id']]++;
//                               //lstSelectedRawData[lstLaundryData[index]['svc_id']]=lstSelectedRawData[lstLaundryData[index]['svc_id']]++;
//                               setState(() =>
//
// //                              strNoCounter=lstSelectedRawData[lstLaundryData[index]['svc_id']]=lstSelectedRawData[lstLaundryData[index]['svc_id']]
//   //                            --
//     //                              strNoCounter=lstSelectedRawData[lstLaundryData[index]['svc_id']].toString()
//                               strNoCounter=lstSelectedRawData[lstLaundryData[index]['svc_id']].toString()
//                               );
//                               debugPrint("###ADDED>>>>" +
//                                   lstRawData[x]['svc_article']+"|"+lstSelectedRawData[lstLaundryData[index]['svc_id']].toString());
//                               debugPrint("###ADDED>>>>" +
//                                   "###|"+lstSelectedRawData.toString());
//
//                               break;
//                             }
//                           }

                                                  //if (lstLaundryData[index]
                                                  //      ['svc_noitemselected'] <
                                                  //21) {
                                                  debugPrint(
                                                      "Selected added>>>>" +
                                                          lstRawData[index]
                                                          [
                                                          'svc_article']
                                                              .toString());
                                                  //}
                                                }
                                              //  onPressed: setState(() {_counter++;});,
                                            ),
                                          ],
                                        ),
                                        isThreeLine: true,
                                      ));
                                })),
                      ],
                    );
                  })
                      :  Center(
                      child: CircularProgressIndicator());
                })));
  }

  void changedDropDownItem(String selectedCity) {
    setState(() {
      _currentItem = selectedCity;
    });
  }

  int intTotalPrice = 0;
  int _state = 0;
  String strLocAddress = "",
      strUserEmail = "",
      strUserPhoneNo = "",
      strUserLat = "",
      strUserLong = "";
  LatLng _geoLocCoordinates; //LatLng(0.0,0.0);
  //LatLng _center = LatLng(-1.38893, 35.8421);

  DateTime selectedDate = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  String strUserslatLong = "";

  // /// Simple query with WHERE raw query
  Future getLoginUserData() async {
    var dbClient = await SqliteDB().db;
    //final res = await dbClient.rawQuery("SELECT fuid,email FROM loginUser");
    final res = await dbClient.rawQuery(
        "SELECT fuid,email, phonenumber,generallocation,latlongaddress FROM loginUser");
    List<Map> result = await dbClient.rawQuery(
        "SELECT fuid,email, phonenumber,generallocation,latlongaddress FROM loginUser");
    debugPrint("|||Logged in user" + result[0]["latlongaddress"].toString());
/////
    setState(() {
      strUserslatLong = result[0]["latlongaddress"].toString();
//      if (strUserslatLong=="")strUserslatLong="0,0";
      strUserEmail = result[0]["email"].toString();
      strUserPhoneNo = result[0]["phonenumber"].toString();
      var vLatLong = strUserslatLong.split(',');
      var llat = double.parse(vLatLong[0]);
      var llong = double.parse(vLatLong[1]);
      strUserLat = llat.toString();
      strUserLong = llong.toString();
      _geoLocCoordinates = new LatLng(llat, llong);
    });
    List<geocode.Placemark> placemarks = await geocode.placemarkFromCoordinates(
        _geoLocCoordinates.latitude, _geoLocCoordinates.longitude);
    setState(() {
      strLocAddress = placemarks.first.administrativeArea +
          "," +
          placemarks.first.locality +
          "," +
          placemarks.first.street +
          "," +
          placemarks.first.subLocality +
          "," +
          placemarks.first.street +
          "," +
          placemarks.first.subThoroughfare +
          "," +
          placemarks.first.thoroughfare +
          "," +
          placemarks.first.name;
      debugPrint("addreesee111:>" + placemarks.toString());
    });

    Flushbar(
      title: "Location",
      message: _geoLocCoordinates.toString(),
      duration: Duration(seconds: 3),
      isDismissible: false,
    )..show(context);
//    return result;
    _show(context);
  }

  void _show(BuildContext ctx) {
// //    getLoginUserData();
//
//     //googler maps flutter
    GoogleMapController mapController;
    final Set<Marker> _markers = {};
    final LatLng _center = const LatLng(-1.28893, 36.8421);
    // void _onAddMarkerButtonPressed(LatLng latlang)async {
    //   setState(() {
    //     _markers.add(Marker(
    //       markerId: MarkerId(latlang.toString()),
    //       position: latlang,
    //       infoWindow:
    //       InfoWindow(title: latlang.toString(), snippet: strLocAddress),
    //       icon: BitmapDescriptor.defaultMarker,
    //     ));
    //   });
    // }
    void _onAddMarkerButtonPressed(LatLng latlang) async {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId(latlang.toString()),
          position: latlang,
          infoWindow: InfoWindow(title: strLocAddress, snippet: "Address"),

          //title:address,
          icon: BitmapDescriptor.defaultMarker,
        ));
      });
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(latlang.latitude, latlang.longitude), zoom: 15),
        ),
      );
    }

    Set<Marker> markers = Set();
    void _onCameraMove(CameraPosition position) {
//      _onAddMarkerButtonPressed(_geoLocCoordinates);

      _geoLocCoordinates = position.target;
    }

    void _onMapCreated(GoogleMapController controller) {
      mapController = controller;
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                  _geoLocCoordinates.latitude, _geoLocCoordinates.longitude),
              zoom: 15),
        ),
      );
      _onAddMarkerButtonPressed(_geoLocCoordinates);
// Create a new marker
    }

    _selectDate(ctx) async {
      /// This will be called every time while displaying day in calender.
      bool _decideWhichDayToEnable(DateTime day) {
        if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))) &&
            day.isBefore(DateTime.now().add(Duration(days: 10))))) {
          return true;
        }
        return false;
      }

      final DateTime picked = await showDatePicker(
        context: ctx,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
        selectableDayPredicate: _decideWhichDayToEnable,
        helpText: 'Select booking date',
        // Can be used as title
        cancelText: 'Not now',
        confirmText: 'Book',
      );
      if (picked != null && picked != selectedDate)
        setState(() {
          //  _onAddMarkerButtonPressed(_geoLocCoordinates);
          selectedDate = picked;
          debugPrint("sel datee>>>>" + selectedDate.toString());
          Navigator.of(context).pop();
          _show(context);
        });
    }

    _pickTime() async {
      TimeOfDay t = await showTimePicker(context: context, initialTime: time);
      if (t != null)
        setState(() {
          //_onAddMarkerButtonPressed(_geoLocCoordinates);
          time = t;
          Navigator.of(context).pop();
          _show(context);
        });
    }

    //print(lstNoOfItemsSelected);
    lstSelectedArticles.clear();
    intTotalPrice = 0;
    for (int i = 0; i < lstRawData.length; i++) {
      if (lstSelectedRawData[lstRawData[i]['svc_id']] != null &&
          lstSelectedRawData[lstRawData[i]['svc_id']] > 0) {
        //if (lstRawData[i]['svc_noitemselected'] > 0) {
        lstSelectedArticles.add(lstRawData[i]);
        debugPrint("srinvoice>>>>" + lstRawData[i]['svc_article'].toString());
        intTotalPrice = intTotalPrice +
            lstSelectedRawData[lstRawData[i]['svc_id']] *
                lstRawData[i]['svc_price'];
      }
    }

    void getpin() {
      //// pop to remove back trace and force user to reload the bottom sheet
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GetPlacePin(),
        ),
      );
    }

    snackbarA(String strToast) {
      final snackBar = SnackBar(
        content: Text(strToast),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
//         action: SnackBarAction(
//           label: 'Retry',
//           onPressed: () {
// //            senddata();
//             // Some code to undo the change.
//           },
//         ),
      );
      Scaffold.of(ctx).showSnackBar(snackBar);
    }

///////////////////////
    TextEditingController strHouseNameNo = new TextEditingController();
    /////////
    Future<String> senddata() async {
      String strReturn = "";
      var list = lstSelectedArticles;
      var concatenate = StringBuffer();
      list.forEach((item) {
        concatenate.write(item);
      });
      String strFr_taskdate = selectedDate.toLocal().toString().split(' ')[0];
      print(concatenate); // displays 'onetwothree'
      // debugPrint("fr_generallocation" +strLocAddress);
      // debugPrint("fr_specificaddress" +strHouseNameNo.text);
      // debugPrint("fr_taskdate" +strFr_taskdate);
      // debugPrint("fr_tasktime" +time.toString());
      // debugPrint("fr_taskdetail" +concatenate.toString());
      // debugPrint("fr_strtotalprice" +intTotalPrice.toString());

      if (strLocAddress.isEmpty) {
        Flushbar(
          title: "Invalid location",
          message:
          "Please click on the location icon to select a location pin from the map",
          duration: Duration(seconds: 3),
          isDismissible: false,
        )..show(context);
      }

      if (strHouseNameNo.text.length < 3 ||
          strHouseNameNo.text.isEmpty ||
          strHouseNameNo.text == "") {
        Flushbar(
          title: "House name/ number missing.",
          message: "Please enter a valid building name and or house number",
          duration: Duration(seconds: 3),
          isDismissible: false,
        )..show(context);
      }
      if (concatenate.toString().isEmpty || concatenate.toString() == "") {
        Flushbar(
          title: "No Laundry items selected.",
          message: "Please choose a number of laundary items",
          duration: Duration(seconds: 3),
          isDismissible: false,
        )..show(context);
      }
      if (concatenate.toString().isNotEmpty &&
          concatenate.toString() != "" &&
          strHouseNameNo.text.length > 3 &&
          strHouseNameNo.text.isNotEmpty &&
          strHouseNameNo.text != "" &&
          strLocAddress.isNotEmpty) {
        var urlPost = 'https://homlie.co.ke/malakane_init/hml_uploadticket.php';
        final strResponse = await http.post(Uri.parse(urlPost), body: {
          "fr_useremail": strUserEmail, //fr_useremail,
          "fr_userphone": strUserPhoneNo, //fr_userphone",
          "fr_funditype": "Cooking", //fr_funditype",
          "fr_generallocation": strLocAddress,
          "fr_latitude": strUserLat,
          "fr_longitude": strUserLong,
          "fr_specificaddress": strHouseNameNo.text,
          "fr_taskdate": strFr_taskdate,
          "fr_tasktime": time.hour.toString() + ":" + time.minute.toString(),
          "fr_taskdetail": concatenate.toString(),
          "fr_strtotalprice": intTotalPrice.toString(),
        });
        print(strResponse.body.toString());
        if (strResponse.body.toString() == "ErrorRE101") {
          ////
          snackbarA("Error, please try again");
          Flushbar(
            title: "Ticket",
            message: "Error. Please try again.",
            duration: Duration(seconds: 3),
            isDismissible: false,
          )..show(context);
        } else {
          Navigator.pop(context);
          Flushbar(
            title: "Ticket",
            message:
            "Your ticket has been created successfully. You can find it in MyTickets tab",
            duration: Duration(seconds: 3),
            isDismissible: false,
          )..show(context);
        }
        debugPrint("|||" + strResponse.body.toString());
        strReturn = strResponse.body.toString();
      }
      return strReturn;
    }

    Widget setUpButtonChild() {
      if (_state == 0) {
        return new Text(
          "Create Ticket",
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
        return Text(
          "Retry creating ticket",
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

////////////////////////////////////////////////////////////////
//   getLoginUserData();

    //  getLoginUserData();
    showModalBottomSheet(
        isScrollControlled: true,
//        height: 10,
        elevation: 5,
        context: ctx,
        //builder: (ctx) =>
        builder: (ctx) {
          //         getLoginUserData();
//          _onAddMarkerButtonPressed(_geoLocCoordinates);
          return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 10.0),
              scrollDirection: Axis.vertical,
              child: Wrap(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Heading(
                    text: Text(
                      "Check Out:",
                      style:
                      TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
                    ),
                    button: IconButton(
                        icon: Icon(
                          Icons.cancel_outlined,
                          size: 35,
                          color: Colors.lightBlue,
                        ),
                        splashColor: Colors.purple,
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                  ),
                  Heading(
                    text: Text(
                      "You have selected ${lstSelectedArticles.length} types of items",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[500]),
                    ),
                  ),
                  Container(
                      child: ListView.builder(
                          itemCount: lstSelectedArticles.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 35,
                              margin: EdgeInsets.all(2),
                              child: ListTile(
                                leading: Icon(Icons.add_circle,
                                    size: 15.0, color: Colors.lightBlue),
                                title: Text(
                                  '${lstSelectedArticles[index]['svc_article']} (${lstSelectedArticles[index]['svc_demographic']}) ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Text(
                                  '@ KSh: ${lstSelectedArticles[index]['svc_price']} x ${lstSelectedRawData[lstSelectedArticles[index]['svc_id']]}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          })),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        ListTile(
                          title: Text(
                            "Total KSh: " + intTotalPrice.toString(),
                            style: TextStyle(
                                fontSize: 21, fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        //////////////////////
                        ListTile(
                          title: Text(
                            "Location Address: " + strLocAddress,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(Icons.location_on_outlined,
                              size: 30.0, color: Colors.lightBlue),
                          onTap: getpin,
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        SizedBox(
                            height: 200,
                            child: GoogleMap(
//                            onMapCreated: _onMapCreated,
//                            myLocationEnabled: true,
                              initialCameraPosition: CameraPosition(
                                  target: _geoLocCoordinates, zoom: 15.0),
                              markers: markers,
                              compassEnabled: true,
                              onCameraMove: _onCameraMove,
                            )
//                           GoogleMap(
//                             onMapCreated: _onMapCreated,
//                             initialCameraPosition: CameraPosition(
//                               target: _center,
//                               zoom: 15.0,
//                             ),
//                             markers: _markers,
//                             onCameraMove: _onCameraMove,
//                             //mapType: _currentMapType,
//                             compassEnabled: true,
//                           ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        //////////////////////
                        ListTile(
                          title: Text(
                            "Start time (24hr system): ${time.hour}:${time.minute}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),

                          trailing: Icon(Icons.more_time_outlined,
                              size: 30.0, color: Colors.lightBlue),

                          ///backgroundColor: Colors.lightBlue,
                          //child: const Icon(Icons.location_searching, size: 30.0),
                          onTap: _pickTime,
                        ),
                        ListTile(
                          title: Text(
                            "Start" +
                                " date: " +
                                "${selectedDate.toLocal()}".split(' ')[0],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(Icons.date_range_outlined,
                              size: 30.0, color: Colors.lightBlue),
                          onTap: () => _selectDate(ctx), // Refer step 3
                          //onTap: _selectDate(ctx),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        ListTile(
                          title: Text(
                            "Specific address/house:",
                            style: TextStyle(fontSize: 18.0),
                          ),
                        ),
                        ListTile(
                          title: TextField(
                            controller: strHouseNameNo,
                            decoration: InputDecoration(
                                hintText: 'enter a house name and no'),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          //alignment: Alignment.center,
                          child: new MaterialButton(
                            child: setUpButtonChild(),
                            onPressed: () async {
                              senddata();
                              setState(() {
                                _state = 0;
//                if (_state == 0) {
                                animateButton();
                                //            }
                              });
                            },
                            elevation: 4.0,
                            minWidth: double.infinity,
                            height: 48.0,
                            color: Colors.cyan,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ])
                ],
              ));
        });
    Marker resultMarker = Marker(
      markerId: MarkerId(_geoLocCoordinates.toString()),
      infoWindow:
      InfoWindow(title: "Selected Location", snippet: strLocAddress),
      icon: BitmapDescriptor.defaultMarker,
      position: _geoLocCoordinates,
    );
// Add it to Set
    markers.add(resultMarker);

//    getLoginUserData();
  }
}

///////////////////////////////////////////////////////////////////////////////////////////
