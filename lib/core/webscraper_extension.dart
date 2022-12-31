import 'package:html/parser.dart';
import 'package:logging/logging.dart';
import 'package:web_scraper/web_scraper.dart';

final _logger = Logger('WebScraper Extensions');

extension WebScraperExtension on WebScraper {
  /// **This method is used only when the result should never be null**
  ///
  /// Calls `getElementAttribute` then unwraps the `String` contents
  List<String> getElementAttributeUnwrapString(
      String selector, String attribute) {
    return getElementAttribute(selector, attribute).map((e) => e!).toList();
  }

  /// Gets first attribute
  dynamic getFirstElementAttribute(String selector, String attribute) {
    return getElementAttribute(selector, attribute).first!;
  }

  /// Gets first title
  String getFirstElementTitle(String selector) {
    try {
    return getElementTitle(selector).first;
    } catch (error) {
      _logger.shout('getFirstElementTitle: "$selector" ${error.toString()}');
      throw ParseError;
    }
  }

  
}
