import 'package:manga_reader/core/utils.dart';
import 'package:web_scraper/web_scraper.dart';

import '../data_classes.dart';

class CosmicScans implements ManhwaSource {
  final _webScraper = WebScraper('https://cosmicscans.com');

  @override
  Future<List<String>> getChapterImages(String chapterUrl) async {
    final chapterRoute =
        chapterUrl.replaceAll(RegExp(r'https://cosmicscans.com'), '');
    if (await _webScraper.loadWebPage(chapterRoute)) {
      final allImages = _webScraper
          .getElement('img.alignnone.size-full', ['src'])
          .map((e) => e['attributes']['src'].toString())
          .toList();

      return allImages;
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
          _webScraper.getElementTitle('div.infox > h1.entry-title').first;

      // ─── Get Description ─────────────────────────────────
      final mangaDescription = _webScraper
          .getElementTitle('div.wd-full > div.entry-content > p')
          .first;

      // ─── Get Cover Url ───────────────────────────────────
      final mangaCover = _webScraper
          .getElement('div.thumbook > div.thumb > img', ['src'])
          .first['attributes']['src']
          .toString();

      // ─── Get Rating ──────────────────────────────────────
      final mangaRating = double.parse(
          _webScraper.getElementTitle('div.rating-prc > div.num').first);

      // ─── Get Status ──────────────────────────────────────
      final mangaStatus = MangaStatus.parse(
        _webScraper.getElementTitle('div.imptdt > i').first,
      );

      // ─── Get Released At ─────────────────────────────────
      // gets the first time tag
      // gets the datetime attribute
      final mangaReleasedAt = DateTime.parse(
        _webScraper.getElement(
          'div.fmed > span > time',
          ['datetime'],
        ).first['attributes']['datetime'],
      );

      // ─── Get Tags ────────────────────────────────────────
      final mangaTags = _webScraper.getElementTitle('span.mgen > a');

      // ─── Get Chapters ────────────────────────────────────
      final mangaChapterUrls = _webScraper
          .getElement('div.chbox > div.eph-num > a', ['href'])
          .map(
            (e) => e['attributes']['href'].toString(),
          )
          .toList();

      final mangaChapterNumbers =
          _webScraper.getElementTitle('span.chapternum').map(
        (e) {
          try {
            return double.parse(extractChapterNumber(e));
          } catch (error) {
            return double.nan;
          }
        },
      ).toList();

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
            mangaChapterNumbers[i],
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
    if (await _webScraper
        .loadWebPage('/manga/?status=&type=&order=popular&page=$page')) {
      // ─── Get All Cover Urls ──────────────────────────────
      final resultCoverUrls = _webScraper
          .getElement('div.bsx > a > div.limit > img', ['src'])
          .map(
            (e) => e['attributes']['src'].toString(),
          )
          .toList();

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
      final resultLatestChapterNumbers =
          _webScraper.getElementTitle('div.epxs').map(
        (e) {
          try {
            return double.parse(extractChapterNumber(e));
          } catch (error) {
            return double.nan;
          }
        },
      ).toList();

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
            resultLatestChapterNumbers[i],
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
    final formattedQuery = query.replaceAll(RegExp(r' '), '+').toLowerCase();

    if (await _webScraper.loadWebPage('/?s=$formattedQuery')) {
      // ─── Get All Cover Urls ──────────────────────────────
      final resultCoverUrls = _webScraper
          .getElement('div.bsx > a > div.limit > img', ['src'])
          .map(
            (e) => e['attributes']['src'].toString(),
          )
          .toList();

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
      final resultLatestChapterNumbers =
          _webScraper.getElementTitle('div.epxs').map(
        (e) {
          try {
            return double.parse(extractChapterNumber(e));
          } catch (error) {
            return double.nan;
          }
        },
      ).toList();

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
            resultLatestChapterNumbers[i],
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
