import 'package:hive/hive.dart';
import 'package:mission_victus/features/health/domain/entities/health_entry.dart';

class HealthEntryModel {
  const HealthEntryModel({
    required this.id,
    required this.date,
    required this.mood,
    required this.sleepHours,
    required this.waterIntake,
    this.note,
  });

  final String id;
  final DateTime date;
  final Mood mood;
  final double sleepHours;
  final double waterIntake;
  final String? note;

  HealthEntry toEntity() {
    return HealthEntry(
      id: id,
      date: date,
      mood: mood,
      sleepHours: sleepHours,
      waterIntake: waterIntake,
      note: note,
    );
  }

  factory HealthEntryModel.fromEntity(HealthEntry entry) {
    return HealthEntryModel(
      id: entry.id,
      date: entry.date,
      mood: entry.mood,
      sleepHours: entry.sleepHours,
      waterIntake: entry.waterIntake,
      note: entry.note,
    );
  }
}

class MoodAdapter extends TypeAdapter<Mood> {
  @override
  final int typeId = 1;

  @override
  Mood read(BinaryReader reader) {
    final value = reader.readByte();
    switch (value) {
      case 0:
        return Mood.good;
      case 1:
        return Mood.okay;
      case 2:
        return Mood.bad;
      default:
        return Mood.okay;
    }
  }

  @override
  void write(BinaryWriter writer, Mood obj) {
    switch (obj) {
      case Mood.good:
        writer.writeByte(0);
      case Mood.okay:
        writer.writeByte(1);
      case Mood.bad:
        writer.writeByte(2);
    }
  }
}

class HealthEntryModelAdapter extends TypeAdapter<HealthEntryModel> {
  @override
  final int typeId = 2;

  @override
  HealthEntryModel read(BinaryReader reader) {
    final id = reader.readString();
    final date = reader.read() as DateTime;
    final mood = reader.read() as Mood;
    final sleepHours = reader.readDouble();
    final waterIntake = reader.readDouble();
    final note = reader.read() as String?;

    return HealthEntryModel(
      id: id,
      date: date,
      mood: mood,
      sleepHours: sleepHours,
      waterIntake: waterIntake,
      note: note,
    );
  }

  @override
  void write(BinaryWriter writer, HealthEntryModel obj) {
    writer.writeString(obj.id);
    writer.write(obj.date);
    writer.write(obj.mood);
    writer.writeDouble(obj.sleepHours);
    writer.writeDouble(obj.waterIntake);
    writer.write(obj.note);
  }
}
