import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'content_widgets/main_widget.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    log('|${record.level.name}| ${record.loggerName} -> ${record.message}');
  });

  runApp(const MangaReaderApp());
}
