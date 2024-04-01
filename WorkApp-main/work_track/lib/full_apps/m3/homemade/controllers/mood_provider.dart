import 'package:flutter/material.dart';

enum MoodTab { Home, View }

class MoodProvider with ChangeNotifier {
  MoodTab _currentTab = MoodTab.Home;

  MoodTab get currentTab => _currentTab;

  void setCurrentTab(MoodTab tab) {
    _currentTab = tab;
    notifyListeners();
  }
}
