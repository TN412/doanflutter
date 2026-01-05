import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // 🎨 Uncomment khi có file Lottie
import '../providers/expense_provider.dart';
import '../utils/currency_helper.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int touchedIndex = -1;

  // 💰 Format số tiền rút gọn cho Donut center (16.8 Tr)
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

          return SingleChildScrollView(
            child: Column(
              children: [
                // Filter Section
                _buildMonthFilter(context, provider),

                const SizedBox(height: 24),

                if (categoryExpenses.isEmpty || totalExpense == 0)
                  SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🎭 Gradient Circle Container với Lottie
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF2E86DE).withOpacity(0.1),
                                  const Color(0xFF48DBFB).withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            // child: Icon(
                            //   Icons.pie_chart_rounded,
                            //   size: 80,
                            //   color: const Color(0xFF2E86DE).withOpacity(0.4),
                            // ),
                            // 🎮 KHI CÓ FILE LOTTIE: Uncomment dòng dưới và comment Icon ở trên
                            child: Lottie.asset(
                              'assets/lottie/Empty_State.json',
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // 💬 Copywriting vui nhộn - Game vibe
                          Text(
                            'Tháng này chưa tiêu gì cả?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy thêm giao dịch để xem phép màu phân tích!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // 🔼 CTA Button
                          // FilledButton.icon(
                          //   onPressed: () {
                          //     Navigator.pop(context); // Quay về Dashboard
                          //   },
                          //   icon: const Icon(Icons.add_rounded, size: 20),
                          //   label: const Text('Thêm giao dịch'),
                          //   style: FilledButton.styleFrom(
                          //     backgroundColor: const Color(0xFF2E86DE),
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 24, vertical: 12),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // Pie Chart với tổng tiền ở giữa 🎯
                  SizedBox(
                    height: 220, // 30-35% màn hình - cân bằng với List
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
                            sectionsSpace: 4, // Viền trắng giữa các lát
                            centerSpaceRadius:
                                80, // Lõi rộng hơn - thoáng cho số tiền
                            sections: _showingSections(
                                provider, categoryExpenses, totalExpense),
                          ),
                        ),
                        // Tổng chi tiêu ở chính giữa
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tổng chi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCompactCurrency(totalExpense), // 16.8 Tr
                              style: TextStyle(
                                fontSize: 24, // Lớn hơn với lõi rộng
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.blueGrey[800], // Xám đậm - hài hòa
                              ),
                            ),
                          ],
                        ),
                      ],
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
                  const SizedBox(
                      height: 80), // 🎯 Bottom padding - tránh cắt item cuối
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

    // 🎨 Màu Pastel/Neon dịu mắt (thay vì đỏ gắt)
    final List<Color> pastelColors = [
      const Color(0xFFFF6B9D), // Pink Coral
      const Color(0xFFC44569), // Dark Pink
      const Color(0xFF8E44AD), // Purple
      const Color(0xFF5F27CD), // Violet
      const Color(0xFF0ABDE3), // Cyan
      const Color(0xFF00D2D3), // Teal
      const Color(0xFFFEA47F), // Peach
      const Color(0xFFF97F51), // Coral
      const Color(0xFFFFB900), // Amber
      const Color(0xFF48DBFB), // Sky Blue
    ];

    return List.generate(sortedEntries.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 13.0 : 10.5;
      final radius =
          isTouched ? 65.0 : 55.0; // Mỏng hơn - vòng tròn thanh thoát 💍
      final entry = sortedEntries[i];
      final percentage = (entry.value / total * 100);
      final color = pastelColors[i % pastelColors.length]; // Dùng pastel

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titlePositionPercentageOffset: 0.5, // ✅ Giữ text ở giữa vòng tròn
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

    // 🎨 Màu Pastel khớp với biểu đồ
    final List<Color> pastelColors = [
      const Color(0xFFFF6B9D), // Pink Coral
      const Color(0xFFC44569), // Dark Pink
      const Color(0xFF8E44AD), // Purple
      const Color(0xFF5F27CD), // Violet
      const Color(0xFF0ABDE3), // Cyan
      const Color(0xFF00D2D3), // Teal
      const Color(0xFFFEA47F), // Peach
      const Color(0xFFF97F51), // Coral
      const Color(0xFFFFB900), // Amber
      const Color(0xFF48DBFB), // Sky Blue
    ];

    return sortedEntries.asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final entry = mapEntry.value;
      final percentage = (entry.value / total * 100);
      final color = pastelColors[index % pastelColors.length]; // Khớp với chart

      return Container(
        margin: const EdgeInsets.only(
            bottom: 12), // 🎴 Tách biệt cards - dễ đọc từng dòng
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // 🎴 Card trắng sạch sẽ
          borderRadius: BorderRadius.circular(16), // Bo góc mềm mại
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row chính: Icon + Tên + Số tiền
            Row(
              children: [
                // Icon với pastel background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    provider.getCategoryIcon(entry.key),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Tên danh mục
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Số tiền + %
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyHelper.format(entry.value),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            //  Thanh XP (Progress Bar) - Game style!
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[100],
                color: color,
                minHeight: 4, // Thanh mỏng thanh thoát
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
