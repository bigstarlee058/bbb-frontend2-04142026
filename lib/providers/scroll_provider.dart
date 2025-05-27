import 'package:flutter/cupertino.dart';

class ScrollProvider extends ChangeNotifier {
  double scrollOffset = 0;
  double scrollOffset1 = 0;
  double scrollOffset2 = 0;

  updateOffSet(value) {
    scrollOffset = value;
    notifyListeners();
  }

  updateOffSet1(value) {
    scrollOffset1 = value;
    notifyListeners();
  }

  updateOffSet2(value) {
    scrollOffset2 = value;
    notifyListeners();
  }
}
