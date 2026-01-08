import 'package:hive/hive.dart';

part 'savings_goal_model.g.dart';

@HiveType(typeId: 4)
class SavingsGoalModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double currentAmount;

  @HiveField(3)
  DateTime? deadline;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  String? iconName; // Material icon name

  @HiveField(6)
  int? colorValue; // Color value

  @HiveField(7)
  String? note;

  SavingsGoalModel({
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    required this.createdAt,
    this.iconName,
    this.colorValue,
    this.note,
  });

  // Tính % hoàn thành
  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  // Số tiền còn thiếu
  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0, double.infinity);
  }

  // Đã hoàn thành chưa
  bool get isCompleted => currentAmount >= targetAmount;

  // Số ngày còn lại
  int? get daysRemaining {
    if (deadline == null) return null;
    final diff = deadline!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  // Số tiền cần tiết kiệm mỗi ngày để đạt mục tiêu
  double? get dailySavingsNeeded {
    if (deadline == null || daysRemaining == null || daysRemaining == 0) {
      return null;
    }
    return remainingAmount / daysRemaining!;
  }

  // Số tiền cần tiết kiệm mỗi tháng
  double? get monthlySavingsNeeded {
    if (deadline == null || daysRemaining == null || daysRemaining == 0) {
      return null;
    }
    final monthsRemaining = daysRemaining! / 30;
    return monthsRemaining > 0 ? remainingAmount / monthsRemaining : null;
  }

  // Copy with method
  SavingsGoalModel copyWith({
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    DateTime? createdAt,
    String? iconName,
    int? colorValue,
    String? note,
  }) {
    return SavingsGoalModel(
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      note: note ?? this.note,
    );
  }
}
