import 'package:intl/intl.dart';
import 'package:web_scraper/web_scraper.dart';

import '../data_classes.dart';

class FlameScans implements ManhwaSource {
  final _webScraper = WebScraper('https://flamescans.org');

  @override
  Future<List<String>> getChapterImages(String chapterUrl) async {
    final chapterUrlEndpoint =
        chapterUrl.replaceAll(RegExp(r'https://flamescans.org'), '');

    if (await _webScraper.loadWebPage(chapterUrlEndpoint)) {
      // get images, then convert them to string and convert map to list
      final allImages = _webScraper
          .getElement('div#readerarea > p > img', ['src'])
          .map(
            (e) => e['attributes']['src'].toString(),
          )
          .toList();

      return allImages;
    }

    return [];
  }

  @override
  Future<MangaDetails> getMangaDetails(String mangaUrl) async {
    final mangaUrlEndpoint =
        mangaUrl.replaceAll(RegExp(r'https://flamescans.org'), '');
    return MangaDetails.empty();
  }

  @override
  Future<List<MangaSearchResult>> popular() async {
    return [];
  }

  @override
  Future<List<MangaSearchResult>> search(String query) async {
    return [];
  }
}
