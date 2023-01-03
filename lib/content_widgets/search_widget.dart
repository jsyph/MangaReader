import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/core/core.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

import 'manga_details.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget>
    with AutomaticKeepAliveClientMixin<SearchWidget> {
  List<MangaSearchResult> _searchResults = [];
  bool _showProgressBAr = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      // This is handled by the search bar itself.
      resizeToAvoidBottomInset: false,
      body: buildFloatingSearchBar(context), 
      
    );
  }

  Widget buildFloatingSearchBar(BuildContext context) {

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 500),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      transition: CircularFloatingSearchBarTransition(),
      debounceDelay: const Duration(milliseconds: 400),
      progress: _showProgressBAr,
      onSubmitted: (query) {
        setState(
          () {
            _showProgressBAr = true;
          },
        );
        _makeSearch(query).then(
          (value) => setState(
            () {
              _searchResults = value;
              _showProgressBAr = false;
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
                                  _latestChapterWidget(searchResult),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          _mangaRatingWidget(searchResult),
                                          pipeSeparatorWidget
                                        ],
                                      ),
                                      _mangaContentTypeWidget(searchResult),
                                      _mangaStatusWidget(searchResult),
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

  Widget _latestChapterWidget(MangaSearchResult mangaSearchResult) {
    // if latest chapter title == zero return the Text widget
    if (mangaSearchResult.latestChapterTitle != null) {
      return Column(
        children: [
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

  Widget _mangaContentTypeWidget(MangaSearchResult mangaSearchResult) {
    if (mangaSearchResult.contentType == null ||
        mangaSearchResult.contentType == MangaContentType.none) {
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
    return mangaType;
  }

  Widget _mangaRatingWidget(MangaSearchResult mangaSearchResult) {
    return RichText(
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
      return mangaStatusTextWidget;
    }

    // is no manga status is found then output a zero size widget
    return const SizedBox.shrink();
  }
}
