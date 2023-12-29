// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:med_adherence_app/features/models/medication_model.dart';
import 'package:alarm/alarm.dart';

class HomepageController extends GetxController {
  static HomepageController get to => Get.find();

  bool loading = true;
  List<Medication> medicationsData = [];
  List<EachMedication> scheduleList = [],
      dueScheduleList = [],
      missedScheduleList = [];

  resetValues() {
    loading = false;
  }

  setAlarm({
    required int id,
    required TimeOfDay scheduleTime,
    required String title,
    required String body,
  }) async {
    final now = DateTime.now();
    DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      scheduleTime.hour,
      scheduleTime.minute,
    );

    // Check if time schedule is past already
    Duration difference = alarmTime.difference(DateTime.now());
    difference = difference + const Duration(minutes: 1);

    if (difference.isNegative == false) {
      // Define Alarm Parameters
      final alarmSettings = AlarmSettings(
        id: id,
        dateTime: alarmTime,
        assetAudioPath: 'assets/alarm.mp3',
        loopAudio: false, 
        vibrate: true,
        volume: 0.8,
        fadeDuration: 3.0,
        notificationTitle: title,
        notificationBody: body,
        enableNotificationOnKill: true,
        androidFullScreenIntent: true,
      );

      // Set the alarm
      await Alarm.set(alarmSettings: alarmSettings);
      print("Done setting alarm for $title at ${alarmTime.toIso8601String()}");
    }
  }

  getAllMedicationsData() async {
    loading = true;
    await fetchMedicationsData();
  }

  fetchMedicationsData() async {
    medicationsData = [];
    scheduleList = [];

    await FirebaseFirestore.instance
        .collection('schedule')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var med in querySnapshot.docs) {
        medicationsData.add(Medication.fromDataSnapshot(med));
        print(med["medicationName"]);
      }
    });

    int idInt = 0;
    for (var medData in medicationsData) {
      print(" ||||||||||| For ${medData.medicationName} ");
      for (var time in medData.times) {
        EachMedication eachMedication = EachMedication(
          id: idInt,
          medicationName: medData.medicationName,
          selectedAmount: medData.selectedAmount,
          selectedDose: medData.selectedDose,
          noOfTimes: medData.noOfTimes,
          noOfDays: medData.noOfDays,
          time: time,
          colour: medData.colour,
          uid: medData.uid,
        );

        scheduleList.add(eachMedication);
        idInt += 1;
        // await

        setAlarm(
          id: eachMedication.id,
          scheduleTime: eachMedication.time,
          title: eachMedication.medicationName,
          body:
              "Time to take ${eachMedication.selectedAmount} ${eachMedication.selectedDose} of ${eachMedication.medicationName}",
        );
      }
    }
    print(
        " >>>>>>>>>>> scheduleList length = ${scheduleList.length} \nwith first and last times: ${scheduleList.first.time} | ${scheduleList.last.time} ");

    // Sort scheduleList according to earliest times
    scheduleList.sort((a, b) {
      final aTime = a.time;
      final bTime = b.time;
      return aTime.hour != bTime.hour
          ? aTime.hour.compareTo(bTime.hour)
          : aTime.minute.compareTo(bTime.minute);
    });
    print(
        " >>>>>>>>>>> scheduleList length = ${scheduleList.length} \nwith first and last times: ${scheduleList.first.time} | ${scheduleList.last.time} ");
    updateListWithTime();
    loading = false;
    update();
  }

  updateListWithTime() {
    int len = scheduleList.length;
    for (int i = 0; i < len; i++) {
      final now = DateTime.now();
      DateTime time = DateTime(
        now.year,
        now.month,
        now.day,
        scheduleList[0].time.hour,
        scheduleList[0].time.minute,
      );

      // Check if time schedule is past already
      Duration difference = time.difference(DateTime.now());
      difference = difference + const Duration(minutes: 1);
      print(" ******** Time difference in minutes: ${difference.inMinutes} ");

      if (difference.isNegative) {
        EachMedication firstItem = scheduleList.removeAt(0);
        scheduleList.add(firstItem);
        print(
            " ---------- Adding ${firstItem.medicationName} to dueScheduleList");
        dueScheduleList.add(firstItem);

        // Ensure only one instance of an object with the same ID exists in the list
        print(
            " ^^^^^^ dueScheduleList len: ${dueScheduleList.length} -- ${dueScheduleList.first.id} | ${dueScheduleList.last.id}");
        final uniqueDueScheduleList = dueScheduleList
            .fold<List<EachMedication>>([],
                (List<EachMedication> result, currentObject) {
          if (!result.any((element) => element.id == currentObject.id)) {
            result.add(currentObject);
          }
          return result;
        });
        print(
            " @@@@@@ uniqueDueScheduleList len: ${uniqueDueScheduleList.length} ");
        dueScheduleList = uniqueDueScheduleList;
      } else {
        // Do nothing if the scheduled time is still in the future
      }
    }
  }

  checkDueSchedules() {
    // Checking if due schedule is missed or not,
    //it becomes missed after 30 minutes without user confirming they have taken it
    int len = dueScheduleList.length, indexSubtractor = 0;
    print(" _________ dueScheduleList len: ${dueScheduleList.length} ");
    if (len > 0) {
      for (int i = 0; i < len; i++) {
        final now = DateTime.now();
        DateTime time = DateTime(
          now.year,
          now.month,
          now.day,
          dueScheduleList[i - indexSubtractor].time.hour,
          dueScheduleList[i - indexSubtractor].time.minute,
        );

        Duration difference = time.difference(DateTime.now());
        difference = difference + const Duration(minutes: 1);
        print(" ******** Time difference in minutes: ${difference.inMinutes} ");
        if ((difference.inMinutes.abs() < 30)) {
          // Still keep in dueScheduleList
        } else {
          EachMedication overdueItem =
              dueScheduleList.removeAt(i - indexSubtractor);
          missedScheduleList.add(overdueItem);
          indexSubtractor += 1;
        }
      }
    }
    print(" ******** missedScheduleList : ${missedScheduleList.length} ");
  }

  removeFromFutureList() {
    print(
        " %%%%%%%% scheduleList First and last times : ${scheduleList.first.time} | ${scheduleList.last.time} ");
    // EachMedication firstItem =
    scheduleList.removeAt(0);
    // scheduleList.add(firstItem);
    print(
        " %%%%%%%% scheduleList First and last times : ${scheduleList.first.time} | ${scheduleList.last.time} ");
    update();
  }

  removeFromDueList(int index) {
    print(" ##### dueScheduleList $index : ${dueScheduleList[index].isTaken} ");
    dueScheduleList[index] = dueScheduleList[index].copyWith(isTaken: true);
    print(" &&&&& dueScheduleList $index : ${dueScheduleList[index].isTaken} ");
    // dueScheduleList.removeAt(index);
    update();
  }
}
