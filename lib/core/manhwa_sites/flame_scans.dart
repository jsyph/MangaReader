import 'dart:developer';

import 'package:manga_reader/core/utils.dart';
import 'package:manga_reader/core/webscraper_extension.dart';
import 'package:web_scraper/web_scraper.dart';

import '../core_types.dart';

class FlameScans implements ManhwaSource {
  final _webScraper = WebScraper('https://flamescans.org');

  @override
  Future<List<String>> getChapterImages(String chapterUrl) async {
    final chapterUrlEndpoint =
        chapterUrl.replaceAll(RegExp(r'https://flamescans.org'), '');

    if (await _webScraper.loadWebPage(chapterUrlEndpoint)) {
      // get images, then convert them to string and convert map to list
      return _webScraper.getElementAttributeUnwrapString(
          'div#readerarea > p > img', 'src');
    }

    return [];
  }

  @override
  Future<MangaDetails> getMangaDetails(String mangaUrl) async {
    final mangaUrlEndpoint =
        mangaUrl.replaceAll(RegExp(r'https://flamescans.org'), '');

    if (await _webScraper.loadWebPage(mangaUrlEndpoint)) {
      // ─── Get Title ───────────────────────────────────────

      final mangaTitle =
          _webScraper.getFirstElementTitle('div.titles > h1.entry-title');

      // ─── Get Description ─────────────────────────────────

      String mangaDescription = _webScraper.getFirstElementTitle(
          'div.summary > div.wd-full > div.entry-content > p');

      // ─── Get Cover Url ───────────────────────────────────

      final mangaCoverUrl = _webScraper.getFirstElementAttribute(
          'div.thumb-half > div.thumb > img', 'src');

      // ─── Get Status ──────────────────────────────────────

      // cant use getFirstElementTitle here as the index is 1 😥
      final mangaStatus = MangaStatus.parse(
        _webScraper.getElementTitle('div.tsinfo > div.imptdt > i')[1],
      );

      // ─── Get Manga Content Type ──────────────────────────

      final mangaContentType = MangaContentType.parse(
        _webScraper.getFirstElementTitle('div.tsinfo > div.imptdt > i'),
      );

      // ─── Get Rating ──────────────────────────────────────

      // Get Manga rating then parse it to double
      final mangaRating = double.parse(
        _webScraper.getFirstElementTitle(
            'div.extra-info > div.mobile-rt > div.numscore'),
      );

      // ─── Get Released At ─────────────────────────────────

      // 1. get html datetime object
      // 2. convert it to string
      // 3. parse it into `DateTime` object
      final mangaReleasedOn = DateTime.parse(
        _webScraper.getFirstElementAttribute(
            'div.imptdt > i > time', 'datetime'),
      );

      // ─── Get Tags ────────────────────────────────────────

      final mangaTags = _webScraper.getElementTitle(
        'div.genres-container > div.wd-full > span.mgen > a',
      );

      // ─── Get Chapters ────────────────────────────────────

      // Get all chapter numbers
      final mangaChapterTitles = _webScraper
          .getElementTitle('span.chapternum')
          .map((e) => removeChapterFromString(e))
          .toList();

      // Get all released on dates
      final mangaChapterReleasedOn = _webScraper
          .getElementTitle('span.chapterdate')
          .map(
            (e) => altDateFormat.parse(e),
          )
          .toList();

      // Get all chapter urls
      final mangaChapterUrls = _webScraper.getElementAttributeUnwrapString(
          'div#chapterlist > ul > li > a', 'href');

      // Comine all into list of MangaChapterDate
      List<MangaChapterData> mangaChapters = [];

      for (var i = 0; i < mangaChapterUrls.length; i++) {
        mangaChapters.add(
          MangaChapterData(
            mangaChapterTitles[i],
            mangaChapterReleasedOn[i],
            mangaChapterUrls[i],
          ),
        );
      }

      // ─── Combine Into Mangadetails ───────────────────────

      return MangaDetails(
        mangaTitle,
        mangaDescription,
        mangaCoverUrl,
        mangaRating,
        mangaStatus,
        mangaReleasedOn,
        mangaChapters,
        mangaTags,
        mangaContentType
      );
    }

    return MangaDetails.empty();
  }

  @override
  Future<List<MangaSearchResult>> popular({int page = 1}) async {
    final targetEndpoint = '/ygd/series/?type=manhwa&order=popular&page=$page';

    return await _makeSearch(targetEndpoint);
  }

  @override
  Future<List<MangaSearchResult>> search(String query) async {
    final formattedQuery = query.replaceAll(RegExp(r' '), '+').toLowerCase();

    return await _makeSearch('/ygd/?s=$formattedQuery');
  }

  Future<List<MangaSearchResult>> _makeSearch(String targetEndpoint) async {
    if (await _webScraper.loadWebPage(targetEndpoint)) {
      // Get cover urls
      final resultCoverUrls = _webScraper.getElementAttributeUnwrapString(
        'img.ts-post-image.wp-post-image.attachment-medium.size-medium',
        'src',
      );

      // get titles and get manga url
      final resultTitleAndMangaUrl =
          _webScraper.getElement('div.bsx > a', ['href', 'title']);

      final resultTitles = resultTitleAndMangaUrl
          .map(
            (e) => e['attributes']['title'].toString(),
          )
          .toList();

      final resulMangaUrls = resultTitleAndMangaUrl
          .map(
            (e) => e['attributes']['href'].toString(),
          )
          .toList();

      // get rating
      final resultRatings = _webScraper
          .getElementTitle('div.mobile-rt > div.numscore')
          .map(
            (e) => double.parse(e),
          )
          .toList();

      // get status
      final resultStatuses = _webScraper
          .getElementTitle('div.status > i')
          .map(
            (e) => MangaStatus.parse(e),
          )
          .toList();

      List<MangaSearchResult> results = [];
      // combine into list of MangaSearchResult
      for (int i = 0; i < resulMangaUrls.length; i++) {
        results.add(
          MangaSearchResult(resultCoverUrls[i], resultTitles[i], null,
              resultRatings[i], resulMangaUrls[i], resultStatuses[i], null),
        );
      }

      return results;
    }

    return [];
  }
}
