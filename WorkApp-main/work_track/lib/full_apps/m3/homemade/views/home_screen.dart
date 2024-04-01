import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/todo.dart';
import 'package:work_track/full_apps/m3/homemade/models/user.dart';
import 'package:work_track/full_apps/m3/homemade/views/admin_dashboard.dart';

import 'package:work_track/full_apps/m3/homemade/views/admin_todo_dashboard.dart';
import 'package:work_track/full_apps/m3/homemade/views/mood_screen.dart';

import 'package:work_track/full_apps/m3/homemade/views/chart.dart';

import 'package:work_track/full_apps/m3/homemade/views/todo.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final UserRole userRole;

  const HomeScreen({Key? key, required this.username, required this.userRole})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: const Color.fromARGB(255, 167, 75, 131),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello, $username!',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            buildCard('Mood Meter', Icons.mood, Colors.purple, () {
              Get.to(() => SliverAppBarWidget(
                    isMonthView: false,
                  ));
            }),
            SizedBox(height: 10),
            buildCard('Todo', Icons.check, Colors.blueAccent, () {
              Get.to(
                () => AddTodoScreen(
                  controller: TodoController(),
                ),
                arguments: username,
              );
            }),
            // Only include pagination card if the user is an admin
            if (userRole == UserRole.admin)
              buildCard('pagination', Icons.assignment,
                  Color.fromARGB(255, 249, 156, 35), () {
                // Print the user role to the console before navigating
                print('User Role: $userRole');
                // Navigate to the ChartFramepg screen for admins
                Get.to(() => ChartFramepg(title: ''));
              }),
            if (userRole == UserRole.admin)
              buildCard('todo admin', Icons.assignment,
                  Color.fromARGB(255, 249, 156, 35), () {
                // Print the user role to the console before navigating
                print('User Role: $userRole');
                // Navigate to the ChartFramepg screen for admins
                Get.to(() => AdminTaskView());
              }),
          ],
        ),
      ),
    );
  }

  Widget buildCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 5,
        color: color,
        child: Container(
          width: 200,
          height: 110,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
