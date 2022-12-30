import 'dart:developer';

import 'package:manga_reader/core/utils.dart';
import 'package:web_scraper/web_scraper.dart';

import '../core_types.dart';

class AsuraScans implements ManhwaSource {
  final _webScraper = WebScraper('https://asura.gg');

  @override
  Future<List<String>> getChapterImages(String chapterUrl) async {
    final chapterRoute = chapterUrl.replaceAll(RegExp('https://www.asurascans.com'), '');

    if (await _webScraper.loadWebPage(chapterRoute)) {
      List<String> allImages = _webScraper
          .getElement('div#readerarea > p > img', ['src'])
          .map(
            (e) => e['attributes']['src'].toString(),
          )
          .toList();

      // checks if there are anomalous images that are not in <p></p>
      final anomalousImages =
          _webScraper.getElement('div#readerarea > img', ['src']);

      if (anomalousImages.isNotEmpty) {
        for (var i = 0; i < anomalousImages.length; i++) {
          final anomalousImage = anomalousImages[i]['attributes']['src'];
          final fileName = anomalousImage.toString().split('/').last;
          final index = int.parse(fileName.split('-').first);

          // and inserts the images into their correct index
          allImages.insert(index, anomalousImage);
        }
      }

      return allImages;
    }

    return [];
  }

  @override
  Future<MangaDetails> getMangaDetails(String mangaUrl) async {
    final mangaRoute =
        mangaUrl.replaceAll(RegExp('https://www.asurascans.com'), '');
    log(mangaRoute);

    if (await _webScraper.loadWebPage(mangaRoute)) {
      // ─── Get Title ───────────────────────────────────────
      final mangaTitle =
          _webScraper.getElementTitle('div.infox > h1.entry-title').first;

      // ─── Get Description ─────────────────────────────────
      final mangaDescription = removeExtraWhiteSpaces(
        _webScraper.getElementTitle('div.wd-full > div.entry-content').first,
      );

      // ─── Get Cover Url ───────────────────────────────────
      final mangaCoverUrl = _webScraper
          .getElement('div.thumbook > div.thumb > img', ['src'])
          .first['attributes']['src']
          .toString();

      // ─── Get Status ──────────────────────────────────────
      final mangaStatus = MangaStatus.parse(
        _webScraper.getElementTitle('div.imptdt > i').first,
      );

      // ─── Get Rating ──────────────────────────────────────
      final mangaRating = double.parse(
        _webScraper
            .getElementTitle('div.rt > div.rating > div.rating-prc > div.num')
            .first,
      );

      // ─── Get Released At ─────────────────────────────────
      final mangaReleasedAt = DateTime.parse(
        _webScraper.getElement(
          'div.flex-wrap > div.fmed > span > time',
          ['datetime'],
        ).first['attributes']['datetime'],
      );

      // ─── Get Tags ────────────────────────────────────────
      final mangaTags = _webScraper.getElementTitle('span.mgen > a');

      // ─── Get Chapters ────────────────────────────────────
      final mangaChapterTitles =
          _webScraper.getElementTitle('span.chapternum').map((e) => removeChapterFromString(e)).toList();

      final mangaChapterReleasedOns = _webScraper
          .getElementTitle('span.chapterdate')
          .map(
            (e) => altDateFormat.parse(e),
          )
          .toList();

      final mangaChapterUrls = _webScraper
          .getElement('div.eph-num > a', ['href'])
          .map(
            (e) => e['attributes']['href'].toString(),
          )
          .toList();

      List<MangaChapterData> mangaChapters = [];
      for (var i = 0; i < mangaChapterUrls.length; i++) {
        mangaChapters.add(
          MangaChapterData(
            mangaChapterTitles[i],
            mangaChapterReleasedOns[i],
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
        mangaReleasedAt,
        mangaChapters,
        mangaTags,
      );
    }

    return MangaDetails.empty();
  }

  @override
  Future<List<MangaSearchResult>> popular({int page = 1}) async {
    if (await _webScraper
        .loadWebPage('/manga/?status=&type=&order=popular&page=$page')) {
      // ─── Get Cover Urls ──────────────────
      final resultCoverUrls = _webScraper
          .getElement('div.bsx > a > div.limit > img.ts-post-image', ['src'])
          .map(
            (e) => e['attributes']['src'].toString(),
          )
          .toList();

      // ─── Get Titles ──────────────────────
      final resultTitles = _webScraper.getElementTitle('div.bigor > div.tt');

      // ─── Get Latest Chapter Numbers ──────
      final resultLatestChapterTitles =
          _webScraper.getElementTitle('div.bigor > div.adds > div.epxs').map((e) => removeChapterFromString(e)).toList();

      // ─── Get Ratings ─────────────────────
      final resultRatings = _webScraper
          .getElementTitle('div.adds > div.rt > div.rating > div.numscore')
          .map(
            (e) => double.parse(e),
          )
          .toList();

      // ─── Get Manga Urls ──────────────────
      final resultMangaUrls = _webScraper
          .getElement('div.bsx > a', ['href'])
          .map(
            (e) => e['attributes']['href'].toString(),
          )
          .toList();

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
          ),
        );
      }

      return results;
    }

    return [];
  }

  @override
  Future<List<MangaSearchResult>> search(String query) async {
    final formattedQuery = query.replaceAll(RegExp(' '), '+').toLowerCase();
    if (await _webScraper.loadWebPage('/?s=$formattedQuery')) {
      // ─── Get Cover Urls ──────────────────
      final resultCoverUrls = _webScraper
          .getElement('div.dsx > a > div.limit > img', ['src'])
          .map(
            (e) => e['attributes']['src'].toString(),
          )
          .toList();

      // ─── Get Titles ──────────────────────
      final resultTitles = _webScraper.getElementTitle('div.bigor > div.tt');

      // ─── Get Latest Chapter Numbers ──────
      final resultLatestChapterTitles =
          _webScraper.getElementTitle('div.bigor > div.adds > div.epxs').map((e) => removeChapterFromString(e)).toList();

      // ─── Get Ratings ─────────────────────
      final resultRatings = _webScraper
          .getElementTitle('div.adds > div.rt > div.rating > div.numscore')
          .map(
            (e) => double.parse(e),
          )
          .toList();

      // ─── Get Manga Urls ──────────────────
      final resultMangaUrls = _webScraper
          .getElement('div.bsx > a', ['href'])
          .map(
            (e) => e['attributes']['href'].toString(),
          )
          .toList();

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
          ),
        );
      }

      return results;
    }

    return [];
  }
}
