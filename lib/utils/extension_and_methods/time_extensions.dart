import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  difference = difference + const Duration(minutes: 1);

  if (difference.isNegative) {
    return "Tomorrow, ${DateFormat('hh:mm a').format(time)}";
  } else {
    if (difference.inHours % 24 <= 0) {
      if (difference.inMinutes % 60 <= 0) {
        return "Due already.";
      } else if (difference.inMinutes % 60 == 1) {
        return "${difference.inMinutes % 60} min remaining";
      } else {
        return "${difference.inMinutes % 60} mins remaining";
      }
    } else if (difference.inMinutes % 60 <= 1) {
      return "${difference.inHours % 24} hr, ${difference.inMinutes % 60} min remaining";
    } else {
      return "${difference.inHours % 24} hrs, ${difference.inMinutes % 60} mins remaining";
    }
  }
}

String convertToTimeAgo(TimeOfDay timeOfDay) {
  final now = DateTime.now();
  DateTime time = DateTime(
    now.year,
    now.month,
    now.day,
    timeOfDay.hour,
    timeOfDay.minute,
  );

  Duration difference = time.difference(DateTime.now());
  difference = difference + const Duration(minutes: 1);
  final timeAgo = DateTime.now().subtract(difference.abs());

  if (timeago.format(timeAgo, locale: 'en_short') == "now") {
    String timeAgoString = "1min ago";
    return timeAgoString;
  } else {
    String timeAgoString = "${timeago.format(timeAgo, locale: 'en_short')} ago";
    return timeAgoString;
  }
}
