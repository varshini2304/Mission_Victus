import 'package:hive/hive.dart';
import 'package:mission_victus/core/constants/app_constants.dart';
import 'package:mission_victus/features/health/data/models/health_entry_model.dart';

class HealthLocalDataSource {
  const HealthLocalDataSource(this._box);

  final Box<HealthEntryModel> _box;

  List<HealthEntryModel> getEntries() {
    final entries = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<bool> hasEntryForDate(DateTime date) async {
    final key = _dateKey(date);
    return _box.containsKey(key);
  }

  Future<void> saveEntry(HealthEntryModel entry) async {
    final key = _dateKey(entry.date);
    await _box.put(key, entry);
  }

  static String _dateKey(DateTime date) {
    return DateTime(date.year, date.month, date.day).toIso8601String();
  }

  static Future<HealthLocalDataSource> create() async {
    final box = await Hive.openBox<HealthEntryModel>(
      AppConstants.healthEntriesBox,
    );
    return HealthLocalDataSource(box);
  }
}
