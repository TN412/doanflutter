import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'screens/main_screen.dart';
import 'screens/add_transaction_screen.dart';

void main() async {
  // Đảm bảo Flutter đã khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Hive database
  await DatabaseService.init();

  // Khởi tạo Notification Service
  try {
    await NotificationService.init();
    await NotificationService.requestPermissions();

    // Đặt nhắc nhở hàng ngày nếu được bật
    if (DatabaseService.getDailyReminderEnabled()) {
      await NotificationService.scheduleDailyReminder();
    }
  } catch (e) {
    // Ignore notification errors on first run or when permissions denied
    print('Notification setup failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ExpenseProvider()..loadData(),
        ),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}
