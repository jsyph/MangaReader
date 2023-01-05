import 'package:flutter/material.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/core/core.dart';

class LatestChapterWidget extends StatelessWidget {
  final MangaSearchResult _mangaSearchResult;

  const LatestChapterWidget(this._mangaSearchResult, {super.key});

  @override
  Widget build(BuildContext context) {
    // if latest chapter title == zero return the Text widget
    if (_mangaSearchResult.latestChapterTitle != null) {
      return Column(
        children: [
          const Divider(),
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

class MangaContentTypeWidget extends StatelessWidget {
  final MangaSearchResult _mangaSearchResult;

  const MangaContentTypeWidget(this._mangaSearchResult, {super.key});

  @override
  Widget build(BuildContext context) {
    if (_mangaSearchResult.contentType == null) {
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
    return Row(
      children: [
        const PipeSeparatorWidget(),
        mangaType,
      ],
    );
  }
}

class MangaStatusWidget extends StatelessWidget {
  final _mangaSearchResult;
  const MangaStatusWidget(this._mangaSearchResult, {super.key});

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
      return Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('|'),
          ),
          mangaStatusTextWidget
        ],
      );
    }

    // is no manga status is found then output a zero size widget
    return const SizedBox.shrink();
  }
}
