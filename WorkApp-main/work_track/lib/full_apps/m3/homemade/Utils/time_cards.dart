import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:work_track/full_apps/m3/homemade/views/calender_time_provide.dart';

class TimeCard extends StatefulWidget {
  final Map tasks;
  final List tasksList6am;
  final String timeForCard;
  final Color dividerColor;
  final int index;

  TimeCard({
    Key? key,
    required this.tasks,
    required this.tasksList6am,
    required this.index,
    required this.dividerColor,
    required String time_for_card,
    required this.timeForCard,
  }) : super(key: key);

  @override
  State<TimeCard> createState() => _TimeCardState();
}

class _TimeCardState extends State<TimeCard> {
  late TextEditingController addTaskController;

  @override
  void initState() {
    super.initState();
    addTaskController = TextEditingController();
  }

  @override
  void dispose() {
    addTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VerticalDivider(
          width: 20,
          thickness: 1,
          indent: 0,
          endIndent: 0,
          color: widget.dividerColor,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.timeForCard,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
            taskList(),
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: widget.dividerColor),
              ),
              child: GestureDetector(
                onTap: () => addTask(widget.index),
                child: Icon(
                  CupertinoIcons.add,
                  color: widget.dividerColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget taskList() {
    for (int i in widget.tasks.keys) {
      if (widget.index == i) {
        return Consumer<SelectedTimeChangeProvider>(
          builder: (context, value, child) {
            return Container(
              height: 120,
              width: widget.tasks[i].isNotEmpty ? 100 : 50,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.tasks[i].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: () => onTaskTap(widget.index, widget.tasks),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.dividerColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              widget.tasks[i][index],
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      }
    }
    return Container(
      height: 120,
      width: 50,
    );
  }

  Future<void> addTask(int tappedIndex) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Task"),
        content: TextField(
          controller: addTaskController,
        ),
        actions: [
          TextButton(
            onPressed: () {
              try {
                widget.tasks[tappedIndex].add(addTaskController.text);
              } on NoSuchMethodError {
                widget.tasks[tappedIndex] = [addTaskController.text];
              } finally {
                Navigator.pop(context);
              }
            },
            child: Text(
              "Add",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onTaskTap(int index, Map addTaskProvider) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Task"),
        content: TextField(
          controller: addTaskController,
        ),
        actions: [
          TextButton(onPressed: () {}, child: const Text("Ok")),
          TextButton(
            onPressed: () {
              widget.tasks[index].remove(addTaskController.text);
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
