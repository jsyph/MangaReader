import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/content_widgets/manga_details.dart';
import 'package:manga_reader/content_widgets/search_widget/stateless_widgets.dart';
import 'package:manga_reader/core/core_types/manga_search_result.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class FloatingSearchBarWidget extends StatefulWidget {
  const FloatingSearchBarWidget({super.key});

  @override
  State<FloatingSearchBarWidget> createState() => _FloatingSearchBarWidget();
}

class _FloatingSearchBarWidget extends State<FloatingSearchBarWidget> with AutomaticKeepAliveClientMixin<FloatingSearchBarWidget>{
    List<MangaSearchResult> _searchResults = [];
  bool _showProgressBar = false;

  @override
  bool get wantKeepAlive => true;

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
    super.build(context);

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
