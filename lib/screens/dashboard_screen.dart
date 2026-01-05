import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // Uncomment khi có file Lottie
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E86DE),
            Color(0xFF48DBFB)
          ], // Blue to Cyan gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E86DE).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Tổng số dư',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Số tiền với icon đồng xu vàng
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon đồng xu vàng
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB900).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: Color(0xFFFFB900), // Màu vàng đồng xu
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  CurrencyHelper.format(provider.currentBalance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
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
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          CurrencyHelper.format(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
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
            // Icon container với gradient và animation-ready
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E86DE).withOpacity(0.1),
                    const Color(0xFF48DBFB).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E86DE).withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                // 🎨 KHI CÓ FILE LOTTIE: Uncomment dòng dưới và comment Icon ở trên
                child: Lottie.asset(
                  'assets/lottie/Empty_State.json',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Copywriting vui hơn
            Text(
              'Ví đang trống trơn nè!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E86DE),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Hãy thêm giao dịch đầu tiên của bạn!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 26),
            // CTA Button nhỏ gọi ý
            // ElevatedButton.icon(
            //   onPressed: () {
            //     // Scroll to bottom to show FAB
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: const Color(0xFF2E86DE),
            //     foregroundColor: Colors.white,
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(24),
            //     ),
            //     elevation: 0,
            //   ),
            //   icon: const Icon(Icons.add_rounded, size: 20),
            //   label: const Text(
            //     'Thêm giao dịch',
            //     style: TextStyle(
            //       fontSize: 15,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final categoryColor =
            provider.getCategoryColor(transaction.categoryName);
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainer,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // Icon hình tròn với filled icons và shadow cartoon style
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                // Physical shadow (cartoon style) - Đổ bóng xám nhẹ xuống dưới
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, 4), // Đổ bóng xuống dưới
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
                border: Border.all(
                  color: categoryColor.withOpacity(0.25),
                  width: 2.5,
                ),
              ),
              child: Icon(
                provider.getCategoryIcon(transaction.categoryName),
                color: categoryColor,
                size: 28,
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
        children: [
          ...TransactionFilter.values.map((filter) {
            final isSelected = provider.transactionFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: FilterChip(
                label: Text(filter.label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    provider.setTransactionFilter(filter);
                  }
                },
                // Pill shape với padding lớn hơn
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                // Filled style khi active - Màu vàng Amber đặc (Gamification)
                backgroundColor: Colors.grey.shade100,
                selectedColor: const Color(0xFFFFC107), // Amber filled
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFFFC107)
                      : Colors.grey.shade300,
                  width: isSelected ? 0 : 1, // Không cần border khi filled
                ),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white // Text trắng trên nền vàng
                      : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          // Khoảng trống an toàn để không bị cắt mép
          const SizedBox(width: 16),
        ],
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
