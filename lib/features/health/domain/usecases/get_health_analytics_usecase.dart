import 'package:mission_victus/features/health/domain/entities/health_analytics.dart';
import 'package:mission_victus/features/health/domain/entities/health_entry.dart';

class GetHealthAnalyticsUseCase {
  const GetHealthAnalyticsUseCase();

  HealthAnalytics call(List<HealthEntry> entries) {
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));

    final last7Days =
        entries.where((entry) => !entry.date.isBefore(startDate)).toList();

    final moodDistribution = {
      Mood.good: 0,
      Mood.okay: 0,
      Mood.bad: 0,
    };

    for (final entry in last7Days) {
      moodDistribution[entry.mood] = (moodDistribution[entry.mood] ?? 0) + 1;
    }

    if (last7Days.isEmpty) {
      return HealthAnalytics(
        totalEntries: 0,
        averageSleep: 0,
        averageWaterIntake: 0,
        moodDistribution: moodDistribution,
      );
    }

    final totalSleep = last7Days.fold<double>(
      0,
      (sum, entry) => sum + entry.sleepHours,
    );
    final totalWater = last7Days.fold<double>(
      0,
      (sum, entry) => sum + entry.waterIntake,
    );

    return HealthAnalytics(
      totalEntries: last7Days.length,
      averageSleep: totalSleep / last7Days.length,
      averageWaterIntake: totalWater / last7Days.length,
      moodDistribution: moodDistribution,
    );
  }
}
