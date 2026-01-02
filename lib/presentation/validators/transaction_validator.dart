/// Validator cho transaction input
/// Tuân thủ Single Responsibility Principle - chỉ lo validation
class TransactionValidator {
  /// Validate amount input
  static ValidationResult validateAmount(String? amountText) {
    if (amountText == null || amountText.isEmpty) {
      return ValidationResult.error('Vui lòng nhập số tiền');
    }

    // Parse amount: remove non-digits
    final amountString = amountText.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(amountString);

    if (amount == null) {
      return ValidationResult.error('Số tiền không hợp lệ');
    }

    if (amount <= 0) {
      return ValidationResult.error('Số tiền phải lớn hơn 0');
    }

    return ValidationResult.success(amount);
  }

  /// Validate category selection
  static ValidationResult<bool> validateCategory(dynamic category) {
    if (category == null) {
      return ValidationResult.error('Vui lòng chọn danh mục');
    }
    return ValidationResult.success(true);
  }

  /// Validate note (optional field)
  static ValidationResult<String?> validateNote(String? note) {
    // Note is optional, always valid
    return ValidationResult.success(note?.trim());
  }

  /// Validate date
  static ValidationResult<DateTime> validateDate(DateTime? date) {
    if (date == null) {
      return ValidationResult.error('Vui lòng chọn ngày');
    }

    // Không cho phép ngày trong tương lai
    if (date.isAfter(DateTime.now())) {
      return ValidationResult.error('Không thể chọn ngày trong tương lai');
    }

    return ValidationResult.success(date);
  }
}

/// Generic validation result
class ValidationResult<T> {
  final bool isValid;
  final String? errorMessage;
  final T? value;

  ValidationResult.success(this.value)
      : isValid = true,
        errorMessage = null;

  ValidationResult.error(this.errorMessage)
      : isValid = false,
        value = null;
}
