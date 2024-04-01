import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/mood_provider.dart';
import 'package:work_track/full_apps/m3/homemade/views/month_view.dart';
import 'package:work_track/full_apps/m3/homemade/views/mood_record_form.dart';
import 'package:work_track/full_apps/m3/homemade/views/week_view.dart';

class SliverAppBarWidget extends StatefulWidget {
  final bool isMonthView;

  const SliverAppBarWidget({Key? key, required this.isMonthView})
      : super(key: key);

  @override
  _SliverAppBarWidgetState createState() => _SliverAppBarWidgetState();
}

class _SliverAppBarWidgetState extends State<SliverAppBarWidget> {
  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    final moodProvider = Provider.of<MoodProvider>(context);

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Color.fromARGB(158, 158, 16, 92),
                leading: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    LucideIcons.chevronLeft,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "Mood Meter",
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 16.0,
                    ),
                  ),
                  background: Image(
                    image: AssetImage(
                      'assets/images/apps/homemade/mood/mood.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    onTap: (index) {
                      if (index == 1) {
                        // Use the provider to update the current tab
                        moodProvider.setCurrentTab(MoodTab.View);
                      } else {
                        moodProvider.setCurrentTab(MoodTab.Home);
                      }
                    },
                    tabs: const [
                      Tab(icon: Icon(Icons.info), text: "Home"),
                      Tab(icon: Icon(Icons.lightbulb_outline), text: "View"),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: widget.isMonthView
              ? _buildMonthBody(context)
              : _buildWeekBody(context),
        ),
      ),
    );
  }

  Widget _buildMonthBody(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    return moodProvider.currentTab == MoodTab.Home
        ? AddMoodRecordForm()
        : ChartFrame(
            title: 'Mood variations',
          );
  }

  Widget _buildWeekBody(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);
    return moodProvider.currentTab == MoodTab.Home
        ? AddMoodRecordForm()
        : ChartFrame2(
            title: 'Mood variations',
          );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

void main() {
  runApp(MaterialApp(
    home:
        SliverAppBarWidget(isMonthView: false), // Change to true for month view
  ));
}
