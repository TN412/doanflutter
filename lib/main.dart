import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/expense_provider.dart';
import 'providers/auth_provider.dart';
import 'infrastructure/database_service.dart';
import 'infrastructure/notification_service.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/login_screen.dart';

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
    // ignore: avoid_print
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
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E86DE), // Xanh dương vui tươi
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Bo tròn hơn
            ),
          ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return auth.isLoggedIn ? const MainScreen() : const LoginScreen();
      },
    );
  }
}
