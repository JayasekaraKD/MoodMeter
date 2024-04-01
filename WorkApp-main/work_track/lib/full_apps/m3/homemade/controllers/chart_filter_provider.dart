import 'package:flutter/material.dart';

enum ChartFilter { week, month }

class ChartFilterProvider extends ChangeNotifier {
  ChartFilter _selectedFilter = ChartFilter.week;

  ChartFilter get selectedFilter => _selectedFilter;

  void setFilter(ChartFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }
}
