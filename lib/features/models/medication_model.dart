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

  static Medication fromDataSnapshot(DocumentSnapshot snapshot) {
    var dataSnapshot = snapshot.data() as Map<String, dynamic>;

    List<TimeOfDay> timesList = (dataSnapshot["times"] as List<dynamic>)
        .map((timeString) {
      // Parse each timeString to TimeOfDay
      List<String> timeParts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
    })
        .toList();

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

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "medicationName": medicationName,
    "selectedAmount": selectedAmount,
    "selectedDose": selectedDose,
    "noOfTimes": noOfTimes,
    "noOfDays": noOfDays,
    // Convert List<TimeOfDay> to List<String> for Firestore storage
    "times": times.map((time) => '${time.hour}:${time.minute}').toList(),
    "colour": colour,
  };
}
