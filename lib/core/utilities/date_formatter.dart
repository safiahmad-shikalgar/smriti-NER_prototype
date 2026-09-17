import 'package:intl/intl.dart';

class DateFormatter {
  static String formatGreetingDate(DateTime date) {
    return DateFormat('EEEE, d MMMM').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
}
