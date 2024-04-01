import 'package:flutter/material.dart';
import 'package:work_track/full_apps/m3/homemade/models/chart_model.dart';
import 'package:get/get.dart';
import 'package:work_track/full_apps/m3/homemade/views/chart.dart';
import 'package:work_track/full_apps/m3/homemade/views/month_view.dart';
import 'package:work_track/full_apps/m3/homemade/views/mood_record_form.dart';

class MoodHomePage extends StatefulWidget {
  @override
  _MoodHomePageState createState() => _MoodHomePageState();
}

class _MoodHomePageState extends State<MoodHomePage> {
  late MoodRecord _latestMoodRecord;

  @override
  void initState() {
    super.initState();
    // You would typically fetch the latest mood record from your data source here
    // For demonstration purposes, I'm initializing it with a sample record
    _latestMoodRecord = MoodRecord(
      date: DateTime.now(),
      mood: 'Happy',
      userId: '',
      score: 1,
      username: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Meter Home'),
        backgroundColor: const Color.fromARGB(255, 167, 75, 131),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Welcome to Mood Meter!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            buildCard('Record your mood', Icons.mood,
                const Color.fromARGB(255, 176, 149, 39), () {
              Get.to(() => AddMoodRecordForm()); // Pass parameters here
            }),
            SizedBox(height: 20),
            SizedBox(height: 20),
            buildCard('Mood Meter', Icons.mood, Colors.purple, () {
              Get.to(() => ChartFrame(
                    title: '',
                  )); // Pass parameters here
            }),
            Column(
              children: [
                Text('Latest Mood Record:'),
                _buildLatestMoodRecord(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('View Mood Chart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestMoodRecord() {
    return Column(
      children: [
        Text('Date: ${_latestMoodRecord.date.toString()}'),
        Text('Mood: ${_latestMoodRecord.mood}'),
        // Add more details as needed
      ],
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
