import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'database_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  // Khởi tạo notification
  static Future<void> init() async {
    if (_initialized) return;

    // Khởi tạo timezone
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );

    _initialized = true;
  }

  // Request permissions (for iOS)
  static Future<bool> requestPermissions() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result ?? true;
  }

  // ==================== NHẮC NHỞ GHI CHI TIÊU ====================

  // Đặt nhắc nhở ghi chi tiêu hàng ngày
  static Future<void> scheduleDailyReminder() async {
    if (!DatabaseService.getDailyReminderEnabled()) return;

    final time = DatabaseService.getReminderTime();
    final hour = time['hour']!;
    final minute = time['minute']!;

    await _notifications.zonedSchedule(
      0, // notification id
      'Nhắc nhở ghi chi tiêu',
      'Đừng quên ghi lại chi tiêu hôm nay nhé! 📝',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Nhắc nhở hàng ngày',
          channelDescription: 'Nhắc nhở ghi chi tiêu hàng ngày',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Hủy nhắc nhở hàng ngày
  static Future<void> cancelDailyReminder() async {
    await _notifications.cancel(0);
  }

  // ==================== CẢNH BÁO VƯỢT NGÂN SÁCH ====================

  // Kiểm tra và gửi cảnh báo vượt ngân sách
  static Future<void> checkBudgetAlert(double currentExpense, double budget) async {
    if (!DatabaseService.getBudgetAlertEnabled()) return;
    if (budget <= 0) return;

    final percentage = (currentExpense / budget * 100).round();

    // Cảnh báo khi đạt 80%, 90%, 100%
    if (percentage == 80) {
      await _showBudgetAlert(
        'Cảnh báo ngân sách',
        'Bạn đã chi tiêu 80% ngân sách tháng này! 💰',
        1,
      );
    } else if (percentage == 90) {
      await _showBudgetAlert(
        'Cảnh báo ngân sách',
        'Bạn đã chi tiêu 90% ngân sách tháng này! ⚠️',
        2,
      );
    } else if (percentage >= 100) {
      await _showBudgetAlert(
        'Vượt ngân sách!',
        'Bạn đã vượt ngân sách tháng này! Hãy cân nhắc chi tiêu! 🚨',
        3,
      );
    }
  }

  static Future<void> _showBudgetAlert(String title, String body, int id) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Cảnh báo ngân sách',
          channelDescription: 'Thông báo khi vượt ngân sách',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ==================== NHẮC NHỞ CHI ĐỊNH KỲ ====================

  // Đặt nhắc nhở cho giao dịch định kỳ
  static Future<void> scheduleRecurringReminder(
    int id,
    String description,
    DateTime nextDate,
  ) async {
    // Nhắc trước 1 ngày
    final reminderDate = nextDate.subtract(const Duration(days: 1));
    
    if (reminderDate.isBefore(DateTime.now())) {
      return; // Không nhắc nếu đã quá hạn
    }

    await _notifications.zonedSchedule(
      100 + id, // offset để tránh conflict với các notification khác
      'Nhắc nhở giao dịch định kỳ',
      'Ngày mai bạn có khoản: $description 📅',
      tz.TZDateTime.from(reminderDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_reminders',
          'Nhắc nhở giao dịch định kỳ',
          channelDescription: 'Nhắc nhở các khoản chi định kỳ sắp đến',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Hủy nhắc nhở giao dịch định kỳ
  static Future<void> cancelRecurringReminder(int id) async {
    await _notifications.cancel(100 + id);
  }

  // ==================== UTILITY ====================

  // Tính thời điểm tiếp theo cho một giờ cụ thể
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Hủy tất cả notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  // Hiển thị notification ngay lập tức (để test)
  static Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      'Test Notification',
      'Thông báo đang hoạt động! ✅',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          'Test',
          channelDescription: 'Test notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
