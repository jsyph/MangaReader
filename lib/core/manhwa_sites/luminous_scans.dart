import 'package:intl/intl.dart';
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
          _webScraper.getElementTitle('div#titlemove > h1.entry-title')[0];

      // ─── Get Tags ────────────────────────────────────────

      final tags = _webScraper.getElementTitle('div.wd-full > span.mgen > a');

      // ─── Get Description ─────────────────────────────────

      // 👇 is a list of strings, which will be joined by `\n`
      final description = _webScraper
          .getElementTitle('div.wd-full > div.entry-content > p')
          .join('\n');

      // ─── Get Cover Url ───────────────────────────────────

      final coverUrl = _webScraper.getElement('div.thumb > img', ['src'])[0]
          ['attributes']['src'];

      // ─── Get Followed By Count ───────────────────────────

      // 1. get followed by text `Followed by x people`
      // 2. remove the `Followed by ` and ` peoplw` from the string
      // 3. parse the number from string to int
      final followedByCount = int.parse(
        _webScraper
            .getElementTitle('div.info-left-margin > div.bmc')[0]
            .replaceAll(RegExp(r'Followed by '), '')
            .replaceAll(RegExp(r' people'), ''),
      );

      // ─── Get Rating ──────────────────────────────────────

      // 1. get rating as string
      // 2. convert string to double
      final rating = double.parse(
          _webScraper.getElementTitle('div.rating-prc > div.num')[0]);

      // ─── Get Status ──────────────────────────────────────

      MangaStatus status;

      // 1. get status
      // 2. match status to relevant `MangaStatus` value
      switch (_webScraper
          .getElementTitle('div.tsinfo > div.imptdt > i')[0]
          .toLowerCase()) {
        case 'ongoing':
          {
            status = MangaStatus.ongoing;
          }
          break;
        case 'completed':
          {
            status = MangaStatus.completed;
          }
          break;
        case 'hiatus':
          {
            status = MangaStatus.hiatus;
          }
          break;

        default:
          {
            status = MangaStatus.none;
          }
          break;
      }

      // ─── Get Year Released ───────────────────────────────

      // 1. get html datetime object
      // 2. convert it to string
      // 3. parse it into `DateTime` object
      final dateReleased = DateTime.parse(
        _webScraper
            .getElement('div.tsinfo > div.imptdt > i > time', ['datetime'])[0]
                ['attributes']['datetime'].toString(),
      );

      // ─── Get Chapters ────────────────────────────────────

      List<MangaChapterData> chapters = [];

      // 1. get chapter title `Chapter x`
      // 2. remove `Chapter `
      // 3. convert chapter number from string to double
      final chapterNumbers = _webScraper
          .getElementTitle(
              'div#chapterlist > ul > li > div.chbox > div.eph-num > a > span.chapternum')
          .map(
        (e) {
          try {
            return double.parse(e.replaceAll(RegExp(r'Chapter '), ''));
          } catch (e) {
            return double.nan;
          }
        },
      ).toList();

      // Create new date time formate
      DateFormat format = DateFormat("MMMM dd, yyyy");

      // get chapter release date and convert them into `DateTime` objects
      final chapterReleasedOn = _webScraper
          .getElementTitle(
              'div#chapterlist > ul > li > div.chbox > div.eph-num > a > span.chapterdate')
          .map((e) => format.parse(e))
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

      // reverese chapter to be in ascending order
      chapters = chapters.reversed.toList();

      // ─── Return Mangadetails Object ──────────────────────

      return MangaDetails(
        title,
        description,
        coverUrl,
        followedByCount,
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
  Future<List<MangaSearchResult>> popular() async {
    if (await _webScraper.loadWebPage('/series?status=&type=&order=popular')) {
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
              e.replaceAll(RegExp(r'Chapter '), ''),
            ),
          )
          .toList();

      // Get Ratings
      final ratings = _webScraper
          .getElementTitle(
              'div.bsx > a > div.bigor > div.adds > div.rt > div.rating > div.numscore')
          .map((e) => double.parse(e))
          .toList();

      List<MangaSearchResult> result = [];

      for (int i = 0; i < mangaUrls.length; i++) {
        result.add(
          MangaSearchResult(
            mangaUrls[i],
            mangaTitles[i],
            latestChapterNumbers[i],
            ratings[i],
            coverUrls[i],
          ),
        );
      }
      return result;
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
              e.replaceAll(RegExp(r'Chapter '), ''),
            ),
          )
          .toList();

      // Get Ratings
      final ratings = _webScraper
          .getElementTitle(
              'div.bsx > a > div.bigor > div.adds > div.rt > div.rating > div.numscore')
          .map((e) => double.parse(e))
          .toList();

      List<MangaSearchResult> result = [];

      for (int i = 0; i < mangaUrls.length; i++) {
        result.add(
          MangaSearchResult(
            mangaUrls[i],
            mangaTitles[i],
            latestChapterNumbers[i],
            ratings[i],
            coverUrls[i],
          ),
        );
      }
    }

    return [];
  }
}
