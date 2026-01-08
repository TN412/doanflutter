import 'package:hive/hive.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late double amount;

  @HiveField(2)
  late DateTime date;

  @HiveField(3)
  late bool isIncome;

  @HiveField(4)
  late String categoryName;

  @HiveField(5)
  String? note;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.categoryName,
    this.note,
  });

  // Phương thức tiện ích để tạo ID duy nhất
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Convert to Map để export JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
      'categoryName': categoryName,
      'note': note,
    };
  }

  // Tạo từ Map khi import JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      isIncome: json['isIncome'],
      categoryName: json['categoryName'],
      note: json['note'],
    );
  }
}
