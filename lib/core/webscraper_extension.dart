import 'package:web_scraper/web_scraper.dart';

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
    return getElementTitle(selector).first;
  }

  
}
