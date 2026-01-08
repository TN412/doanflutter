import 'package:flutter/material.dart';
import '../domain/entities/transaction_model.dart';
import '../domain/entities/category_model.dart';
import '../domain/entities/recurring_transaction_model.dart';
import '../domain/entities/savings_goal_model.dart';
import '../infrastructure/database_service.dart';
import '../infrastructure/notification_service.dart';
import '../domain/repositories/i_transaction_repository.dart';
import '../domain/repositories/i_category_repository.dart';
import '../domain/repositories/i_settings_repository.dart';
import '../data/repositories/transaction_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/enums/transaction_filter.dart';

class ExpenseProvider extends ChangeNotifier {
  // Repositories (Dependency Injection)
  late final ITransactionRepository _transactionRepository;
  late final ICategoryRepository _categoryRepository;
  late final ISettingsRepository _settingsRepository;

  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  List<RecurringTransactionModel> _recurringTransactions = [];
  List<SavingsGoalModel> _savingsGoals = [];
  DateTime _selectedMonth = DateTime.now();
  String _selectedFilter = 'month'; // 'week', 'month'
  TransactionFilter _transactionFilter =
      TransactionFilter.all; // Filter: all/income/expense

  // Constructor with dependency injection
  ExpenseProvider({
    ITransactionRepository? transactionRepository,
    ICategoryRepository? categoryRepository,
    ISettingsRepository? settingsRepository,
  }) {
    // Use provided repositories or create default ones
    _transactionRepository = transactionRepository ?? TransactionRepository();
    _categoryRepository = categoryRepository ?? CategoryRepository();
    _settingsRepository = settingsRepository ?? SettingsRepository();
  }

  // Getters
  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  List<RecurringTransactionModel> get recurringTransactions =>
      _recurringTransactions;
  List<SavingsGoalModel> get savingsGoals => _savingsGoals;
  DateTime get selectedMonth => _selectedMonth;
  String get selectedFilter => _selectedFilter;
  TransactionFilter get transactionFilter => _transactionFilter;

  // Khởi tạo và load dữ liệu
  Future<void> loadData() async {
    _transactions = await _transactionRepository.getAllTransactions();
    _categories = await _categoryRepository.getAllCategories();
    _recurringTransactions = DatabaseService.getAllRecurringTransactions();
    _savingsGoals = DatabaseService.getAllSavingsGoals();

    // Kiểm tra recurring transactions cần tạo
    await _checkRecurringTransactions();

    // Kiểm tra cảnh báo ngân sách
    await _checkBudgetAlert();

    notifyListeners();
  }

  // ==================== TÍNH TOÁN TỔNG ====================

  // Tổng thu nhập
  double get totalIncome {
    return _transactions
        .where((transaction) => transaction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Tổng chi tiêu
  double get totalExpense {
    return _transactions
        .where((transaction) => !transaction.isIncome)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Số dư hiện tại
  double get currentBalance {
    return totalIncome - totalExpense;
  }

  // ==================== LỌC THEO THỜI GIAN ====================

  // Lấy giao dịch theo tháng được chọn
  List<TransactionModel> getTransactionsByMonth(DateTime month) {
    return _transactions.where((transaction) {
      return transaction.date.year == month.year &&
          transaction.date.month == month.month;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sắp xếp mới nhất trước
  }

  // Lấy giao dịch theo tuần
  List<TransactionModel> getTransactionsByWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return _transactions.where((transaction) {
      return transaction.date
              .isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Lấy giao dịch CHỈ lọc theo THỜI GIAN (cho tính toán summary)
  // Tuân thủ SRP - tách riêng filter theo time và type
  List<TransactionModel> get timeFilteredTransactions {
    if (_selectedFilter == 'week') {
      return getTransactionsByWeek(_selectedMonth);
    } else {
      return getTransactionsByMonth(_selectedMonth);
    }
  }

  // Lấy giao dịch để HIỂN THỊ (lọc theo time + type)
  // Filter type CHỈ ảnh hưởng đến danh sách, KHÔNG ảnh hưởng summary
  List<TransactionModel> get displayTransactions {
    return _applyTransactionTypeFilter(timeFilteredTransactions);
  }

  // DEPRECATED: Giữ lại để backward compatibility
  List<TransactionModel> get filteredTransactions => displayTransactions;

  // Helper method: Lọc theo loại giao dịch (all/income/expense)
  // Tuân thủ Single Responsibility - tách logic filter riêng
  List<TransactionModel> _applyTransactionTypeFilter(
      List<TransactionModel> transactions) {
    switch (_transactionFilter) {
      case TransactionFilter.all:
        return transactions;
      case TransactionFilter.income:
        return transactions.where((t) => t.isIncome).toList();
      case TransactionFilter.expense:
        return transactions.where((t) => !t.isIncome).toList();
    }
  }

  // Thay đổi tháng được chọn
  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
  }

  // Thay đổi filter (week/month)
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Thay đổi transaction filter (all/income/expense)
  // Tuân thủ OCP - có thể mở rộng thêm filter mới
  void setTransactionFilter(TransactionFilter filter) {
    _transactionFilter = filter;
    notifyListeners();
  }

  // ==================== TÍNH TOÁN CHO DASHBOARD ====================

  // Thu nhập trong khoảng thời gian (KHÔNG bị ảnh hưởng bởi TransactionFilter)
  // Tuân thủ SRP - Summary luôn hiển thị tổng, bất kể filter nào đang chọn
  double get filteredIncome {
    return timeFilteredTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Chi tiêu trong khoảng thời gian (KHÔNG bị ảnh hưởng bởi TransactionFilter)
  double get filteredExpense {
    return timeFilteredTransactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // ==================== BIỂU ĐỒ TRÒN (PIE CHART) ====================

  // Tính data cho pie chart - nhóm chi tiêu theo category
  // Dùng timeFilteredTransactions vì pie chart KHÔNG bị ảnh hưởng bởi filter type
  Map<String, double> getExpensesByCategory() {
    final expenseTransactions =
        timeFilteredTransactions.where((t) => !t.isIncome).toList();

    Map<String, double> categoryExpenses = {};

    for (var transaction in expenseTransactions) {
      if (categoryExpenses.containsKey(transaction.categoryName)) {
        categoryExpenses[transaction.categoryName] =
            categoryExpenses[transaction.categoryName]! + transaction.amount;
      } else {
        categoryExpenses[transaction.categoryName] = transaction.amount;
      }
    }

    return categoryExpenses;
  }

  // Lấy màu sắc của category
  Color getCategoryColor(String categoryName) {
    final category = _categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => CategoryModel(
        name: categoryName,
        iconCodePoint: Icons.help_outline.codePoint,
        colorValue: Colors.grey.value,
        isIncome: false,
      ),
    );
    return category.color;
  }

  // Lấy icon của category (tuân thủ SRP - Provider lo truy xuất data)
  IconData getCategoryIcon(String categoryName) {
    final category = _categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => CategoryModel(
        name: categoryName,
        iconCodePoint: Icons.help_outline.codePoint,
        colorValue: Colors.grey.value,
        isIncome: false,
      ),
    );
    return category.icon;
  }

  // ==================== BIỂU ĐỒ DÒNG TIỀN (CASHFLOW) ====================

  // Tính data cho cashflow chart theo từng ngày trong tháng
  Map<int, Map<String, double>> getCashflowByDay() {
    final monthTransactions = getTransactionsByMonth(_selectedMonth);
    Map<int, Map<String, double>> dailyData = {};

    for (var transaction in monthTransactions) {
      int day = transaction.date.day;

      if (!dailyData.containsKey(day)) {
        dailyData[day] = {'income': 0.0, 'expense': 0.0};
      }

      if (transaction.isIncome) {
        dailyData[day]!['income'] =
            dailyData[day]!['income']! + transaction.amount;
      } else {
        dailyData[day]!['expense'] =
            dailyData[day]!['expense']! + transaction.amount;
      }
    }

    return dailyData;
  }

  // ==================== QUẢN LÝ DANH MỤC ====================

  // Lấy danh mục chi tiêu
  List<CategoryModel> get expenseCategories {
    return _categories.where((cat) => !cat.isIncome).toList();
  }

  // Lấy danh mục thu nhập
  List<CategoryModel> get incomeCategories {
    return _categories.where((cat) => cat.isIncome).toList();
  }

  // Thêm danh mục mới
  Future<void> addCategory(CategoryModel category) async {
    await _categoryRepository.addCategory(category);
    await loadData();
  }

  // Xóa danh mục
  Future<void> deleteCategory(int index) async {
    await _categoryRepository.deleteCategory(index);
    await loadData();
  }

  // Kiểm tra danh mục có đang được sử dụng
  bool isCategoryInUse(String categoryName) {
    return _categoryRepository.isCategoryInUse(categoryName);
  }

  // ==================== CRUD GIAO DỊCH ====================

  // Thêm giao dịch mới
  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactionRepository.addTransaction(transaction);
    await loadData();
  }

  // Cập nhật giao dịch
  Future<void> updateTransaction(
      int index, TransactionModel transaction) async {
    await _transactionRepository.updateTransaction(index, transaction);
    await loadData();
  }

  // Xóa giao dịch
  Future<void> deleteTransaction(int index) async {
    await _transactionRepository.deleteTransaction(index);
    await loadData();
  }

  // Tìm index của giao dịch theo ID
  int findTransactionIndex(String id) {
    return _transactionRepository.findTransactionIndexById(id);
  }

  // ==================== TÌM KIẾM ====================

  // Tìm kiếm giao dịch theo ghi chú hoặc danh mục
  List<TransactionModel> searchTransactions(String query) {
    if (query.isEmpty) return _transactions;

    final lowerQuery = query.toLowerCase();
    return _transactions.where((transaction) {
      final note = transaction.note?.toLowerCase() ?? '';
      final category = transaction.categoryName.toLowerCase();
      return note.contains(lowerQuery) || category.contains(lowerQuery);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // ==================== NGÂN SÁCH ====================

  // Lấy ngân sách tháng
  double get monthlyBudget {
    return _settingsRepository.getMonthlyBudget();
  }

  // Đặt ngân sách tháng
  Future<void> setMonthlyBudget(double budget) async {
    await _settingsRepository.setMonthlyBudget(budget);
    notifyListeners();
  }

  // Kiểm tra có vượt ngân sách không
  bool get isOverBudget {
    if (monthlyBudget == 0) return false;
    return filteredExpense > monthlyBudget;
  }

  // Phần trăm đã sử dụng ngân sách
  double get budgetUsagePercentage {
    if (monthlyBudget == 0) return 0;
    return (filteredExpense / monthlyBudget * 100).clamp(0, 100);
  }

  // ==================== NHÓM GIAO DỊCH THEO NGÀY ====================

  // Nhóm giao dịch theo ngày để hiển thị trong list
  Map<String, List<TransactionModel>> get transactionsGroupedByDate {
    final Map<String, List<TransactionModel>> grouped = {};

    for (var transaction in filteredTransactions) {
      final dateKey = _formatDateKey(transaction.date);

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  // Format date key cho nhóm
  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Hôm nay';
    } else if (transactionDate == yesterday) {
      return 'Hôm qua';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // ==================== BACKUP & RESTORE ====================

  // Export dữ liệu
  Future<Map<String, dynamic>> exportData() async {
    return await _settingsRepository.exportToJson();
  }

  // Import dữ liệu
  Future<void> importData(Map<String, dynamic> data) async {
    await _settingsRepository.importFromJson(data);
    await loadData();
  }

  // Reset toàn bộ dữ liệu
  Future<void> resetAllData() async {
    await _settingsRepository.resetDatabase();
    await loadData();
  }

  // ==================== RECURRING TRANSACTIONS ====================

  // Kiểm tra và tạo giao dịch định kỳ đến hạn
  Future<void> _checkRecurringTransactions() async {
    final activeRecurring = DatabaseService.getActiveRecurringTransactions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var recurring in activeRecurring) {
      final nextDate = DateTime(
        recurring.nextDate.year,
        recurring.nextDate.month,
        recurring.nextDate.day,
      );

      // Nếu ngày tiếp theo <= hôm nay, tạo giao dịch
      if (nextDate.isBefore(today) || nextDate.isAtSameMomentAs(today)) {
        // Tạo giao dịch mới từ recurring
        final transaction = TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: recurring.amount,
          categoryName: _getCategoryNameByIndex(recurring.categoryIndex),
          date: recurring.nextDate,
          note: '${recurring.description} (Tự động)',
          isIncome: recurring.isIncome,
        );

        await DatabaseService.addTransaction(transaction);

        // Cập nhật nextDate
        recurring.nextDate = recurring.calculateNextDate();
        final index = _recurringTransactions.indexOf(recurring);
        if (index >= 0) {
          await DatabaseService.updateRecurringTransaction(index, recurring);
        }

        // Đặt nhắc nhở cho lần tiếp theo
        await NotificationService.scheduleRecurringReminder(
          index,
          recurring.description,
          recurring.nextDate,
        );
      }
    }
  }

  // Thêm recurring transaction
  Future<void> addRecurringTransaction(
      RecurringTransactionModel recurring) async {
    await DatabaseService.addRecurringTransaction(recurring);

    // Đặt nhắc nhở
    final index = _recurringTransactions.length;
    await NotificationService.scheduleRecurringReminder(
      index,
      recurring.description,
      recurring.nextDate,
    );

    await loadData();
  }

  // Cập nhật recurring transaction
  Future<void> updateRecurringTransaction(
    int index,
    RecurringTransactionModel recurring,
  ) async {
    await DatabaseService.updateRecurringTransaction(index, recurring);

    if (recurring.isActive) {
      await NotificationService.scheduleRecurringReminder(
        index,
        recurring.description,
        recurring.nextDate,
      );
    } else {
      await NotificationService.cancelRecurringReminder(index);
    }

    await loadData();
  }

  // Xóa recurring transaction
  Future<void> deleteRecurringTransaction(int index) async {
    await NotificationService.cancelRecurringReminder(index);
    await DatabaseService.deleteRecurringTransaction(index);
    await loadData();
  }

  // Bật/tắt recurring transaction
  Future<void> toggleRecurringTransaction(int index) async {
    final recurring = _recurringTransactions[index];
    recurring.isActive = !recurring.isActive;
    await updateRecurringTransaction(index, recurring);
  }

  // ==================== SAVINGS GOALS ====================

  // Thêm savings goal
  Future<void> addSavingsGoal(SavingsGoalModel goal) async {
    await DatabaseService.addSavingsGoal(goal);
    await loadData();
  }

  // Cập nhật savings goal
  Future<void> updateSavingsGoal(int index, SavingsGoalModel goal) async {
    await DatabaseService.updateSavingsGoal(index, goal);
    await loadData();
  }

  // Xóa savings goal
  Future<void> deleteSavingsGoal(int index) async {
    await DatabaseService.deleteSavingsGoal(index);
    await loadData();
  }

  // Thêm tiền vào savings goal
  Future<void> addToSavingsGoal(int index, double amount) async {
    await DatabaseService.addToSavingsGoal(index, amount);
    await loadData();
  }

  // Lấy savings goals đang hoạt động
  List<SavingsGoalModel> get activeSavingsGoals {
    return _savingsGoals.where((g) => !g.isCompleted).toList();
  }

  // ==================== NOTIFICATIONS ====================

  // Kiểm tra cảnh báo ngân sách
  Future<void> _checkBudgetAlert() async {
    if (monthlyBudget > 0) {
      await NotificationService.checkBudgetAlert(
        filteredExpense,
        monthlyBudget,
      );
    }
  }

  // Đặt nhắc nhở hàng ngày
  Future<void> setDailyReminder(bool enabled,
      {int hour = 20, int minute = 0}) async {
    await DatabaseService.setDailyReminderEnabled(enabled);
    if (enabled) {
      await DatabaseService.setReminderTime(hour, minute);
      await NotificationService.scheduleDailyReminder();
    } else {
      await NotificationService.cancelDailyReminder();
    }
    notifyListeners();
  }

  // Đặt cảnh báo ngân sách
  Future<void> setBudgetAlert(bool enabled) async {
    await DatabaseService.setBudgetAlertEnabled(enabled);
    notifyListeners();
  }

  // Getters cho notification settings
  bool get dailyReminderEnabled => DatabaseService.getDailyReminderEnabled();
  bool get budgetAlertEnabled => DatabaseService.getBudgetAlertEnabled();
  Map<String, int> get reminderTime => DatabaseService.getReminderTime();

  // ==================== HELPER ====================

  String _getCategoryNameByIndex(int index) {
    if (index >= 0 && index < _categories.length) {
      return _categories[index].name;
    }
    return 'Khác';
  }
}
