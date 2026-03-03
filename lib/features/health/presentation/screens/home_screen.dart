import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mission_victus/core/theme/app_colors.dart';
import 'package:mission_victus/features/health/domain/entities/health_entry.dart';
import 'package:mission_victus/features/health/presentation/providers/health_entries_notifier.dart';
import 'package:mission_victus/features/health/presentation/screens/add_entry_screen.dart';
import 'package:mission_victus/features/health/presentation/screens/analytics_screen.dart';
import 'package:mission_victus/features/health/presentation/widgets/empty_state.dart';
import 'package:mission_victus/features/health/presentation/widgets/health_entry_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fetchEntriesProvider);
    final themeMode = ref.watch(themeModeProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Insights'),
        actions: [
          IconButton(
            tooltip: 'Analytics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AnalyticsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.insights_outlined),
          ),
          IconButton(
            tooltip: 'Toggle dark mode',
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggle();
            },
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AddEntryScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(fetchEntriesProvider.notifier).loadEntries(),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    _greeting(now),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),
                  _TodaySummaryCard(entry: _findTodayEntry(state.entries)),
                  const SizedBox(height: 16),
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  if (state.entries.isEmpty)
                    const EmptyState(
                      title: 'No entries yet',
                      subtitle: 'Log today\'s health insight ✨',
                      icon: Icons.spa_outlined,
                    )
                  else
                    ...state.entries
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: HealthEntryTile(entry: entry),
                            )),
                ],
              ),
      ),
    );
  }

  HealthEntry? _findTodayEntry(List<HealthEntry> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final entry in entries) {
      final date = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (date == today) {
        return entry;
      }
    }
    return null;
  }

  String _greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good Morning 🌿';
    if (hour < 17) return 'Good Afternoon 🌿';
    return 'Good Evening 🌿';
  }
}

class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({
    required this.entry,
  });

  final HealthEntry? entry;

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('EEE, d MMM').format(DateTime.now());
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.18),
              Theme.of(context).colorScheme.secondary.withOpacity(0.22),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: entry == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today • $dateText'),
                  const SizedBox(height: 8),
                  Text(
                    'Log today\'s health insight ✨',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today • $dateText'),
                  const SizedBox(height: 8),
                  Text(
                    '${_emoji(entry!.mood)} ${entry!.mood.label}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text('Sleep: ${entry!.sleepHours.toStringAsFixed(1)} hrs'),
                  Text('Water: ${entry!.waterIntake.toStringAsFixed(1)} L'),
                  if ((entry!.note ?? '').isNotEmpty)
                    Text(
                      entry!.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
      ),
    );
  }

  String _emoji(Mood mood) {
    switch (mood) {
      case Mood.good:
        return '😊';
      case Mood.okay:
        return '😌';
      case Mood.bad:
        return '😔';
    }
  }
}
