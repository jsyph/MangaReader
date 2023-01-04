/// Contains the chapter data for each chapter in the manga:
/// - __chapterNumber__: (*double*) number of chapter
/// - __releasedOn__: (*DateTime*) date the chapter is released on
/// - __chapterUrl__: (*String*) the url for the chapter
class MangaChapterData {
  final String chapterTitle;
  final DateTime releasedOn;
  final String chapterUrl;
  final String mangaSourceName;

  MangaChapterData(
    this.chapterTitle,
    this.releasedOn,
    this.chapterUrl,
    this.mangaSourceName,
  );

  @override
  String toString() {
    return '''MangaChapterData(
      chapterTitle: $chapterTitle,\n
    releasedOn: $releasedOn,\n
    chapterUrl: $chapterUrl,\n
    )''';
  }
}