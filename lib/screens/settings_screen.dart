import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_helper.dart';
import '../services/notification_service.dart';
import 'recurring_transactions_screen.dart';
import 'savings_goals_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return ListView(
            children: [
              // Budget Section
              _buildSectionHeader(context, 'Ngân sách'),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.green),
                ),
                title: const Text('Ngân sách tháng'),
                subtitle: Text(
                  provider.monthlyBudget > 0
                      ? CurrencyHelper.format(provider.monthlyBudget)
                      : 'Chưa đặt giới hạn',
                ),
                trailing: const Icon(Icons.edit),
                onTap: () => _showBudgetDialog(context, provider),
              ),

              // Notifications Section
              _buildSectionHeader(context, 'Thông báo'),
              SwitchListTile(
                secondary: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.2),
                  child: const Icon(Icons.notifications, color: Colors.purple),
                ),
                title: const Text('Nhắc nhở hàng ngày'),
                subtitle: const Text('Nhắc ghi chi tiêu mỗi ngày'),
                value: provider.dailyReminderEnabled,
                onChanged: (value) {
                  provider.setDailyReminder(value);
                },
              ),
              SwitchListTile(
                secondary: CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  child: const Icon(Icons.warning, color: Colors.orange),
                ),
                title: const Text('Cảnh báo ngân sách'),
                subtitle: const Text('Thông báo khi vượt ngân sách'),
                value: provider.budgetAlertEnabled,
                onChanged: (value) {
                  provider.setBudgetAlert(value);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: const Icon(Icons.access_time, color: Colors.blue),
                ),
                title: const Text('Giờ nhắc nhở'),
                subtitle: Text(
                  '${provider.reminderTime['hour']!.toString().padLeft(2, '0')}:'
                  '${provider.reminderTime['minute']!.toString().padLeft(2, '0')}',
                ),
                onTap: () => _showTimePickerDialog(context, provider),
              ),

              // Features Section
              _buildSectionHeader(context, 'Tính năng nâng cao'),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.indigo.withOpacity(0.2),
                  child: const Icon(Icons.repeat, color: Colors.indigo),
                ),
                title: const Text('Giao dịch định kỳ'),
                subtitle: Text('${provider.recurringTransactions.length} giao dịch'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecurringTransactionsScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal.withOpacity(0.2),
                  child: const Icon(Icons.savings, color: Colors.teal),
                ),
                title: const Text('Mục tiêu tiết kiệm'),
                subtitle: Text('${provider.savingsGoals.length} mục tiêu'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavingsGoalsScreen(),
                    ),
                  );
                },
              ),

              // Data Management Section
              _buildSectionHeader(context, 'Quản lý dữ liệu'),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.2),
                  child: const Icon(Icons.file_upload, color: Colors.blue),
                ),
                title: const Text('Sao lưu dữ liệu'),
                subtitle: const Text('Xuất dữ liệu ra file JSON'),
                onTap: () => _exportData(context, provider),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  child: const Icon(Icons.file_download, color: Colors.orange),
                ),
                title: const Text('Khôi phục dữ liệu'),
                subtitle: const Text('Nhập dữ liệu từ file JSON'),
                onTap: () => _importData(context, provider),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  child: const Icon(Icons.delete_forever, color: Colors.red),
                ),
                title: const Text('Xóa toàn bộ dữ liệu'),
                subtitle: const Text('Reset ứng dụng về ban đầu'),
                onTap: () => _showResetConfirmDialog(context, provider),
              ),

              // Statistics Section
              _buildSectionHeader(context, 'Thống kê'),
              ListTile(
                leading: const Icon(Icons.data_usage),
                title: const Text('Tổng số giao dịch'),
                trailing: Text(
                  '${provider.transactions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Tổng số danh mục'),
                trailing: Text(
                  '${provider.categories.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              // About Section
              _buildSectionHeader(context, 'Thông tin'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Về ứng dụng'),
                subtitle: const Text('Expense Tracker v1.0.0'),
                onTap: () => _showAboutDialog(context),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Phát triển bởi'),
                subtitle: const Text('Flutter Developer'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Time picker dialog
  static void _showTimePickerDialog(BuildContext context, ExpenseProvider provider) async {
    final time = provider.reminderTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: time['hour']!, minute: time['minute']!),
    );

    if (picked != null) {
      provider.setDailyReminder(true, hour: picked.hour, minute: picked.minute);
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, ExpenseProvider provider) {
    final controller = TextEditingController(
      text: provider.monthlyBudget > 0 
          ? provider.monthlyBudget.toStringAsFixed(0) 
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt ngân sách tháng'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Nhập số tiền',
            suffixText: '₫',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final budget = double.tryParse(controller.text) ?? 0.0;
              provider.setMonthlyBudget(budget);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    budget > 0
                        ? 'Đã đặt ngân sách ${CurrencyHelper.format(budget)}'
                        : 'Đã xóa giới hạn ngân sách',
                  ),
                ),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, ExpenseProvider provider) async {
    try {
      // Lấy dữ liệu
      final data = provider.exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Lấy thư mục Downloads
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'expense_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      // Ghi file
      await file.writeAsString(jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã sao lưu thành công!\nFile: $fileName'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi sao lưu: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, ExpenseProvider provider) async {
    try {
      // Chọn file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      // Đọc file
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;

      // Xác nhận trước khi import
      if (context.mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận khôi phục'),
            content: const Text(
              'Dữ liệu hiện tại sẽ bị thay thế hoàn toàn. '
              'Bạn có chắc chắn muốn tiếp tục?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Khôi phục'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await provider.importData(data);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Khôi phục dữ liệu thành công!')),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi khôi phục: $e')),
        );
      }
    }
  }

  void _showResetConfirmDialog(BuildContext context, ExpenseProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xác nhận xóa dữ liệu'),
        content: const Text(
          'Hành động này sẽ xóa vĩnh viễn:\n'
          '• Tất cả giao dịch\n'
          '• Danh mục tùy chỉnh\n'
          '• Cài đặt ngân sách\n\n'
          'Dữ liệu không thể khôi phục. Bạn có chắc chắn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await provider.resetAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa toàn bộ dữ liệu'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Expense Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      children: [
        const Text(
          'Ứng dụng quản lý chi tiêu cá nhân offline.\n\n'
          'Tính năng:\n'
          '• Quản lý giao dịch thu chi\n'
          '• Thống kê chi tiêu theo danh mục\n'
          '• Đặt ngân sách tháng\n'
          '• Sao lưu và khôi phục dữ liệu\n\n'
          'Phát triển với Flutter & Provider.',
        ),
      ],
    );
  }
}
