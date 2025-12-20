import 'package:intl/intl.dart';

class DateHelper {
  static String format(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  static String formatDay(DateTime date) {
    // Use simple format without day name to avoid locale initialization
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatMonthYear(DateTime date) {
    return DateFormat('MM/yyyy').format(date);
  }
}
