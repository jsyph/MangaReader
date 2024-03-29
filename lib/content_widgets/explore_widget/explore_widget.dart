import 'dart:developer' as dart_dev;
import 'dart:math' as dart_math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/content_widgets/explore_widget/popular_tab.dart';
import 'package:manga_reader/content_widgets/explore_widget/updates_tab.dart';
import 'package:manga_reader/core/core.dart';

import '../../core/database_types/page_data.dart';

class CurrentChapterNumberData {
  CurrentChapterNumberData(
    this.currentNumber,
    this.timeStamp,
  );

  factory CurrentChapterNumberData.empty() {
    return CurrentChapterNumberData(
      1,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  int currentNumber;
  int timeStamp;
}

class ExploreWidget extends StatefulWidget {
  const ExploreWidget({super.key});

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget>
    with
        AutomaticKeepAliveClientMixin<ExploreWidget>,
        SingleTickerProviderStateMixin {
  bool isFABVisible = true;

  String _currentSelectedMangaSourceName = '';
  List<MangaSearchResult> _popularManga = [];
  CurrentChapterNumberData _popularTabCurrentPageNumberData =
      CurrentChapterNumberData.empty();

  late final TabController _tabController;
  List<MangaSearchResult> _updatesManga = [];
  CurrentChapterNumberData _updatesTabCurrentPageNumberData =
      CurrentChapterNumberData.empty();

  @override
  void initState() {
    super.initState();

    // Tab Container
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        // Get source name
        _loadMangaSourceName();

        // open box then get popular manga
        _openMainBox().whenComplete(
          () => _getPopularManga(),
        );
      },
    );
  }

  // for mixin 👇
  @override
  bool get wantKeepAlive => true;

  Future<void> _changePopularManga(String mangaSourceName) async {
    // If the _popularManga list is empty, which means the screen is being update, pass, else continue.
    if (_popularManga.isNotEmpty) {
      setState(
        () {
          // make popular_manga to []
          _popularManga = [];
          // reset CurrentChapterNumberData
          _popularTabCurrentPageNumberData = CurrentChapterNumberData.empty();
        },
      );
      _updatePopularManga(
        mangaSourceName,
        _popularTabCurrentPageNumberData.currentNumber,
      );
    }
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

  Future<void> _changeUpdatesManga(String mangaSourceName) async {
    // If the _popularManga list is empty, which means the screen is being update, pass, else continue.
    if (_updatesManga.isNotEmpty) {
      setState(
        () {
          // make popular_manga to []
          _updatesManga = [];
          // reset CurrentChapterNumberData
          _updatesTabCurrentPageNumberData = CurrentChapterNumberData.empty();
        },
      );
      await _updateRecentlyUpdatedManga(
        mangaSourceName,
        _updatesTabCurrentPageNumberData.currentNumber,
      );
    }
  }

  /// is run only at startup
  void _getPopularManga() async {
    // get popular from internet or memory

    List<MangaSearchResult> results = [];

    final box = Hive.box(runtimeType.toString());

    final storedPopularManga =
        box.get('$_currentSelectedMangaSourceName-popularManga');

    if (storedPopularManga != null) {
      for (int i = 0; i < storedPopularManga.length; i++) {
        if (storedPopularManga[i].page == 1) {
          final firstPage = storedPopularManga[i];

          dart_dev.log('Read from memory? ${storedPopularManga != null && DateTime.now().difference(
                firstPage.time,
              ).inDays <= 2}');

          // If '$_currentSelectedMangaSourceName-popularManga' is not null and the time is less than or equal 2 days, then return stored value
          if (DateTime.now().difference(firstPage.time).inDays <= 2) {
            results = firstPage.results;
          }
        }
      }
    }

    if (results.isEmpty) {
      dart_dev.log('Getting data from $_currentSelectedMangaSourceName');
      results = await mangaSourcesData[_currentSelectedMangaSourceName]!
          .popular(page: 1);

      box.put(
        '$_currentSelectedMangaSourceName-popularManga',
        [
          DataBasePageData(
            1,
            DateTime.now(),
            results,
          ),
        ],
      );

      dart_dev.log('put data from $_currentSelectedMangaSourceName for 1');
    }

    if (mounted) {
      setState(
        () {
          _popularManga.addAll(results);
        },
      );
    }
  }

// TODO: MAKE THIS WORK
  /// is run only at startup
  void _getRecentlyUpdatedManga() async {
    // get popular from internet or memory

    List<MangaSearchResult> results = [];

    results = await mangaSourcesData[_currentSelectedMangaSourceName]!
        .updates(page: 1);

    if (mounted) {
      setState(
        () {
          _updatesManga.addAll(results);
        },
      );
    }
  }

  void _loadMangaSourceName() {
    // ─── Set Manga Source ────────────────────────────────────────

    final value = mangaSourcesData.keys.first;
    setState(
      () {
        _currentSelectedMangaSourceName = value;
      },
    );
  }

  Future<void> _openMainBox() async {
    await Hive.openBox(runtimeType.toString());
  }

  void _updatePopularManga(String mangaSourceName, int pageNumber) async {
    // get popular from internet or memory

    List<MangaSearchResult> results = [];

    final box = Hive.box(runtimeType.toString());

    dynamic storedPopularManga = box.get('$mangaSourceName-popularManga');
    dart_dev.log('storedPopularManga is $storedPopularManga');

    if (storedPopularManga != null) {
      for (int i = 0; i < storedPopularManga.length; i++) {
        if (storedPopularManga[i].page == pageNumber) {
          final loadFromLocal = (storedPopularManga != null &&
              DateTime.now()
                      .difference(
                        storedPopularManga[i].time,
                      )
                      .inDays <=
                  2);

          dart_dev.log('loading from local: $loadFromLocal for $mangaSourceName');
          if (loadFromLocal) {
            results = storedPopularManga[i].results;
          }
        }
      }
    }

    // If result is empty
    if (results.isEmpty) {
      results =
          await mangaSourcesData[mangaSourceName]!.popular(page: pageNumber);

      var dataToBeStored = storedPopularManga;

      if (storedPopularManga != null) {
        dataToBeStored.add(
          DataBasePageData(
            pageNumber,
            DateTime.now(),
            results,
          ),
        );
      } else {
        dataToBeStored = [
          DataBasePageData(
            pageNumber,
            DateTime.now(),
            results,
          ),
        ];
      }

      box.put('$mangaSourceName-popularManga', dataToBeStored);

      dart_dev.log('put data from $mangaSourceName for $pageNumber');
    }

    setState(() {
      _popularManga.addAll(results);
    });
  }

  Future<void> _updateRecentlyUpdatedManga(
      String mangaSourceName, int pageNumber) async {
    final internalPopularManga =
        await mangaSourcesData[mangaSourceName]!.updates(page: pageNumber);

    if (mounted) {
      setState(
        () {
          _updatesManga.addAll(internalPopularManga);
        },
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_currentSelectedMangaSourceName.isEmpty) {
      return const LoadingWidget();
    }

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            snap: true,
            floating: true,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: Theme.of(context).appBarTheme.backgroundColor,

                // dropdown below..
                child: AnimatedContainer(
                  padding: const EdgeInsets.all(8),
                  duration: const Duration(seconds: 3),
                  curve: Curves.ease,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.white),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    gradient: LinearGradient(
                      colors: [
                        Color(mangaSourcesData[_currentSelectedMangaSourceName]!
                            .colorScheme
                            .primaryColor),
                        Color(mangaSourcesData[_currentSelectedMangaSourceName]!
                            .colorScheme
                            .secondaryColor),
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      // ignore: prefer_const_constructors
                      end: FractionalOffset(1.0, 0.0),
                      stops: const [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _currentSelectedMangaSourceName,
                    onChanged: (value) {
                      if (value != null) {
                        // 👇 Code to run when selected manga source is changed
                        dart_dev.log(value);
                        _changePopularManga(value).then(
                          (_) => _changeSelectedMangaSourceName(value),
                        );

                        _changeUpdatesManga(value).then(
                          (_) => _changeSelectedMangaSourceName(value),
                        );

                        // 👆 -------------------------------------------------
                      }
                    },
                    items: mangaSourcesData.keys
                        .map(
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

                    selectedItemBuilder: (context) {
                      return mangaSourcesData.keys.map(
                        (item) {
                          return Center(
                            child: Text(
                              item,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(mangaSourcesData[
                                                    _currentSelectedMangaSourceName]!
                                                .colorScheme
                                                .primaryColor)
                                            .computeLuminance() >
                                        0.4
                                    ? Colors.black
                                    : Colors.white,
                              ),
                            ),
                          );
                        },
                      ).toList();
                    },
                  ),
                ),
              )
            ],
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            NotificationListener<ScrollEndNotification>(
              child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: PopularTab(
                  _popularManga,
                  _currentSelectedMangaSourceName,
                  // scrollController,
                ),
              ),
              onNotification: (ScrollNotification scrollNotification) {
                dart_dev.log((scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent)
                    .toString());

                if (scrollNotification.metrics.pixels ==
                    scrollNotification.metrics.maxScrollExtent) {
                  if ((DateTime.now().millisecondsSinceEpoch -
                          _popularTabCurrentPageNumberData.timeStamp) >=
                      10000) {
                    dart_dev.log('Getting new page');

                    setState(
                      () {
                        _popularTabCurrentPageNumberData.currentNumber++;
                        _popularTabCurrentPageNumberData.timeStamp =
                            DateTime.now().millisecondsSinceEpoch;
                      },
                    );
                    _updatePopularManga(
                      _currentSelectedMangaSourceName,
                      _popularTabCurrentPageNumberData.currentNumber,
                    );
                  } else {
                    dart_dev.log('aaaa');
                    const snackBar = SnackBar(
                      content: Text(
                        'You Are Going too Fast, Slow Down!',
                      ),
                      duration: Duration(milliseconds: 100),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
                return false;
              },
            ),
            NotificationListener<ScrollEndNotification>(
              child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: RecentUpdatesTab(
                  _updatesManga,
                  _currentSelectedMangaSourceName,
                ),
              ),
              onNotification: (ScrollNotification scrollNotification) {
                dart_dev.log((scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent)
                    .toString());

                if (scrollNotification.metrics.pixels ==
                    scrollNotification.metrics.maxScrollExtent) {
                  if ((DateTime.now().millisecondsSinceEpoch -
                          _updatesTabCurrentPageNumberData.timeStamp) >=
                      10000) {
                    dart_dev.log('Getting new page');

                    setState(
                      () {
                        _updatesTabCurrentPageNumberData.currentNumber++;
                        _updatesTabCurrentPageNumberData.timeStamp =
                            DateTime.now().millisecondsSinceEpoch;
                      },
                    );
                    _updateRecentlyUpdatedManga(
                      _currentSelectedMangaSourceName,
                      _updatesTabCurrentPageNumberData.currentNumber,
                    );
                  } else {
                    dart_dev.log('aaaa');
                    const snackBar = SnackBar(
                      content: Text(
                        'You Are Going too Fast, Slow Down!',
                      ),
                      duration: Duration(milliseconds: 100),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                }
                return false;
              },
            ),
          ],
        ),
      ),
    );
  }
}
