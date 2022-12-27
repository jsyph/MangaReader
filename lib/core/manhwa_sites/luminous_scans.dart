import 'package:manga_reader/core/utils.dart';
import 'package:web_scraper/web_scraper.dart';

import '../data_classes.dart';

class LuminousScans implements ManhwaSource {
  final _webScraper = WebScraper('https://luminousscans.com');

  @override
  Future<List<String>> getChapterImages(String chapterUrl) async {
    final chapterUrlEndpoint =
        chapterUrl.replaceAll(RegExp(r'https://luminousscans.com'), '');

    if (await _webScraper.loadWebPage(chapterUrlEndpoint)) {
      final allImages = _webScraper
          .getElement('img.alignnone.size-full', ['src'])
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
        mangaUrl.replaceAll(RegExp(r'https://luminousscans.com'), '');

    if (await _webScraper.loadWebPage(mangaUrlEndpoint)) {
      // ─── Get Title ───────────────────────────────────────

      final title =
          _webScraper.getElementTitle('div#titlemove > h1.entry-title').first;

      // ─── Get Tags ────────────────────────────────────────

      final tags = _webScraper.getElementTitle('div.wd-full > span.mgen > a');

      // ─── Get Description ─────────────────────────────────

      // 👇 is a list of strings, which will be joined by `\n`
      final description = _webScraper
          .getElementTitle('div.wd-full > div.entry-content > p')
          .join('\n');

      // ─── Get Cover Url ───────────────────────────────────

      final coverUrl = _webScraper
          .getElement('div.thumb > img', ['src']).first['attributes']['src'];

      // ─── Get Rating ──────────────────────────────────────

      // 1. get rating as string
      // 2. convert string to double
      final rating = double.parse(
        _webScraper.getElementTitle('div.rating-prc > div.num').first,
      );

      // ─── Get Status ──────────────────────────────────────

      final status = MangaStatus.parse(
        _webScraper.getElementTitle('div.tsinfo > div.imptdt > i').first,
      );

      // ─── Get Year Released ───────────────────────────────

      // 1. get html datetime object
      // 2. convert it to string
      // 3. parse it into `DateTime` object
      final dateReleased = DateTime.parse(
        _webScraper
            .getElement('div.tsinfo > div.imptdt > i > time', ['datetime'])
            .first['attributes']['datetime']
            .toString(),
      );

      // ─── Get Chapters ────────────────────────────────────

      List<MangaChapterData> chapters = [];

      // 1. get chapter title `Chapter x`
      // 2. remove `Chapter `
      // 3. convert chapter number from string to double
      final chapterNumbers = _webScraper
          .getElementTitle(
        'div#chapterlist > ul > li > div.chbox > div.eph-num > a > span.chapternum',
      )
          .map(
        (e) {
          try {
            return double.parse(extractChapterNumber(e));
          } catch (e) {
            return double.nan;
          }
        },
      ).toList();

      // get chapter release date and convert them into `DateTime` objects
      final chapterReleasedOn = _webScraper
          .getElementTitle(
            'div#chapterlist > ul > li > div.chbox > div.eph-num > a > span.chapterdate',
          )
          .map((e) => altDateFormat.parse(e))
          .toList();

      final chapterUrls = _webScraper
          .getElement(
            'div#chapterlist > ul > li > div.chbox > div.eph-num > a',
            ['href'],
          )
          .map((e) => e['attributes']['href'].toString())
          .toList();

      // add chapter object to list
      for (var i = 0; i < chapterUrls.length; i++) {
        chapters.add(
          MangaChapterData(
            chapterNumbers[i],
            chapterReleasedOn[i],
            chapterUrls[i],
          ),
        );
      }

      // ─── Return Mangadetails Object ──────────────────────

      return MangaDetails(
        title,
        description,
        coverUrl,
        rating,
        status,
        dateReleased,
        chapters,
        tags,
      );
    }

    return MangaDetails.empty();
  }

  @override
  Future<List<MangaSearchResult>> popular({int page = 1}) async {
    if (await _webScraper
        .loadWebPage('/series?status=&type=&order=popular&page=$page')) {
      // Get manga ruls and titles
      final anchorTag =
          _webScraper.getElement('div.bsx > a', ['href', 'title']);

      final mangaUrls = anchorTag
          .map(
            (e) => e['attributes']['href'].toString(),
          )
          .toList();
      final mangaTitles = anchorTag
          .map(
            (e) => e['attributes']['title'].toString(),
          )
          .toList();

      // Get cover images
      final coverUrls = _webScraper
          .getElement('div.bsx > a > div.limit > img.wp-post-image', ['src'])
          .map(
            (e) => e['attributes']['src'].toString(),
          )
          .toList();

      // Get latest Chapters
      // gets the `Chapter xx` text then removes the `Chapter `, then converts the number to double
      final latestChapterNumbers = _webScraper
          .getElementTitle('div.bsx > a > div.bigor > div.adds > div.epxs')
          .map(
        (e) {
          final regExp = RegExp(r'[1-9]\d*(\.\d+)?');

          final chapterNumber = regExp.firstMatch(e)?.group(0) ?? '';

          return double.parse(chapterNumber);
        },
      ).toList();

      // Get Ratings
      final ratings = _webScraper
          .getElementTitle(
              'div.bsx > a > div.bigor > div.adds > div.rt > div.rating > div.numscore')
          .map((e) => double.parse(e))
          .toList();

      List<MangaSearchResult> results = [];

      for (int i = 0; i < mangaUrls.length; i++) {
        results.add(
          MangaSearchResult(
            coverUrls[i],
            mangaTitles[i],
            latestChapterNumbers[i],
            ratings[i],
            mangaUrls[i],
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
    final formatedQuery = query.toLowerCase().replaceAll(RegExp(r' '), '-');

    if (await _webScraper.loadWebPage('/?s=$formatedQuery')) {
      // Get manga ruls and titles
      final anchorTag =
          _webScraper.getElement('div.bsx > a', ['href', 'title']);

      final mangaUrls = anchorTag
          .map(
            (e) => e['attributes']['href'].toString(),
          )
          .toList();
      final mangaTitles = anchorTag
          .map(
            (e) => e['attributes']['title'].toString(),
          )
          .toList();

      // Get cover images
      final coverUrls = _webScraper
          .getElement('div.bsx > a > div.limit > img.ts-post-image', ['src'])
          .map(
            (e) => e['attributes']['src'].toString(),
          )
          .toList();

      // Get latest Chapters
      // gets the `Chapter xx` text then removes the `Chapter `, then converts the number to double
      final latestChapterNumbers = _webScraper
          .getElementTitle('div.bsx > a > div.bigor > div.adds > div.epxs')
          .map(
            (e) => double.parse(
              extractChapterNumber(e),
            ),
          )
          .toList();

      // Get Ratings
      final ratings = _webScraper
          .getElementTitle(
              'div.bsx > a > div.bigor > div.adds > div.rt > div.rating > div.numscore')
          .map((e) => double.parse(e))
          .toList();

      List<MangaSearchResult> results = [];

      for (int i = 0; i < mangaUrls.length; i++) {
        results.add(
          MangaSearchResult(
            mangaUrls[i],
            mangaTitles[i],
            latestChapterNumbers[i],
            ratings[i],
            coverUrls[i],
            MangaStatus.none,
          ),
        );
      }

      return results;
    }

    return [];
  }
}
