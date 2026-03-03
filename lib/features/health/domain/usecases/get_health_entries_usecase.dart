import 'package:mission_victus/features/health/domain/entities/health_entry.dart';
import 'package:mission_victus/features/health/domain/repositories/health_repository.dart';

class GetHealthEntriesUseCase {
  const GetHealthEntriesUseCase(this._repository);

  final HealthRepository _repository;

  Future<List<HealthEntry>> call() {
    return _repository.getEntries();
  }
}
