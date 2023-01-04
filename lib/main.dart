import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:manga_reader/core/core.dart';
import 'package:manga_reader/core/database_types/page_data.dart';
import 'content_widgets/main_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    log('|${record.level.name}| ${record.loggerName} -> ${record.message}');
  });

  await Hive.initFlutter();

  Hive.registerAdapter(DataBasePageDataAdapter());
  Hive.registerAdapter(MangaSearchResultAdapter());
  Hive.registerAdapter(MangaStatusAdapter());
  Hive.registerAdapter(MangaContentTypeAdapter());

  runApp(const MangaReaderApp());
}
