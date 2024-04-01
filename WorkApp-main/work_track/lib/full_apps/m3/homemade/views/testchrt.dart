// // month_main.dart
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:work_track/full_apps/m3/homemade/controllers/chart_controller.dart';

// class MonthPage extends StatelessWidget {
//   final String title;

//   const MonthPage({
//     Key? key,
//     required this.title,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChartFrame(
//       title: title,
//       fetchData: (controller, month, currentPage) {
//         return controller.fetchDataFromFirestore(
//           month: month,
//           currentPage: currentPage,
//         );
//       },
//     );
//   }
// }

// // week_main.dart
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:work_track/full_apps/m3/homemade/controllers/chart_controller.dart';

// class WeekPage extends StatelessWidget {
//   final String title;

//   const WeekPage({
//     Key? key,
//     required this.title,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ChartFrame(
//       title: title,
//       fetchData: (controller, month, currentPage) {
//         return controller.fetchDataFromFirestore(
//           month: null,
//           currentPage: currentPage,
//         );
//       },
//     );
//   }
// }
