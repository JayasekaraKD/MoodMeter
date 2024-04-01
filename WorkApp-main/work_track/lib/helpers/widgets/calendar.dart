import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PurpleCalendarButton extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const PurpleCalendarButton({Key? key, required this.onDateSelected})
      : super(key: key);

  @override
  _PurpleCalendarButtonState createState() => _PurpleCalendarButtonState();
}

class _PurpleCalendarButtonState extends State<PurpleCalendarButton> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.purple, // Set primary color to purple
            hintColor: Colors.purple, // Set accent color to purple
            colorScheme: ColorScheme.light(primary: Colors.purple),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });

      // Pass the selected date to the parent widget
      widget.onDateSelected(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _selectDate(context),
      icon: const Icon(
        Icons.calendar_today,
        color: Colors.purple,
      ),
      label: Row(
        children: [
          Text(
            DateFormat.yMMMd().format(_selectedDate),
            style: TextStyle(color: Colors.purple),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.purple),
        ],
      ),
    );
  }
}
