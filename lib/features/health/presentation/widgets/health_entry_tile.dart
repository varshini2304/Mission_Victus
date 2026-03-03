import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mission_victus/core/theme/app_colors.dart';
import 'package:mission_victus/features/health/domain/entities/health_entry.dart';

class HealthEntryTile extends StatelessWidget {
  const HealthEntryTile({
    super.key,
    required this.entry,
  });

  final HealthEntry entry;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('EEE, d MMM yyyy').format(entry.date);
    final mood = _moodMeta(entry.mood);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 320),
      tween: Tween(begin: 0.95, end: 1),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border(
              left: BorderSide(color: mood.$3, width: 5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('${mood.$1} ${mood.$2}'),
                Text('Sleep: ${entry.sleepHours.toStringAsFixed(1)} hrs'),
                Text('Water: ${entry.waterIntake.toStringAsFixed(1)} L'),
                if ((entry.note ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  (String, String, Color) _moodMeta(Mood mood) {
    switch (mood) {
      case Mood.good:
        return ('😊', 'Good', AppColors.primary);
      case Mood.okay:
        return ('😌', 'Okay', Colors.amber.shade700);
      case Mood.bad:
        return ('😔', 'Bad', AppColors.accent);
    }
  }
}
