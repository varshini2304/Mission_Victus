import 'package:mission_victus/core/utils/health_entry_validator.dart';
import 'package:mission_victus/features/health/domain/entities/health_entry.dart';
import 'package:mission_victus/features/health/domain/repositories/health_repository.dart';
import 'package:uuid/uuid.dart';

enum AddHealthEntryStatus {
  success,
  duplicate,
  invalid,
}

class AddHealthEntryResult {
  const AddHealthEntryResult({
    required this.status,
    this.message,
  });

  final AddHealthEntryStatus status;
  final String? message;
}

class AddHealthEntryInput {
  const AddHealthEntryInput({
    required this.date,
    required this.mood,
    required this.sleepHours,
    required this.waterIntake,
    this.note,
  });

  final DateTime date;
  final Mood mood;
  final double sleepHours;
  final double waterIntake;
  final String? note;
}

class AddHealthEntryUseCase {
  AddHealthEntryUseCase(
    this._repository, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final HealthRepository _repository;
  final Uuid _uuid;

  Future<AddHealthEntryResult> call(AddHealthEntryInput input) async {
    final sleepValidation =
        HealthEntryValidator.validateSleepHours(input.sleepHours);
    if (sleepValidation != null) {
      return AddHealthEntryResult(
        status: AddHealthEntryStatus.invalid,
        message: sleepValidation,
      );
    }

    final waterValidation =
        HealthEntryValidator.validateWaterIntake(input.waterIntake);
    if (waterValidation != null) {
      return AddHealthEntryResult(
        status: AddHealthEntryStatus.invalid,
        message: waterValidation,
      );
    }

    final normalizedDate =
        DateTime(input.date.year, input.date.month, input.date.day);

    final exists = await _repository.hasEntryForDate(normalizedDate);
    if (exists) {
      return const AddHealthEntryResult(status: AddHealthEntryStatus.duplicate);
    }

    final cleanedNote = input.note?.trim();

    await _repository.saveEntry(
      HealthEntry(
        id: _uuid.v4(),
        date: normalizedDate,
        mood: input.mood,
        sleepHours: input.sleepHours,
        waterIntake: input.waterIntake,
        note: (cleanedNote == null || cleanedNote.isEmpty) ? null : cleanedNote,
      ),
    );

    return const AddHealthEntryResult(status: AddHealthEntryStatus.success);
  }
}
