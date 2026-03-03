import 'package:mission_victus/features/health/data/datasources/health_local_data_source.dart';
import 'package:mission_victus/features/health/data/models/health_entry_model.dart';
import 'package:mission_victus/features/health/domain/entities/health_entry.dart';
import 'package:mission_victus/features/health/domain/repositories/health_repository.dart';

class HealthRepositoryImpl implements HealthRepository {
  const HealthRepositoryImpl(this._localDataSource);

  final HealthLocalDataSource _localDataSource;

  @override
  Future<List<HealthEntry>> getEntries() async {
    final models = _localDataSource.getEntries();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> hasEntryForDate(DateTime date) {
    return _localDataSource.hasEntryForDate(date);
  }

  @override
  Future<void> saveEntry(HealthEntry entry) {
    return _localDataSource.saveEntry(HealthEntryModel.fromEntity(entry));
  }
}
