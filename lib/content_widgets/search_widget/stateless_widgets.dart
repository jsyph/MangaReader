import 'package:flutter/material.dart';
import 'package:manga_reader/core/core.dart';

class LatestChapterWidget extends StatelessWidget {
  const LatestChapterWidget(this._mangaSearchResult, {super.key});

  final MangaSearchResult _mangaSearchResult;

  @override
  Widget build(BuildContext context) {
    // if latest chapter title == zero return the Text widget
    if (_mangaSearchResult.latestChapterTitle != null) {
      return Column(
        children: [
          Text(
            textAlign: TextAlign.center,
            'Latest Chapter: ${_mangaSearchResult.latestChapterTitle}',
          ),
        ],
      );
    } else {
      // is no manga status is found then output a zero size widget
      return const SizedBox.shrink();
    }
  }
}

class MangaRatingWidget extends StatelessWidget {
  const MangaRatingWidget(this._mangaSearchResult, {super.key});

  final MangaSearchResult _mangaSearchResult;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyText1,
        children: [
          TextSpan(text: '${_mangaSearchResult.rating}'),
          const WidgetSpan(
            child: Padding(
              padding: EdgeInsets.only(
                left: 2.0,
              ),
              child: Icon(
                Icons.star,
                color: Colors.yellow,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MangaContentTypeWidget extends StatelessWidget {
  const MangaContentTypeWidget(this._mangaSearchResult, {super.key});

  final MangaSearchResult _mangaSearchResult;

  @override
  Widget build(BuildContext context) {
    if (_mangaSearchResult.contentType == null ||
        _mangaSearchResult.contentType == MangaContentType.none) {
      return const SizedBox.shrink();
    }

    late final Text mangaType;
    switch (_mangaSearchResult.contentType) {
      case MangaContentType.manhwa:
        {
          mangaType = const Text(
            'Manhwa',
            style: TextStyle(
              // Manhwa colour
              color: Colors.white,
            ),
          );
          break;
        }

      case MangaContentType.manhua:
        {
          mangaType = const Text(
            'Manhua',
            style: TextStyle(
              // Manhua Colour
              color: Colors.white,
            ),
          );
          break;
        }
      case MangaContentType.manga:
        {
          mangaType = const Text(
            'Manga',
            style: TextStyle(
              // Manga Colour
              color: Colors.white,
            ),
          );
          break;
        }
      default:
        {
          break;
        }
    }
    return mangaType;
  }
}

class MangaStatusWidget extends StatelessWidget {
  const MangaStatusWidget(this._mangaSearchResult, {super.key});

  final MangaSearchResult _mangaSearchResult;

  @override
  Widget build(BuildContext context) {
    // Figure out when to display status

    if (_mangaSearchResult.status != MangaStatus.none) {
      Widget mangaStatusTextWidget = const Text('');
      switch (_mangaSearchResult.status) {
        case MangaStatus.ongoing:
          {
            mangaStatusTextWidget = const Text(
              'Ongoing',
              style: TextStyle(
                // Ongoing Colour
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            );
            break;
          }
        case MangaStatus.hiatus:
          {
            mangaStatusTextWidget = const Text(
              'Hiatus',
              style: TextStyle(
                // Hiatus Colour
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            );
            break;
          }
        case MangaStatus.completed:
          {
            mangaStatusTextWidget = const Text(
              'Completed',
              style: TextStyle(
                // Completed Colour
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            );
            break;
          }
        case MangaStatus.cancelled:
          {
            mangaStatusTextWidget = const Text(
              'Cancelled',
              style: TextStyle(
                // Cancelled Colour
                color: Colors.white,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            );
            break;
          }

        default:
          {
            break;
          }
      }
      return mangaStatusTextWidget;
    }

    // is no manga status is found then output a zero size widget
    return const SizedBox.shrink();
  }
}
