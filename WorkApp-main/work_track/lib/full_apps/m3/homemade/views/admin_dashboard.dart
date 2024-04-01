import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/adminctrl.dart';
import 'package:work_track/full_apps/m3/homemade/models/chart_model.dart';
import 'package:work_track/gen/assets.gen.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

class ChartFramepg extends StatefulWidget {
  const ChartFramepg({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _ChartFrameState createState() => _ChartFrameState();
}

class _ChartFrameState extends State<ChartFramepg> {
  ChartController _controller = ChartController();
  PageController _pageController =
      PageController(initialPage: DateTime.now().month - 1);

  int _currentPage = DateTime.now().month - 1;
  String _selectedUsername = 'all'; // Default selection is 'all'

  @override
  void initState() {
    super.initState();
    // Fetch usernames on initialization
    _controller.fetchUsernames().then((_) {
      // Set the initial selectedUsername to 'all'
      setState(() {
        _selectedUsername = 'all';
      });

      // Fetch data for the initial month, currentPage, and selectedUsername
      _controller.fetchDataFromFirestore(
        month: _getCurrentMonth(),
        currentPage: _currentPage,
        selectedUsername: _selectedUsername,
      );
    });
  }

  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month Selector
                _buildMonthSelector(),
                // User Dropdown
                _buildUserDropdown(),
              ],
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _controller.getTotalPages(),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });

                  // Pass the current page to fetchDataFromFirestore
                  _controller.fetchDataFromFirestore(
                    month: _getCurrentMonth(),
                    currentPage: _currentPage,
                    selectedUsername: _selectedUsername,
                  );
                },
                itemBuilder: (context, index) {
                  DateTime month = DateTime(
                    DateTime.now().year,
                    index + 1,
                  );

                  return Container(
                    height: 200, // Set a fixed height for the chart
                    child: FutureBuilder<List<MoodRecord>>(
                      future: _controller.fetchDataFromFirestore(
                        month: month,
                        currentPage: _currentPage,
                        selectedUsername: _selectedUsername,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text('No mood records available.'));
                        } else {
                          return MoodCountBarChartWidget(
                            moodPercentages:
                                _calculateMoodPercentages(snapshot.data!),
                            pge: index,
                          );
                        }
                      },
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

  Widget _buildUserDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // DropdownButton to select a user
          DropdownButton<String>(
            value: _selectedUsername,
            items: _controller.usernames.map((String username) {
              return DropdownMenuItem<String>(
                value: username,
                child: Text(username),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedUsername = newValue ?? 'all';
              });

              // Print the selected username to the console
              print('Selected username: $_selectedUsername');

              // Fetch data based on the selected user
              _controller.fetchDataFromFirestore(
                month: _getCurrentMonth(),
                currentPage: _currentPage,
                selectedUsername: _selectedUsername,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    DateTime startDate = DateTime(DateTime.now().year, _currentPage + 1, 1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_left_rounded),
            onPressed: () {
              if (_pageController.hasClients &&
                  _currentPage > -_controller.getTotalPages()) {
                // Subtract 1 from _currentPage
                setState(() {
                  _currentPage -= 1;
                });
                _pageController.jumpToPage(_currentPage);
                _controller.fetchDataFromFirestore(
                    month: _getCurrentMonth(), currentPage: _currentPage);
              }
            },
          ),
          Text(
            'Month of ${DateFormat('MMMM yyyy').format(startDate)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w100),
          ),
          IconButton(
            icon: Icon(Icons.arrow_right_rounded),
            onPressed: () {
              if (_pageController.hasClients &&
                  _currentPage < _controller.getTotalPages() - 1) {
                // Add 1 to _currentPage when clicking right arrow
                setState(() {
                  _currentPage += 1;
                });
                _pageController.jumpToPage(_currentPage);
                _controller.fetchDataFromFirestore(
                    month: _getCurrentMonth(), currentPage: _currentPage);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<List<Map<int, double>>> _fetchMoodPercentages() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('moods')
            .orderBy('date')
            .where('userId', isEqualTo: user.uid) // Filter by user's UID
            .get();

        List<MoodRecord> allRecords = querySnapshot.docs.map((doc) {
          return MoodRecord.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();

        // Group records by month
        var groupedRecords = groupRecordsByMonth(allRecords);

        // Calculate percentages for each mood category
        var moodPercentages = calculateMoodPercentages(groupedRecords);

        return moodPercentages;
      } else {
        // Handle the case when the user is not logged in
        return [];
      }
    } catch (e) {
      print('Error fetching mood records: $e');
      return [];
    }
  }

  Map<int, List<MoodRecord>> groupRecordsByMonth(List<MoodRecord> records) {
    return groupBy(
        records,
        (MoodRecord record) => DateTime(record.date.year, record.date.month)
            .millisecondsSinceEpoch);
  }

  List<Map<int, double>> calculateMoodPercentages(
      Map<int, List<MoodRecord>> groupedRecords) {
    List<Map<int, double>> moodPercentages = [];

    groupedRecords.forEach((month, records) {
      // Count occurrences of each mood score
      var moodCounts = Map<int, int>.fromIterable(
        List.generate(5, (index) => index + 1),
        key: (item) => item,
        value: (item) => records.where((record) => record.score == item).length,
      );

      // Calculate percentages
      var totalEntries = records.length;
      var percentages = Map<int, double>.fromEntries(
        moodCounts.entries.map(
          (entry) => MapEntry(
            entry.key,
            totalEntries == 0 ? 0 : entry.value / totalEntries * 100,
          ),
        ),
      );

      moodPercentages.add(percentages);
    });

    return moodPercentages;
  }

  List<Map<int, double>> _calculateMoodPercentages(List<MoodRecord> records) {
    // Group records by month
    var groupedRecords = groupRecordsByMonth(records);

    // Calculate percentages for each mood category
    return calculateMoodPercentages(groupedRecords);
  }

  DateTime _getCurrentMonth() {
    int selectedYear = DateTime.now().year;
    int selectedMonth = DateTime.now().month + _currentPage;

    // Adjust month and year for negative page index
    while (selectedMonth <= 0) {
      selectedMonth += 12;
      selectedYear -= 1;
    }

    return DateTime(selectedYear, selectedMonth);
  }
}

class MoodCountBarChartWidget extends StatelessWidget {
  const MoodCountBarChartWidget({
    Key? key,
    required this.moodPercentages,
    required this.pge,
  }) : super(key: key);

  final List<Map<int, double>> moodPercentages;
  final int pge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          barGroups: _getBarChartGroups(
            moodPercentages,
            pge,
          ),
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Container(),
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) => Container(),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: titleWidgets,
                reservedSize: 40,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 40,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 20,
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarChartGroups(
      List<Map<int, double>> moodPercentages, int cage) {
    var list = List.generate(
      5,
      (ind) {
        var percentages = moodPercentages[cage];
        var percentage = percentages?[ind + 1] ?? 0.0;
        return BarChartGroupData(
          x: ind + 1,
          barRods: [
            BarChartRodData(
              toY: percentage,
              color: _getColorByMoodScore(ind + 1),
              width: 20,
            ),
          ],
        );
      },
    );
    return list;
  }

  Color? _getColorByMoodScore(int score) {
    Color? color;
    switch (score) {
      case 1:
        color = Colors.red;
        break;
      case 2:
        color = Colors.orange;
        break;
      case 3:
        color = Colors.blue;
        break;
      case 4:
        color = Colors.cyan;
        break;
      case 5:
        color = Colors.green;
        break;
      default:
        color = null;
    }
    return color;
  }

  Widget titleWidgets(double score, TitleMeta meta) {
    String icon;
    Color color;
    switch (score.toInt()) {
      case 1:
        icon = Assets.moodIcons.crying;
        color = Colors.red;
        break;
      case 2:
        icon = Assets.moodIcons.confused;
        color = Colors.orange;
        break;
      case 3:
        icon = Assets.moodIcons.neutral;
        color = Colors.blue;
        break;
      case 4:
        icon = Assets.moodIcons.smile;
        color = Colors.cyan;
        break;
      case 5:
        icon = Assets.moodIcons.happy;
        color = Colors.green;
        break;
      default:
        throw StateError('Invalid');
    }
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: SvgPicture.asset(
        icon,
        color: color,
        height: 32,
        width: 32,
      ),
    );
  }
}
