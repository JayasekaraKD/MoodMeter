import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MoodRecord {
  final String userId; // Add the 'userId' field
  final int score;
  final String mood; // Add the 'userId' field
  final DateTime date;
  String username; // Add this line if it's missing

  MoodRecord({
    required this.userId,
    required this.score,
    required this.mood,
    required this.date,
    required this.username,
  });

  factory MoodRecord.fromJson(Map<String, dynamic> json) {
    return MoodRecord(
      userId: json['userId'] ?? '', // Use the 'userId' field from the JSON
      score: json['score'] ?? 0,
      mood: json['mood'] ?? '', // Use the 'userId' field from the JSON
      date: (json['date'] as Timestamp).toDate(),
      username: json['username'] as String,
    );
  }

  String formattedDate() {
    return DateFormat.yMd().format(date);
  }
}
