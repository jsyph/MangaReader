import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/content_widgets/explore_widget/common.dart';
import 'package:manga_reader/content_widgets/explore_widget/popular_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../styles.dart';

class ExploreWidget extends StatefulWidget {
  const ExploreWidget({super.key});

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget>
    with AutomaticKeepAliveClientMixin<ExploreWidget> {
  final logger = Logger('ExploreWidget');

  String _currentSelectedMangaSourceName = '';

  bool _readyToDisplay = false;

  final _popularPanel = PopularTab();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!_readyToDisplay) {
      return scaffoldLoadingNoProgressWidget;
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Current Source:'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              tabs: [
                Tab(
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Popular",
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: SizedBox(width: 10),
                        ),
                        WidgetSpan(
                          child: Icon(Icons.trending_up, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Updates",
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: SizedBox(width: 10),
                        ),
                        WidgetSpan(
                          child: Icon(Icons.new_releases, size: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Theme.of(context).appBarTheme.backgroundColor,

              // dropdown below..
              child: DropdownButton<String>(
                value: _currentSelectedMangaSourceName,
                onChanged: (value) {
                  if (value != null) {
                    _popularPanel.changeMangaSource(value);

                    _changeSelectedMangaSourceName(value);

                    if (mounted) {
                      logger.fine('');
                    }
                  }
                },
                items: mangaSourcesData.keys
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                    .toList(),

                // add extra sugar..
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
                underline: const SizedBox(),
              ),
            )
          ],
        ),
        body: TabBarView(
          children: [
            PopularTab(),
            const Text('fuck'),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _startup();
  }

  void _changeSelectedMangaSourceName(String mangaSourceName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('selected_manga_source', mangaSourceName);
    log('is mounted: $mounted');

    if (mounted) {
      setState(
        () {
          _currentSelectedMangaSourceName = mangaSourceName;
        },
      );
    }
  }

  void _startup() async {
    // ─── Set Manga Source ────────────────────────────────────────
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? selctedManga = prefs.getString('selected_manga_source');

    if (selctedManga == null) {
      final value = mangaSourcesData.keys.first;
      await prefs.setString(
        'selected_manga_source',
        value,
      );
      _currentSelectedMangaSourceName = value;
    } else {
      _currentSelectedMangaSourceName = selctedManga;
    }

    setState(() {
      _readyToDisplay = true;
    });
  }
}
