import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'explore_widget/explore_widget.dart';
import 'home_widget.dart';
import 'library_widget.dart';
import 'settings_wdiget.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class MangaReaderApp extends StatelessWidget {
  const MangaReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MainWidget(),
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
    );
  }
}

class _MainWidgetState extends State<MainWidget> {
  final _animationDuration = const Duration(milliseconds: 400);
  int _currentIndex = 0;
  final _curveAnimation = Curves.easeOutCubic;
  final _pageController = PageController();
  final List<Widget> _widgetOptions = [
    const HomeWidget(),
    const ExploreWidget(),
    const LibraryWidget(),
    const SettingsWidget(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: _widgetOptions,
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        selectedIndex: _currentIndex,
        showElevation: true,
        itemCornerRadius: 30,
        curve: _curveAnimation,
        animationDuration: _animationDuration,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(
            index,
          );
        },
        items: [
          BottomNavyBarItem(
            icon: const Icon(Icons.home),
            title: const Text('Home'),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const FaIcon(FontAwesomeIcons.globe),
            title: const Text('Explore'),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.collections_bookmark),
            title: const Text('Library'),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.settings),
            title: const Text('Settings'),
            activeColor: Colors.white,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
