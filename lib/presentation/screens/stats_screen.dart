import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../providers/expense_provider.dart';
import '../../utils/currency_helper.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int touchedIndex = -1;

  String _formatCompactCurrency(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} Tỷ';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} Tr';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)} K';
    }
    return CurrencyHelper.format(amount);
  }

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
          final totalIncome = provider.filteredIncome;

          final hasData = totalExpense > 0 || totalIncome > 0;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildMonthFilter(context, provider),
                const SizedBox(height: 16),
                if (!hasData)
                  _buildEmptyState()
                else ...[
                  // Cashflow Chart
                  _buildCashflowChart(context, provider),
                  const SizedBox(height: 24),

                  // Pie Chart
                  if (totalExpense > 0) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Cơ cấu chi tiêu',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback:
                                    (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection ==
                                            null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex = pieTouchResponse
                                        .touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 4,
                              centerSpaceRadius: 80,
                              sections: _showingSections(
                                  provider, categoryExpenses, totalExpense),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Tổng chi',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(_formatCompactCurrency(totalExpense),
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey[800])),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chi tiết theo danh mục',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ..._buildDetailsList(context, provider,
                              categoryExpenses, totalExpense),
                        ],
                      ),
                    ),
                  ] else
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('Chưa có chi tiêu nào trong tháng này'),
                    )),

                  const SizedBox(height: 80),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCashflowChart(BuildContext context, ExpenseProvider provider) {
    final dailyData = provider.getCashflowByDay();
    final daysInMonth = DateUtils.getDaysInMonth(
        provider.selectedMonth.year, provider.selectedMonth.month);

    // Calc Width based on days (approx 20px per bar group)
    final chartWidth = daysInMonth * 30.0; // Needs adjustment

    // Check max Value for Y Axis
    double maxY = 0;
    dailyData.forEach((key, value) {
      if ((value['income'] ?? 0) > maxY) maxY = value['income']!;
      if ((value['expense'] ?? 0) > maxY) maxY = value['expense']!;
    });
    if (maxY == 0) maxY = 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Dòng tiền (Thu/Chi)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: chartWidth > MediaQuery.of(context).size.width - 32
                ? chartWidth
                : MediaQuery.of(context).size.width - 32,
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: maxY * 1.2, // Add some headroom
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            value.toInt().toString(), // Day number
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false)), // Hide Y Axis
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(daysInMonth, (index) {
                  final day = index + 1;
                  final data =
                      dailyData[day] ?? {'income': 0.0, 'expense': 0.0};
                  return BarChartGroupData(
                    x: day,
                    barRods: [
                      BarChartRodData(
                        toY: data['income'] ?? 0.0,
                        color: Colors.greenAccent,
                        width: 6,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      BarChartRodData(
                        toY: data['expense'] ?? 0.0,
                        color: Colors.redAccent,
                        width: 6,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                    barsSpace: 4,
                  );
                }),
              ),
            ),
          ),
        ),
      ],
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
              final newMonth = DateTime(provider.selectedMonth.year,
                  provider.selectedMonth.month - 1);
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
                      color: Theme.of(context).colorScheme.primary),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newMonth = DateTime(provider.selectedMonth.year,
                  provider.selectedMonth.month + 1);
              provider.setSelectedMonth(newMonth);
            },
          ),
        ],
      ),
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
          const SizedBox(height: 24),
          Text(
            'Tháng này chưa tiêu gì cả?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
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

    final List<Color> pastelColors = [
      const Color(0xFFFF6B9D),
      const Color(0xFFC44569),
      const Color(0xFF8E44AD),
      const Color(0xFF5F27CD),
      const Color(0xFF0ABDE3),
      const Color(0xFF00D2D3),
      const Color(0xFFFEA47F),
      const Color(0xFFF97F51),
      const Color(0xFFFFB900),
      const Color(0xFF48DBFB),
    ];

    return List.generate(sortedEntries.length, (i) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 65.0 : 55.0;
      final entry = sortedEntries[i];
      final color = pastelColors[i % pastelColors.length]; // Dùng pastel

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '',
        radius: radius,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  List<Widget> _buildDetailsList(BuildContext context, ExpenseProvider provider,
      Map<String, double> categoryExpenses, double totalExpense) {
    if (categoryExpenses.isEmpty) return [];

    final sortedEntries = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<Color> pastelColors = [
      const Color(0xFFFF6B9D),
      const Color(0xFFC44569),
      const Color(0xFF8E44AD),
      const Color(0xFF5F27CD),
      const Color(0xFF0ABDE3),
      const Color(0xFF00D2D3),
      const Color(0xFFFEA47F),
      const Color(0xFFF97F51),
      const Color(0xFFFFB900),
      const Color(0xFF48DBFB),
    ];

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryName = entry.value.key;
      final amount = entry.value.value;
      final percentage = totalExpense > 0 ? (amount / totalExpense * 100) : 0.0;
      final color = pastelColors[index % pastelColors.length];

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(categoryName,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyHelper.format(amount),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}
