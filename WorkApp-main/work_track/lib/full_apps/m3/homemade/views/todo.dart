import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/todo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_track/full_apps/m3/homemade/models/user.dart';
import 'package:work_track/full_apps/m3/homemade/views/TaskListScreen.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({Key? key, required TodoController controller})
      : super(key: key);

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  late String userEmail;
  // Updated getUserEmail function to set userEmail
  Future<void> getUserEmail() async {
    FirebaseAuth.User? user = FirebaseAuth.FirebaseAuth.instance.currentUser;

    if (user != null) {
      userEmail = user.email ?? 'No email available'; // Get the user's email
      print('email: $userEmail');
    } else {
      print('User is not logged in');
    }
  }

  int idx = 0;
  bool imp = false;
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  List<String> category = [
    'Work',
    'Study',
    'Food',
    'Workout',
    'Others',
  ];
  List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];

  DateTime selectedDate = DateTime.now();
  // TimeOfDay startTime = TimeOfDay.now();
  // TimeOfDay endTime =
  //     TimeOfDay.fromDateTime(DateTime.now().add(Duration(hours: 1)));

  Future<void> addTaskToFirestore(String email) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Convert TimeOfDay to DateTime
    // DateTime now = DateTime.now();
    // DateTime startDateTime = DateTime(
    //     now.year, now.month, now.day, startTime.hour, startTime.minute);
    // DateTime endDateTime =
    //     DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

    await firestore.collection('tasks').add({
      'title': _title.text,
      'description': _description.text,
      'category': category[idx],
      'important': imp,
      'date': selectedDate,
      'email': email,
      'status': 'pending',
    });

    _title.clear();
    _description.clear();
    _dateController.clear();
  }

  String selectedUser = ''; // Added variable to store selected user

  // Fetch users from Firebase
  Stream<List<String>> getUsers() {
    return FirebaseFirestore.instance
        .collection('users') // Change to the actual collection name for users
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .where((doc) => doc['username'] != null)
          .map((doc) => doc['username'].toString())
          .toList();
      print("Users: $users"); // Print the actual list of users
      return users;
    });
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    List<Widget> buttons = List.generate(category.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              idx = index;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors[index],
            primary: Colors.white,
          ),
          child: Text(category[index]),
        ),
      );
    });

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: h / 60,
              ),
              Row(
                children: [
                  label(
                    "Add Task",
                    30,
                    FontWeight.bold,
                  ),
                ],
              ),
              SizedBox(
                height: h / 30,
              ),
              label(
                "Task title",
                18,
                FontWeight.bold,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: w - w / 30,
                  height: h / 13,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors[idx], Color(0xff616B7B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: TextFormField(
                      controller: _title,
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: imp
                            ? Icon(
                                Icons.star_outline_outlined,
                                color: Colors.red,
                                size: w / 15,
                                shadows: [
                                  BoxShadow(
                                    color: Colors.red,
                                    blurRadius: 30.0,
                                    spreadRadius: 6.0,
                                  ),
                                ],
                              )
                            : null,
                        border: InputBorder.none,
                        hintText: "Add title",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.only(left: 20, top: 10),
                      ),
                      cursorColor: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: h / 30,
              ),
              label("Description", 18, FontWeight.bold),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: w - w / 30,
                  height: h / 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors[idx], Color(0xff616B7B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextFormField(
                    maxLines: 10,
                    controller: _description,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Add description",
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.only(left: 20, top: 8),
                    ),
                    cursorColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: h / 30,
              ),
              label("Date", 18, FontWeight.bold),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  width: w - w / 30,
                  height: h / 13,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors[idx], Color(0xff616B7B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );

                          if (pickedDate != null &&
                              pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                              _dateController.text =
                                  "${pickedDate.toLocal()}".split(' ')[0];
                            });
                          }
                        },
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _dateController,
                          style: TextStyle(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Select Date",
                            hintStyle: TextStyle(color: Colors.grey),
                            contentPadding: EdgeInsets.only(left: 20, top: 10),
                          ),
                          cursorColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: h / 30,
              ),
              SizedBox(
                height: h / 30,
              ),
              SizedBox(
                height: h / 30,
              ),
              label("Assignee", 18, FontWeight.bold),
              StreamBuilder<List<String>>(
                stream: getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    print('Error fetching users: ${snapshot.error}');
                    return Text('Error fetching users. Please try again.');
                  } else if (snapshot.hasData) {
                    List<String> users = snapshot.data!;

                    // Check if selectedUser is not null and exists in the list
                    if (selectedUser == null || !users.contains(selectedUser)) {
                      // Set selectedUser to the first user in the list or any default value
                      selectedUser =
                          users.isNotEmpty ? users.first : 'Default User';
                    }

                    return Container(
                      width: w - w / 30,
                      height: h / 13,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors[idx], Color(0xff616B7B)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: DropdownButton<String>(
                        value: selectedUser,
                        icon: const Icon(Icons
                            .arrow_drop_down), // Changed the icon to arrow_drop_down
                        iconSize: 24,
                        elevation: 16,
                        alignment: Alignment.centerRight,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        underline: Container(), // Removed the default underline
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedUser = newValue!;
                          });
                        },
                        items: users.map((String user) {
                          return DropdownMenuItem<String>(
                            value: user,
                            child: Align(
                              alignment:
                                  Alignment.center, // Align text to the left
                              child: Text(user),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Text('No data available.');
                  }
                },
              ),
              SizedBox(
                height: h / 30,
              ),
              SizedBox(
                height: h / 30,
              ),
              ElevatedButton(
                onPressed: () {
                  imp = !imp;
                  setState(() {});
                  print("Important: $imp");
                },
                child: Text(
                  "Important",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: imp
                      ? Colors.red
                      : const Color.fromARGB(255, 91, 113, 131),
                ),
              ),
              SizedBox(
                height: h / 30,
              ),
              label("Category", 18, FontWeight.bold),
              Wrap(
                children: buttons,
              ),
              SizedBox(
                height: h / 20,
              ),
              SizedBox(
                height: h / 20,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await getUserEmail(); // Await the function to get the user's email

                    addTaskToFirestore(
                        userEmail); // Pass userEmail to addTaskToFirestore
                    print("Task added to Firestore");
                    print("User email: $userEmail");
                  },
                  child: Text("Add Task",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 148, 2, 99),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    minimumSize: Size(200, 50),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget label(String text, double size, FontWeight fontWeight) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: const Color.fromARGB(255, 0, 0, 0),
        fontWeight: fontWeight,
      ),
    );
  }
}
