import 'package:intl/intl.dart';

String formatHour(DateTime date) => DateFormat('hh:mm a').format(date);
String formatMonthDay(DateTime date) =>
    DateFormat('d/MM/yy hh:mm').format(date);
