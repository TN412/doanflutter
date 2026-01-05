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
            // 1. Switch Income/Expense - Sliding Switch Style (Golden Ratio)
            Container(
              margin: const EdgeInsets.all(16),
              height: 52, // Chiều cao tối ưu cho ngón tay
              padding:
                  const EdgeInsets.all(3), // Padding nhỏ gọn - Golden Ratio
              decoration: BoxDecoration(
                color: Colors.grey.shade200, // Track xám nhạt
                borderRadius:
                    BorderRadius.circular(26), // Height / 2 (tuyệt đối)
              ),
              child: Stack(
                children: [
                  // Animated Thumb (khối trắng trượt) - Đầy đặn hơn
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: _isIncome
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 0.5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(23), // 26 - 3 padding
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isIncome = false),
                          child: Container(
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: Text(
                              'Chi tiêu',
                              style: TextStyle(
                                color: !_isIncome
                                    ? const Color(0xFFFF4757) // Đỏ nổi bật
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isIncome = true),
                          child: Container(
                            color: Colors.transparent,
                            alignment: Alignment.center,
                            child: Text(
                              'Thu nhập',
                              style: TextStyle(
                                color: _isIncome
                                    ? const Color(
                                        0xFF2ED573) // Xanh lá tích cực
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // 2. Amount Input - Hero Section (Fixed Alignment)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon đồng xu vàng
                        Icon(
                          Icons.monetization_on_rounded,
                          size: 56,
                          color: const Color(0xFFFFB900),
                        ),
                        const SizedBox(width: 12),
                        // Số tiền - Nhân vật chính
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              CurrencyInputFormatter(),
                            ],
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              // Màu đậm rõ ràng: Đỏ cho chi tiêu, Xanh lá cho thu nhập
                              color: _isIncome
                                  ? const Color(0xFF2ED573)
                                  : const Color(0xFFFF4757),
                              letterSpacing: -1,
                              height: 1.2,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: TextStyle(
                                // Màu động theo tab - Rực rỡ hơn!
                                color: _isIncome
                                    ? const Color(0xFF2ED573).withOpacity(0.3)
                                    : const Color(0xFFFF4757).withOpacity(0.3),
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số tiền';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // 3. Date Picker - Container Style
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
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
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: const Color(0xFF2E86DE),
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            DateHelper.formatDay(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),

                  // 4. Note Input - Container Style
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_rounded,
                          color: Colors.grey.shade600,
                          size: 22,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              hintText: 'Ghi chú (tùy chọn)',
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // 5. Category Selection
                  const Padding(
                    padding:
                        EdgeInsets.only(top: 4.0, bottom: 8.0), // Chặt chẽ hơn
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
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
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
                        child: AnimatedScale(
                          scale: isSelected
                              ? 1.05
                              : 1.0, // Scale animation khi chọn
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutBack,
                          child: Container(
                            decoration: BoxDecoration(
                              // Nền màu của icon khi selected
                              color: isSelected
                                  ? category.color.withOpacity(0.15)
                                  : Colors.grey.shade50, // Nền xám cực nhạt
                              // Viền đậm khi selected
                              border: isSelected
                                  ? Border.all(
                                      color: category.color,
                                      width: 3,
                                    )
                                  : null, // Bỏ viền khi chưa chọn
                              borderRadius:
                                  BorderRadius.circular(20), // Squircle
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: category.color.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icon container
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: category.color.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    category.icon,
                                    color: category.color,
                                    size: 28,
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
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? category.color
                                        : Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF2E86DE),
              Color(0xFF48DBFB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E86DE).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _saveTransaction,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Icon(
            _isEditMode ? Icons.update_rounded : Icons.save_rounded,
            color: Colors.white,
          ),
          label: Text(
            _isEditMode ? 'Cập nhật' : 'Lưu giao dịch',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
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
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20), // Squircle
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                color: Colors.grey.shade600,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm mới',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
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
