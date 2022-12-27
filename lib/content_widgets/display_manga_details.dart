import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:manga_reader/content_widgets/common.dart';
import 'package:manga_reader/core/core.dart';
import 'package:readmore/readmore.dart';

class DisplayMangaDetails extends StatefulWidget {
  final String _mangaUrl;
  final ManhwaSource _mangaSource;
  const DisplayMangaDetails(this._mangaUrl, this._mangaSource, {super.key});

  @override
  State<DisplayMangaDetails> createState() => _DisplayMangaDetails();
}

class _DisplayMangaDetails extends State<DisplayMangaDetails> {
  MangaDetails mangaDetails = MangaDetails.empty();

  void _getMangaDetails() async {
    final output = await widget._mangaSource.getMangaDetails(widget._mangaUrl);
    setState(
      () {
        mangaDetails = output;
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _getMangaDetails();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const coverImagePaddingLTR = 20.0;
    const coverImagePaddingB = 0.0;

    if (mangaDetails.title.isEmpty) {
      return scaffoldLoadingNoProgress;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manga Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                coverImagePaddingLTR,
                coverImagePaddingLTR,
                coverImagePaddingLTR,
                coverImagePaddingB,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: CachedNetworkImage(
                  imageUrl: mangaDetails.coverUrl,
                  width: 400,
                ),
              ),
            ),
            Text(
              mangaDetails.title,
              style: const TextStyle(fontSize: 30),
            ),
            ReadMoreText(
              mangaDetails.description,
              trimLines: 2,
              trimMode: TrimMode.Length,
            )
            // TODO: Continue to create window
          ],
        ),
      ),
    );
  }
}
