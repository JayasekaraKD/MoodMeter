import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:work_track/helpers/widgets/calendar.dart';
import 'package:work_track/helpers/widgets/clock.dart';
import 'package:work_track/helpers/widgets/mood_options.dart';

class MoodConfiguration {
  final String iconPath;
  final Color color;
  final String label;
  final int score;

  MoodConfiguration({
    required this.iconPath,
    required this.color,
    required this.label,
    required this.score,
  });
}

final List<MoodConfiguration> kMoodConfigurations = [
  MoodConfiguration(
    iconPath: 'assets/mood_icons/happy.svg',
    color: Colors.green,
    label: "Great",
    score: 5,
  ),
  MoodConfiguration(
    iconPath: 'assets/mood_icons/smile.svg',
    color: Colors.cyan,
    label: "Positive",
    score: 4,
  ),
  MoodConfiguration(
    iconPath: 'assets/mood_icons/neutral.svg',
    color: Colors.blue,
    label: "Alright",
    score: 3,
  ),
  MoodConfiguration(
    iconPath: 'assets/mood_icons/confused.svg',
    color: Colors.orange,
    label: "Bad",
    score: 2,
  ),
  MoodConfiguration(
    iconPath: 'assets/mood_icons/crying.svg',
    color: Colors.red,
    label: "Awful",
    score: 1,
  ),
  MoodConfiguration(
    iconPath: 'assets/mood_icons/crying.svg',
    color: Colors.yellow,
    label: "Amazed",
    score: 6,
  ),
  MoodConfiguration(
    iconPath: 'assets/mood_icons/crying.svg',
    color: Colors.purple,
    label: "Grateful",
    score: 7,
  ),
  MoodConfiguration(
    iconPath: 'assets/mood_icons/crying.svg',
    color: Colors.pink,
    label: "Loved",
    score: 8,
  ),
];

class AddMoodRecordForm extends StatefulWidget {
  const AddMoodRecordForm({Key? key}) : super(key: key);

  @override
  _AddMoodRecordFormState createState() => _AddMoodRecordFormState();
}

class _AddMoodRecordFormState extends State<AddMoodRecordForm> {
  late final TextEditingController _noteController;
  late MoodConfiguration selectedMoodConfiguration;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    selectedMoodConfiguration = kMoodConfigurations[2];
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Mood Record Form"),
          backgroundColor: const Color.fromARGB(255, 167, 75, 131),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + keyboardSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Text(
                "How are you feeling today?",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildDateButton(),
                  buildTimeButton(),
                ],
              ),
              const SizedBox(height: 30),
              buildMoodOptions(),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Explain more about your day",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: buildNoteTextField(),
              ),
              const SizedBox(height: 30),
              buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDateButton() {
    return PurpleCalendarButton(
      onDateSelected: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  Widget buildTimeButton() {
    return PurpleClockButton();
  }

  Widget buildMoodOptions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: kMoodConfigurations
              .sublist(0, 4)
              .map(
                (config) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMoodConfiguration = config;
                    });
                  },
                  child: MoodOption(
                    moodConfiguration: config,
                    isSelected: selectedMoodConfiguration == config,
                  ),
                ),
              )
              .toList(),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: kMoodConfigurations
              .sublist(4, 8)
              .map(
                (config) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMoodConfiguration = config;
                    });
                  },
                  child: MoodOption(
                    moodConfiguration: config,
                    isSelected: selectedMoodConfiguration == config,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget buildNoteTextField() {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 167, 75, 131),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: const Color.fromARGB(255, 167, 75, 131)),
        ),
        hintText: "Add a note",
      ),
      maxLines: null,
      onChanged: (value) {},
    );
  }

  Widget buildButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _submitMoodToFirebase();
              },
              style: ElevatedButton.styleFrom(),
              child: const Text("Save"),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitMoodToFirebase() async {
    try {
      await Firebase.initializeApp();

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userSnapshot.exists) {
          String username = userSnapshot['username'];

          CollectionReference moodCollection =
              FirebaseFirestore.instance.collection('moods');

          String dayOfWeek = DateFormat('EEEE').format(_selectedDate);

          await moodCollection.add({
            'userId': user.uid,
            'username': username,
            'mood': selectedMoodConfiguration.label,
            'date': Timestamp.fromDate(_selectedDate),
            'dayOfWeek': dayOfWeek,
            'note': _noteController.text,
            'score': selectedMoodConfiguration.score,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Current mood is recorded."),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print("Username not found for the current user");
        }
      } else {
        print("User not authenticated");
      }
    } catch (e) {
      print("Error submitting mood to Firestore: $e");
    }
  }
}
