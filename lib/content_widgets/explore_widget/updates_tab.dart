import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/core.dart';
import '../common.dart';
import '../manga_details.dart';
import 'common.dart';

class UpdatesTab extends StatefulWidget {
  final _state = _UpdatesTab();

  UpdatesTab({super.key});

  Future<void> changeUpdatesManga(String mangaSource) async {
    await _state.changeUpdatesManga(mangaSource);
  }

  @override
  // ignore: no_logic_in_create_state
  State<UpdatesTab> createState() => _state;
}

class _UpdatesTab extends State<UpdatesTab>
    with AutomaticKeepAliveClientMixin<UpdatesTab> {
  List<MangaSearchResult> _updatesManga = [];

  final _scrollController = ScrollController();

  CurrentChapterNumberData _currentPageNumberData =
      CurrentChapterNumberData.empty();

  String _mangaSourceName = mangaSourcesData.keys.first;

  // 👇 mixin stuff
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_updatesManga.isEmpty) {
      return loadingWidget;
    }

    return Scrollbar(
      child: GridView.count(
        controller: _scrollController,
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
                            mangaSourcesData[_mangaSourceName]!),
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

  Future<void> changeUpdatesManga(String mangaSourceName) async {
    // If the _popularManga list is empty, which means the screen is being update, pass, else continue.
    if (_updatesManga.isNotEmpty) {
      setState(
        () {
          if (_scrollController.hasClients) {
            // make popular_manga to []
            _updatesManga = [];
            // reset CurrentChapterNumberData
            _currentPageNumberData = CurrentChapterNumberData.empty();
            // make _mangaSourceName to mangaSourceName
            _mangaSourceName = mangaSourceName;
            // reset position of gridview
            _scrollController
                .jumpTo(_scrollController.position.minScrollExtent);
            // set isReady to display drop down menu
          }
        },
      );
      await _updatePopularManga(
        mangaSourceName,
        _currentPageNumberData.currentNumber,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getPopularManga();
    });

    // Add listener to load new manga
    _scrollController.addListener(
      () async {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
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
                _mangaSourceName, _currentPageNumberData.currentNumber);
          } else {
            const snackBar = SnackBar(
              content: Text('You Are Going too Fast, Slow Down!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        }
      },
    );
  }

  /// is run only at startup
  void _getPopularManga() async {
    // get popular from internet or memory

    List<MangaSearchResult> results = [];

    results = await mangaSourcesData[_mangaSourceName]!
        .updates(page: _currentPageNumberData.currentNumber);

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
        pipeSeperatorWidget,
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

  Future<void> _updatePopularManga(
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
}
