import 'dart:convert';

import 'package:flutter/services.dart';

class TodoModel {
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? date;
  final DateTime? startDate;
  final DateTime? endDate;

  TodoModel({
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.date,
    this.startDate,
    this.endDate,
  });
}
