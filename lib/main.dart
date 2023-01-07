import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:manga_reader/core/core.dart';
import 'package:manga_reader/core/database_types/bookmark_data.dart';
import 'package:manga_reader/core/database_types/page_data.dart';

import 'content_widgets/main_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    log('|${record.level.name}| ${record.loggerName} -> ${record.message}');
  });

  await Hive.initFlutter();

  Hive.registerAdapter(DataBasePageDataAdapter());
  Hive.registerAdapter(MangaSearchResultAdapter());
  Hive.registerAdapter(MangaStatusAdapter());
  Hive.registerAdapter(MangaContentTypeAdapter());
  Hive.registerAdapter(MangaDetailsAdapter());
  Hive.registerAdapter(DataBaseBookmarkDataAdapter());


  runApp(const MangaReaderApp());
}
