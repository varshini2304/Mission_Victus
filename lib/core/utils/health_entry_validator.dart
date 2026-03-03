class HealthEntryValidator {
  const HealthEntryValidator._();

  static String? validateSleepHours(double value) {
    if (value < 0 || value > 24) {
      return 'Sleep hours must be between 0 and 24.';
    }
    return null;
  }

  static String? validateWaterIntake(double value) {
    if (value <= 0) {
      return 'Water intake must be greater than 0.';
    }
    return null;
  }
}
