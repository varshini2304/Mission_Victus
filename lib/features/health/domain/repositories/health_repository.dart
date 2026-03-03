import 'package:mission_victus/features/health/domain/entities/health_entry.dart';

abstract class HealthRepository {
  Future<List<HealthEntry>> getEntries();

  Future<bool> hasEntryForDate(DateTime date);

  Future<void> saveEntry(HealthEntry entry);
}
