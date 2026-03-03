import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mission_victus/core/theme/app_colors.dart';
import 'package:mission_victus/features/health/domain/entities/health_entry.dart';
import 'package:mission_victus/features/health/presentation/providers/health_entries_notifier.dart';
import 'package:mission_victus/features/health/presentation/widgets/empty_state.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetchState = ref.watch(fetchEntriesProvider);
    final analytics = ref.watch(analyticsProvider);

    if (fetchState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (analytics.totalEntries == 0) {
      return const Scaffold(
        body: Center(
          child: EmptyState(
            title: 'No analytics available',
            subtitle: 'Add entries to view last 7 days insights.',
            icon: Icons.bar_chart_outlined,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('7-Day Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AnalyticsCard(
            title: 'Total Entries',
            value: analytics.totalEntries.toString(),
            icon: Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 10),
          _AnalyticsCard(
            title: 'Average Sleep',
            value: '${analytics.averageSleep.toStringAsFixed(1)} hrs',
            icon: Icons.nightlight_round,
          ),
          const SizedBox(height: 10),
          _AnalyticsCard(
            title: 'Average Water Intake',
            value: '${analytics.averageWaterIntake.toStringAsFixed(1)} L',
            icon: Icons.water_drop_outlined,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mood Distribution',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _MoodBar(
                    label: 'Good',
                    emoji: '😊',
                    count: analytics.moodDistribution[Mood.good] ?? 0,
                    total: analytics.totalEntries,
                    color: AppColors.primary,
                  ),
                  _MoodBar(
                    label: 'Okay',
                    emoji: '😌',
                    count: analytics.moodDistribution[Mood.okay] ?? 0,
                    total: analytics.totalEntries,
                    color: Colors.amber.shade700,
                  ),
                  _MoodBar(
                    label: 'Bad',
                    emoji: '😔',
                    count: analytics.moodDistribution[Mood.bad] ?? 0,
                    total: analytics.totalEntries,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _MoodBar extends StatelessWidget {
  const _MoodBar({
    required this.label,
    required this.emoji,
    required this.count,
    required this.total,
    required this.color,
  });

  final String label;
  final String emoji;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$emoji $label • $count'),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 10,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 450),
                    tween: Tween(begin: 0, end: ratio),
                    builder: (context, value, _) {
                      return Container(
                        height: 10,
                        width: constraints.maxWidth * value,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
