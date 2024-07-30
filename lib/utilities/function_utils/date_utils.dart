import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

int getDaysFromDateToToday(DateTime date) {
  DateTime one = DateTime.now();
  DateTime two = date.toUtc();
  Duration diff = one.difference(two);
  return diff.inDays;
}

DateTime onlyDMY(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

bool areTwoDatesDMYEquals(DateTime date1, DateTime date2) {
  return onlyDMY(date1).compareTo(onlyDMY(date2)) == 0;
}

//parse date to dd/MM/yyyy
String parseDateToString(DateTime date) {
  return "${date.day}/${date.month}/${date.year}";
}

bool isDateWithinDateRangeDMY(DateTime date, DateTime startDate, DateTime endDate) {
  return onlyDMY(date).compareTo(onlyDMY(startDate)) >= 0 && onlyDMY(date).compareTo(onlyDMY(endDate)) <= 0;
}

String formatDateWithDaySuffix(DateTime date) {
  try {
    String day = DateFormat('d').format(date);
    String month = DateFormat('MMM').format(date);
    String year = DateFormat('y').format(date);

    String daySuffix;

    switch (day) {
      case '1':
      case '21':
      case '31':
        daySuffix = 'st';
        break;
      case '2':
      case '22':
        daySuffix = 'nd';
        break;
      case '3':
      case '23':
        daySuffix = 'rd';
        break;
      default:
        daySuffix = 'th';
    }

    return '$day$daySuffix $month, $year';
  } catch (e) {
    return 'N/A';
  }
}

bool isToday(DateTime date) {
  DateTime now = DateTime.now();
  return date.day == now.day && date.month == now.month && date.year == now.year;
}

bool isYesterday(DateTime date) {
  DateTime now = DateTime.now();
  DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
  return date.day == yesterday.day && date.month == yesterday.month && date.year == yesterday.year;
}

String formatDateWithTime(DateTime date) {
  final hourPresentation = DateFormat('HH:mm').format(date);
  if (isToday(date)) {
    return "today at $hourPresentation";
  } else if (isYesterday(date)) {
    return "yesterday at $hourPresentation";
  } else {
    return "${DateFormat('dd/MM/yyyy').format(date)} at $hourPresentation";
  }
}