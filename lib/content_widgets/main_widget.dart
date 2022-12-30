import 'package:flutter/material.dart';
import 'home_widget.dart';
import 'library_widget.dart';
import 'explore_widget.dart';
import 'settings_widget.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

class MangaReaderApp extends StatelessWidget {
  const MangaReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MainWidget(),
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
    );
  }
}

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeWidget(),
    ExploreWidget(),
    LibraryWidget(),
    SettingsWidget(),
  ];

  void _onItemTapped(int index) {
    setState(
      () {
        _selectedIndex = index;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _selectedIndex,
        showElevation: true,
        itemCornerRadius: 24,
        curve: Curves.easeInOutExpo,
        onItemSelected: (index) => _onItemTapped(index),
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.home),
            title: const Text('Home'),
            activeColor: Colors.red,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.travel_explore),
            title: const Text('Explore'),
            activeColor: Colors.purple,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.collections_bookmark),
            title: const Text('Library'),
            activeColor: Colors.blue,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.settings),
            title: const Text('Settings'),
            activeColor: Colors.grey,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
