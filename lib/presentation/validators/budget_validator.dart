import 'transaction_validator.dart';

/// Validator cho budget settings
/// Tuân thủ Single Responsibility Principle
class BudgetValidator {
  /// Validate monthly budget amount
  static ValidationResult<double> validateBudget(String? budgetText) {
    if (budgetText == null || budgetText.isEmpty) {
      return ValidationResult.success(0.0); // 0 means no limit
    }

    final budget = double.tryParse(budgetText);

    if (budget == null) {
      return ValidationResult.error('Ngân sách không hợp lệ');
    }

    if (budget < 0) {
      return ValidationResult.error('Ngân sách không thể âm');
    }

    return ValidationResult.success(budget);
  }

  /// Check if budget is exceeded
  static bool isBudgetExceeded(double currentExpense, double budget) {
    if (budget == 0) return false; // No limit
    return currentExpense > budget;
  }

  /// Calculate budget usage percentage
  static double calculateUsagePercentage(double currentExpense, double budget) {
    if (budget == 0) return 0;
    return (currentExpense / budget * 100).clamp(0, 100);
  }
}
