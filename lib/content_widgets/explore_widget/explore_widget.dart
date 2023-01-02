import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/content_widgets/explore_widget/common.dart';
import 'package:manga_reader/content_widgets/explore_widget/popular_tab.dart';
import 'package:manga_reader/content_widgets/explore_widget/updates_tab.dart';

class ExploreWidget extends StatefulWidget {
  const ExploreWidget({super.key});

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget>
    with
        AutomaticKeepAliveClientMixin<ExploreWidget>,
        SingleTickerProviderStateMixin {
  // for mixin 👇
  @override
  bool get wantKeepAlive => true;

  String _currentSelectedMangaSourceName = '';

  final _popularTab = PopularTab();
  final _updatesTab = UpdatesTab();

  late final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_currentSelectedMangaSourceName.isEmpty) {
      return scaffoldLoadingNoProgressWidget;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Source:'),
        bottom: TabBar(
          controller: _tabController,
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
                      child: FaIcon(
                        FontAwesomeIcons.fire,
                        size: 16,
                        color: Colors.redAccent,
                      ),
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
                      child: Icon(
                        Icons.new_releases,
                        size: 16,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                  // 👇 Code to run when selected manga source is changed
                  log(value);
                  _popularTab.changePopularManga(value).whenComplete(
                        () => _changeSelectedMangaSourceName(value),
                      );

                  _updatesTab.changeUpdatesManga(value).whenComplete(
                        () => _changeSelectedMangaSourceName(value),
                      );

                  // 👆 -------------------------------------------------
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
        controller: _tabController,
        children: [
          _popularTab,
          _updatesTab,
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _loadMangaSourceName();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _changeSelectedMangaSourceName(String mangaSourceName) async {
    if (mounted) {
      setState(
        () {
          _currentSelectedMangaSourceName = mangaSourceName;
        },
      );
    }
  }

  void _loadMangaSourceName() async {
    // ─── Set Manga Source ────────────────────────────────────────

    final value = mangaSourcesData.keys.first;
    setState(
      () {
        _currentSelectedMangaSourceName = value;
      },
    );
  }
}
