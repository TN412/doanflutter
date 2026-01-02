import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/recurring_transaction_model.dart';
import '../utils/currency_helper.dart';
import '../utils/date_helper.dart';

class RecurringTransactionsScreen extends StatelessWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch định kỳ'),
        centerTitle: true,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final recurring = provider.recurringTransactions;

          if (recurring.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.repeat, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có giao dịch định kỳ',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recurring.length,
            itemBuilder: (context, index) {
              final item = recurring[index];
              return _buildRecurringCard(context, provider, item, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecurringCard(
    BuildContext context,
    ExpenseProvider provider,
    RecurringTransactionModel item,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isIncome
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          child: Icon(
            item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: item.isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          item.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${item.frequencyDisplay} • ${CurrencyHelper.format(item.amount)}'),
            Text('Tiếp theo: ${DateHelper.format(item.nextDate)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: item.isActive,
              onChanged: (value) {
                provider.toggleRecurringTransaction(index);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, provider, index),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final descController = TextEditingController();
    final amountController = TextEditingController();
    bool isIncome = false;
    String frequency = 'monthly';
    DateTime nextDate = DateTime.now();
    int selectedCategory = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm giao dịch định kỳ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                ),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Số tiền'),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  title: const Text('Thu nhập'),
                  value: isIncome,
                  onChanged: (value) => setState(() => isIncome = value),
                ),
                DropdownButtonFormField<String>(
                  value: frequency,
                  decoration: const InputDecoration(labelText: 'Tần suất'),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Hàng ngày')),
                    DropdownMenuItem(value: 'weekly', child: Text('Hàng tuần')),
                    DropdownMenuItem(
                        value: 'monthly', child: Text('Hàng tháng')),
                    DropdownMenuItem(value: 'yearly', child: Text('Hàng năm')),
                  ],
                  onChanged: (value) => setState(() => frequency = value!),
                ),
                ListTile(
                  title: const Text('Ngày bắt đầu'),
                  subtitle: Text(DateHelper.format(nextDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: nextDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => nextDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  final recurring = RecurringTransactionModel(
                    description: descController.text,
                    amount: double.parse(amountController.text),
                    categoryIndex: selectedCategory,
                    isIncome: isIncome,
                    frequency: frequency,
                    nextDate: nextDate,
                    createdAt: DateTime.now(),
                  );
                  provider.addRecurringTransaction(recurring);
                  Navigator.pop(context);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, ExpenseProvider provider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa giao dịch định kỳ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteRecurringTransaction(index);
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
