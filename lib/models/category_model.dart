import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late int iconCodePoint; // Lưu icon code point

  @HiveField(2)
  late int colorValue; // Lưu màu dưới dạng int

  @HiveField(3)
  late bool isIncome; // true: thu nhập, false: chi tiêu

  CategoryModel({
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.isIncome,
  });

  // Helper getter để lấy IconData từ code point
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  // Helper getter để lấy Color từ value
  Color get color => Color(colorValue);

  // Convert to Map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
      'isIncome': isIncome,
    };
  }

  // Tạo từ Map
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'],
      iconCodePoint: json['iconCodePoint'],
      colorValue: json['colorValue'],
      isIncome: json['isIncome'],
    );
  }

  // Danh mục mặc định cho chi tiêu
  static List<CategoryModel> getDefaultExpenseCategories() {
    return [
      CategoryModel(
        name: 'Ăn uống',
        iconCodePoint: Icons.restaurant.codePoint,
        colorValue: Colors.orange.value,
        isIncome: false,
      ),
      CategoryModel(
        name: 'Di chuyển',
        iconCodePoint: Icons.directions_car.codePoint,
        colorValue: Colors.blue.value,
        isIncome: false,
      ),
      CategoryModel(
        name: 'Mua sắm',
        iconCodePoint: Icons.shopping_bag.codePoint,
        colorValue: Colors.pink.value,
        isIncome: false,
      ),
      CategoryModel(
        name: 'Giải trí',
        iconCodePoint: Icons.movie.codePoint,
        colorValue: Colors.purple.value,
        isIncome: false,
      ),
      CategoryModel(
        name: 'Sức khỏe',
        iconCodePoint: Icons.local_hospital.codePoint,
        colorValue: Colors.red.value,
        isIncome: false,
      ),
      CategoryModel(
        name: 'Giáo dục',
        iconCodePoint: Icons.school.codePoint,
        colorValue: Colors.indigo.value,
        isIncome: false,
      ),
      CategoryModel(
        name: 'Hóa đơn',
        iconCodePoint: Icons.receipt.codePoint,
        colorValue: Colors.brown.value,
        isIncome: false,
      ),
      CategoryModel(
        name: 'Khác',
        iconCodePoint: Icons.more_horiz.codePoint,
        colorValue: Colors.grey.value,
        isIncome: false,
      ),
    ];
  }

  // Danh mục mặc định cho thu nhập
  static List<CategoryModel> getDefaultIncomeCategories() {
    return [
      CategoryModel(
        name: 'Lương',
        iconCodePoint: Icons.account_balance_wallet.codePoint,
        colorValue: Colors.green.value,
        isIncome: true,
      ),
      CategoryModel(
        name: 'Thưởng',
        iconCodePoint: Icons.card_giftcard.codePoint,
        colorValue: Colors.teal.value,
        isIncome: true,
      ),
      CategoryModel(
        name: 'Đầu tư',
        iconCodePoint: Icons.trending_up.codePoint,
        colorValue: Colors.lightGreen.value,
        isIncome: true,
      ),
      CategoryModel(
        name: 'Khác',
        iconCodePoint: Icons.attach_money.codePoint,
        colorValue: Colors.greenAccent.value,
        isIncome: true,
      ),
    ];
  }
}
