import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'content_widgets/main_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    log('|${record.level.name}| ${record.loggerName} -> ${record.message}');
  });

  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});

  runApp(const MangaReaderApp());
}
