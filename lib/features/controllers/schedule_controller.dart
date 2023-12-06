import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';

class ScheduleController extends GetxController {
  static ScheduleController get to => Get.find();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController medicationNameController =
  TextEditingController();
  // final TextEditingController dosageController = TextEditingController();
  RxString selectedAmount = '1 pill'.obs;
  RxString selectedDose = '250 mg'.obs;
  RxInt noOfTimes = 1.obs;
  RxInt noOfDays = 1.obs;
  // Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  List<Rx<TimeOfDay>> selectedTime = [];
  Rx<String> selectedColor = "#808080".obs;
  final List<Rx<String>> colour = [
    "#808080".obs,
    "#FF0000".obs,
    "#0000FF".obs,
    "#FFFF00".obs,
    "#00FFFF".obs,
    "#FF00FF".obs,
  ];

  Color getColor(String colorHex) => Color(int.parse(colorHex.substring(1, colorHex.length), radix: 16) + 0xFF000000);

  bool showProgressBar = false;

  void incrementNoOfTimes() {
    noOfTimes.value = (noOfTimes.value >= 1) ? noOfTimes.value + 1 : 1;
  }

  void decrementNofOfTimes() {
    noOfTimes.value = (noOfTimes.value > 1) ? noOfTimes.value - 1 : 1;
  }

  void incrementNoOfDays() {
    noOfDays.value = (noOfDays.value >= 1) ? noOfDays.value + 1 : 1;
  }

  void decrementNofOfDays() {
    noOfDays.value = (noOfDays.value > 1) ? noOfDays.value - 1 : 1;
  }

  showTimePicker(BuildContext context, int fieldIndex) {
    Rx<TimeOfDay> selectedTimeTemp = selectedTime[fieldIndex];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              height: MediaQuery.of(context).copyWith().size.height / 2,
              child: Column(
                children: [
                  TimePickerSpinner(
                    is24HourMode: false,
                    normalTextStyle: const TextStyle(fontSize: 24, color: Colors.blue),
                    highlightedTextStyle: const TextStyle(fontSize: 24, color: Colors.black),
                    spacing: 50,
                    itemHeight: 80,
                    isForce2Digits: true,
                    onTimeChange: (time) {
                      if (time is TimeOfDay) {
                        setState(() {
                          selectedTimeTemp.value = time as TimeOfDay;
                        });
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      selectedTime[fieldIndex] = selectedTimeTemp;
                      Get.back();
                      update();
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Future addSchedule() async {
    try {
      List timeStrings = [];
      for (int i = 0; i < selectedTime.length; i++) {
        timeStrings.add(selectedTime[i].value.toString());
      }
      await firestore.collection('schedule').add({
        "medicationName": medicationNameController.text.trim(),
        "selectedAmount": selectedAmount.value,
        "selectedDose": selectedDose.value,
        "noOfTimes": noOfTimes.value,
        "noOfDays": noOfDays.value,
        "times": timeStrings,
        "colour": selectedColor.value,
        "uid": FirebaseAuth.instance.currentUser!.uid,
      }).then((value) {
        print("Val: $value");
        Get.snackbar("Successful",
            "Schedule uploaded successfully.");
      });

      medicationNameController.text = '';
      selectedAmount = '1 pill'.obs;
      selectedDose = '250 mg'.obs;
      noOfTimes = 1.obs;
      noOfDays = 1.obs;
      selectedTime = [];
      selectedColor = "#808080".obs;
    } catch (e) {
      print(" >>>>>>>>>>>> Exception occurred: ${e.toString()}");
    }
  }


}


