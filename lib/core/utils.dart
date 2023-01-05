import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';

DateFormat altDateFormat = DateFormat("MMMM dd, yyyy");

String removeExtraWhiteSpaces(String text) {
  final cleanedText = text.trim().replaceAll(RegExp(r' \s+'), ' ');

  return cleanedText;
}

String fixStringEncoding(String text) {
  final codeUnits = text.codeUnits;
  try {
    log(text[35]);
    return const Utf8Decoder().convert(codeUnits);
  } catch (e) {
    final codeUnits = text
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll('…', '...')
        .replaceAll('“', '"')
        .codeUnits;
    return const Utf8Decoder().convert(codeUnits);
  }
}

String removeChapterFromString(String text) {
  return text.replaceAll('\n', ' ').trim().replaceAll('Chapter ', '');
}
