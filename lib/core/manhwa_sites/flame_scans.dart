import 'package:manga_reader/core/utils.dart';
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

    if (await _webScraper.loadWebPage(mangaUrlEndpoint)) {
      // ─── Get Title ───────────────────────────────────────

      final mangaTitle =
          _webScraper.getElementTitle('div.titles > h1.entry-title')[0];

      // ─── Get Description ─────────────────────────────────

      String mangaDescription = _webScraper
          .getElementTitle('div.summary > div.wd-full > div.entry-content > p')
          .first;

      // ─── Get Cover Url ───────────────────────────────────

      final mangaCoverUrl = _webScraper
          .getElement('div.thumb-half > div.thumb > img', ['src'])
          .map(
            (e) => e['attributes']['src'].toString(),
          )
          .first;

      // ─── Get Status ──────────────────────────────────────

      final mangaStatus = MangaStatus.parse(
        _webScraper.getElementTitle('div.tsinfo > div.imptdt > i')[1],
      );

      // ─── Get Rating ──────────────────────────────────────

      // Get Manga rating then parse it to double
      final mangaRating = double.parse(
        _webScraper
            .getElementTitle('div.extra-info > div.mobile-rt > div.numscore')
            .first,
      );

      // ─── Get Released At ─────────────────────────────────

      // 1. get html datetime object
      // 2. convert it to string
      // 3. parse it into `DateTime` object
      final mangaReleasedOn = DateTime.parse(
        _webScraper
            .getElement(
              'div.imptdt > i > time',
              ['datetime'],
            )
            .first['attributes']['datetime']
            .toString(),
      );

      // ─── Get Tags ────────────────────────────────────────

      final mangaTags = _webScraper.getElementTitle(
        'div.genres-container > div.wd-full > span.mgen > a',
      );

      // ─── Get Chapters ────────────────────────────────────

      // Get all chapter numbers
      final mangaChapterTitless =
          _webScraper.getElementTitle('span.chapternum').map((e) => removeChapterFromString(e)).toList();

      // Get all released on dates
      final mangaChapterReleasedOn = _webScraper
          .getElementTitle('span.chapterdate')
          .map(
            (e) => altDateFormat.parse(e),
          )
          .toList();

      // Get all chapter urls
      final mangaChapterUrls = _webScraper
          .getElement('div#chapterlist > ul > li > a', ['href'])
          .map(
            (e) => e['attributes']['href'].toString(),
          )
          .toList();

      // Comine all into list of MangaChapterDate
      List<MangaChapterData> mangaChapters = [];

      for (var i = 0; i < mangaChapterUrls.length; i++) {
        mangaChapters.add(
          MangaChapterData(
            mangaChapterTitless[i],
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
      );
    }

    return MangaDetails.empty();
  }

  @override
  Future<List<MangaSearchResult>> popular({int page = 1}) async {
    if (await _webScraper
        .loadWebPage('/ygd/series/?type=manhwa&order=popular&page=$page')) {
      // Get cover urls
      final resultCoverUrls = _webScraper
          .getElement(
              'img.ts-post-image.wp-post-image.attachment-medium.size-medium',
              ['src'])
          .map((e) => e['attributes']['src'].toString())
          .toList();

      // get titles and get manga url
      final resultTitleAndMangaUrl =
          _webScraper.getElement('div.bsx > a', ['href', 'title']);

      final resultTitles = resultTitleAndMangaUrl
          .map((e) => e['attributes']['title'].toString())
          .toList();

      final resulMangaUrls = resultTitleAndMangaUrl
          .map((e) => e['attributes']['href'].toString())
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
          MangaSearchResult(
            resultCoverUrls[i],
            resultTitles[i],
            '',
            resultRatings[i],
            resulMangaUrls[i],
            resultStatuses[i],
          ),
        );
      }

      return results;
    }

    return [];
  }

  @override
  Future<List<MangaSearchResult>> search(String query) async {
    final formatedQuery = query.replaceAll(RegExp(r' '), '+').toLowerCase();

    if (await _webScraper.loadWebPage('/ygd/?s=$formatedQuery')) {
      // Get cover urls
      final resultCoverUrls = _webScraper
          .getElement(
              'img.ts-post-image.wp-post-image.attachment-medium.size-medium',
              ['src'])
          .map((e) => e['attributes']['src'].toString())
          .toList();

      // get titles and get manga url
      final resultTitleAndMangaUrl =
          _webScraper.getElement('div.bsx > a', ['href', 'title']);

      final resultTitles = resultTitleAndMangaUrl
          .map((e) => e['attributes']['title'].toString())
          .toList();

      final resulMangaUrls = resultTitleAndMangaUrl
          .map((e) => e['attributes']['href'].toString())
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
          MangaSearchResult(
            resultCoverUrls[i],
            resultTitles[i],
            '',
            resultRatings[i],
            resulMangaUrls[i],
            resultStatuses[i],
          ),
        );
      }

      return results;
    }

    return [];
  }
}
