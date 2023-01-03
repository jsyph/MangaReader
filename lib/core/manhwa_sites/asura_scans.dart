import 'dart:developer';

import 'package:logging/logging.dart';
import 'package:manga_reader/core/utils.dart';
import 'package:manga_reader/core/webscraper_extension.dart';
import 'package:web_scraper/web_scraper.dart';

import '../core_types.dart';

class AsuraScans implements ManhwaSource {
  final _webScraper = WebScraper('https://asura.gg');
  final logger = Logger('AsuraScans');
  final _mangaSourceName = 'Asura Scans';

  @override
  Future<List<String>> getChapterImages(String chapterUrl) async {
    final chapterRoute =
        chapterUrl.replaceAll(RegExp('https://www.asurascans.com'), '');

    if (await _webScraper.loadWebPage(chapterRoute)) {
      List<String> allImages = _webScraper.getElementAttributeUnwrapString(
          'div#readerarea > p > img', 'src');

      // checks if there are anomalous images that are not in <p></p>
      final anomalousImages = _webScraper.getElementAttributeUnwrapString(
          'div#readerarea > img', 'src');

      if (anomalousImages.isNotEmpty) {
        for (var i = 0; i < anomalousImages.length; i++) {
          final anomalousImage = anomalousImages[i];
          final fileName = anomalousImage.toString().split('/').last;
          final index = int.parse(fileName.split('-').first);

          // and inserts the images into their correct index
          allImages.insert(index, anomalousImage);
        }
      }

      logger.fine('Got ${allImages.length} images, Chapter Url: $chapterUrl');

      return allImages;
    }

    return [];
  }

  @override
  Future<MangaDetails> getMangaDetails(String mangaUrl) async {
    final mangaRoute =
        mangaUrl.replaceAll(RegExp('https://www.asurascans.com'), '');

    if (await _webScraper.loadWebPage(mangaRoute)) {
      // ─── Get Title ───────────────────────────────────────
      final mangaTitle =
          _webScraper.getFirstElementTitle('div.infox > h1.entry-title');

      // ─── Get Description ─────────────────────────────────
      final mangaDescription = removeExtraWhiteSpaces(
        _webScraper.getFirstElementTitle('div.wd-full > div.entry-content'),
      );

      // ─── Get Cover Url ───────────────────────────────────
      final mangaCoverUrl = _webScraper.getFirstElementAttribute(
          'div.thumbook > div.thumb > img', 'src');

      // ─── Get Status ──────────────────────────────────────
      final mangaStatus = MangaStatus.parse(
        _webScraper.getFirstElementTitle('div.imptdt > i'),
      );

      // ─── Get Manga Content Type ──────────────────────────
      final mangaContentType = MangaContentType.parse(
        _webScraper.getElementTitle('div.imptdt > i').last,
      );

      // ─── Get Rating ──────────────────────────────────────
      final mangaRating = double.parse(
        _webScraper.getFirstElementTitle(
            'div.rt > div.rating > div.rating-prc > div.num'),
      );

      // ─── Get Released At ─────────────────────────────────
      final mangaReleasedAt = DateTime.parse(
        _webScraper.getFirstElementAttribute(
            'div.flex-wrap > div.fmed > span > time', 'datetime'),
      );

      // ─── Get Tags ────────────────────────────────────────
      final mangaTags = _webScraper.getElementTitle('span.mgen > a');

      // ─── Get Chapters ────────────────────────────────────
      final mangaChapterTitles = _webScraper
          .getElementTitle('span.chapternum')
          .map((e) => removeChapterFromString(e))
          .toList();

      final mangaChapterReleasedOns = _webScraper
          .getElementTitle('span.chapterdate')
          .map(
            (e) => altDateFormat.parse(e),
          )
          .toList();

      final mangaChapterUrls = _webScraper.getElementAttributeUnwrapString(
          'div.eph-num > a', 'href');

      List<MangaChapterData> mangaChapters = [];
      for (var i = 0; i < mangaChapterUrls.length; i++) {
        mangaChapters.add(
          MangaChapterData(
            mangaChapterTitles[i],
            mangaChapterReleasedOns[i],
            mangaChapterUrls[i],
            _mangaSourceName,
          ),
        );
      }
      log(mangaChapters.toString());

      // ─── Combine Into Mangadetails ───────────────────────

      logger.fine('Got MangaDetails for $mangaRoute');
      return MangaDetails(
        mangaTitle,
        mangaDescription,
        mangaCoverUrl,
        mangaRating,
        mangaStatus,
        mangaReleasedAt,
        mangaChapters,
        mangaTags,
        mangaContentType,
        _mangaSourceName,
      );
    }

    logger.shout(
        'getMangaDetails returns an empty MangaDetails, this should not happen.');
    return MangaDetails.empty();
  }

  @override
  Future<List<MangaSearchResult>> popular({int page = 1}) async {
    final targetEndpoint = '/manga/?status=&type=&order=popular&page=$page';

    return await _makeSearch(targetEndpoint);
  }

  @override
  Future<List<MangaSearchResult>> search(String query) async {
    final targetEndpoint = query.replaceAll(RegExp(' '), '+').toLowerCase();

    return await _makeSearch('/?s=$targetEndpoint');
  }

  @override
  Future<List<MangaSearchResult>> updates({int page = 1}) async {
    final targetEndpoint = '/manga/?page=$page&order=update';

    return await _makeSearch(targetEndpoint);
  }

  Future<List<MangaSearchResult>> _makeSearch(String targetEndpoint) async {
    if (await _webScraper.loadWebPage(targetEndpoint)) {
      // ─── Get Cover Urls ──────────────────
      final resultCoverUrls = _webScraper.getElementAttributeUnwrapString(
          'div.bsx > a > div.limit > img.ts-post-image', 'src');

      // ─── Get Titles ──────────────────────
      final resultTitles = _webScraper.getElementTitle('div.bigor > div.tt');

      // ─── Get Latest Chapter Numbers ──────
      final resultLatestChapterTitles = _webScraper
          .getElementTitle('div.bigor > div.adds > div.epxs')
          .map((e) => removeChapterFromString(e))
          .toList();

      // ─── Get Ratings ─────────────────────
      final resultRatings = _webScraper
          .getElementTitle('div.adds > div.rt > div.rating > div.numscore')
          .map(
            (e) => double.parse(e),
          )
          .toList();

      // ─── Get Manga Content Types ─────────────────────────
      final resultMangaContentTypes = _webScraper
          .getElementTitle('span.type')
          .map(
            (e) => MangaContentType.parse(e),
          )
          .toList();

      // ─── Get Manga Urls ──────────────────
      final resultMangaUrls =
          _webScraper.getElementAttributeUnwrapString('div.bsx > a', 'href');

      // ─── Into Mangasearchresult List ─────

      List<MangaSearchResult> results = [];

      for (var i = 0; i < resultMangaUrls.length; i++) {
        results.add(
          MangaSearchResult(
            resultCoverUrls[i],
            resultTitles[i],
            resultLatestChapterTitles[i],
            resultRatings[i],
            resultMangaUrls[i],
            MangaStatus.none,
            resultMangaContentTypes[i],
            _mangaSourceName,
          ),
        );
      }

      logger.fine('Got search results for $targetEndpoint');

      return results;
    }

    return [];
  }
}
