import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mission_victus/features/health/data/datasources/health_local_data_source.dart';
import 'package:mission_victus/features/health/data/models/health_entry_model.dart';
import 'package:mission_victus/features/health/data/repositories/health_repository_impl.dart';
import 'package:mission_victus/features/health/domain/entities/health_analytics.dart';
import 'package:mission_victus/features/health/domain/entities/health_entry.dart';
import 'package:mission_victus/features/health/domain/repositories/health_repository.dart';
import 'package:mission_victus/features/health/domain/usecases/add_health_entry_usecase.dart';
import 'package:mission_victus/features/health/domain/usecases/get_health_analytics_usecase.dart';
import 'package:mission_victus/features/health/domain/usecases/get_health_entries_usecase.dart';

final localDataSourceProvider =
    FutureProvider<HealthLocalDataSource>((ref) async {
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(MoodAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(HealthEntryModelAdapter());
  }

  return HealthLocalDataSource.create();
});

final healthRepositoryProvider = FutureProvider<HealthRepository>((ref) async {
  final localDataSource = await ref.watch(localDataSourceProvider.future);
  return HealthRepositoryImpl(localDataSource);
});

final getHealthEntriesUseCaseProvider =
    FutureProvider<GetHealthEntriesUseCase>((ref) async {
  final repository = await ref.watch(healthRepositoryProvider.future);
  return GetHealthEntriesUseCase(repository);
});

final addHealthEntryUseCaseProvider =
    FutureProvider<AddHealthEntryUseCase>((ref) async {
  final repository = await ref.watch(healthRepositoryProvider.future);
  return AddHealthEntryUseCase(repository);
});

final analyticsUseCaseProvider = Provider<GetHealthAnalyticsUseCase>(
    (ref) => const GetHealthAnalyticsUseCase());

class FetchEntriesState {
  const FetchEntriesState({
    required this.isLoading,
    required this.entries,
    this.errorMessage,
  });

  final bool isLoading;
  final List<HealthEntry> entries;
  final String? errorMessage;

  factory FetchEntriesState.initial() {
    return const FetchEntriesState(isLoading: true, entries: []);
  }

  FetchEntriesState copyWith({
    bool? isLoading,
    List<HealthEntry>? entries,
    String? errorMessage,
  }) {
    return FetchEntriesState(
      isLoading: isLoading ?? this.isLoading,
      entries: entries ?? this.entries,
      errorMessage: errorMessage,
    );
  }
}

class FetchEntriesNotifier extends StateNotifier<FetchEntriesState> {
  FetchEntriesNotifier(this._ref) : super(FetchEntriesState.initial()) {
    loadEntries();
  }

  final Ref _ref;

  Future<void> loadEntries() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final useCase = await _ref.read(getHealthEntriesUseCaseProvider.future);
      final entries = await useCase();
      state = FetchEntriesState(isLoading: false, entries: entries);
    } catch (error) {
      state = FetchEntriesState(
        isLoading: false,
        entries: state.entries,
        errorMessage: error.toString(),
      );
    }
  }
}

final fetchEntriesProvider =
    StateNotifierProvider<FetchEntriesNotifier, FetchEntriesState>(
  (ref) => FetchEntriesNotifier(ref),
);

class AddEntryState {
  const AddEntryState({
    required this.isSaving,
    this.errorMessage,
  });

  final bool isSaving;
  final String? errorMessage;

  factory AddEntryState.initial() {
    return const AddEntryState(isSaving: false);
  }

  AddEntryState copyWith({
    bool? isSaving,
    String? errorMessage,
  }) {
    return AddEntryState(
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }
}

class AddEntryNotifier extends StateNotifier<AddEntryState> {
  AddEntryNotifier(this._ref) : super(AddEntryState.initial());

  final Ref _ref;

  Future<AddHealthEntryResult> addEntry(AddHealthEntryInput input) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final useCase = await _ref.read(addHealthEntryUseCaseProvider.future);
      final result = await useCase(input);
      state = state.copyWith(
        isSaving: false,
        errorMessage: result.status == AddHealthEntryStatus.invalid
            ? result.message
            : null,
      );
      if (result.status == AddHealthEntryStatus.success) {
        await _ref.read(fetchEntriesProvider.notifier).loadEntries();
      }
      return result;
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
      return AddHealthEntryResult(
        status: AddHealthEntryStatus.invalid,
        message: error.toString(),
      );
    }
  }
}

final addEntryProvider = StateNotifierProvider<AddEntryNotifier, AddEntryState>(
  (ref) => AddEntryNotifier(ref),
);

final analyticsProvider = Provider<HealthAnalytics>((ref) {
  final entries = ref.watch(fetchEntriesProvider).entries;
  final useCase = ref.watch(analyticsUseCaseProvider);
  return useCase(entries);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggle() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
