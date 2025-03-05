import 'package:flutter/cupertino.dart';

class MainPageProvider extends ChangeNotifier {
  int selectedPage = 0;

  changeTab(int index) {
    selectedPage = index;
    notifyListeners();
  }
}
