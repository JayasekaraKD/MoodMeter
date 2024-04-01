import 'dart:js_util';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/todo.dart';
import 'package:work_track/full_apps/m3/homemade/views/filter_provider.dart';
import 'package:work_track/full_apps/m3/homemade/views/filter_sidebar.dart';
import 'package:work_track/full_apps/m3/homemade/views/todo.dart';
import 'package:work_track/full_apps/m3/homemade/views/todo_screen.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late String selectedFilter;
  String currentWeekTitle = '';
  late DateTime weekStart;
  late DateTime weekEnd;
  late String currentMonthTitle;
  late DateTime monthStart;
  DateTime? _selectedDate;
  String userEmail = FirebaseAuth.instance.currentUser!.email.toString();

  // Convert DateTime.now() to UTC
  // DateTime nowUtc = DateTime.now().toUtc();

  // DateTime todayStart = DateTime.now().toUtc();
  // DateTime todayEnd = DateTime.now().toUtc().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    weekStart = weekStart = getRecentSunday(DateTime.now());
    weekEnd = weekStart.add(const Duration(days: 6));
    selectedFilter = 'Weekly';
    currentWeekTitle = _calculateWeekTitle();
    monthStart = DateTime.now();
    monthStart = DateTime(monthStart.year, monthStart.month, 1);
    selectedFilter = 'Monthly';
    currentMonthTitle = _calculateMonthTitle();
    selectedFilter = 'Today';
  }

  DateTime getRecentSunday(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday % 7));
  }

  DateTime getFollowingSaturday(DateTime dateTime) {
    final daysUntilSaturday = DateTime.saturday - dateTime.weekday;
    return dateTime.add(Duration(days: daysUntilSaturday));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 10, left: 16, bottom: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 8),
                            Text(
                              'What\'s up, John!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'Montserrat',
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(
                            255, 175, 76, 130), // Adjust the color as needed
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add,
                            color: Colors.white), // Customize the icon color
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTodoScreen(
                                controller: TodoController(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      child: ToggleButtons(
                        isSelected: [
                          selectedFilter == 'Weekly',
                          selectedFilter == 'Monthly',
                          selectedFilter == 'Today',
                        ],
                        constraints:
                            const BoxConstraints.expand(width: 80, height: 40),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black,
                        selectedColor: Colors.white,
                        fillColor: Color.fromARGB(255, 175, 76, 130),
                        borderWidth: 1,
                        onPressed: (int newIndex) {
                          String newValue;
                          switch (newIndex) {
                            case 0:
                              newValue = 'Weekly';
                              break;
                            case 1:
                              newValue = 'Monthly';
                              break;
                            case 2:
                              newValue = 'Today';
                              break;
                            default:
                              newValue = 'Weekly';
                          }

                          Provider.of<FilterModel>(context, listen: false)
                              .updateFilter(newValue);
                          selectedFilter = newValue;

                          if (newValue == 'Weekly') {
                            currentWeekTitle = _calculateWeekTitle();
                          } else if (newValue == 'Monthly') {
                            currentMonthTitle = _calculateMonthTitle();
                          } else if (newValue == 'Today') {
                            _selectedDate = DateTime.now();
                          }

                          setState(() {});
                        },
                        children: const [
                          Text('Weekly'),
                          Text('Monthly'),
                          Text('Today'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 120.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                SizedBox(width: 16),
                Expanded(child: _buildCategoryCard(context, 'Work')),
                SizedBox(width: 16),
                Expanded(child: _buildCategoryCard(context, 'Study')),
                SizedBox(width: 16),
                Expanded(child: _buildCategoryCard(context, 'Food')),
                SizedBox(width: 16),
                Expanded(child: _buildCategoryCard(context, 'Workout')),
                SizedBox(width: 16),
                Expanded(child: _buildCategoryCard(context, 'Others')),
                SizedBox(width: 16),
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 24,
                  left: 16,
                  bottom: 16,
                  right: 16,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        20), // Adjust the border radius as needed
                    color: Colors
                        .grey[300], // Set the grey color for the background
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons
                            .arrow_back_ios), // Add the icon for previous week navigation
                        onPressed: () {
                          updateWeekDates(false);
                          updateMonthDates(
                              false); // Navigate to the previous week
                        },
                      ),
                      Text(
                        selectedFilter == 'Weekly'
                            ? (currentWeekTitle.isNotEmpty
                                ? currentWeekTitle
                                : 'My Tasks')
                            : selectedFilter == 'Monthly'
                                ? (currentMonthTitle.isNotEmpty
                                    ? currentMonthTitle
                                    : 'My Tasks')
                                : 'Today',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                          color: Color.fromARGB(255, 167, 75, 131),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons
                            .arrow_forward_ios), // Add the icon for upcoming week navigation
                        onPressed: () {
                          updateWeekDates(true);
                          updateMonthDates(
                              true); // Navigate to the previous week
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
              child: SingleChildScrollView(
            child: FutureBuilder<User?>(
              future: FirebaseAuth.instance.authStateChanges().first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final User? user = snapshot.data;
                if (user == null) {
                  return const Center(child: Text('No user logged in.'));
                }
                DateTime now = DateTime.now();
                DateTime startOfDay = DateTime(now.year, now.month, now.day);
                DateTime endOfDay = DateTime(now.year, now.month, now.day + 1);
                return selectedFilter == 'Weekly'
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('tasks')
                            .where('email', isEqualTo: user.email)
                            .where('date',
                                isGreaterThanOrEqualTo:
                                    selectedFilter == 'Weekly'
                                        ? weekStart
                                        : monthStart)
                            .where('date',
                                isLessThanOrEqualTo: selectedFilter == 'Weekly'
                                    ? weekEnd
                                    : DateTime(monthStart.year,
                                        monthStart.month + 1, 0))
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            print('Error: ${snapshot.error}');
                            return const Center(
                                child: Text('An error occurred.'));
                          } else if (snapshot.hasData &&
                              snapshot.data!.docs.isNotEmpty) {
                            final tasks = snapshot.data?.docs;
                            final inProgressTasks = tasks
                                ?.where((task) => task?['status'] == 'pending')
                                .toList();
                            final completedTasks = tasks
                                ?.where((task) => task?['status'] == 'complete')
                                .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (inProgressTasks != null &&
                                    inProgressTasks.isNotEmpty)
                                  _buildTaskList(
                                      'In Progress', inProgressTasks),
                                if (completedTasks != null &&
                                    completedTasks.isNotEmpty)
                                  _buildTaskList('Completed', completedTasks),
                              ],
                            );
                          } else {
                            return const Center(
                              child: Text('No tasks found.'),
                            );
                          }
                        },
                      )
                    : selectedFilter == 'Today'
                        ? FutureBuilder<QuerySnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('tasks')
                                .where('email', isEqualTo: user.email)
                                .where('date',
                                    isGreaterThanOrEqualTo: startOfDay)
                                .where('date', isLessThan: endOfDay)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                print('Error: ${snapshot.error}');
                                return const Center(
                                    child: Text('An error occurred.'));
                              } else if (!snapshot.hasData) {
                                print('No data available.');
                                return const Center(
                                    child: Text('No tasks found.'));
                              } else if (snapshot.data!.docs.isEmpty) {
                                print('No tasks found for today.');
                                return const Center(
                                  child: Text('No tasks found for today.'),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                final tasks = snapshot.data?.docs;
                                final inProgressTasks = tasks
                                    ?.where(
                                        (task) => task?['status'] == 'pending')
                                    .toList();
                                final completedTasks = tasks
                                    ?.where(
                                        (task) => task?['status'] == 'complete')
                                    .toList();

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    if (inProgressTasks != null &&
                                        inProgressTasks.isNotEmpty)
                                      _buildTaskList(
                                          'In Progress', inProgressTasks),
                                    if (completedTasks != null &&
                                        completedTasks.isNotEmpty)
                                      _buildTaskList(
                                          'Completed', completedTasks),
                                  ],
                                );
                              } else {
                                return const Center(
                                  child: Text('No tasks found for today.'),
                                );
                              }
                            },
                          )
                        : SizedBox(
                            child: TableCalendar(
                              focusedDay: DateTime.now(),
                              firstDay: DateTime(
                                  monthStart.year, monthStart.month - 1, 1),
                              lastDay: DateTime(
                                  monthStart.year, monthStart.month + 1, 0),
                              calendarFormat: CalendarFormat.month,
                              headerVisible: false, // Hide the month header
                              availableGestures: AvailableGestures.none,
                              weekNumbersVisible: false,
                              selectedDayPredicate: (day) {
                                // Customize the style for the selected day
                                if (isSameDay(_selectedDate, day)) {
                                } else {}
                                return isSameDay(_selectedDate, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDate = selectedDay;
                                });
                                _showTaskDetailsPopup(selectedDay, userEmail);
                              },
                            ),
                          );
              },
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTaskList(String title, List<QueryDocumentSnapshot>? tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: tasks?.length,
          itemBuilder: (context, index) {
            final task = tasks?[index];
            final title = task?['title'];
            final description = task?['description'];
            final isImportant = task?['important'];
            final status = task?['status'];
            final Timestamp? timestamp = task?['date'];
            final DateTime? date = timestamp?.toDate();
            const importantTag = 'Important';
            return Card(
              elevation: 5,
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Color.fromARGB(255, 248, 246, 246),
              child: ListTile(
                title: Text(
                  title ?? '',
                  style: const TextStyle(
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
                      description ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: <Widget>[
                        if (isImportant == true)
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 192, 187, 187),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              importantTag,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 0, 0),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date != null
                          ? '${date.toLocal().toLocal().toString().split(' ')[0]}'
                          : '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Theme(
                      data: ThemeData(
                        unselectedWidgetColor:
                            Color.fromARGB(255, 175, 76, 122),
                        checkboxTheme: CheckboxThemeData(
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return null;
                              }
                              if (states.contains(MaterialState.selected)) {
                                return Color.fromARGB(255, 175, 76, 130);
                              }
                              return null;
                            },
                          ),
                        ),
                        radioTheme: RadioThemeData(
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return null;
                              }
                              if (states.contains(MaterialState.selected)) {
                                return Color.fromARGB(255, 175, 76, 130);
                              }
                              return null;
                            },
                          ),
                        ),
                        switchTheme: SwitchThemeData(
                          thumbColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return null;
                              }
                              if (states.contains(MaterialState.selected)) {
                                return Color.fromARGB(255, 175, 76, 130);
                              }
                              return null;
                            },
                          ),
                          trackColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return null;
                              }
                              if (states.contains(MaterialState.selected)) {
                                return Color.fromARGB(255, 175, 76, 130);
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      child: Checkbox(
                        value: status == 'complete',
                        onChanged: (bool? value) {
                          if (value != null) {
                            final taskId = task?.id;
                            if (taskId != null) {
                              final taskReference = FirebaseFirestore.instance
                                  .collection('tasks')
                                  .doc(taskId);
                              taskReference.update(
                                  {'status': value ? 'complete' : 'pending'});
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        final taskId = task?.id;
                        if (taskId != null) {
                          final taskReference = FirebaseFirestore.instance
                              .collection('tasks')
                              .doc(taskId);
                          taskReference.delete().then((_) {
                            print('Task deleted successfully.');
                          }).catchError((error) {
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
        ),
      ],
    );
  }

  void _showTaskDetailsPopup(DateTime? selectedDate, String userEmail) {
    if (selectedDate != null) {
      DateTime startOfDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      DateTime endOfDay = DateTime(
          selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);

      FirebaseFirestore.instance
          .collection('tasks')
          .where('email', isEqualTo: userEmail)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get()
          .then((QuerySnapshot querySnapshot) {
        print(selectedDate);
        if (querySnapshot.docs.isNotEmpty) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.calendar_today),
                    SizedBox(width: 8),
                    Text(DateFormat.yMd().format(selectedDate)),
                  ],
                ),
                content: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var doc in querySnapshot.docs)
                        _buildTaskBox(doc.data()
                            as Map<String, dynamic>), // Mapping tasks here
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('No Task Details'),
                content: Text('No task details found for the selected date.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      }).catchError((error) {
        print('Error fetching task details: $error');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Error fetching task details: $error'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      });
    }
  }

  Widget _buildTaskBox(Map<String, dynamic> taskDetails) {
    String taskTitle = taskDetails['title'] as String? ?? 'No title available';
    String taskDescription =
        taskDetails['description'] as String? ?? 'No description available';
    String taskCategory =
        taskDetails['category'] as String? ?? 'No category available';
    String taskStatus =
        taskDetails['status'] as String? ?? 'No status available';

    return Container(
      margin: EdgeInsets.only(bottom: 8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(Icons.article),
            title: Text(taskTitle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(taskDescription),
                SizedBox(height: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary:
                        taskStatus == 'pending' ? Colors.yellow : Colors.green,
                  ),
                  onPressed: () {
                    // Add functionality when the button is pressed
                  },
                  child: Text(
                    taskStatus,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateWeekDates(bool goToNextWeek) {
    if (selectedFilter == 'Weekly') {
      final daysToMove = goToNextWeek ? 7 : -7;
      weekStart = getRecentSunday(weekStart.add(Duration(days: daysToMove)));
      weekEnd = getFollowingSaturday(weekEnd.add(Duration(days: daysToMove)));

      currentWeekTitle =
          '${weekStart.day} ${_getMonthName(weekStart.month)} - ${weekEnd.day} ${_getMonthName(weekEnd.month)}';
      setState(() {
        currentWeekTitle = currentWeekTitle;
      });
    }
  }

  void updateMonthDates(bool goToNextMonth) {
    final newMonth = monthStart.month + (goToNextMonth ? 1 : -1);
    final newYear =
        monthStart.year + (newMonth > 12 ? 1 : (newMonth < 1 ? -1 : 0));
    final adjustedMonth = newMonth > 12 ? 1 : (newMonth < 1 ? 12 : newMonth);

    monthStart = DateTime(newYear, adjustedMonth, 1);

    setState(() {
      currentMonthTitle = _calculateMonthTitle();
    });
  }

  String _calculateWeekTitle() {
    if (selectedFilter == 'Weekly') {
      final startDate = '${weekStart.day} ${_getMonthName(weekStart.month)}';
      final endDate = '${weekEnd.day} ${_getMonthName(weekEnd.month)}';

      return '$startDate - $endDate';
    }
    return '';
  }

  String _calculateMonthTitle() {
    return _getMonthName(monthStart.month);
  }

  String _getMonthName(int month) {
    final monthsInYear = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthsInYear[month - 1];
  }

  void _updateFilter(String newFilter) {
    setState(() {
      selectedFilter = newFilter;
      currentWeekTitle = _calculateWeekTitle();
    });
  }

  Widget _buildCategoryCard(BuildContext context, String category) {
    return FutureBuilder<int>(
      future: _getTaskCountForCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (!snapshot.hasData) {
          return Text('Error: ${snapshot.error}');
        }
        final taskCount = snapshot.data ?? 0;
        final progress = taskCount > 0 ? (taskCount / 20) * 100 : 0;

        return Container(
          width: 120.0,
          padding: EdgeInsets.all(8),
          decoration: _getCategoryDecoration(category),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category),
                color: Colors.white,
              ),
              SizedBox(height: 4),
              Text(
                category,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress / 100.0,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '$taskCount Task',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<int> _getTaskCountForCategory(String category) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('category', isEqualTo: category)
        .get();
    return querySnapshot.size;
  }

  BoxDecoration _getCategoryDecoration(String category) {
    switch (category) {
      case 'Work':
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 148, 201, 245),
              Color.fromARGB(255, 0, 126, 252)
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        );
      case 'Study':
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA5D6A7), Color.fromARGB(255, 59, 241, 68)],
          ),
          borderRadius: BorderRadius.circular(15),
        );
      case 'Food':
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 243, 229, 149),
              Color.fromARGB(255, 255, 218, 11)
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        );
      case 'Workout':
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFCE93D8), Color.fromARGB(255, 169, 2, 240)],
          ),
          borderRadius: BorderRadius.circular(15),
        );
      case 'Others':
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 247, 117, 203),
              Color.fromARGB(255, 245, 25, 146)
            ],
          ),
          borderRadius: BorderRadius.circular(15),
        );
      default:
        return BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(15),
        );
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Study':
        return Icons.book;
      case 'Food':
        return Icons.fastfood;
      case 'Workout':
        return Icons.fitness_center;
      case 'Others':
        return Icons.category;
      default:
        return Icons.category;
    }
  }
}
