import 'package:flutter/material.dart';
import 'package:motivateme_mobile_app/calendar.dart';
import 'package:motivateme_mobile_app/home_page.dart';
import 'package:motivateme_mobile_app/profile_page.dart';

class NavigationPage extends StatefulWidget {
  NavigationPage({
    Key key,
  }) : super(key: key);

  @override
  NavigationPageState createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> {
  final List<Widget> pages = [ 
    HomePage(),
    TableEventsExample(),
    ProfilePage()
  ]; // contains the pages that user can navigate to
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      this._selectedIndex = index;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: this.pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedIconTheme: IconThemeData(color: Theme.of(context).primaryColor),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
