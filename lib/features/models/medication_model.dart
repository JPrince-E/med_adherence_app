import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Medication {
  final String medicationName;
  final String selectedAmount;
  final String selectedDose;
  final String noOfTimes;
  final String noOfDays;
  final List<TimeOfDay> times;
  final String colour;
  final String uid;

  Medication({
    required this.medicationName,
    required this.selectedAmount,
    required this.selectedDose,
    required this.noOfTimes,
    required this.noOfDays,
    required this.times,
    required this.colour,
    required this.uid,
  });

  // Updated factory method
  factory Medication.fromDataSnapshot(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    List<TimeOfDay> timesList = (dataSnapshot["times"] as List<dynamic>)
        .map((timeString) {
      // Extract hours and minutes from the string
      final matches = RegExp(r'(\d+):(\d+)').firstMatch(timeString);
      if (matches != null && matches.groupCount == 2) {
        // Parse each timeString to TimeOfDay
        int hours = int.parse(matches.group(1)!);
        int minutes = int.parse(matches.group(2)!);
        return TimeOfDay(hour: hours, minute: minutes);
      } else {
        // Handle the case where the timeString format is incorrect
        throw FormatException('Invalid time format: $timeString');
      }
    }).toList();

    return Medication(
      uid: dataSnapshot["uid"],
      medicationName: dataSnapshot["medicationName"],
      selectedAmount: dataSnapshot["selectedAmount"],
      selectedDose: dataSnapshot["selectedDose"],
      noOfTimes: dataSnapshot["noOfTimes"].toString(),
      noOfDays: dataSnapshot["noOfDays"].toString(),
      times: timesList,
      colour: dataSnapshot["colour"],
    );
  }
}