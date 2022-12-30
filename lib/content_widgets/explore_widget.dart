import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/content_widgets/manga_details.dart';
import 'package:manga_reader/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../styles.dart';

Map<String, ManhwaSource> _mangaSourcesData = {
  'Asura Scans': AsuraScans(),
  'Cosmic Scans': CosmicScans(),
  'Flame Scans': FlameScans(),
  'Luminous Scans': LuminousScans(),
};

class ExploreWidget extends StatefulWidget {
  const ExploreWidget({super.key});

  @override
  State<ExploreWidget> createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget> {
  List<MangaSearchResult> _popularManga = [];
  String _currentSelectedMangaSourceName = '';

  @override
  Widget build(BuildContext context) {
    if (_popularManga.isEmpty) {
      return scaffoldLoadingNoProgressWidget;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Displaying Popular on'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Theme.of(context).appBarTheme.backgroundColor,

            // dropdown below..
            child: DropdownButton<String>(
              value: _currentSelectedMangaSourceName,
              onChanged: (value) {
                if (value != null) {
                  setState(
                    () {
                      _popularManga = [];
                    },
                  );
                  if (mounted) {
                    log(value);
                    _updatePopularManga(value).whenComplete(
                        () => _updateSelectedMangaSourceName(value));
                  }
                }
              },
              items: _mangaSourcesData.keys
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
      body: Scrollbar(
        child: GridView.count(
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
                              _mangaSourcesData[
                                  _currentSelectedMangaSourceName]!),
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
                          if (mangaSearchResult.latestChapterTitle.isNotEmpty) {
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
                              if (mangaSearchResult.status !=
                                  MangaStatus.none) {
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _startUp();
      },
    );
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
      final value = _mangaSourcesData.keys.first;
      await prefs.setString(
        'selected_manga_source',
        value,
      );
      _currentSelectedMangaSourceName = value;
    } else {
      _currentSelectedMangaSourceName = selctedManga;
    }

    // get popular from internet or memory

    final storedPopular = await _loadSearchResults();

    List<MangaSearchResult> results = [];

    if (storedPopular == null) {
      results =
          await _mangaSourcesData[_currentSelectedMangaSourceName]!.popular();
      _storeSearchResults(results);
    } else {
      results = storedPopular;
    }

    if (mounted) {
      setState(
        () {
          _popularManga = results;
        },
      );
    }
  }

  void _storeSearchResults(List<MangaSearchResult> mangaSearchResults) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String encodedData = MangaSearchResult.encode(mangaSearchResults);

    await prefs.setString('popular_manga', encodedData);
  }

  Future<void> _updatePopularManga(String mangaSourceName) async {
    final popularManga = await _mangaSourcesData[mangaSourceName]!.popular();
    _storeSearchResults(popularManga);
    if (mounted) {
      setState(
        () {
          _popularManga = popularManga;
        },
      );
    }
  }

  void _updateSelectedMangaSourceName(String mangaSourceName) async {
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
}
