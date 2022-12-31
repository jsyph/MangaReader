import '../../core/core.dart';

final mangaSourcesData = {
  'Asura Scans': AsuraScans(),
  'Cosmic Scans': CosmicScans(),
  'Flame Scans': FlameScans(),
  'Luminous Scans': LuminousScans(),
};

class CurrentChapterNumberData {
  int currentNumber;
  int timeStamp;

  CurrentChapterNumberData(
    this.currentNumber,
    this.timeStamp,
  );

  factory CurrentChapterNumberData.empty() {
    return CurrentChapterNumberData(
      1,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
