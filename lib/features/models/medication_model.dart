import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Medication {
  final String medicationName;
  final String selectedAmount;
  final String selectedDose;
  final String noOfTimes;
  final String noOfDays;
  final List<TimeOfDay> times;
  final List<bool> taken;
  String colour;
  final String uid;
  bool isTaken;

  Medication copyWith({List<TimeOfDay>? times}) {
    return Medication(
      uid: this.uid,
      medicationName: this.medicationName,
      selectedAmount: this.selectedAmount,
      selectedDose: this.selectedDose,
      noOfTimes: this.noOfTimes,
      noOfDays: this.noOfDays,
      times: times ?? this.times,  // Replace times if provided, otherwise use the existing times
      taken: this.taken,
      colour: this.colour,
      isTaken: this.isTaken,
    );
  }

  Medication({
    required this.medicationName,
    required this.selectedAmount,
    required this.selectedDose,
    required this.noOfTimes,
    required this.noOfDays,
    required this.times, required
    this.taken,
    required this.colour,
    required this.uid,
    this.isTaken = false,
  });

  // Updated factory method
  factory Medication.fromDataSnapshot(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    List<TimeOfDay> timesList = [];
    List<bool> takenList = [];

    if (dataSnapshot["times"] != null) {
      timesList = (dataSnapshot["times"] as List<dynamic>).map((timeString) {
        final matches = RegExp(r'(\d+):(\d+)').firstMatch(timeString);
        if (matches != null && matches.groupCount == 2) {
          int hours = int.parse(matches.group(1)!);
          int minutes = int.parse(matches.group(2)!);
          return TimeOfDay(hour: hours, minute: minutes);
        } else {
          throw FormatException('Invalid time format: $timeString');
        }
      }).toList();
    }

    if (dataSnapshot["taken"] != null) {
      takenList = (dataSnapshot["taken"] as List<dynamic>).map((takenString) {
        try {
          return bool.parse((takenString ?? false).toString());
        } catch (e) {
          print("Error parsing boolean: $e");
          return false;
        }
      }).toList();
    }

    return Medication(
      uid: dataSnapshot["uid"],
      medicationName: dataSnapshot["medicationName"],
      selectedAmount: dataSnapshot["selectedAmount"],
      selectedDose: dataSnapshot["selectedDose"],
      noOfTimes: dataSnapshot["noOfTimes"].toString(),
      noOfDays: dataSnapshot["noOfDays"].toString(),
      times: timesList,
      taken: takenList,
      colour: dataSnapshot["colour"],
      isTaken: dataSnapshot["isTaken"] ?? false,
    );
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "medicationName": medicationName,
      "selectedAmount": selectedAmount,
      "selectedDose": selectedDose,
      "noOfTimes": noOfTimes,
      "noOfDays": noOfDays,
      "times": times.map((time) => _formatTime(time)).toList(),
      "colour": colour,
      // Add other properties as needed
    };
  }
}
