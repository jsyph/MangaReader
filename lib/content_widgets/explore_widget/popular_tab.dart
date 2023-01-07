import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/content_widgets/explore_widget/common_widgets.dart';
import 'package:manga_reader/content_widgets/manga_details.dart';
import 'package:manga_reader/core/core.dart';

class PopularTab extends StatelessWidget {
  final List<MangaSearchResult> _popularManga;
  final String _mangaSourceName;

  const PopularTab(this._popularManga, this._mangaSourceName, {super.key});

  @override
  Widget build(BuildContext context) {
    if (_popularManga.isEmpty) {
      return const LoadingWidget();
    }

    return Scrollbar(
      child: GridView.count(
        // controller: scrollController,
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        childAspectRatio: 0.50,
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
                          mangaSourcesData[_mangaSourceName]!,
                        ),
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

                      LatestChapterWidget(mangaSearchResult),

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

                          MangaStatusWidget(mangaSearchResult),

                          MangaContentTypeWidget(mangaSearchResult)
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
