import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../providers/expense_provider.dart';
import '../utils/date_helper.dart';
import '../presentation/validators/transaction_validator.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel?
      transaction; // Transaction cần edit (null nếu là add mode)
  final int? transactionIndex; // Index của transaction trong database

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.transactionIndex,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isIncome = false;
  DateTime _selectedDate = DateTime.now();
  CategoryModel? _selectedCategory;

  // Getter để check edit mode
  bool get _isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    // Nếu là edit mode, load dữ liệu từ transaction
    if (_isEditMode) {
      _loadTransactionData();
    }
  }

  void _loadTransactionData() {
    final transaction = widget.transaction!;
    _amountController.text = transaction.amount.toStringAsFixed(0);
    _noteController.text = transaction.note ?? '';
    _isIncome = transaction.isIncome;
    _selectedDate = transaction.date;

    // Load category sau khi build context available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final categories =
          _isIncome ? provider.incomeCategories : provider.expenseCategories;

      // Tìm category theo tên
      _selectedCategory = categories.firstWhere(
        (cat) => cat.name == transaction.categoryName,
        orElse: () => categories.first,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      // Validate category using TransactionValidator
      final categoryValidation =
          TransactionValidator.validateCategory(_selectedCategory);
      if (!categoryValidation.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(categoryValidation.errorMessage!)),
        );
        return;
      }

      // Validate amount using TransactionValidator
      final amountValidation =
          TransactionValidator.validateAmount(_amountController.text);
      if (!amountValidation.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(amountValidation.errorMessage!)),
        );
        return;
      }

      // Validate date
      final dateValidation = TransactionValidator.validateDate(_selectedDate);
      if (!dateValidation.isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(dateValidation.errorMessage!)),
        );
        return;
      }

      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      if (_isEditMode) {
        // Update existing transaction
        final updatedTransaction = TransactionModel(
          id: widget.transaction!.id, // Giữ nguyên ID cũ
          amount: amountValidation.value!,
          date: dateValidation.value!,
          isIncome: _isIncome,
          categoryName: _selectedCategory!.name,
          note: _noteController.text.trim(),
        );

        await provider.updateTransaction(
            widget.transactionIndex!, updatedTransaction);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật giao dịch')),
          );
        }
      } else {
        // Add new transaction
        final newTransaction = TransactionModel(
          id: TransactionModel.generateId(),
          amount: amountValidation.value!,
          date: dateValidation.value!,
          isIncome: _isIncome,
          categoryName: _selectedCategory!.name,
          note: _noteController.text.trim(),
        );

        await provider.addTransaction(newTransaction);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final categories =
        _isIncome ? provider.incomeCategories : provider.expenseCategories;

    // Nếu đổi loại giao dịch mà category hiện tại không phù hợp thì reset
    if (_selectedCategory != null && _selectedCategory!.isIncome != _isIncome) {
      _selectedCategory = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Sửa giao dịch' : 'Thêm giao dịch'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // 1. Switch Income/Expense
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncome = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isIncome
                              ? Colors.redAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            'Chi tiêu',
                            style: TextStyle(
                              color: !_isIncome ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIncome = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isIncome ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Center(
                          child: Text(
                            'Thu nhập',
                            style: TextStyle(
                              color: _isIncome ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // 2. Amount Input
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CurrencyInputFormatter(),
                    ],
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _isIncome ? Colors.green : Colors.redAccent,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0 ₫',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số tiền';
                      }
                      return null;
                    },
                  ),
                  const Divider(),

                  // 3. Date Picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(DateHelper.formatDay(_selectedDate)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                  const Divider(),

                  // 4. Note Input
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      hintText: 'Ghi chú (tùy chọn)',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                  const Divider(),

                  // 5. Category Selection
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Danh mục',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: categories.length + 1, // +1 for Add New Category
                    itemBuilder: (context, index) {
                      if (index == categories.length) {
                        return _buildAddCategoryButton();
                      }

                      final category = categories[index];
                      final isSelected =
                          _selectedCategory?.name == category.name;

                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = category),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? category.color.withOpacity(0.2)
                                : Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: isSelected
                                  ? category.color
                                  : Colors.grey.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    category.color.withOpacity(0.1),
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? category.color
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTransaction,
        icon: Icon(_isEditMode ? Icons.update : Icons.save),
        label: Text(_isEditMode ? 'Cập nhật' : 'Lưu giao dịch'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAddCategoryButton() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to Add Category Screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tính năng thêm danh mục sẽ có sau')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Icon(Icons.add, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Thêm mới',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Formatter để hiển thị tiền tệ khi gõ
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    double value = double.parse(newValue.text);
    final formatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
          offset: newText.length - 2), // -2 để con trỏ trước ký tự đ
    );
  }
}
