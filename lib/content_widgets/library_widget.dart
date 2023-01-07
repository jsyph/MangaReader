import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LibraryWidget extends StatefulWidget {
  const LibraryWidget({super.key});

  @override
  State<LibraryWidget> createState() => _LibraryWidgetState();
}

class _LibraryWidgetState extends State<LibraryWidget>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            title: Row(
              children: const [
                FaIcon(FontAwesomeIcons.book),
                SizedBox(width: 15),
                Text('Library')
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  text: 'Recent',
                ),
                Tab(
                  text: 'Bookmarks',
                ),
                Tab(
                  text: 'Downloads',
                ),
              ],
            ),
          )
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            Text('Recent'),
            Text('Bookmarks'),
            Text('Downloads')
          ],
        ),
      ),
    );
  }
}
