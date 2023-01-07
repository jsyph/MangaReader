import 'dart:developer';

import 'package:manga_reader/core/manhwa_sites/helper_functions.dart';
import 'package:manga_reader/core/utils.dart';
import 'package:manga_reader/core/webscraper_extension.dart';
import 'package:web_scraper/web_scraper.dart';

import '../core_types/core_types.dart';

class LuminousScans implements ManhwaSource {
  final _mangaSourceName = 'Luminous Scans';
  final _webScraper = WebScraper('https://luminousscans.com');

  @override
  MangaSourceTheme get colorScheme => MangaSourceTheme(0xffbda2ea, 0xffb6b9ff);

  @override
  Future<List<String>> getChapterImages(String chapterUrl) async {
    final chapterUrlEndpoint =
        chapterUrl.replaceAll(RegExp(r'https://luminousscans.com'), '');

    if (await _webScraper.loadWebPage(chapterUrlEndpoint)) {
      return _webScraper.getElementAttributeUnwrapString(
          'img.alignnone.size-full', 'src');
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
          _webScraper.getFirstElementTitle('div#titlemove > h1.entry-title');

      // ─── Get Tags ────────────────────────────────────────

      final tags = _webScraper.getElementTitle('div.wd-full > span.mgen > a');

      // ─── Get Description ─────────────────────────────────

      // 👇 is a list of strings, which will be joined by `\n`
      final description = _webScraper
          .getElementTitle('div.wd-full > div.entry-content > p')
          .join('\n');

      // ─── Get Cover Url ───────────────────────────────────

      final coverUrl =
          _webScraper.getFirstElementAttribute('div.thumb > img', 'src');

      // ─── Get Rating ──────────────────────────────────────

      // 1. get rating as string
      // 2. convert string to double
      final rating = double.parse(
        _webScraper.getFirstElementTitle('div.rating-prc > div.num'),
      );

      // ─── Get Status ──────────────────────────────────────

      final status = MangaStatus.parse(
        _webScraper.getFirstElementTitle('div.tsinfo > div.imptdt > i'),
      );

      // ─── Get Type ────────────────────────────────────────

      final mangaContentType = MangaContentType.parse(
          _webScraper.getFirstElementTitle('div.tsinfo > div.imptdt > a'));

      // ─── Get Year Released ───────────────────────────────

      // 1. get html datetime object
      // 2. convert it to string
      // 3. parse it into `DateTime` object
      final dateReleased = DateTime.parse(
        _webScraper.getFirstElementAttribute(
            'div.tsinfo > div.imptdt > i > time', 'datetime'),
      );

      // ─── Get Chapters ────────────────────────────────────

      List<MangaChapterData> chapters = [];

      // 1. get chapter title `Chapter x`
      // 2. remove `Chapter `
      // 3. convert chapter number from string to double
      final chapterTitles = _webScraper
          .getElementTitle(
            'div#chapterlist > ul > li > div.chbox > div.eph-num > a > span.chapternum',
          )
          .map((e) => removeChapterFromString(e))
          .toList();

      // get chapter release date and convert them into `DateTime` objects
      final chapterReleasedOn = _webScraper
          .getElementTitle(
            'div#chapterlist > ul > li > div.chbox > div.eph-num > a > span.chapterdate',
          )
          .map((e) => altDateFormat.parse(e))
          .toList();

      final chapterUrls = _webScraper.getElementAttributeUnwrapString(
          'div#chapterlist > ul > li > div.chbox > div.eph-num > a', 'href');

      // add chapter object to list
      for (var i = 0; i < chapterUrls.length; i++) {
        chapters.add(
          MangaChapterData(
            chapterTitles[i],
            chapterReleasedOn[i],
            chapterUrls[i],
            _mangaSourceName,
            previousMangaChapterUrl(i, chapterUrls),
            nextMangaChapterUrl(i, chapterUrls),
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
        mangaContentType,
        _mangaSourceName,
      );
    }

    return MangaDetails.empty();
  }

  @override
  Future<List<MangaSearchResult>> popular({int page = 1}) async {
    final targetEndpoint = '/series?status=&type=&order=popular&page=$page';

    return await _makeSearch(targetEndpoint);
  }

  @override
  Future<List<MangaSearchResult>> search(String query) async {
    final formattedQuery = query.toLowerCase().replaceAll(RegExp(r' '), '-');

    return await _makeSearch('/?s=$formattedQuery');
  }

  @override
  Future<List<MangaSearchResult>> updates({int page = 1}) async {
    final targetEndpoint = '/series?status=&type=&order=update&page=$page';

    return await _makeSearch(targetEndpoint);
  }

  Future<List<MangaSearchResult>> _makeSearch(String targetEndpoint) async {
    if (await _webScraper.loadWebPage(targetEndpoint)) {
      // Get manga urls and titles
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
      final coverUrls = _webScraper.getElementAttributeUnwrapString(
          'div.bsx > a > div.limit > img.wp-post-image', 'src');

      // Get latest Chapters
      // gets the `Chapter xx` text then removes the `Chapter `, then converts the number to double
      final latestChapterTitles = _webScraper
          .getElementTitle('div.bsx > a > div.bigor > div.adds > div.epxs')
          .map((e) => removeChapterFromString(e))
          .toList();

      // Get Ratings
      final ratings = _webScraper
          .getElementTitle(
              'div.bsx > a > div.bigor > div.adds > div.rt > div.rating > div.numscore')
          .map((e) => double.parse(e))
          .toList();

      // Get manga content type
      final mangaContentTypes =
          _webScraper.getElementAttributeUnwrapString('span.type', 'class').map(
        (mangaType) {
          log(mangaType);
          return MangaContentType.parse(mangaType.replaceAll('type ', ''));
        },
      ).toList();
      log(mangaContentTypes.toString());

      List<MangaSearchResult> results = [];

      for (int i = 0; i < mangaUrls.length; i++) {
        log((!mangaTitles[i].contains('(Novel)')).toString());
        // if manga title contains (Novel) then add
        if (!mangaTitles[i].contains('(Novel)')) {
          results.add(
            MangaSearchResult(
                coverUrls[i],
                mangaTitles[i],
                latestChapterTitles[i],
                ratings[i],
                mangaUrls[i],
                MangaStatus.none,
                mangaContentTypes[i],
                _mangaSourceName),
          );
        } else {
          mangaContentTypes.insert(i, MangaContentType.none);
        }
      }
      return results;
    }

    return [];
  }
}
