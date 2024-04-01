import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/chart_controller.dart';
import 'package:work_track/full_apps/m3/homemade/models/chart_model.dart';
import 'package:work_track/full_apps/m3/homemade/views/chart.dart';
import 'package:work_track/full_apps/m3/homemade/views/month_view.dart';

class ChartFrame2 extends StatefulWidget {
  const ChartFrame2({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _ChartFrame2State createState() => _ChartFrame2State();
}

class _ChartFrame2State extends State<ChartFrame2> {
  ChartController _controller = ChartController();
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = _calculateInitialPage();
    _pageController = PageController(initialPage: _currentPage);
    _fetchDataForCurrentWeek();
  }

  int _calculateInitialPage() {
    DateTime now = DateTime.now();
    DateTime startOfCurrentWeek =
        DateTime(now.year, now.month, now.day - now.weekday);
    return (now.difference(startOfCurrentWeek).inDays / 7).floor();
  }

  Future<void> _fetchDataForCurrentWeek() async {
    await _controller.fetchDataFromFirestore(
      month: null,
      currentPage: _currentPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headline6,
                ),
                const Spacer(),
                // Add the button to navigate to the other page
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChartFrame(
                          title: 'Monthly View',
                        ),
                      ),
                    );
                  },
                  child: Text('View Monthly'),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            _buildMonthSelector(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 100,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });

                  _controller.fetchDataFromFirestore(
                    month: null,
                    currentPage: page,
                  );
                },
                itemBuilder: (context, index) {
                  DateTime startDate = DateTime.now().subtract(
                    Duration(days: 7 * index),
                  );
                  DateTime endDate = startDate.add(Duration(days: 6));

                  return Container(
                    height: 200,
                    child: FutureBuilder<List<MoodRecord>>(
                      future: _controller.fetchDataFromFirestore(
                        month: null,
                        currentPage: _currentPage,
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
                          return buildMoodVariationLineChart(snapshot.data!);
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

  Widget _buildMonthSelector() {
    DateTime now = DateTime.now();

    DateTime startDate;
    DateTime endDate;

    startDate = DateTime(now.year, now.month, now.day - now.weekday + 1);
    endDate = startDate.add(Duration(days: 6));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_left_rounded),
            onPressed: () {
              int previousPage = (_currentPage + 1) % 100;
              _pageController.jumpToPage(previousPage);
            },
          ),
          Text(
            'Week of ${DateFormat('MMMM d').format(startDate.subtract(Duration(days: (_currentPage ?? 0) * 7)))} - ${DateFormat('MMMM d').format(endDate.subtract(Duration(days: (_currentPage ?? 0) * 7)))}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w100),
          ),
          IconButton(
            icon: Icon(Icons.arrow_right_rounded),
            onPressed: () {
              int nextPage = (_currentPage - 1 + 100) % 100;

              bool hasDataForNextPage =
                  _controller.hasDataForNextPage(nextPage);

              if (hasDataForNextPage) {
                _pageController.jumpToPage(nextPage);

                DateTime newStartDate = startDate.subtract(
                  Duration(days: 7 * nextPage - 2),
                );
                DateTime newEndDate = newStartDate.add(Duration(days: 6));

                _controller.fetchDataFromFirestore(
                  month: null,
                  currentPage: nextPage,
                );

                setState(() {
                  _currentPage = nextPage;
                  startDate = newStartDate;
                  endDate = newEndDate;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildMoodVariationLineChart(List<MoodRecord> moodRecords) {
    List<FlSpot> dots = getDots(moodRecords);

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: dots,
            isCurved: true,
            isStrokeCapRound: true,
            preventCurveOverShooting: true,
            barWidth: 4,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.red.withOpacity(.35),
                  Colors.orange.withOpacity(.35),
                  Colors.blue.withOpacity(.35),
                  Colors.cyan.withOpacity(.35),
                  Colors.green.withOpacity(.35),
                ].sublist(0, 5),
              ),
            ),
          ),
        ],
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: _getHorizontalInterval(),
        ),
        borderData: FlBorderData(
          show: false,
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
              getTitlesWidget: (value, meta) => Container(),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: getLeftTitleWidgets,
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getBottomTitleInterval(),
              reservedSize: 40,
              getTitlesWidget: (value, meta) => getBottomTitleWidgets(value),
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: false,
        ),
        minY: 1,
        maxY: 5,
      ),
    );
  }

// Updated method to get the day of the week abbreviation
  String getDayOfWeekAbbreviation(int dayOfWeek) {
    switch (dayOfWeek) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget getBottomTitleWidgets(double value) {
    // Assuming value represents the day of the week (1 for Mon, 2 for Tue, etc.)
    int dayOfWeek = ((value - 1) % 7).toInt() + 1;

    // Use the dayOfWeekAbbreviation method to get the abbreviation
    String abbreviation = getDayOfWeekAbbreviation(dayOfWeek);

    return Text(abbreviation, style: TextStyle(fontSize: 12));
  }

  double _getHorizontalInterval() {
    return 1;
  }

  Widget getLeftTitleWidgets(double value, TitleMeta meta) {
    String icon;
    Color color;
    switch (value.toInt()) {
      case 1:
        icon = 'assets/mood_icons/crying.svg';
        color = Colors.red;
        break;
      case 2:
        icon = 'assets/mood_icons/confused.svg';
        color = Colors.orange;
        break;
      case 3:
        icon = 'assets/mood_icons/neutral.svg';
        color = Colors.blue;
        break;
      case 4:
        icon = 'assets/mood_icons/smile.svg';
        color = Colors.cyan;
        break;
      case 5:
        icon = 'assets/mood_icons/happy.svg';
        color = Colors.green;
        break;
      default:
        throw StateError('Invalid');
    }
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: SvgPicture.asset(
        icon,
        color: color,
        height: 32,
        width: 32,
      ),
    );
  }

  double _getBottomTitleInterval() {
    // Since we want to show all days of the week, set the interval to 1
    return 1;
  }

  List<FlSpot> getDots(List<MoodRecord> moodRecords) {
    List<FlSpot> dots = [];
    moodRecords.sort((a, b) => a.date.weekday.compareTo(b.date.weekday));

    moodRecords.asMap().forEach((index, record) {
      double x = record.date.weekday.toDouble();
      dots.add(FlSpot(x, record.score.toDouble()));
    });

    return dots;
  }
}
