import 'package:flutter/material.dart';
import 'content_widgets/main_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});

  runApp(const MangaReaderApp());
}
