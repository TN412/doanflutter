import '../../domain/enums/transaction_filter.dart';

/// Extension for UI labels
/// Tuân thủ Clean Architecture - Presentation concern ở Presentation layer
extension TransactionFilterExtension on TransactionFilter {
  /// Lấy label hiển thị cho UI
  String get label {
    switch (this) {
      case TransactionFilter.all:
        return 'Xem tất cả';
      case TransactionFilter.income:
        return 'Thu nhập';
      case TransactionFilter.expense:
        return 'Chi tiêu';
    }
  }
}
