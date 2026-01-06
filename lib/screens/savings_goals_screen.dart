import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/savings_goal_model.dart';
import '../utils/currency_helper.dart';

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục tiêu tiết kiệm'),
        centerTitle: true,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final goals = provider.savingsGoals;

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có mục tiêu tiết kiệm',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _buildGoalCard(context, provider, goal, index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    ExpenseProvider provider,
    SavingsGoalModel goal,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  goal.iconName != null
                      ? IconData(int.parse(goal.iconName!),
                          fontFamily: 'MaterialIcons')
                      : Icons.savings,
                  color: goal.colorValue != null
                      ? Color(goal.colorValue!)
                      : Colors.blue,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (goal.deadline != null)
                        Text(
                          'Còn ${goal.daysRemaining} ngày',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
                if (goal.isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goal.progressPercentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: goal.isCompleted ? Colors.green : Colors.blue,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyHelper.format(goal.currentAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${goal.progressPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  CurrencyHelper.format(goal.targetAmount),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddMoneyDialog(context, provider, index, goal),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm tiền'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showEditGoalDialog(context, provider, index, goal),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, provider, index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime? deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Thêm mục tiêu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên mục tiêu'),
                ),
                TextField(
                  controller: targetController,
                  decoration: const InputDecoration(labelText: 'Số tiền mục tiêu'),
                  keyboardType: TextInputType.number,
                ),
                ListTile(
                  title: const Text('Hạn chót (tùy chọn)'),
                  subtitle: Text(
                    deadline != null
                        ? '${deadline!.day}/${deadline!.month}/${deadline!.year}'
                        : 'Chưa đặt',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() => deadline = picked);
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
                if (nameController.text.isNotEmpty &&
                    targetController.text.isNotEmpty) {
                  final goal = SavingsGoalModel(
                    name: nameController.text,
                    targetAmount: double.parse(targetController.text),
                    deadline: deadline,
                    createdAt: DateTime.now(),
                    colorValue: Colors.blue.value,
                  );
                  provider.addSavingsGoal(goal);
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

  void _showAddMoneyDialog(
    BuildContext context,
    ExpenseProvider provider,
    int index,
    SavingsGoalModel goal,
  ) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm tiền vào mục tiêu'),
        content: TextField(
          controller: amountController,
          decoration: const InputDecoration(
            labelText: 'Số tiền',
            prefixText: '₫ ',
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final amount = double.parse(amountController.text);
                provider.addToSavingsGoal(index, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, ExpenseProvider provider, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa mục tiêu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteSavingsGoal(index);
              Navigator.pop(context);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(
    BuildContext context,
    ExpenseProvider provider,
    int index,
    SavingsGoalModel goal,
  ) {
    final nameController = TextEditingController(text: goal.name);
    final targetController = TextEditingController(text: goal.targetAmount.toString());
    DateTime? deadline = goal.deadline;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Sửa mục tiêu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên mục tiêu'),
                ),
                TextField(
                  controller: targetController,
                  decoration: const InputDecoration(labelText: 'Số tiền mục tiêu'),
                  keyboardType: TextInputType.number,
                ),
                ListTile(
                  title: const Text('Hạn chót (tùy chọn)'),
                  subtitle: Text(
                    deadline != null
                        ? '${deadline!.day}/${deadline!.month}/${deadline!.year}'
                        : 'Chưa đặt',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: deadline ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() => deadline = picked);
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
                if (nameController.text.isNotEmpty &&
                    targetController.text.isNotEmpty) {
                  final updatedGoal = goal.copyWith(
                    name: nameController.text,
                    targetAmount: double.parse(targetController.text),
                    deadline: deadline,
                  );
                  provider.updateSavingsGoal(index, updatedGoal);
                  Navigator.pop(context);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
