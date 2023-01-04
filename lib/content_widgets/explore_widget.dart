import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/core/core.dart';

import '../core/database_types/page_data.dart';
import 'manga_details.dart';

class CurrentChapterNumberData {
  int currentNumber;
  int timeStamp;

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
  // ─── For AppBar ──────────────────────────────────────────────────────

  bool isScrollingDown = false;
  bool _showAppBar = true;

  // ─── Explore Widget ──────────────────────────────────────────────────

  String _currentSelectedMangaSourceName = '';
  late final TabController _tabController;

  // for mixin 👇
  @override
  bool get wantKeepAlive => true;
  // ─── For Popular Tab ─────────────────────────────────────────────────

  List<MangaSearchResult> _popularManga = [];
  CurrentChapterNumberData _popularTabCurrentPageNumberData =
      CurrentChapterNumberData.empty();
  final _popularTabScrollViewController = ScrollController();

  // ─── For Updates Tab ─────────────────────────────────────────────────

  List<MangaSearchResult> _updatesManga = [];
  CurrentChapterNumberData _updatesTabCurrentPageNumberData =
      CurrentChapterNumberData.empty();
  final _updatesTabScrollViewController = ScrollController();
  // ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_currentSelectedMangaSourceName.isEmpty) {
      return scaffoldLoadingNoProgressWidget;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AnimatedContainer(
              height: _showAppBar ? 120.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: AppBar(
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
                    child: DropdownButton<String>(
                      value: _currentSelectedMangaSourceName,
                      onChanged: (value) {
                        if (value != null) {
                          // 👇 Code to run when selected manga source is changed
                          log(value);
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
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _popularTabWidget(),
                  _updatesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _popularTabScrollViewController.dispose();
    _popularTabScrollViewController.removeListener(() {});

    _updatesTabScrollViewController.dispose();
    _updatesTabScrollViewController.removeListener(() {});

    super.dispose();
  }

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

        // Get recently updated manga
        _getRecentlyUpdatedManga();

        // Show and hide app bar on popular tab scroll
        _popularTabScrollViewController.addListener(() {
          if (_popularTabScrollViewController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            if (!isScrollingDown) {
              isScrollingDown = true;
              _showAppBar = false;
              setState(() {});
            }
          }

          if (_popularTabScrollViewController.position.userScrollDirection ==
              ScrollDirection.forward) {
            if (isScrollingDown) {
              isScrollingDown = false;
              _showAppBar = true;
              setState(() {});
            }
          }
        });

        // Add listener to load new manga
        _popularTabScrollViewController.addListener(
          () async {
            if (_popularTabScrollViewController.position.pixels ==
                _popularTabScrollViewController.position.maxScrollExtent) {
              // If more than 10 seconds have passed since last page change, then change the page
              if ((DateTime.now().millisecondsSinceEpoch -
                      _popularTabCurrentPageNumberData.timeStamp) >=
                  10000) {
                log('Getting new page');

                setState(
                  () {
                    _popularTabCurrentPageNumberData.currentNumber++;
                    _popularTabCurrentPageNumberData.timeStamp =
                        DateTime.now().millisecondsSinceEpoch;
                  },
                );
                _updatePopularManga(_currentSelectedMangaSourceName,
                    _popularTabCurrentPageNumberData.currentNumber);
              } else {
                const snackBar = SnackBar(
                  content: Text('You Are Going too Fast, Slow Down!'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            }
          },
        );

        // show and hide app bar on tab scroll
        _updatesTabScrollViewController.addListener(() {
          if (_updatesTabScrollViewController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            if (!isScrollingDown) {
              isScrollingDown = true;
              _showAppBar = false;
              setState(() {});
            }
          }

          if (_updatesTabScrollViewController.position.userScrollDirection ==
              ScrollDirection.forward) {
            if (isScrollingDown) {
              isScrollingDown = false;
              _showAppBar = true;
              setState(() {});
            }
          }
        });
      },
    );
  }

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

    log('Read from memory? ${storedPopularManga != null && DateTime.now().difference(
          storedPopularManga.last.time,
        ).inDays <= 2}');

    // If '$_currentSelectedMangaSourceName-popularManga' is not null and the time is less than or equal 2 days, then return stored value
    if (storedPopularManga != null &&
        DateTime.now()
                .difference(
                  storedPopularManga.last.time,
                )
                .inDays <=
            2) {
      results = storedPopularManga.last.results;
    } else {
      log('Getting data from $_currentSelectedMangaSourceName');
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

      log('put data from $_currentSelectedMangaSourceName for 1');
    }

    if (mounted) {
      setState(
        () {
          _popularManga.addAll(results);
        },
      );
    }
  }

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

  Widget _latestChapterWidget(MangaSearchResult mangaSearchResult) {
    // if latest chapter title == zero return the Text widget
    if (mangaSearchResult.latestChapterTitle != null) {
      return Column(
        children: [
          const Divider(),
          Text(
            textAlign: TextAlign.center,
            'Latest Chapter: ${mangaSearchResult.latestChapterTitle}',
          ),
        ],
      );
    } else {
      // is no manga status is found then output a zero size widget
      return const SizedBox.shrink();
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

  Widget _mangaContentTypeWidget(MangaSearchResult mangaSearchResult) {
    if (mangaSearchResult.contentType == null) {
      return const SizedBox.shrink();
    }

    late final Text mangaType;
    switch (mangaSearchResult.contentType) {
      case MangaContentType.manhwa:
        {
          mangaType = const Text(
            'Manhwa',
            style: TextStyle(
              // Manhwa colour
              color: Colors.white,
            ),
          );
          break;
        }

      case MangaContentType.manhua:
        {
          mangaType = const Text(
            'Manhua',
            style: TextStyle(
              // Manhua Colour
              color: Colors.white,
            ),
          );
          break;
        }
      case MangaContentType.manga:
        {
          mangaType = const Text(
            'Manga',
            style: TextStyle(
              // Manga Colour
              color: Colors.white,
            ),
          );
          break;
        }
      default:
        {
          break;
        }
    }
    return Row(
      children: [
        pipeSeparatorWidget,
        mangaType,
      ],
    );
  }

  Widget _mangaStatusWidget(MangaSearchResult mangaSearchResult) {
    // Figure out when to display status

    if (mangaSearchResult.status != MangaStatus.none) {
      Widget mangaStatusTextWidget = const Text('');
      switch (mangaSearchResult.status) {
        case MangaStatus.ongoing:
          {
            mangaStatusTextWidget = const Text(
              'Ongoing',
              style: TextStyle(
                // Ongoing Colour
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            );
            break;
          }
        case MangaStatus.hiatus:
          {
            mangaStatusTextWidget = const Text(
              'Hiatus',
              style: TextStyle(
                // Hiatus Colour
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            );
            break;
          }
        case MangaStatus.completed:
          {
            mangaStatusTextWidget = const Text(
              'Completed',
              style: TextStyle(
                // Completed Colour
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            );
            break;
          }
        case MangaStatus.cancelled:
          {
            mangaStatusTextWidget = const Text(
              'Cancelled',
              style: TextStyle(
                // Cancelled Colour
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            );
            break;
          }

        default:
          {
            break;
          }
      }
      return Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('|'),
          ),
          mangaStatusTextWidget
        ],
      );
    }

    // is no manga status is found then output a zero size widget
    return const SizedBox.shrink();
  }

  Future<void> _openMainBox() async {
    await Hive.openBox(runtimeType.toString());
  }

  Widget _popularTabWidget() {
    if (_popularManga.isEmpty) {
      return loadingWidget;
    }

    return Scrollbar(
      child: GridView.count(
        controller: _popularTabScrollViewController,
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 0.50,
        // physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: _popularManga.map(
          (mangaSearchResult) {
            // https://stackoverflow.com/a/57866878/14928208 👇
            return Material(
              child: Ink(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DisplayMangaDetails(
                            mangaSearchResult.mangaUrl,
                            mangaSourcesData[_currentSelectedMangaSourceName]!),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: CachedNetworkImage(
                            width: 200,
                            height: 200,
                            imageUrl: mangaSearchResult.coverUrl,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) {
                              return LinearProgressIndicator(
                                backgroundColor: Colors.purple,
                                color: Colors.purpleAccent,
                                value: downloadProgress.progress,
                              );
                            },
                            errorWidget: (context, url, error) {
                              return const Icon(Icons.error);
                            },
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        textAlign: TextAlign.center,
                        mangaSearchResult.title,
                      ),

                      _latestChapterWidget(mangaSearchResult),

                      const Spacer(),

                      // Rating | Status | type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // rating
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyText1,
                              children: [
                                TextSpan(text: '${mangaSearchResult.rating}'),
                                const WidgetSpan(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 2.0,
                                    ),
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _mangaStatusWidget(mangaSearchResult),

                          _mangaContentTypeWidget(mangaSearchResult)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  void _updatePopularManga(String mangaSourceName, int pageNumber) async {
    // get popular from internet or memory

    List<MangaSearchResult> results = [];

    final box = Hive.box(runtimeType.toString());

    dynamic storedPopularManga = box.get('$mangaSourceName-popularManga');
    log('storedPopularManga is $storedPopularManga');

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

          log('loading from local: $loadFromLocal for $mangaSourceName');
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

      log('put data from $mangaSourceName for $pageNumber');
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

  Widget _updatesTab() {
    if (_updatesManga.isEmpty) {
      return loadingWidget;
    }

    return Scrollbar(
      child: GridView.count(
        controller: _updatesTabScrollViewController,
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 0.50,
        children: _updatesManga.map(
          (mangaSearchResult) {
            // https://stackoverflow.com/a/57866878/14928208 👇
            return Material(
              child: Ink(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DisplayMangaDetails(
                            mangaSearchResult.mangaUrl,
                            mangaSourcesData[_currentSelectedMangaSourceName]!),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: CachedNetworkImage(
                            width: 200,
                            height: 200,
                            imageUrl: mangaSearchResult.coverUrl,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) {
                              return LinearProgressIndicator(
                                backgroundColor: Colors.purple,
                                color: Colors.purpleAccent,
                                value: downloadProgress.progress,
                              );
                            },
                            errorWidget: (context, url, error) {
                              return const Icon(Icons.error);
                            },
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      const Spacer(),

                      Text(
                        textAlign: TextAlign.center,
                        mangaSearchResult.title,
                      ),

                      _latestChapterWidget(mangaSearchResult),

                      const Spacer(),

                      // Rating | Status | type
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // rating
                          RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyText1,
                              children: [
                                TextSpan(text: '${mangaSearchResult.rating}'),
                                const WidgetSpan(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 2.0,
                                    ),
                                    child: Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _mangaStatusWidget(mangaSearchResult),

                          _mangaContentTypeWidget(mangaSearchResult)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
