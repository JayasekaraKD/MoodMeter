import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminTaskView extends StatefulWidget {
  @override
  _AdminTaskViewState createState() => _AdminTaskViewState();
}

class _AdminTaskViewState extends State<AdminTaskView> {
  String selectedUser = '';
  List<String> users = [];
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    // Fetch the list of users when the widget is initialized
    fetchUsers();
  }

  // Fetch users from Firestore
  Future<void> fetchUsers() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();
      setState(() {
        users = userSnapshot.docs
            .where((doc) => doc['username'] != null)
            .map((doc) => doc['username'].toString())
            .toList();
      });
      selectedUser = users.isNotEmpty ? users.first : '';
      // Fetch tasks for the initial selected user
      fetchTasks(selectedUser);
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  // Fetch tasks from Firestore based on the selected user's username
  Future<void> fetchTasks(String userUsername) async {
    try {
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('username', isEqualTo: userUsername)
          .orderBy('date', descending: true)
          .get();
      setState(() {
        tasks = tasksSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
      print('Tasks for $userUsername: $tasks');
    } catch (error) {
      print('Error fetching tasks: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Task View'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tasks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            // User circles with horizontal scroll
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CircleAvatar(
                      radius: 20,
                      child: Text(
                        users[index][0].toUpperCase(),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            // Dropdown for selecting a user to filter tasks
            DropdownButton<String>(
              value: selectedUser,
              onChanged: (String? newValue) {
                setState(() {
                  selectedUser = newValue!;
                  print(selectedUser);
                  // Fetch tasks for the selected user
                  fetchTasks(selectedUser);
                });
              },
              items: users.map((String user) {
                return DropdownMenuItem<String>(
                  value: user,
                  child: Text(user),
                );
              }).toList(),
              hint: Text('Select a user'),
            ),
            SizedBox(height: 16),
            // Display tasks based on selected user
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  print(
                      'Task Data: $task'); // Print the entire task data for debugging

                  return Card(
                    // Customize the UI for displaying tasks
                    child: ListTile(
                      title: Text(task['title'] ?? ''),
                      subtitle: Text(task['description'] ?? ''),
                      trailing: Text('Status: ${task['status'] ?? ''}'),
                      // Add more details or actions as needed
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
