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
        return AlertDialog(
          title: const Text(
            'CHỌN THÁNG',
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildYearSelector(context, controller),
                const SizedBox(height: 24),
                _buildMonthGrid(context, controller),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, controller.selectedDate);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildYearSelector(
      BuildContext context, MonthYearPickerController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: controller.canGoPreviousYear
              ? () => controller.previousYear()
              : null,
        ),
        const SizedBox(width: 16),
        Text(
          controller.selectedYear.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              controller.canGoNextYear ? () => controller.nextYear() : null,
        ),
      ],
    );
  }

  Widget _buildMonthGrid(
      BuildContext context, MonthYearPickerController controller) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final isSelected = month == controller.selectedMonth;

        return InkWell(
          onTap: () => controller.selectMonth(month),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              controller.getMonthName(month),
              style: TextStyle(
                color:
                    isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}
