// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:med_adherence_app/features/models/medication_model.dart';

class HomepageController extends GetxController {
  static HomepageController get to => Get.find();

  bool loading = true;
  List<Medication> medicationsData = [];

  resetValues() {
    loading = false;
  }

  getAllMedicationsData() async {
    loading = true;
    medicationsData = [];

    FirebaseFirestore.instance
        .collection('schedule')
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var med in querySnapshot.docs) {
        medicationsData.add(Medication.fromDataSnapshot(med));
        print(med["medicationName"]);
      }
    });

    loading = false;
    update();
  }
}
