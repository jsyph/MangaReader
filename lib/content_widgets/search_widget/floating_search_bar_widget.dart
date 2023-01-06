import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/content_widgets/manga_details.dart';
import 'package:manga_reader/core/core.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class FloatingSearchBarWidget extends StatefulWidget {
  const FloatingSearchBarWidget({super.key});

  @override
  State<FloatingSearchBarWidget> createState() => _FloatingSearchBarWidget();
}

class _FloatingSearchBarWidget extends State<FloatingSearchBarWidget>{
    List<MangaSearchResult> _searchResults = [];
  bool _showProgressBar = false;


    Future<List<MangaSearchResult>> _makeSearch(String query) async {
    final allSources = mangaSourcesData.values.toList();
    log(allSources.toString());
    List<MangaSearchResult> searchResults = [];

    for (int i = 0; i < allSources.length; i++) {
      log(i.toString());
      final searchResult = await allSources[i].search(query);
      log(searchResult.toString());
      searchResults.addAll(
        searchResult,
      );
    }

    return searchResults;
  }

  @override
  Widget build(BuildContext context) {

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 500),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      transition: CircularFloatingSearchBarTransition(),
      debounceDelay: const Duration(milliseconds: 400),
      progress: _showProgressBar,
      onSubmitted: (query) {
        setState(
          () {
            _showProgressBar = true;
          },
        );
        _makeSearch(query).then(
          (value) => setState(
            () {
              _searchResults = value;
              _showProgressBar = false;
            },
          ),
        );
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: true,
        ),
      ],

      clearQueryOnClose: false,

      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _searchResults.map(
                (searchResult) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    margin: const EdgeInsets.all(8.0),
                    child: Ink(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisplayMangaDetails(
                                searchResult.mangaUrl,
                                mangaSourcesData[searchResult.mangaSourceName]!,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  width: 100,
                                  height: 120,
                                  imageUrl: searchResult.coverUrl,
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
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    searchResult.title,
                                    textAlign: TextAlign.center,
                                  ),
                                  const Divider(),
                                  LatestChapterWidget(searchResult),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          MangaRatingWidget(searchResult),
                                          const PipeSeparatorWidget()
                                        ],
                                      ),
                                      MangaContentTypeWidget(searchResult),
                                      MangaStatusWidget(searchResult),
                                    ],
                                  ),
                                  Text(searchResult.mangaSourceName),
                                ],
                              ),
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
      },
    );
  }
}

class LatestChapterWidget extends StatelessWidget {
  const LatestChapterWidget(this._mangaSearchResult, {super.key});

  final MangaSearchResult _mangaSearchResult;

  @override
  Widget build(BuildContext context) {
    // if latest chapter title == zero return the Text widget
    if (_mangaSearchResult.latestChapterTitle != null) {
      return Column(
        children: [
          Text(
            textAlign: TextAlign.center,
            'Latest Chapter: ${_mangaSearchResult.latestChapterTitle}',
          ),
        ],
      );
    } else {
      // is no manga status is found then output a zero size widget
      return const SizedBox.shrink();
    }
  }
}

class MangaRatingWidget extends StatelessWidget {
  const MangaRatingWidget(this._mangaSearchResult, {super.key});

  final MangaSearchResult _mangaSearchResult;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyText1,
        children: [
          TextSpan(text: '${_mangaSearchResult.rating}'),
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
    );
  }
}

class MangaContentTypeWidget extends StatelessWidget {
  const MangaContentTypeWidget(this._mangaSearchResult, {super.key});

  final MangaSearchResult _mangaSearchResult;

  @override
  Widget build(BuildContext context) {
    if (_mangaSearchResult.contentType == null ||
        _mangaSearchResult.contentType == MangaContentType.none) {
      return const SizedBox.shrink();
    }

    late final Text mangaType;
    switch (_mangaSearchResult.contentType) {
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
    return mangaType;
  }
}

class MangaStatusWidget extends StatelessWidget {
  const MangaStatusWidget(this._mangaSearchResult, {super.key});

  final MangaSearchResult _mangaSearchResult;

  @override
  Widget build(BuildContext context) {
    // Figure out when to display status

    if (_mangaSearchResult.status != MangaStatus.none) {
      Widget mangaStatusTextWidget = const Text('');
      switch (_mangaSearchResult.status) {
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
      return mangaStatusTextWidget;
    }

    // is no manga status is found then output a zero size widget
    return const SizedBox.shrink();
  }
}
