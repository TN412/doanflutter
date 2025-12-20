import 'package:hive/hive.dart';
import 'category_model.dart';

part 'recurring_transaction_model.g.dart';

@HiveType(typeId: 3)
class RecurringTransactionModel extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  double amount;

  @HiveField(2)
  int categoryIndex;

  @HiveField(3)
  bool isIncome;

  @HiveField(4)
  String frequency; // 'daily', 'weekly', 'monthly', 'yearly'

  @HiveField(5)
  DateTime nextDate;

  @HiveField(6)
  bool isActive;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  String? note;

  RecurringTransactionModel({
    required this.description,
    required this.amount,
    required this.categoryIndex,
    required this.isIncome,
    required this.frequency,
    required this.nextDate,
    this.isActive = true,
    required this.createdAt,
    this.note,
  });

  // Tính ngày tiếp theo dựa trên frequency
  DateTime calculateNextDate() {
    switch (frequency) {
      case 'daily':
        return DateTime(nextDate.year, nextDate.month, nextDate.day + 1);
      case 'weekly':
        return DateTime(nextDate.year, nextDate.month, nextDate.day + 7);
      case 'monthly':
        return DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
      case 'yearly':
        return DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
      default:
        return nextDate;
    }
  }

  // Hiển thị frequency dạng tiếng Việt
  String get frequencyDisplay {
    switch (frequency) {
      case 'daily':
        return 'Hàng ngày';
      case 'weekly':
        return 'Hàng tuần';
      case 'monthly':
        return 'Hàng tháng';
      case 'yearly':
        return 'Hàng năm';
      default:
        return frequency;
    }
  }

  // Copy with method
  RecurringTransactionModel copyWith({
    String? description,
    double? amount,
    int? categoryIndex,
    bool? isIncome,
    String? frequency,
    DateTime? nextDate,
    bool? isActive,
    DateTime? createdAt,
    String? note,
  }) {
    return RecurringTransactionModel(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      categoryIndex: categoryIndex ?? this.categoryIndex,
      isIncome: isIncome ?? this.isIncome,
      frequency: frequency ?? this.frequency,
      nextDate: nextDate ?? this.nextDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }
}
