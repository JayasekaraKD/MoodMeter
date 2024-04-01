import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:work_track/full_apps/m3/homemade/Utils/task_cards.dart';
import 'package:work_track/full_apps/m3/homemade/views/calender_page.dart';
import 'package:work_track/full_apps/m3/homemade/views/time_provider.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({Key? key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final timeProvider = Provider.of<TimeProvider>(context, listen: false);
      timeProvider.setTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Dispose the timer when the widget is removed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Scaffold Built today's page");
    return Scaffold(
      body: SlidingUpPanel(
        maxHeight: 440,
        defaultPanelState: PanelState.OPEN,
        isDraggable: false,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        panel: Padding(
          padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Tasks",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      height: 45,
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(
                          "Reminders",
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TaskCard(clr: const Color.fromARGB(255, 173, 155, 140)),
                      TaskCard(clr: const Color.fromARGB(255, 169, 172, 139)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            height: ScreenUtil().screenHeight,
            width: ScreenUtil().screenWidth,
            color: Color.fromARGB(255, 186, 187, 190),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: Text(
                                    "Today",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: (() => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          const CalenderPage())),
                                )),
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: Text(
                                    "Calender",
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(50),
                          color: const Color.fromARGB(255, 153, 154, 157),
                        ),
                        child: const Center(
                          child: Icon(CupertinoIcons.add),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Tuesday",
                    style: GoogleFonts.poppins(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              direction: Axis.vertical,
                              spacing: -30,
                              children: [
                                Consumer<TimeProvider>(
                                  builder: (context, val, child) {
                                    return Text(
                                      val.time,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 70,
                                      ),
                                    );
                                  },
                                ),
                                Consumer<TimeProvider>(
                                  builder: ((context, value, child) {
                                    return Text(
                                      value.month,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 70,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const VerticalDivider(
                          width: 20,
                          thickness: 1,
                          indent: 30,
                          endIndent: 30,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "1:20 PM ",
                              style: GoogleFonts.poppins(fontSize: 28),
                            ),
                            Text(
                              "New York ",
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                            Text(
                              "6:20 PM ",
                              style: GoogleFonts.poppins(fontSize: 28),
                            ),
                            Text(
                              "UK",
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
