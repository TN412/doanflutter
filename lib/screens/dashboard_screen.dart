import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_helper.dart';
import '../utils/date_helper.dart';
import 'add_transaction_screen.dart';
import '../presentation/widgets/month_year_picker.dart';
import '../domain/enums/transaction_filter.dart';
import '../presentation/extensions/transaction_filter_extension.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chi tiêu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              _showMonthPicker(context);
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadData();
            },
            child: Column(
              children: [
                _buildSummaryCard(context, provider),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch sử giao dịch',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      _buildTransactionFilterChips(context, provider),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildTransactionList(context, provider),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ExpenseProvider provider) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Tổng số dư',
            style: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyHelper.format(provider.currentBalance),
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildIncomeExpenseItem(
                  context,
                  'Thu nhập',
                  provider.filteredIncome,
                  Icons.arrow_downward,
                  Colors.greenAccent,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.onPrimary.withOpacity(0.3),
              ),
              Expanded(
                child: _buildIncomeExpenseItem(
                  context,
                  'Chi tiêu',
                  provider.filteredExpense,
                  Icons.arrow_upward,
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseItem(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyHelper.format(amount),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(BuildContext context, ExpenseProvider provider) {
    // Dùng displayTransactions - chỉ danh sách bị ảnh hưởng bởi filter type
    final transactions = provider.displayTransactions;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có giao dịch nào',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainer,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: provider
                  .getCategoryColor(transaction.categoryName)
                  .withOpacity(0.2),
              child: Icon(
                provider.getCategoryIcon(transaction.categoryName),
                color: provider.getCategoryColor(transaction.categoryName),
              ),
            ),
            title: Text(
              transaction.categoryName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  Text(transaction.note!),
                Text(
                  DateHelper.format(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: Text(
              CurrencyHelper.format(transaction.amount),
              style: TextStyle(
                color: transaction.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            onTap: () {
              // Navigate to edit screen
              _editTransaction(context, provider, index);
            },
            onLongPress: () {
              // Show delete confirmation
              _showDeleteDialog(context, provider, index);
            },
          ),
        );
      },
    );
  }

  // Build transaction filter chips (tuân thủ SRP - UI component riêng)
  Widget _buildTransactionFilterChips(
      BuildContext context, ExpenseProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TransactionFilter.values.map((filter) {
          final isSelected = provider.transactionFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(filter.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  provider.setTransactionFilter(filter);
                }
              },
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Show month picker dialog
  void _showMonthPicker(BuildContext context) async {
    // Sử dụng custom MonthYearPicker từ presentation layer
    // Tuân thủ Single Responsibility - widget riêng lo việc chọn tháng/năm
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    final picked = await MonthYearPicker.show(
      context: context,
      initialDate: provider.selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      provider.setSelectedMonth(picked);
    }
  }

  void _editTransaction(
      BuildContext context, ExpenseProvider provider, int index) {
    final transaction = provider.displayTransactions[index];
    // Tìm index thực trong danh sách tất cả transactions
    final actualIndex = provider.findTransactionIndex(transaction.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          transaction: transaction,
          transactionIndex: actualIndex,
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, ExpenseProvider provider, int index) {
    final transaction = provider.displayTransactions[index];
    final actualIndex = provider.findTransactionIndex(transaction.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc muốn xóa giao dịch "${transaction.categoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await provider.deleteTransaction(actualIndex);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa giao dịch')),
                );
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
