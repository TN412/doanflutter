import '../../domain/repositories/i_settings_repository.dart';
import '../../services/database_service.dart';

/// Settings Repository Implementation
/// Tuân thủ Dependency Inversion
class SettingsRepository implements ISettingsRepository {
  @override
  double getMonthlyBudget() {
    return DatabaseService.getMonthlyBudget();
  }

  @override
  Future<void> setMonthlyBudget(double budget) async {
    await DatabaseService.setMonthlyBudget(budget);
  }

  @override
  Future<Map<String, dynamic>> exportToJson() async {
    return DatabaseService.exportToJson();
  }

  @override
  Future<void> importFromJson(Map<String, dynamic> data) async {
    await DatabaseService.importFromJson(data);
  }

  @override
  Future<void> resetDatabase() async {
    await DatabaseService.resetDatabase();
  }

  @override
  bool getDailyReminderEnabled() {
    return DatabaseService.getDailyReminderEnabled();
  }

  @override
  Future<void> setDailyReminderEnabled(bool enabled) async {
    await DatabaseService.setDailyReminderEnabled(enabled);
  }

  @override
  bool getBudgetAlertEnabled() {
    return DatabaseService.getBudgetAlertEnabled();
  }

  @override
  Future<void> setBudgetAlertEnabled(bool enabled) async {
    await DatabaseService.setBudgetAlertEnabled(enabled);
  }

  @override
  Map<String, int> getReminderTime() {
    return DatabaseService.getReminderTime();
  }

  @override
  Future<void> setReminderTime(int hour, int minute) async {
    await DatabaseService.setReminderTime(hour, minute);
  }
}
