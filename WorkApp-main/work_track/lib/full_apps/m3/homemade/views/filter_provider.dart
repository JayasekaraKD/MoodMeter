// import 'package:flutter/material.dart';

// class FilterProvider extends ChangeNotifier {
//   String _selectedFilter = 'Week'; // Initial filter value

//   String get selectedFilter => _selectedFilter;

//   void updateFilter(String newFilter) {
//     _selectedFilter = newFilter;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';

class FilterModel extends ChangeNotifier {
  String _selectedDateFilter = 'Day'; // Default date filter
  String _selectedCategoryFilter = 'Category A'; // Default category filter

  // Getter methods for retrieving filter values
  String get selectedDateFilter => _selectedDateFilter;
  String get selectedCategoryFilter => _selectedCategoryFilter;

  // Methods to update filter values
  void updateDateFilter(String newDateFilter) {
    _selectedDateFilter = newDateFilter;
    notifyListeners(); // Notify listeners of the change
  }

  void updateCategoryFilter(String newCategoryFilter) {
    _selectedCategoryFilter = newCategoryFilter;
    notifyListeners(); // Notify listeners of the change
  }

  String _selectedFilter = 'Weekly'; // Default selected filter

  String get selectedFilter => _selectedFilter;

  void updateFilter(String newFilter) {
    _selectedFilter = newFilter;
    notifyListeners();
  }
}
