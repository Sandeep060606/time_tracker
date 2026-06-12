import 'package:intl/intl.dart';

class DateTimeUtils {
  const DateTimeUtils._();

  static final DateFormat apiDateTime = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat displayDateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat displayDate = DateFormat('dd MMM yyyy');
  static final DateFormat displayTime = DateFormat('hh:mm:ss a');

  static String formatForApi(DateTime value) => apiDateTime.format(value);

  static String scanSession(DateTime value) => value.hour < 12 ? 'FN' : 'AN';

  static bool isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
