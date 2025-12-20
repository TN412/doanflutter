import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return formatter.format(amount);
  }
}
