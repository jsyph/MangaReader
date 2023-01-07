import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:http/retry.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/content_widgets/main_widget.dart';
import 'package:manga_reader/core/core.dart';
import 'package:fullscreen/fullscreen.dart';
import 'package:page_transition/page_transition.dart';

class DisplayChapter extends StatefulWidget {
  const DisplayChapter(
    this._chapterData,
    this._allChapters,
    this._mangaSource, {
    super.key,
  });

  final List<MangaChapterData> _allChapters;
  final MangaChapterData _chapterData;
  final ManhwaSource _mangaSource;

  @override
  State<DisplayChapter> createState() => _DisplayChapter();
}

class _DisplayChapter extends State<DisplayChapter> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  List<String> _chapterImages = [];
  bool _isFullScreen = false;
  late final MangaChapterData? _nextMangaChapterData;
  late final MangaChapterData? _previousMangaChapterData;

  @override
  void dispose() async {
    super.dispose();

    await FullScreen.exitFullScreen();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _nextMangaChapterData = _getNextChapterData();
        _previousMangaChapterData = _getPreviousChapterData();

        _getChapterImages();
      },
    );
  }

  void _getChapterImages() async {
    final output = await widget._mangaSource
        .getChapterImages(widget._chapterData.chapterUrl);

    setState(
      () {
        _chapterImages = output;
      },
    );
  }

  Future<void> _toggleFullScreen() async {
    final isFullScreen = (await FullScreen.isFullScreen)!;

    if (isFullScreen) {
      setState(() => _isFullScreen = false);
      await FullScreen.exitFullScreen();
    } else {
      setState(() => _isFullScreen = true);
      await FullScreen.enterFullScreen(FullScreenMode.EMERSIVE_STICKY);
    }
  }

  MangaChapterData? _getNextChapterData() {
    if ((widget._allChapters.indexOf(widget._chapterData) + 1) >
        (widget._allChapters.length - 1)) {
      return null;
    }

    return widget
        ._allChapters[widget._allChapters.indexOf(widget._chapterData) + 1];
  }

  MangaChapterData? _getPreviousChapterData() {
    if ((widget._allChapters.indexOf(widget._chapterData) - 1) == -1) {
      return null;
    }

    return widget
        ._allChapters[widget._allChapters.indexOf(widget._chapterData) - 1];
  }

  @override
  Widget build(BuildContext context) {
    // hide status bar

    if (_chapterImages.isEmpty) {
      return const LoadingScaffold();
    }

    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(Icons.list),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            floating: true,
            title: DropdownButton(
              value: widget._chapterData,
              onChanged: (selectedChapterData) {
                if (selectedChapterData != null) {
                  if (widget._allChapters.indexOf(selectedChapterData) >
                      widget._allChapters.indexOf(widget._chapterData)) {
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        child: DisplayChapter(
                          selectedChapterData,
                          widget._allChapters,
                          widget._mangaSource,
                        ),
                        type: PageTransitionType.leftToRight,
                      ),
                    );
                  } else if (widget._allChapters.indexOf(selectedChapterData) <
                      widget._allChapters.indexOf(widget._chapterData)) {
                    Navigator.pushReplacement(
                      context,
                      PageTransition(
                        child: DisplayChapter(
                          selectedChapterData,
                          widget._allChapters,
                          widget._mangaSource,
                        ),
                        type: PageTransitionType.rightToLeft,
                      ),
                    );
                  }
                }
              },
              items: widget._allChapters.map(
                (chapterData) {
                  log('`${chapterData.chapterTitle}`');
                  return DropdownMenuItem(
                    value: chapterData,
                    child: SizedBox(
                      width: 180,
                      child: Text(
                        'Chapter ${chapterData.chapterTitle}',
                        style: const TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  );
                },
              ).toList(),

              selectedItemBuilder: (context) {
                return widget._allChapters.map(
                  (chapterData) {
                    return DropdownMenuItem(
                      value: chapterData,
                      child: SizedBox(
                        width: 180,
                        child: Text(
                          'Chapter ${chapterData.chapterTitle}',
                          style: const TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          softWrap: false,
                        ),
                      ),
                    );
                  },
                ).toList();
              },

              // add extra sugar..
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),
              underline: const SizedBox(),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  await _toggleFullScreen();
                },
                icon: Icon(
                    _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
              )
            ],
          )
        ],
        body: MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: Scrollbar(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: _chapterImages.map(
                    (imageUrl) {
                      return Image.network(
                        // TODO: MAKE THIS WORK (╯°□°）╯︵ ┻━┻
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          return child;
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          return Center(child: child);
                        },
                      );
                    },
                  ).toList(),
                ),
                Row(
                  children: [
                    _previousChapterButtonWidget(),
                    _nextChapterButtonWidget(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _previousChapterButtonWidget() {
    if (_previousMangaChapterData != null) {
      return Expanded(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).backgroundColor,
              minimumSize: const Size.fromHeight(70)),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageTransition(
                child: DisplayChapter(
                  _previousMangaChapterData!,
                  widget._allChapters,
                  widget._mangaSource,
                ),
                type: PageTransitionType.leftToRight,
              ),
            );
          },
          label: const Text('Previous Chapter'),
          icon: const Icon(Icons.navigate_before),
        ),
      );
    } else {
      return Expanded(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).backgroundColor,
              minimumSize: const Size.fromHeight(70)),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageTransition(
                child: const MainWidget(),
                type: PageTransitionType.fade,
              ),
            );
          },
          label: const Text('Home'),
          icon: const Icon(Icons.home),
        ),
      );
    }
  }

  Widget _nextChapterButtonWidget() {
    if (_nextMangaChapterData != null) {
      return Expanded(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).backgroundColor,
              minimumSize: const Size.fromHeight(70)),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageTransition(
                child: DisplayChapter(
                  _nextMangaChapterData!,
                  widget._allChapters,
                  widget._mangaSource,
                ),
                type: PageTransitionType.rightToLeft,
              ),
            );
          },
          label: const Text('Next Chapter'),
          icon: const Icon(Icons.navigate_next),
        ),
      );
    } else {
      return Expanded(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).backgroundColor,
            minimumSize: const Size.fromHeight(70),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              PageTransition(
                child: const MainWidget(),
                type: PageTransitionType.fade,
              ),
            );
          },
          label: const Text('Home'),
          icon: const Icon(Icons.home),
        ),
      );
    }
  }
}
