import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/todo.dart';
import 'package:work_track/full_apps/m3/homemade/views/filter_provider.dart';

class TodoScreen extends StatelessWidget {
  final TodoController controller;
  final double categoryCardWidth = 180.0;

  const TodoScreen({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterProvider = Provider.of<FilterModel>(context);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 16),
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Add logic to perform search functionality
              onChanged: (value) {
                // Perform search logic here based on the value entered in the text field
                // You might want to filter the tasks accordingly and update the displayed tasks

                // For example, you can filter the tasks by title or description
                // final filteredTasks = tasks.where((task) {
                //   final title = task['title'] as String?;
                //   final description = task['description'] as String?;
                //   if (title != null && description != null) {
                //     return title.contains(value) || description.contains(value);
                //   }
                //   return false;
                // }).toList();
              },
            ),
          ),
          SizedBox(height: 16),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Open a filter dialog or any action you want to perform
              // when the filter icon is tapped
            },
          ),
          SizedBox(width: 8),
          // DropdownButton<String>(
          //   value: filterProvider.selectedFilter,
          //   onChanged: (String? newValue) {
          //     if (newValue != null) {
          //       filterProvider.updateFilter(newValue);
          //       // Add logic to filter tasks based on the selected filter
          //       // Modify your StreamBuilder query to include filters for week, month, etc.
          //     }
          //   },
          //   items: ['Week', 'Month', 'OtherFilters']
          //       .map<DropdownMenuItem<String>>(
          //         (String value) => DropdownMenuItem<String>(
          //           value: value,
          //           child: Text(value),
          //         ),
          //       )
          //       .toList(),
          // ),
          // Categories
          SizedBox(
            height: categoryCardWidth,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(
                  width: 16,
                  height: 13,
                ),
                _buildCategoryCard(context, 'Task Completed'),
                SizedBox(width: 16),
                _buildCategoryCard(context, 'On Going Task'),
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: 24,
                  left: 16,
                  bottom: 16,
                  right: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today Tasks', // Add the subtitle here
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        color: Color.fromARGB(255, 167, 75, 131),
                      ),
                    ),
                    SizedBox(width: 8),
                    // IconButton(
                    //   icon: Icon(
                    //       Icons.add), // Add the Add Task button with + icon
                    //   onPressed: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) =>
                    //             // AddTodoScreen(controller: todoController),
                    //             TodoScreen(controller: todoController),
                    //       ),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ],
          ),
          // Task List
          Expanded(
            child: FutureBuilder<User?>(
              future: FirebaseAuth.instance.authStateChanges().first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final User? user = snapshot.data;

                if (user == null) {
                  return Center(
                    child: Text('No user logged in.'),
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('tasks')
                      .where('email', isEqualTo: user.email)
                      .where('status', isEqualTo: 'pending')
                      // Filter by user email
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final tasks = snapshot.data?.docs;
                    final today = DateTime.now();
                    final compltedTasks = tasks?.where((task) {
                      final timestamp = task['date'] as Timestamp?;
                      if (timestamp != null) {
                        final taskDate = timestamp.toDate();
                        return taskDate.day == today.day &&
                            taskDate.month == today.month &&
                            taskDate.year == today.year;
                      }
                      return false;
                    }).toList();

                    if (compltedTasks == null || compltedTasks.isEmpty) {
                      return Center(
                        child: Text('No tasks for today.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: compltedTasks.length,
                      itemBuilder: (context, index) {
                        final task = compltedTasks[index];
                        final title = task['title'];
                        final description = task['description'];
                        final isImportant = task['important'];
                        final status = task['status'];
                        // Convert Timestamp to DateTime
                        final Timestamp? timestamp = task['date'];
                        final DateTime? date = timestamp?.toDate();

                        // Define a variable for the important tag
                        final importantTag = 'Important';

                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Color.fromARGB(255, 248, 246, 246),
                          child: ListTile(
                            title: Text(
                              title,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 6),
                                Text(
                                  description,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: <Widget>[
                                    if (isImportant == true)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 192, 187, 187),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Text(
                                          importantTag,
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 255, 0, 0),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Theme(
                                  data: ThemeData(
                                    unselectedWidgetColor:
                                        const Color.fromARGB(255, 175, 76, 122),
                                    checkboxTheme: CheckboxThemeData(
                                      fillColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return null;
                                        }
                                        if (states
                                            .contains(MaterialState.selected)) {
                                          return const Color.fromARGB(
                                              255, 175, 76, 130);
                                        }
                                        return null;
                                      }),
                                    ),
                                    radioTheme: RadioThemeData(
                                      fillColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return null;
                                        }
                                        if (states
                                            .contains(MaterialState.selected)) {
                                          return const Color.fromARGB(
                                              255, 175, 76, 130);
                                        }
                                        return null;
                                      }),
                                    ),
                                    switchTheme: SwitchThemeData(
                                      thumbColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return null;
                                        }
                                        if (states
                                            .contains(MaterialState.selected)) {
                                          return const Color.fromARGB(
                                              255, 175, 76, 130);
                                        }

                                        return null;
                                      }),
                                      trackColor: MaterialStateProperty
                                          .resolveWith<Color?>(
                                              (Set<MaterialState> states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return null;
                                        }
                                        if (states
                                            .contains(MaterialState.selected)) {
                                          return const Color.fromARGB(
                                              255, 175, 76, 130);
                                        }
                                        return null;
                                      }),
                                    ),
                                  ),
                                  child: Checkbox(
                                    value: status ==
                                        'complete', // Check if status is 'complete'
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        final taskId = task?.id;
                                        if (taskId != null) {
                                          final taskReference =
                                              FirebaseFirestore.instance
                                                  .collection('tasks')
                                                  .doc(taskId);

                                          // Update 'status' field to 'complete' or 'pending' based on checkbox selection
                                          taskReference.update({
                                            'status':
                                                value ? 'complete' : 'pending'
                                          });
                                        }
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    // 1. Identify the task to delete (in this case, using its unique ID)
                                    final taskId = task?.id;

                                    if (taskId != null) {
                                      // 2. Use the ID to reference the Firestore document
                                      final taskReference = FirebaseFirestore
                                          .instance
                                          .collection('tasks')
                                          .doc(taskId);

                                      // 3. Delete the Firestore document
                                      taskReference.delete().then((_) {
                                        // Handle successful deletion, e.g., show a message to the user
                                        print('Task deleted successfully.');
                                      }).catchError((error) {
                                        // Handle any errors that may occur during deletion
                                        print('Error deleting task: $error');
                                      });
                                    }
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Color.fromARGB(255, 255, 0, 0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Complted Tasks', // Add the subtitle here
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        fontFamily: 'Montserrat',
                        color: Color.fromARGB(255, 167, 75, 131),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Task List
          Expanded(
            child: FutureBuilder<User?>(
              future: FirebaseAuth.instance.authStateChanges().first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final User? user = snapshot.data;

                if (user == null) {
                  return Center(
                    child: Text('No user logged in.'),
                  );
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('tasks')
                      .where('email', isEqualTo: user.email)
                      .where('status',
                          isEqualTo: 'complete') // Filter by user email
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final tasks = snapshot.data?.docs;
                    final today = DateTime.now();
                    final todayTasks = tasks?.where((task) {
                      final timestamp = task['date'] as Timestamp?;
                      if (timestamp != null) {
                        final taskDate = timestamp.toDate();
                        return taskDate.day == today.day &&
                            taskDate.month == today.month &&
                            taskDate.year == today.year;
                      }
                      return false;
                    }).toList();

                    if (todayTasks == null || todayTasks.isEmpty) {
                      return Center(
                        child: Text('No tasks for today.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: todayTasks.length,
                      itemBuilder: (context, index) {
                        final task = todayTasks[index];
                        final title = task['title'];
                        final description = task['description'];
                        final isImportant = task['important'];
                        final status = task['status'];
                        // Convert Timestamp to DateTime
                        final Timestamp? timestamp = task['date'];
                        final DateTime? date = timestamp?.toDate();

                        // Define a variable for the important tag
                        final importantTag = 'Important';

                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Color.fromARGB(255, 248, 246, 246),
                          child: ListTile(
                            title: Text(
                              title,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 6),
                                Text(
                                  description,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: <Widget>[
                                    if (isImportant == true)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 192, 187, 187),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Text(
                                          importantTag,
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 255, 0, 0),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String status) {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    return FutureBuilder<User?>(
      future: _auth.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Error fetching user data');
        }
        final User? user = snapshot.data;
        final String? userEmail = user?.email;

        return FutureBuilder<Map<String, int>>(
          future: _fetchTaskCounts(userEmail),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final Map<String, int>? taskCounts = snapshot.data;
            final int completedTaskCount = taskCounts?['complete'] ?? 0;
            final int pendingTaskCount = taskCounts?['pending'] ?? 0;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodoScreen(
                      controller: TodoController(),
                    ),
                  ),
                );
              },
              child: _buildCategoryItem(
                status,
                status == 'Task Completed'
                    ? completedTaskCount
                    : pendingTaskCount,
                Color.fromARGB(255, 175, 76, 130),
                _getStatusIcon(status),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, int>> _fetchTaskCounts(String? userEmail) async {
    try {
      final int completedTaskCount =
          await _getTaskCountForStatus('complete', userEmail ?? '');
      final int pendingTaskCount =
          await _getTaskCountForStatus('pending', userEmail ?? '');

      return {'complete': completedTaskCount, 'pending': pendingTaskCount};
    } catch (e) {
      print('Error fetching task counts: $e');
      return {'complete': 0, 'pending': 0};
    }
  }

  Future<int> _getTaskCountForStatus(String status, String userEmail) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('tasks')
            .where('status', isEqualTo: status)
            .where('email', isEqualTo: userEmail)
            .get();

    return querySnapshot.size;
  }

  Decoration _getStatusDecoration(String status) {
    switch (status) {
      case 'Task Completed':
        return BoxDecoration(
          color: Color.fromARGB(255, 175, 76, 130),
          borderRadius: BorderRadius.circular(8),
        );
      case 'On Going Task':
        return BoxDecoration(
          color: Color.fromARGB(255, 175, 76, 130),
          borderRadius: BorderRadius.circular(8),
        );
      default:
        return BoxDecoration(
          color: Color.fromARGB(255, 175, 76, 130),
          borderRadius: BorderRadius.circular(8),
        );
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Task Completed':
        return Icons.check_circle_outline;
      case 'On Going Task':
        return Icons.pending_actions;
      default:
        return Icons.pending_actions;
    }
  }
}

Widget _buildCategoryItem(String title, int count, Color color, IconData icon) {
  var categoryCardWidth = 180.0;
  return Container(
    width: categoryCardWidth,
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 5),
        Icon(
          icon,
          color: Colors.white,
          size: 40, // Adjust the size as needed
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '$count Task${count != 1 ? 's' : ''}',
          style: TextStyle(color: Colors.white),
        ),
      ],
    ),
  );
}
