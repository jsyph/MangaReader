import 'package:manga_reader/core/core.dart';
import 'package:manga_reader/core/manhwa_sites/manhwa_sites.dart';
import 'package:test/test.dart';

void main() {
  group(
    'FlameScans',
    () {
      final flameScans = FlameScans();
      test(
        'Get chapter Images',
        () async {
          final chapterImages = flameScans.getChapter(
            'https://flamescans.org/ygd/1671922861-reincarnation-of-the-murim-clans-former-ranker-chapter-1/',
          );

          expect((await chapterImages).length, equals(18));
        },
      );

      test(
        'Get Manga Details',
        () async {
          final mangaDetails = await flameScans.getMangaDetails(
            'https://flamescans.org/ygd/series/1671922922-reincarnation-of-the-murim-clans-former-ranker/',
          );

          expect(
            mangaDetails.title,
            equals(
              'Reincarnation of the Murim Clan’s Former Ranker',
            ),
          );
          expect(
            mangaDetails.coverUrl,
            equals(
              'https://flamescans.org/wp-content/uploads/2021/10/Murim_Clans_Former_Ranker_Cover-1-1.png',
            ),
          );
          expect(
            mangaDetails.tags,
            ['Action', 'Adventure', 'Murim', 'Shounen'],
          );
        },
      );

      test(
        'Get Popular Manga',
        () async {
          final popularManga = await flameScans.popular();

          expect(
            popularManga.length,
            equals(24),
          );
        },
      );

      test(
        'Test Search',
        () async {
          final searchResult = await flameScans.search('Nine');

          expect(
            searchResult.length,
            equals(3),
          );
        },
      );
    },
  );

  group(
    'LuminousScans',
    () {
      final luminousScans = LuminousScans();
      test(
        'Get chapter Images',
        () async {
          final chapterImages = luminousScans.getChapter(
            'https://luminousscans.com/1671729411-i-stole-the-number-one-rankers-soul-chapter-1-2/',
          );

          expect(
            (await chapterImages).length,
            equals(11),
          );
        },
      );

      test(
        'Get Manga Details',
        () async {
          final mangaDetails = await luminousScans.getMangaDetails(
            'https://luminousscans.com/series/1671729411-i-stole-the-number-one-rankers-soul/',
          );

          expect(
            mangaDetails.title,
            equals(
              'I Stole The Number One Ranker’s Soul',
            ),
          );
          expect(
              mangaDetails.coverUrl,
              equals(
                  'https://luminousscans.com/wp-content/uploads/2022/09/resource.png'));
          expect(
            mangaDetails.tags,
            [],
          );
        },
      );

      test(
        'Get Popular Manga',
        () async {
          final popularManga = await luminousScans.popular();

          expect(
            popularManga.length,
            equals(20),
          );
        },
      );

      test(
        'Test Search',
        () async {
          final searchResult = await luminousScans.search('legend');

          expect(
            searchResult.length,
            equals(3),
          );
        },
      );
    },
  );

  group(
    'CosmicScans',
    () {
      final cosmicScans = CosmicScans();

      test(
        'Get chapter Images',
        () async {
          final chapterImages = cosmicScans.getChapter(
            'https://cosmicscans.com/for-my-derelict-favorite-chapter-1/',
          );

          expect(
            (await chapterImages).length,
            equals(11),
          );
        },
      );

      test(
        'Get Manga Details',
        () async {
          final mangaDetails = await cosmicScans.getMangaDetails(
            'https://cosmicscans.com/manga/for-my-derelict-favorite/',
          );

          expect(
            mangaDetails.title,
            equals('For My Derelict Favorite'),
          );
          expect(
            mangaDetails.coverUrl,
            equals(
              'https://cosmicscans.com/wp-content/uploads/2022/06/for-my-derelict-favorite-1-285x400-1.webp',
            ),
          );
          expect(
            mangaDetails.tags,
            ['Drama', 'Fantasy', 'Returner', 'Romance', 'Shoujo'],
          );
        },
      );

      test(
        'Get Popular Manga',
        () async {
          final popularManga = await cosmicScans.popular();

          expect(
            popularManga.length,
            equals(20),
          );
        },
      );

      test(
        'Test Search',
        () async {
          final searchResult = await cosmicScans.search('legend');

          expect(
            searchResult.length,
            equals(3),
          );
        },
      );
    },
  );
}
