// @dart=2.9
import 'package:papaya/screens/details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';
import '../pages/services_page.dart';
import '../pages/activity_page.dart';
import '../pages/mytickets_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>()
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_selectedIndex].currentState.maybePop();

        print(
            'isFirstRouteInCurrentTab: ' + isFirstRouteInCurrentTab.toString());

        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Feather.activity,
                color: kGoodLightGray,
              ),
              title: Text('Activity'),
              activeIcon: Icon(
                Feather.activity,
                color: Colors.cyan,
              ),
            ),
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.add_comment,
                color: kGoodLightGray,
                semanticLabel: 'Services',
              ),
              title: Text('Services'),
              activeIcon: const Icon(
                Icons.add_comment,
                color: Colors.cyan,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Feather.menu,
                color: kGoodLightGray,
                size: 24,
              ),
              title: Text('My Tickets'),
              activeIcon: Icon(
                Feather.menu,
                color: Colors.cyan,
                size: 24,
              ),
            ),
          ],
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        body:


        Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
          ],
        ),
      ),
    );
  }

//  void _next() {
  //  Navigator.push(
    //    context, MaterialPageRoute(builder: (context) => DetailsScreen()));
  //}

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          ActivityPage(),
          ServicesPage(
    //        onNext: _next,
          ),
          MyTicketsPage(),
        ].elementAt(index);
      },
    };
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders;
    routeBuilders = _routeBuilders(context, index);

    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name](context),
          );
        },
      ),
    );
  }
}
