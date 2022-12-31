import 'dart:developer';

import 'package:manga_reader/core/utils.dart';
import 'package:manga_reader/core/webscraper_extension.dart';
import 'package:web_scraper/web_scraper.dart';

import '../core_types.dart';

class CosmicScans implements ManhwaSource {
  final _webScraper = WebScraper('https://cosmicscans.com');

  @override
  Future<List<String>> getChapterImages(String chapterUrl) async {
    final chapterRoute =
        chapterUrl.replaceAll(RegExp(r'https://cosmicscans.com'), '');

    if (await _webScraper.loadWebPage(chapterRoute)) {
      return _webScraper.getElementAttributeUnwrapString(
          'img.alignnone.size-full', 'src');
    }

    return [];
  }

  @override
  Future<MangaDetails> getMangaDetails(String mangaUrl) async {
    final mangaRoute =
        mangaUrl.replaceAll(RegExp(r'https://cosmicscans.com'), '');

    if (await _webScraper.loadWebPage(mangaRoute)) {
      // ─── Get Titles ──────────────────────────────────────
      final mangaTitle =
          _webScraper.getFirstElementTitle('div.infox > h1.entry-title');

      // ─── Get Description ─────────────────────────────────
      String? mangaDescription;

      final descriptionElement =
          _webScraper.getElementTitle('div.wd-full > div.entry-content > p');

      if (descriptionElement.isNotEmpty) {
        mangaDescription = descriptionElement.first;
        mangaDescription = fixStringEncoding(mangaDescription);
      }

      // ─── Get Cover Url ───────────────────────────────────
      final mangaCover = _webScraper.getFirstElementAttribute(
          'div.thumbook > div.thumb > img', 'src');

      // ─── Get Rating ──────────────────────────────────────
      final mangaRating = double.parse(
          _webScraper.getFirstElementTitle('div.rating-prc > div.num'));

      // ─── Get Status ──────────────────────────────────────
      final mangaStatus = MangaStatus.parse(
        _webScraper.getFirstElementTitle('div.imptdt > i'),
      );

      // ─── Get Released At ─────────────────────────────────
      // gets the first time tag
      // gets the datetime attribute
      final mangaReleasedAt = DateTime.parse(
        _webScraper.getFirstElementAttribute(
            'div.fmed > span > time', 'datetime'),
      );

      // ─── Get Tags ────────────────────────────────────────
      final mangaTags = _webScraper.getElementTitle('span.mgen > a');

      // ─── Get Chapters ────────────────────────────────────
      final mangaChapterUrls = _webScraper.getElementAttributeUnwrapString(
          'div.chbox > div.eph-num > a', 'href');

      final mangaChapterTitles = _webScraper
          .getElementTitle('span.chapternum')
          .map(
            (e) => removeChapterFromString(e),
          )
          .toList();

      final mangaChapterDates = _webScraper
          .getElementTitle('span.chapterdate')
          .map(
            (e) => altDateFormat.parse(e),
          )
          .toList();

      List<MangaChapterData> mangaChapters = [];

      for (var i = 0; i < mangaChapterUrls.length; i++) {
        mangaChapters.add(
          MangaChapterData(
            mangaChapterTitles[i],
            mangaChapterDates[i],
            mangaChapterUrls[i],
          ),
        );
      }

      // ─── Group Into MangaDetail ──────────────────────────
      return MangaDetails(
        mangaTitle,
        mangaDescription,
        mangaCover,
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
    final targetEndpoint = '/manga/?status=&type=&order=popular&page=$page';

    return await _makeSearch(targetEndpoint);
  }

  @override
  Future<List<MangaSearchResult>> search(String query) async {
    final formattedQuery = query.replaceAll(RegExp(r' '), '+').toLowerCase();

    return await _makeSearch('/?s=$formattedQuery');
  }

  Future<List<MangaSearchResult>> _makeSearch(String targetEndpoint) async {
    if (await _webScraper.loadWebPage(targetEndpoint)) {
      // ─── Get All Cover Urls ──────────────────────────────
      final resultCoverUrls = _webScraper.getElementAttributeUnwrapString(
          'div.bsx > a > div.limit > img', 'src');

      // ─── Get All Titles And Manga Urls ───────────────────
      final resultTitleAndMangaurls =
          _webScraper.getElement('div.bsx > a', ['href', 'title']);

      final resultTitle = resultTitleAndMangaurls
          .map(
            (e) => e['attributes']['title'].toString(),
          )
          .toList();

      final resultMangaUrls = resultTitleAndMangaurls
          .map(
            (e) => e['attributes']['href'].toString(),
          )
          .toList();

      // ─── Get All Latest Chapters ─────────────────────────
      final resultLatestChapterTitles = _webScraper
          .getElementTitle('div.epxs')
          .map((e) => removeChapterFromString(e))
          .toList();

      // ─── Get All Rating ──────────────────────────────────
      final resultRatings = _webScraper
          .getElementTitle(
              'div.bigor > div.adds > div.rt > div.rating > div.numscore')
          .map(
            (e) => double.parse(e),
          )
          .toList();

      // ─── Combine Into List Of MangaSearchResult ──────────
      List<MangaSearchResult> results = [];
      for (var i = 0; i < resultMangaUrls.length; i++) {
        results.add(
          MangaSearchResult(
            resultCoverUrls[i],
            resultTitle[i],
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
