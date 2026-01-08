import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // Uncomment khi có file Lottie
import '../../providers/expense_provider.dart';
import '../../utils/currency_helper.dart';
import 'add_transaction_screen.dart';
import '../widgets/month_year_picker.dart';
import '../../domain/enums/transaction_filter.dart';
import '../extensions/transaction_filter_extension.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: _buildAppBar(context, provider),
          body: RefreshIndicator(
            onRefresh: () async {
              await provider.loadData();
            },
            child: _isSearching
                ? _buildSearchResults(context, provider)
                : Column(
                    children: [
                      _buildSummaryCard(context, provider),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Lịch sử giao dịch',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                _buildTimeFilterToggle(context, provider),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTransactionFilterChips(context, provider),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildGroupedTransactionList(context, provider),
                      ),
                    ],
                  ),
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
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ExpenseProvider provider) {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm giao dịch (Ghi chú, Danh mục)...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {}); // Rebuild to update search results
          },
        ),
      );
    }

    return AppBar(
      title: const Text('Quản lý chi tiêu'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: () {
            _showMonthPicker(context);
          },
        ),
      ],
    );
  }

  Widget _buildTimeFilterToggle(
      BuildContext context, ExpenseProvider provider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            context,
            'Tuần',
            provider.selectedFilter == 'week',
            () => provider.setFilter('week'),
          ),
          _buildToggleButton(
            context,
            'Tháng',
            provider.selectedFilter == 'month',
            () => provider.setFilter('month'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
              child: Lottie.asset(
                'assets/lottie/Empty_State.json',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Chưa có giao dịch nào!',
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
              'Thêm giao dịch ngay để quản lý tài chính hiệu quả hơn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị kết quả tìm kiếm (Flat List)
  Widget _buildSearchResults(BuildContext context, ExpenseProvider provider) {
    final results = provider.searchTransactions(_searchController.text);

    if (results.isEmpty) {
      if (_searchController.text.isEmpty) {
        return const Center(
          child: Text('Nhập từ khóa để tìm kiếm...'),
        );
      }
      return const Center(
        child: Text('Không tìm thấy giao dịch nào phù hợp.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildTransactionItem(context, provider, results[index]);
      },
    );
  }

  // Widget hiển thị danh sách giao dịch GOM NHÓM THEO NGÀY
  Widget _buildGroupedTransactionList(
      BuildContext context, ExpenseProvider provider) {
    final groupedTransactions = provider.transactionsGroupedByDate;

    if (groupedTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: groupedTransactions.keys.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final transactions = groupedTransactions[dateKey]!;

        // Tính tổng tiền trong ngày
        double dayTotal = 0;
        for (var t in transactions) {
          if (t.isIncome)
            dayTotal += t.amount;
          else
            dayTotal -= t.amount;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header ngày
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    dayTotal > 0
                        ? '+${CurrencyHelper.format(dayTotal)}'
                        : CurrencyHelper.format(dayTotal),
                    style: TextStyle(
                      color: dayTotal >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
            // Danh sách giao dịch trong ngày
            ...transactions.map(
              (transaction) =>
                  _buildTransactionItem(context, provider, transaction),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, ExpenseProvider provider, transaction) {
    final categoryColor = provider.getCategoryColor(transaction.categoryName);
    final actualIndex = provider.findTransactionIndex(transaction.id);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainer,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
            border: Border.all(
              color: categoryColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            provider.getCategoryIcon(transaction.categoryName),
            color: categoryColor,
            size: 24,
          ),
        ),
        title: Text(
          transaction.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: transaction.note != null && transaction.note!.isNotEmpty
            ? Text(
                transaction.note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Text(
          CurrencyHelper.format(transaction.amount),
          style: TextStyle(
            color: transaction.isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: () {
          _editTransaction(context, provider, actualIndex);
        },
        onLongPress: () {
          _showDeleteDialog(
              context, provider, actualIndex, transaction.categoryName);
        },
      ),
    );
  }

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: Colors.grey.shade100,
                selectedColor: const Color(0xFFFFC107),
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFFFC107)
                      : Colors.grey.shade300,
                  width: isSelected ? 0 : 1,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) async {
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
    // Also reset filter to month if user selects a month? Or keep it as is.
    // Usually selecting a month implies Month View.
    provider.setFilter('month');
  }

  void _editTransaction(
      BuildContext context, ExpenseProvider provider, int index) {
    if (index >= 0) {
      final transactionModel = provider.transactions[index];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTransactionScreen(
            transaction: transactionModel,
            transactionIndex: index,
          ),
        ),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, ExpenseProvider provider,
      int index, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa giao dịch "$categoryName"?'),
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
              await provider.deleteTransaction(index);
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
