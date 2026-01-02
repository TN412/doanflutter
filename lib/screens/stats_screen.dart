import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_helper.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê chi tiêu'),
        centerTitle: true,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final categoryExpenses = provider.getExpensesByCategory();
          final totalExpense = provider.filteredExpense;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Filter Section
                _buildMonthFilter(context, provider),

                const SizedBox(height: 24),

                if (categoryExpenses.isEmpty || totalExpense == 0)
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pie_chart_outline,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có dữ liệu chi tiêu',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Pie Chart
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _showingSections(
                            provider, categoryExpenses, totalExpense),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Details List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chi tiết theo danh mục',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        ..._buildDetailsList(
                            context, provider, categoryExpenses, totalExpense),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthFilter(BuildContext context, ExpenseProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newMonth = DateTime(
                provider.selectedMonth.year,
                provider.selectedMonth.month - 1,
              );
              provider.setSelectedMonth(newMonth);
            },
          ),
          Column(
            children: [
              Text(
                'Tháng ${provider.selectedMonth.month}/${provider.selectedMonth.year}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (provider.selectedMonth.month == DateTime.now().month &&
                  provider.selectedMonth.year == DateTime.now().year)
                Text(
                  '(Tháng này)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newMonth = DateTime(
                provider.selectedMonth.year,
                provider.selectedMonth.month + 1,
              );
              provider.setSelectedMonth(newMonth);
            },
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(
    ExpenseProvider provider,
    Map<String, double> categoryExpenses,
    double total,
  ) {
    final List<MapEntry<String, double>> sortedEntries =
        categoryExpenses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return List.generate(sortedEntries.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 110.0 : 100.0;
      final entry = sortedEntries[i];
      final percentage = (entry.value / total * 100);
      final color = provider.getCategoryColor(entry.key);

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    });
  }

  List<Widget> _buildDetailsList(
    BuildContext context,
    ExpenseProvider provider,
    Map<String, double> categoryExpenses,
    double total,
  ) {
    final sortedEntries = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.map((entry) {
      final percentage = (entry.value / total * 100);
      final color = provider.getCategoryColor(entry.key);

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              provider.getCategoryIcon(entry.key),
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            entry.key,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyHelper.format(entry.value),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
