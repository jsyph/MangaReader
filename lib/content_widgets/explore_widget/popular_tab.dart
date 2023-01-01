import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/core.dart';
import '../common.dart';
import '../manga_details.dart';
import 'common.dart';

class PopularTab extends StatefulWidget {
  const PopularTab({super.key});

  void changePopularManga(BuildContext context, mangaSource) {
    context.findAncestorStateOfType<_PopularTab>()!.changePopularManga(mangaSource);
  }

  @override
  // ignore: no_logic_in_create_state
  State<PopularTab> createState() => _PopularTab();
}

class _PopularTab extends State<PopularTab>
    with AutomaticKeepAliveClientMixin<PopularTab> {
  List<MangaSearchResult> _popularManga = [];

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

    if (_popularManga.isEmpty) {
      return loadingWidget;
    }

    return Scrollbar(
      child: GridView.count(
        controller: _scrollController,
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 0.50,
        children: _popularManga.map(
          (mangaSearchResult) {
            // https://stackoverflow.com/a/57866878/14928208 👇
            return Material(
              child: Ink(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (Colors.purple[600])!,
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
                        style: GoogleFonts.montserrat(),
                      ),

                      const Divider(),

                      () {
                        // if latest chapter title == zero return the Text widget
                        if (mangaSearchResult.latestChapterTitle != null) {
                          return Text(
                            textAlign: TextAlign.center,
                            'Latest Chapter: ${mangaSearchResult.latestChapterTitle}',
                            style: GoogleFonts.cairo(),
                          );
                        } else {
                          // is no manga status is found then output a zero size widget
                          return const SizedBox.shrink();
                        }
                      }(),

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

                          // Figure out when to display status
                          () {
                            if (mangaSearchResult.status != MangaStatus.none) {
                              Widget mangaStatusTextWidget = const Text('');
                              switch (mangaSearchResult.status) {
                                case MangaStatus.ongoing:
                                  {
                                    mangaStatusTextWidget = const Text(
                                      'Ongoing',
                                      style: TextStyle(
                                        color: Colors.green,
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
                                        color: Colors.orange,
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
                                        color: Colors.blue,
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
                                        color: Colors.red,
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
                          }(),

                          () {
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
                                      color: Colors.pink,
                                    ),
                                  );
                                  break;
                                }

                              case MangaContentType.manhua:
                                {
                                  mangaType = const Text(
                                    'Manhua',
                                    style: TextStyle(
                                      color: Colors.green,
                                    ),
                                  );
                                  break;
                                }
                              case MangaContentType.manga:
                                {
                                  mangaType = const Text(
                                    'Manga',
                                    style: TextStyle(
                                      color: Colors.yellowAccent,
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
                          }()
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

  void changePopularManga(String mangaSourceName) async {
    setState(
      () {
        // make popular_manga to []
        _popularManga = [];
        // reset CurrentChapterNumberData
        _currentPageNumberData = CurrentChapterNumberData.empty();
        // make _mangaSourceName to mangaSourceName
        _mangaSourceName = mangaSourceName;
        // reset position of gridview
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      },
    );

    await _updatePopularManga(
      mangaSourceName,
      _currentPageNumberData.currentNumber,
    );
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
        .popular(page: _currentPageNumberData.currentNumber);

    if (mounted) {
      setState(
        () {
          _popularManga.addAll(results);
        },
      );
    }
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
