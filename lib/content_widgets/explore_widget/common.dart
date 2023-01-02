import '../../core/core.dart';

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
