import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/month_year_picker_controller.dart';

/// Custom Month & Year Picker Widget
/// Tuân thủ Single Responsibility Principle - CHỈ LO UI RENDERING
/// Logic đã được tách ra MonthYearPickerController
class MonthYearPicker {
  /// Show month and year picker dialog
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final currentYear = DateTime.now().year;
    final startYear = firstDate?.year ?? 2020;
    final endYear = lastDate?.year ?? currentYear;

    return await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return ChangeNotifierProvider(
          create: (_) => MonthYearPickerController(
            initialDate: initialDate,
            startYear: startYear,
            endYear: endYear,
          ),
          child: const _MonthYearPickerDialog(),
        );
      },
    );
  }
}

/// Internal dialog widget for month/year selection
/// CHỈ LO UI - KHÔNG CÓ LOGIC
class _MonthYearPickerDialog extends StatelessWidget {
  const _MonthYearPickerDialog();

  @override
  Widget build(BuildContext context) {
    return Consumer<MonthYearPickerController>(
      builder: (context, controller, child) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Bo góc mềm mại
          ),
          elevation: 24,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E86DE).withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: 0,
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header nhẹ nhàng hơn
                const Text(
                  'Tháng & Năm',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E86DE),
                  ),
                ),
                const SizedBox(height: 24),
                _buildYearSelector(context, controller),
                const SizedBox(height: 24),
                _buildMonthGrid(context, controller),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Nút Hủy - Text đỏ nhạt
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nút OK - Gradient Button bo tròn
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF2E86DE),
                            Color(0xFF48DBFB),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(24), // Stadium border
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2E86DE).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, controller.selectedDate);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildYearSelector(
      BuildContext context, MonthYearPickerController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Nút Previous Year - Icon trong hình tròn
        Container(
          decoration: BoxDecoration(
            color: controller.canGoPreviousYear
                ? Colors.grey.shade100
                : Colors.grey.shade50,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: controller.canGoPreviousYear
                  ? const Color(0xFF2E86DE)
                  : Colors.grey.shade300,
            ),
            onPressed: controller.canGoPreviousYear
                ? () => controller.previousYear()
                : null,
          ),
        ),
        const SizedBox(width: 24),
        // Năm - Màu xanh đậm, lớn và đậm
        Text(
          controller.selectedYear.toString(),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E86DE),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 24),
        // Nút Next Year - Icon trong hình tròn
        Container(
          decoration: BoxDecoration(
            color: controller.canGoNextYear
                ? Colors.grey.shade100
                : Colors.grey.shade50,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: controller.canGoNextYear
                  ? const Color(0xFF2E86DE)
                  : Colors.grey.shade300,
            ),
            onPressed:
                controller.canGoNextYear ? () => controller.nextYear() : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(
      BuildContext context, MonthYearPickerController controller) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isSelected = month == controller.selectedMonth;

        return InkWell(
          onTap: () => controller.selectMonth(month),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              // Gradient xanh khi selected - Giống thẻ ATM Dashboard
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF2E86DE),
                        Color(0xFF48DBFB),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16), // Bo góc mềm mại
              // Shadow 3D khi selected - Tạo cảm giác nổi lên
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2E86DE).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ]
                  : [],
            ),
            alignment: Alignment.center,
            child: Text(
              controller.getMonthName(month),
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
