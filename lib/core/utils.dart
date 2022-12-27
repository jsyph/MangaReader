import 'package:intl/intl.dart';

String extractChapterNumber(String text) {
  final regExp = RegExp(r'[1-9]\d*(\.\d+)?');

  final chapterNumber = regExp.firstMatch(text)?.group(0) ?? '';

  return chapterNumber;
}

DateFormat altDateFormat = DateFormat("MMMM dd, yyyy");
