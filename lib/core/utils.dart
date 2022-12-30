import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';

DateFormat altDateFormat = DateFormat("MMMM dd, yyyy");

String removeExtraWhiteSpaces(String text) {
  final cleanedText = text.trim().replaceAll(RegExp(r' \s+'), ' ');

  log(cleanedText);

  return cleanedText;
}

String fixStringEncoding(String text) {
  final codeUnits = text.codeUnits;
  try {
    return const Utf8Decoder().convert(codeUnits);
  } catch (e) {
    log(text[209]);
      final codeUnits = text.replaceAll('’', "'").replaceAll('‘', "'").replaceAll('…', '...').codeUnits;
      return const Utf8Decoder().convert(codeUnits);
  }
}

String removeChapterFromString(String text) {
  return text.replaceAll('\n', ' ').trim().replaceAll('Chapter ', '');
}