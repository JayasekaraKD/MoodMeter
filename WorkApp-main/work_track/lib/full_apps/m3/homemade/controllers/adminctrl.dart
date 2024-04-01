import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_track/full_apps/m3/homemade/models/chart_model.dart';

class ChartController extends ChangeNotifier {
  List<String> _usernames = [];
  List<String> get usernames => _usernames;

  Future<void> fetchUsernames() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      _usernames =
          querySnapshot.docs.map((doc) => doc['username'] as String).toList();
      _usernames.add('all'); // Add 'all' option to the dropdown

      notifyListeners();
    } catch (e) {
      print('Error fetching usernames: $e');
    }
  }

  Future<List<MoodRecord>> fetchDataFromFirestore(
      {DateTime? month, int? currentPage, String? selectedUsername}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('moods')
            .orderBy('date')
            // .where('userId', isEqualTo: user.uid) // Filter by user's UID
            .get();

        List<MoodRecord> allRecords = querySnapshot.docs.map((doc) {
          return MoodRecord.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        return _filterRecords(allRecords, month, currentPage, selectedUsername);
      } else {
        // Handle the case when the user is not logged in
        return [];
      }
    } catch (e) {
      print('Error fetching mood records: $e');
      return [];
    }
  }

  List<MoodRecord> _filterRecords(List<MoodRecord> allRecords, DateTime? month,
      int? currentPage, String? selectedUsername) {
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

      if (selectedUsername == 'all') {
        // Include records from all users
        return allRecords
            .where((record) =>
                record.date.isAfter(startOfMonth) &&
                record.date.isBefore(endOfMonth.add(Duration(days: 1))))
            .toList();
      } else {
        // Include records only for the selected user
        return allRecords
            .where((record) =>
                record.username == selectedUsername &&
                record.date.isAfter(startOfMonth) &&
                record.date.isBefore(endOfMonth.add(Duration(days: 1))))
            .toList();
      }
    } else {
      // Include records from 2023 and 2024
      return allRecords
          .where(
              (record) => record.date.year >= 2023 && record.date.year <= 2024)
          .toList();
    }
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
