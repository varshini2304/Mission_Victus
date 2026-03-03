enum Mood {
  good,
  okay,
  bad,
}

extension MoodX on Mood {
  String get label {
    switch (this) {
      case Mood.good:
        return 'Good';
      case Mood.okay:
        return 'Okay';
      case Mood.bad:
        return 'Bad';
    }
  }
}

class HealthEntry {
  const HealthEntry({
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

  HealthEntry copyWith({
    String? id,
    DateTime? date,
    Mood? mood,
    double? sleepHours,
    double? waterIntake,
    String? note,
  }) {
    return HealthEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      sleepHours: sleepHours ?? this.sleepHours,
      waterIntake: waterIntake ?? this.waterIntake,
      note: note ?? this.note,
    );
  }
}
