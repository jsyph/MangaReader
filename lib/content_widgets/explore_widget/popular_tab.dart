import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/core.dart';
import '../common.dart';
import '../manga_details.dart';
import 'common.dart';

class PopularTab extends StatefulWidget {
  final _state = _PopularTab();

  PopularTab({super.key});

  Future<void> changeMangaSource(String sourceName) async {
    _state.changePopularManga(sourceName);
  }

  @override
  // ignore: no_logic_in_create_state
  State<PopularTab> createState() => _state;
}

class _PopularTab extends State<PopularTab>
    with AutomaticKeepAliveClientMixin<PopularTab> {
  final logger = Logger('PopularTabState');

  List<MangaSearchResult> _popularManga = [];

  final _scrollController = ScrollController();

  CurrentChapterNumberData _currentPageNumberData =
      CurrentChapterNumberData.empty();

  @override
  bool get wantKeepAlive => true;

  String _selectedMangaSourceName = '';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_popularManga.isEmpty) {
      return loadingWidget;
    }

    return Scrollbar(
      child: GridView.count(
        key: const PageStorageKey<String>('popularTab'),
        physics: const AlwaysScrollableScrollPhysics(),
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
                            mangaSourcesData[_selectedMangaSourceName]!),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 190,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: CachedNetworkImage(
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

                      // Rating | Status
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
                                      size: 20,
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
        _popularManga = [];
        _currentPageNumberData = CurrentChapterNumberData.empty();
      },
    );

    await _getPopularManga(
        mangaSourceName, _currentPageNumberData.currentNumber);
  }

  @override
  void initState() {
    super.initState();

    _startUp();

    // Add listener to load new manga
    _scrollController.addListener(
      () async {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          logger.fine('Loading next page: $_currentPageNumberData');

          // If more than 10 seconds have passed since last page change, then change the page
          if ((DateTime.now().millisecondsSinceEpoch -
                  _currentPageNumberData.timeStamp) >=
              10000) {
            logger.info('More than 10 seconds have passed');

            setState(
              () {
                _currentPageNumberData.currentNumber++;
                _currentPageNumberData.timeStamp =
                    DateTime.now().millisecondsSinceEpoch;
              },
            );
            _getPopularManga(
                _selectedMangaSourceName, _currentPageNumberData.currentNumber);
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

  Future<void> _getPopularManga(String mangaSourceName, int pageNumber) async {
    final popularManga =
        await mangaSourcesData[mangaSourceName]!.popular(page: pageNumber);

    if (mounted) {
      setState(
        () {
          popularManga.addAll(popularManga);
        },
      );
    }

    _storeSearchResults(popularManga);
  }

  Future<List<MangaSearchResult>?> _loadSearchResults() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final encodedData = prefs.getString('popular_manga');

    if (encodedData == null) {
      return null;
    }

    final List<MangaSearchResult> results =
        MangaSearchResult.decode(encodedData);

    return results;
  }

  /// is run only at startup
  void _startUp() async {
    // ─── Set Manga Source ────────────────────────────────────────
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? selctedManga = prefs.getString('selected_manga_source');

    if (selctedManga == null) {
      final value = mangaSourcesData.keys.first;
      await prefs.setString(
        'selected_manga_source',
        value,
      );
      _selectedMangaSourceName = value;
    } else {
      _selectedMangaSourceName = selctedManga;
    }

    // get popular from internet or memory

    final storedPopular = await _loadSearchResults();

    List<MangaSearchResult> results = [];

    if (storedPopular == null) {
      results = await mangaSourcesData[_selectedMangaSourceName]!
          .popular(page: _currentPageNumberData.currentNumber);
      _storeSearchResults(results);
    } else {
      results.addAll(storedPopular);
    }

    if (mounted) {
      setState(
        () {
          _popularManga.addAll(results);
        },
      );
    }
  }

  void _storeSearchResults(List<MangaSearchResult> mangaSearchResults) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String encodedData = MangaSearchResult.encode(mangaSearchResults);

    await prefs.setString('popular_manga', encodedData);
  }
}
