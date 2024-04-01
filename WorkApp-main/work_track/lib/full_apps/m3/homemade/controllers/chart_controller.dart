import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_track/full_apps/m3/homemade/models/chart_model.dart';

class ChartController extends ChangeNotifier {
  ChartFilter _selectedFilter = ChartFilter.week;

  ChartFilter get selectedFilter => _selectedFilter;

  set selectedFilter(ChartFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<List<String>> getUsernames() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isNotEqualTo: user.email) // Exclude current user
            .get();

        List<String> usernames =
            querySnapshot.docs.map((doc) => doc['username'] as String).toList();

        return usernames;
      } else {
        // Handle the case when the user is not logged in
        return [];
      }
    } catch (e) {
      print('Error fetching usernames: $e');
      return [];
    }
  }

  Future<void> fetchDataForUser(String username) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('moods')
            .orderBy('date')
            .where('userId', isEqualTo: user.uid) // Filter by user's UID
            .where('username',
                isEqualTo: username) // Filter by selected username
            .get();

        List<MoodRecord> userRecords = querySnapshot.docs.map((doc) {
          return MoodRecord.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        // Notify listeners and update the chart with the new data
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching mood records for user: $e');
    }
  }

  Future<List<MoodRecord>> fetchDataFromFirestore(
      {DateTime? month, int? currentPage}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('moods')
            .orderBy('date')
            .where('userId', isEqualTo: user.uid) // Filter by user's UID
            .get();

        List<MoodRecord> allRecords = querySnapshot.docs.map((doc) {
          return MoodRecord.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        return _filterRecords(allRecords, month, currentPage);
      } else {
        // Handle the case when the user is not logged in
        return [];
      }
    } catch (e) {
      print('Error fetching mood records: $e');
      return [];
    }
  }

  List<MoodRecord> _filterRecords(
      List<MoodRecord> allRecords, DateTime? month, int? currentPage) {
    if (selectedFilter == ChartFilter.week) {
      DateTime now = DateTime.now();

      DateTime startOfWeek =
          DateTime(now.year, now.month, now.day - now.weekday);
      DateTime endOfWeek = startOfWeek.add(Duration(days: 7));

      startOfWeek =
          startOfWeek.subtract(Duration(days: (currentPage ?? 0) * 7));
      endOfWeek = endOfWeek.subtract(Duration(days: (currentPage ?? 0) * 7));

      return allRecords
          .where((record) =>
              record.date.isAfter(startOfWeek) &&
              record.date.isBefore(endOfWeek.add(Duration(days: 1))))
          .toList();
    } else if (selectedFilter == ChartFilter.month) {
      if (month != null) {
        DateTime startOfMonth;
        DateTime endOfMonth;

        const daysPerMonth = 31; // Assuming an average of 30 days per month

        if (currentPage != null && currentPage < 0) {
          // For navigating to previous months
          startOfMonth = month
              .subtract(Duration(days: 1))
              .subtract(Duration(days: currentPage.abs() * daysPerMonth));
          endOfMonth = month
              .subtract(Duration(days: 1))
              .subtract(Duration(days: (currentPage.abs() - 1) * daysPerMonth));
        } else {
          // For navigating to future months
          startOfMonth = DateTime(month.year, month.month, 1);
          endOfMonth = DateTime(month.year, month.month + 1, 1)
              .subtract(Duration(days: 1));
        }

        return allRecords
            .where((record) =>
                record.date.isAfter(startOfMonth) &&
                record.date.isBefore(endOfMonth.add(Duration(days: 1))))
            .toList();
      } else {
        // Include records from 2023 and 2024
        return allRecords
            .where((record) =>
                record.date.year >= 2023 && record.date.year <= 2024)
            .toList();
      }
    }
    return allRecords;
  }

  bool hasDataForNextPage(int currentPage) {
    int totalPages = getTotalPages();
    return currentPage < totalPages - 1; // Return true if there is a next page
  }

  int getTotalPages() {
    // Implement this method based on your total number of pages logic
    // Return the total number of pages
    return 100;
  }
}

enum ChartFilter {
  week,
  month,
}
