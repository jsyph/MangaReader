import 'package:flutter/material.dart';
import 'main_widget.dart';
import 'core/manhwa_sites/luminous_scans.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({});

  runApp(const MangaReaderApp());
}
