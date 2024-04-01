import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import the flutter_svg package
import 'package:work_track/full_apps/m3/homemade/views/mood_record_form.dart';

class MoodOption extends StatelessWidget {
  final MoodConfiguration moodConfiguration;
  final bool isSelected;

  MoodOption({
    required this.moodConfiguration,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Card(
        elevation: isSelected ? 4 : 0,
        color: isSelected
            ? moodConfiguration.color
                .withOpacity(0.8) // Adjust opacity as needed
            : Theme.of(context).colorScheme.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              SvgPicture.asset(
                moodConfiguration.iconPath,
                color: isSelected
                    ? Theme.of(context).colorScheme.surface
                    : moodConfiguration.color,
                height: 64,
                width: 64,
              ),
              const SizedBox(height: 4),
              Text(
                moodConfiguration.label,
                style: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.surface
                      : moodConfiguration.color,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
