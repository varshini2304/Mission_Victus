import 'package:mission_victus/features/health/domain/entities/health_entry.dart';

class HealthAnalytics {
  const HealthAnalytics({
    required this.totalEntries,
    required this.averageSleep,
    required this.averageWaterIntake,
    required this.moodDistribution,
  });

  final int totalEntries;
  final double averageSleep;
  final double averageWaterIntake;
  final Map<Mood, int> moodDistribution;
}
