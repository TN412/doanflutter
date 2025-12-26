import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/recurring_transaction_model.dart';
import '../models/savings_goal_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  // Tên các box
  static const String transactionBoxName = 'transactions';
  static const String categoryBoxName = 'categories';
  static const String settingsBoxName = 'settings';
  static const String recurringBoxName = 'recurring_transactions';
  static const String savingsGoalsBoxName = 'savings_goals';

  // Lazy box references
  static Box<TransactionModel>? _transactionBox;
  static Box<CategoryModel>? _categoryBox;
  static Box? _settingsBox;
  static Box<RecurringTransactionModel>? _recurringBox;
  static Box<SavingsGoalModel>? _savingsGoalsBox;

  // Khởi tạo Hive và mở các box
  static Future<void> init() async {
    await Hive.initFlutter();

    // Đăng ký adapters
    Hive.registerAdapter(TransactionModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());
    Hive.registerAdapter(RecurringTransactionModelAdapter());
    Hive.registerAdapter(SavingsGoalModelAdapter());
    Hive.registerAdapter(UserModelAdapter());

    // Mở các box
    _transactionBox = await Hive.openBox<TransactionModel>(transactionBoxName);
    _categoryBox = await Hive.openBox<CategoryModel>(categoryBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);
    _recurringBox = await Hive.openBox<RecurringTransactionModel>(recurringBoxName);
    _savingsGoalsBox = await Hive.openBox<SavingsGoalModel>(savingsGoalsBoxName);

    // Khởi tạo danh mục mặc định nếu chưa có
    await _initDefaultCategories();
  }

  // Khởi tạo danh mục mặc định lần đầu
  static Future<void> _initDefaultCategories() async {
    if (_categoryBox!.isEmpty) {
      final defaultCategories = [
        ...CategoryModel.getDefaultExpenseCategories(),
        ...CategoryModel.getDefaultIncomeCategories(),
      ];

      for (var category in defaultCategories) {
        await _categoryBox!.add(category);
      }
    }
  }

  // ==================== TRANSACTION CRUD ====================

  // Thêm giao dịch mới
  static Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionBox!.add(transaction);
  }

  // Lấy tất cả giao dịch
  static List<TransactionModel> getAllTransactions() {
    return _transactionBox!.values.toList();
  }

  // Lấy giao dịch theo index
  static TransactionModel? getTransaction(int index) {
    return _transactionBox!.getAt(index);
  }

  // Cập nhật giao dịch
  static Future<void> updateTransaction(int index, TransactionModel transaction) async {
    await _transactionBox!.putAt(index, transaction);
  }

  // Xóa giao dịch
  static Future<void> deleteTransaction(int index) async {
    await _transactionBox!.deleteAt(index);
  }

  // Xóa tất cả giao dịch
  static Future<void> deleteAllTransactions() async {
    await _transactionBox!.clear();
  }

  // ==================== CATEGORY CRUD ====================

  // Thêm danh mục mới
  static Future<void> addCategory(CategoryModel category) async {
    await _categoryBox!.add(category);
  }

  // Lấy tất cả danh mục
  static List<CategoryModel> getAllCategories() {
    return _categoryBox!.values.toList();
  }

  // Lấy danh mục chi tiêu
  static List<CategoryModel> getExpenseCategories() {
    return _categoryBox!.values.where((cat) => !cat.isIncome).toList();
  }

  // Lấy danh mục thu nhập
  static List<CategoryModel> getIncomeCategories() {
    return _categoryBox!.values.where((cat) => cat.isIncome).toList();
  }

  // Cập nhật danh mục
  static Future<void> updateCategory(int index, CategoryModel category) async {
    await _categoryBox!.putAt(index, category);
  }

  // Xóa danh mục
  static Future<void> deleteCategory(int index) async {
    await _categoryBox!.deleteAt(index);
  }

  // Kiểm tra danh mục có đang được sử dụng không
  static bool isCategoryInUse(String categoryName) {
    return _transactionBox!.values
        .any((transaction) => transaction.categoryName == categoryName);
  }

  // ==================== SETTINGS ====================

  // Lưu ngân sách tháng
  static Future<void> setMonthlyBudget(double budget) async {
    await _settingsBox!.put('monthlyBudget', budget);
  }

  // Lấy ngân sách tháng
  static double getMonthlyBudget() {
    return _settingsBox!.get('monthlyBudget', defaultValue: 0.0);
  }

  // ==================== BACKUP & RESTORE ====================

  // Export tất cả dữ liệu sang JSON
  static Map<String, dynamic> exportToJson() {
    return {
      'transactions': _transactionBox!.values.map((t) => t.toJson()).toList(),
      'categories': _categoryBox!.values.map((c) => c.toJson()).toList(),
      'settings': _settingsBox!.toMap(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  // Import dữ liệu từ JSON
  static Future<void> importFromJson(Map<String, dynamic> data) async {
    // Xóa dữ liệu cũ
    await _transactionBox!.clear();
    await _categoryBox!.clear();

    // Import transactions
    if (data['transactions'] != null) {
      for (var transJson in data['transactions']) {
        await _transactionBox!.add(TransactionModel.fromJson(transJson));
      }
    }

    // Import categories
    if (data['categories'] != null) {
      for (var catJson in data['categories']) {
        await _categoryBox!.add(CategoryModel.fromJson(catJson));
      }
    }

    // Import settings
    if (data['settings'] != null) {
      for (var entry in (data['settings'] as Map).entries) {
        await _settingsBox!.put(entry.key, entry.value);
      }
    }
  }

  // Reset toàn bộ database
  static Future<void> resetDatabase() async {
    await _transactionBox!.clear();
    await _categoryBox!.clear();
    await _settingsBox!.clear();
    await _recurringBox!.clear();
    await _savingsGoalsBox!.clear();
    await _initDefaultCategories();
  }

  // Đóng tất cả các box
  static Future<void> close() async {
    await _transactionBox?.close();
    await _categoryBox?.close();
    await _settingsBox?.close();
    await _recurringBox?.close();
    await _savingsGoalsBox?.close();
  }

  // ==================== RECURRING TRANSACTIONS ====================

  // Thêm giao dịch định kỳ
  static Future<void> addRecurringTransaction(RecurringTransactionModel recurring) async {
    await _recurringBox!.add(recurring);
  }

  // Lấy tất cả giao dịch định kỳ
  static List<RecurringTransactionModel> getAllRecurringTransactions() {
    return _recurringBox!.values.toList();
  }

  // Lấy giao dịch định kỳ đang hoạt động
  static List<RecurringTransactionModel> getActiveRecurringTransactions() {
    return _recurringBox!.values.where((r) => r.isActive).toList();
  }

  // Cập nhật giao dịch định kỳ
  static Future<void> updateRecurringTransaction(int index, RecurringTransactionModel recurring) async {
    await _recurringBox!.putAt(index, recurring);
  }

  // Xóa giao dịch định kỳ
  static Future<void> deleteRecurringTransaction(int index) async {
    await _recurringBox!.deleteAt(index);
  }

  // ==================== SAVINGS GOALS ====================

  // Thêm mục tiêu tiết kiệm
  static Future<void> addSavingsGoal(SavingsGoalModel goal) async {
    await _savingsGoalsBox!.add(goal);
  }

  // Lấy tất cả mục tiêu tiết kiệm
  static List<SavingsGoalModel> getAllSavingsGoals() {
    return _savingsGoalsBox!.values.toList();
  }

  // Lấy mục tiêu đang hoạt động (chưa hoàn thành)
  static List<SavingsGoalModel> getActiveSavingsGoals() {
    return _savingsGoalsBox!.values.where((g) => !g.isCompleted).toList();
  }

  // Cập nhật mục tiêu tiết kiệm
  static Future<void> updateSavingsGoal(int index, SavingsGoalModel goal) async {
    await _savingsGoalsBox!.putAt(index, goal);
  }

  // Xóa mục tiêu tiết kiệm
  static Future<void> deleteSavingsGoal(int index) async {
    await _savingsGoalsBox!.deleteAt(index);
  }

  // Thêm tiền vào mục tiêu
  static Future<void> addToSavingsGoal(int index, double amount) async {
    final goal = _savingsGoalsBox!.getAt(index);
    if (goal != null) {
      goal.currentAmount += amount;
      await goal.save();
    }
  }

  // ==================== NOTIFICATION SETTINGS ====================

  // Lưu cài đặt nhắc nhở hàng ngày
  static Future<void> setDailyReminderEnabled(bool enabled) async {
    await _settingsBox!.put('dailyReminderEnabled', enabled);
  }

  static bool getDailyReminderEnabled() {
    return _settingsBox!.get('dailyReminderEnabled', defaultValue: true);
  }

  // Lưu giờ nhắc nhở
  static Future<void> setReminderTime(int hour, int minute) async {
    await _settingsBox!.put('reminderHour', hour);
    await _settingsBox!.put('reminderMinute', minute);
  }

  static Map<String, int> getReminderTime() {
    return {
      'hour': _settingsBox!.get('reminderHour', defaultValue: 20),
      'minute': _settingsBox!.get('reminderMinute', defaultValue: 0),
    };
  }

  // Lưu cài đặt cảnh báo vượt ngân sách
  static Future<void> setBudgetAlertEnabled(bool enabled) async {
    await _settingsBox!.put('budgetAlertEnabled', enabled);
  }

  static bool getBudgetAlertEnabled() {
    return _settingsBox!.get('budgetAlertEnabled', defaultValue: true);
  }
}
