import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// extension DateTimeExtension on DateTime {

// }

String convertTimeOfDayToDateTime(TimeOfDay timeOfDay) {
  final now = DateTime.now();
  DateTime time = DateTime(
    now.year,
    now.month,
    now.day,
    timeOfDay.hour,
    timeOfDay.minute,
  );

  Duration difference = time.difference(DateTime.now());

  if (difference.isNegative) {
    return "Tomorrow, ${DateFormat('hh:mm a').format(time)}";
  } else {
    if (difference.inHours % 24 <= 0) {
      return "${difference.inMinutes % 60} mins remaining";
    } else {
      return "${difference.inHours % 24} hrs, ${difference.inMinutes % 60} mins remaining";
    }
  }
}
