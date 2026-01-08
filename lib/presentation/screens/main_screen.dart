import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, -4),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
          // Bo tròn góc trên để tạo cảm giác mềm mại
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            elevation: 0,
            backgroundColor: Colors.white,
            // Indicator màu vàng nổi bật với Amber
            indicatorColor: const Color(0xFFFFC107).withOpacity(0.25),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            height: 72,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  color: Colors.grey.shade400,
                  size: 26,
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.home,
                    color: Color(0xFFFFC107),
                    size: 28,
                  ),
                ),
                label: 'Tổng quan',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.pie_chart_outline,
                  color: Colors.grey.shade400,
                  size: 26,
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.pie_chart,
                    color: Color(0xFFFFC107),
                    size: 28,
                  ),
                ),
                label: 'Thống kê',
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.settings_outlined,
                  color: Colors.grey.shade400,
                  size: 26,
                ),
                selectedIcon: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.settings,
                    color: Color(0xFFFFC107),
                    size: 28,
                  ),
                ),
                label: 'Cài đặt',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
