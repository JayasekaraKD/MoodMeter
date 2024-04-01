import 'package:flutter/material.dart';

class PurpleClockButton extends StatefulWidget {
  @override
  _PurpleClockButtonState createState() => _PurpleClockButtonState();
}

class _PurpleClockButtonState extends State<PurpleClockButton> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _selectTime(context),
      icon: const Icon(
        Icons.access_time,
        color: Colors.purple,
      ),
      label: Row(
        children: [
          Text(
            _selectedTime.format(context),
            style: TextStyle(color: Colors.purple),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.purple),
        ],
      ),
    );
  }
}
