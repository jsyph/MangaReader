import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/content_widgets/explore_widget/common.dart';
import 'package:manga_reader/content_widgets/explore_widget/updates_tab.dart';
import 'package:manga_reader/core/core.dart';

import '../manga_details.dart';

class ExploreWidget extends StatefulWidget {
  const ExploreWidget({super.key});

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget>
    with
        AutomaticKeepAliveClientMixin<ExploreWidget>,
        SingleTickerProviderStateMixin {
  // Popular Tab
  List<MangaSearchResult> _popularManga = [];
  CurrentChapterNumberData _currentPageNumberData =
      CurrentChapterNumberData.empty();

  String _currentSelectedMangaSourceName = '';

  late final TabController _tabController;

  // for mixin 👇
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_currentSelectedMangaSourceName.isEmpty) {
      return scaffoldLoadingNoProgressWidget;
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
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

                        // _changeUpdatesManga(value).then(
                        //       (_) => _changeSelectedMangaSourceName(value),
                        //     );

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
          ];
        },
        body: MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: Builder(
            builder: (context) {
              final controller = PrimaryScrollController.of(context);
              _addPopularMangaScrollControllerListener(controller!);
              return TabBarView(
                controller: _tabController,
                children: [
                  _popularTabWidget(controller),
                  Text('hello'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _addPopularMangaScrollControllerListener(ScrollController controller) {
    // I need to use this as the scroll controller for some reason has multiple listeners doing the same thing
    if (!controller.hasListeners) {
      return controller.addListener(
        () async {
          if (controller.position.pixels ==
              controller.position.maxScrollExtent) {
            // If more than 10 seconds have passed since last page change, then change the page
            if ((DateTime.now().millisecondsSinceEpoch -
                    _currentPageNumberData.timeStamp) >=
                10000) {
              log('Getting new page');

              setState(
                () {
                  _currentPageNumberData.currentNumber++;
                  _currentPageNumberData.timeStamp =
                      DateTime.now().millisecondsSinceEpoch;
                },
              );
              _updatePopularManga(
                _currentSelectedMangaSourceName,
                _currentPageNumberData.currentNumber,
              );
            } else {
              const snackBar = SnackBar(
                content: Text('You Are Going too Fast, Slow Down!'),
                duration: Duration(milliseconds: 500),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          }
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _loadMangaSourceName();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getPopularManga();
    });
  }

  Future<void> _changePopularManga(String mangaSourceName) async {
    // If the _popularManga list is empty, which means the screen is being update, pass, else continue.
    if (_popularManga.isNotEmpty) {
      setState(
        () {
          // make popular_manga to []
          _popularManga = [];
          // reset CurrentChapterNumberData
          _currentPageNumberData = CurrentChapterNumberData.empty();
        },
      );
      await _updatePopularManga(
        mangaSourceName,
        _currentPageNumberData.currentNumber,
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

  /// is run only at startup
  void _getPopularManga() async {
    // get popular from internet or memory

    List<MangaSearchResult> results = [];

    results = await mangaSourcesData[_currentSelectedMangaSourceName]!
        .popular(page: _currentPageNumberData.currentNumber);

    if (mounted) {
      setState(
        () {
          _popularManga.addAll(results);
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

  void _loadMangaSourceName() async {
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

  Widget _popularTabWidget(ScrollController controller) {
    if (_popularManga.isEmpty) {
      return loadingWidget;
    }

    return Scrollbar(
      child: GridView.count(
        controller: controller,
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 0.50,
        physics: const NeverScrollableScrollPhysics(),
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

  Future<void> _updatePopularManga(
      String mangaSourceName, int pageNumber) async {
    final internalPopularManga =
        await mangaSourcesData[mangaSourceName]!.popular(page: pageNumber);

    if (mounted) {
      setState(
        () {
          _popularManga.addAll(internalPopularManga);
        },
      );
    }
  }
}
