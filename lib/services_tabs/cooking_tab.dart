import 'package:papaya/screens/details_screen.dart';
import 'package:flutter/material.dart';

class CookingTab extends StatefulWidget {
  @override
  ListViewActivity createState() {
    return new ListViewActivity();
  }
}

class ListViewActivity extends State<CookingTab> {
  final titles = [
    "Chicken",
    "Pilau",
    "Omena"
  ];
  final subtitles = [
    "chicken order created 3 min ago four people",
    "pilau ticket for 5 people",
    "githeri required for 20 men"
  ];
  final icons = [Icons.ac_unit, Icons.access_alarm, Icons.access_time];

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.deepPurpleAccent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                'Select category',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Aleo',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                    color: Colors.white),
              ),
            ),
            Expanded(
                //height: 500.0,
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20.0),
                    itemCount: titles.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: ListTile(
                              onTap: () {
                                setState(() {
                                  titles.add(
                                      'List' + (titles.length + 1).toString());
                                  subtitles.add('Here is list' +
                                      (titles.length + 1).toString() +
                                      ' subtitle');
                                  icons.add(Icons.zoom_out_sharp);
                                });
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(titles[index] + ' pressed!'),
                                ));
                              },
                              title: Text(titles[index]),
                              subtitle: Text(subtitles[index]),
                              leading: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "https://images.unsplash.com/photo-1547721064-da6cfb341d50")),
                              trailing: Icon(icons[index])));
                    })),
          ],
        ));
  }
}
