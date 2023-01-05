import 'package:flutter/material.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/core/core.dart';

class DisplayChapter extends StatefulWidget {
  final MangaChapterData _chapterData;
  final ManhwaSource _mangaSource;
  final MangaChapterData? _previousChapterData;
  final MangaChapterData? _nextChapterData;
  const DisplayChapter(
    this._chapterData,
    this._mangaSource,
    this._previousChapterData,
    this._nextChapterData, {
    super.key,
  });

  @override
  State<DisplayChapter> createState() => _DisplayChapter();
}

class _DisplayChapter extends State<DisplayChapter> {
  List<String> chapterImages = [];
  String chapterNumber = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _getChapterImages();
      },
    );
  }

  void _getChapterImages() async {
    final output = await widget._mangaSource
        .getChapterImages(widget._chapterData.chapterUrl);

    setState(
      () {
        chapterImages = output;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (chapterImages.isEmpty) {
      return const LoadingScaffold();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chapter ${widget._chapterData.chapterTitle}',
        ),
      ),
      body: Scrollbar(
        child: ListView(
          children: chapterImages.map(
            (imageUrl) {
              return Image.network(
                imageUrl,
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
