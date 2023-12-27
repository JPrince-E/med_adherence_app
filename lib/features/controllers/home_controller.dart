// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:med_adherence_app/features/models/medication_model.dart';
import 'package:alarm/alarm.dart';

class HomepageController extends GetxController {
  static HomepageController get to => Get.find();

  bool loading = true;
  List<Medication> medicationsData = [];
  List<EachMedication> scheduleList = [];

  resetValues() {
    loading = false;
  }

  getAllMedicationsData() async {
    loading = true;
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

    for (var medData in medicationsData) {
      print(" ||||||||||| For ${medData.medicationName} ");
      for (var time in medData.times) {
        print(" time time ");
        EachMedication eachMedication = EachMedication(
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

    loading = false;
    update();
  }
}
