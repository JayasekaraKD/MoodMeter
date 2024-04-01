import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/chart_controller.dart';
import 'package:work_track/full_apps/m3/homemade/models/chart_model.dart';
import 'package:work_track/full_apps/m3/homemade/views/week_view.dart';

class ChartFrame extends StatefulWidget {
  const ChartFrame({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _ChartFrameState createState() => _ChartFrameState();
}

class _ChartFrameState extends State<ChartFrame> {
  ChartController _controller = ChartController();
  PageController _pageController =
      PageController(initialPage: DateTime.now().month - 1);

  int _currentPage = DateTime.now().month - 1;

  // Initialize the selectedFilter to ChartFilter.month in the constructor
  _ChartFrameState() {
    _controller.selectedFilter = ChartFilter.month;
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
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChartFrame2(
                          title: 'Weekly View',
                        ),
                      ),
                    );
                  },
                  child: Text('View Weekly'),
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
                itemCount: 24,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });

                  // Pass the current page to fetchDataFromFirestore
                  _controller.fetchDataFromFirestore(
                    month: _getCurrentMonth(),
                    currentPage: _currentPage,
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
          horizontalInterval:
              _getHorizontalInterval(), // Set interval based on the filter
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

  DateTime _getCurrentMonth() {
    int selectedYear = DateTime.now().year;
    int selectedMonth = _currentPage + 1;

    // Adjust month and year for negative page index
    if (selectedMonth <= 0) {
      selectedMonth = 12 + selectedMonth;
      selectedYear -= 1;
    }

    return DateTime(selectedYear, selectedMonth);
  }

  double _getHorizontalInterval() {
    return _controller.selectedFilter == ChartFilter.month ? 3 : 1;
  }

  double _getBottomTitleInterval() {
    return _controller.selectedFilter == ChartFilter.month ? 3 : 1;
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

  List<FlSpot> getDots(List<MoodRecord> moodRecords) {
    List<FlSpot> dots = [];
    moodRecords.sort((a, b) => a.date.compareTo(b.date));

    moodRecords.asMap().forEach((index, record) {
      double x = record.date.day.toDouble();
      dots.add(FlSpot(x, record.score.toDouble()));
    });

    return dots;
  }
}
