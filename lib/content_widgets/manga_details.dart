import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/content_widgets/display_chapter.dart';
import 'package:manga_reader/core/core.dart';
import 'package:manga_reader/core/utils.dart';
import 'package:readmore/readmore.dart';

class DisplayMangaDetails extends StatefulWidget {
  const DisplayMangaDetails(this._mangaUrl, this._mangaSource, {super.key});

  final ManhwaSource _mangaSource;
  final String _mangaUrl;

  @override
  State<DisplayMangaDetails> createState() => _DisplayMangaDetails();
}

class _DisplayMangaDetails extends State<DisplayMangaDetails> {
  List<MangaChapterData> mangaChapters = [];
  MangaDetails mangaDetails = MangaDetails.empty();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _getMangaDetails();
      },
    );
  }

  void _getMangaDetails() async {
    final output = await widget._mangaSource.getMangaDetails(widget._mangaUrl);
    if (mounted) {
      setState(
        () {
          mangaDetails = output;
          mangaChapters = output.chapters;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const contentPaddingLTR = 20.0;
    const contentPaddingB = 0.0;

    if (mangaDetails.title.isEmpty) {
      return const LoadingScaffold();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Details'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              contentPaddingLTR,
              contentPaddingLTR,
              contentPaddingLTR,
              contentPaddingB,
            ),
            child: Column(
              children: [
                // image
                SizedBox(
                  height: 400,
                  width: 400,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: mangaDetails.coverUrl,
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
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                // title
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    mangaDetails.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                // Rating and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // rating
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyText1,
                        children: [
                          TextSpan(text: '${mangaDetails.rating}'),
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

                    const PipeSeparatorWidget(),

                    // Figure out when to display status
                    _MangaStatusWidget(mangaDetails),
                  ],
                ),

                // description
                Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Synopsis:',
                        style: TextStyle(
                          fontSize: 20,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const Divider(),
                    _MangaDescriptionWidget(mangaDetails),
                  ],
                ),

                const Divider(),

                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bookmark_add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    // TODO: Create function
                    onPressed: () {},
                    label: const Text('Add Bookmark'),
                  ),
                ),

                const Divider(),

                Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Chapters:',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 70,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              // TODO: Create function
                              onPressed: () {},
                              child: const Text(
                                'Read First Chapter',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 70,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                              ),
                              // TODO: Create function
                              onPressed: () {},
                              child:
                                  _LatestChapterButtonChildWidget(mangaDetails),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(width: 2.0, color: Colors.purple),
                      ),
                      margin: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 500,
                            child: () {
                              // if there are no chapter found retern a text widget
                              if (mangaDetails.chapters.isEmpty) {
                                return const Center(
                                  child: Text('Chapter List is Empty'),
                                );
                              }
                              // else display chapters widget
                              return Scrollbar(
                                child: GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  mainAxisSpacing: 4.0,
                                  crossAxisSpacing: 4.0,
                                  padding: const EdgeInsets.all(4.0),
                                  children: mangaChapters.map(
                                    (chapterData) {
                                      return Material(
                                        child: Ink(
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return DisplayChapter(
                                                      chapterData,
                                                      mangaChapters,
                                                      widget._mangaSource,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                                border: Border.all(
                                                  width: 2.0,
                                                  color: Colors.pink,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    textAlign: TextAlign.center,
                                                    'Chapter ${chapterData.chapterTitle}',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                  const Divider(),
                                                  Text(
                                                    altDateFormat.format(
                                                      chapterData.releasedOn,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              );
                            }(),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              width: 60,
                              height: 60,
                              padding: const EdgeInsets.all(8.0),
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: FloatingActionButton(
                                  tooltip: 'Reverse Order',
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  backgroundColor:
                                      Theme.of(context).backgroundColor,
                                  child: const FaIcon(
                                    FontAwesomeIcons.arrowRightArrowLeft,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () {
                                        mangaChapters =
                                            mangaChapters.reversed.toList();
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),

                const Divider(),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text:
                              'Released on: ${altDateFormat.format(mangaDetails.releasedAt)}'),
                      const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.create,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MangaStatusWidget extends StatelessWidget {
  const _MangaStatusWidget(this._mangaDetails);

  final MangaDetails _mangaDetails;

  @override
  Widget build(BuildContext context) {
    Widget mangaStatusTextWidget = const Text('');
    switch (_mangaDetails.status) {
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
    return mangaStatusTextWidget;
  }
}

class _MangaDescriptionWidget extends StatelessWidget {
  const _MangaDescriptionWidget(this._mangaDetails);

  final MangaDetails _mangaDetails;

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      () {
        if (_mangaDetails.description == null) {
          return 'No Description';
        }

        return _mangaDetails.description!;
      }(),
      textAlign: TextAlign.justify,
      trimCollapsedText: ' Show More',
      trimExpandedText: ' Show Less',
      moreStyle: const TextStyle(
        color: Colors.purpleAccent,
      ),
      lessStyle: const TextStyle(color: Colors.purpleAccent),
    );
  }
}

class _LatestChapterButtonChildWidget extends StatelessWidget {
  const _LatestChapterButtonChildWidget(this._mangaDetails);

  final MangaDetails _mangaDetails;

  @override
  Widget build(BuildContext context) {
    if (_mangaDetails.chapters.isEmpty) {
      return const Text('No Latest Chapter');
    }

    return Text(
      'Read Latest Chapter ${_mangaDetails.chapters.first.chapterTitle}',
      textAlign: TextAlign.center,
    );
  }
}
