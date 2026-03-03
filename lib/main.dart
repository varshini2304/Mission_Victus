import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mission_victus/core/constants/app_constants.dart';
import 'package:mission_victus/core/theme/app_theme.dart';
import 'package:mission_victus/features/health/presentation/providers/health_entries_notifier.dart';
import 'package:mission_victus/features/health/presentation/screens/splash_screen.dart';

void main() {
  runApp(const ProviderScope(child: HealthInsightApp()));
}

class HealthInsightApp extends ConsumerWidget {
  const HealthInsightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
