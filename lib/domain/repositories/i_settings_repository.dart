/// Settings Repository Interface
/// Tuân thủ Dependency Inversion Principle
abstract class ISettingsRepository {
  /// Get monthly budget (synchronous)
  double getMonthlyBudget();

  /// Set monthly budget
  Future<void> setMonthlyBudget(double budget);

  /// Export data to JSON
  Future<Map<String, dynamic>> exportToJson();

  /// Import data from JSON
  Future<void> importFromJson(Map<String, dynamic> data);

  /// Reset all data
  Future<void> resetDatabase();

  /// Get daily reminder settings
  bool getDailyReminderEnabled();

  /// Set daily reminder
  Future<void> setDailyReminderEnabled(bool enabled);

  /// Get budget alert settings
  bool getBudgetAlertEnabled();

  /// Set budget alert
  Future<void> setBudgetAlertEnabled(bool enabled);

  /// Get reminder time
  Map<String, int> getReminderTime();

  /// Set reminder time
  Future<void> setReminderTime(int hour, int minute);
}
