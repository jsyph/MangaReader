  String? nextMangaChapterUrl(int currentIndex, List<String> chapterUrls) {
    if ((currentIndex + 1) > (chapterUrls.length-1)) {
      return null;
    }

    return chapterUrls[currentIndex + 1];
  }

  String? previousMangaChapterUrl(int currentIndex, List<String> chapterUrls) {
    if ((currentIndex - 1 )== -1) {
      return null;
    }

    return chapterUrls[currentIndex - 1];
  }