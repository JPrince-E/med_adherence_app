// ignore_for_file: avoid_print

// /*
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:med_adherence_app/features/controllers/home_controller.dart';
import 'package:med_adherence_app/features/models/medication_model.dart';
import 'package:med_adherence_app/features/views/edit_schedule.dart';
import 'package:med_adherence_app/global.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:med_adherence_app/utils/extension_and_methods/time_extensions.dart';
import 'package:timer_builder/timer_builder.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

String _formatTime(TimeOfDay time) {
  return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}

List<Medication> medicationsToTake = [];
List<Medication> medicationsTaken = [];

class _HomePageState extends State<HomePage> {
  final HomepageController _controller = HomepageController.to;

  late Timer _timer;

  String fullName = '';
  String email = '';
  String imageProfile =
      'https://firebasestorage.googleapis.com/v0/b/dating-app-a5c06.appspot.com/o/Place%20Holder%2Fprofile_avatar.jpg?alt=media&token=dea921b1-1228-47c2-bc7b-01fb05bd8e2d';

  retrieveUserInfo() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(currentUserID)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        if (snapshot.data()!["imageProfile"] != null) {
          setState(() {
            imageProfile = snapshot.data()!["imageProfile"];
          });
        }
        setState(() {
          fullName = snapshot.data()!["fullName"];
          email = snapshot.data()!["email"];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Trigger rebuild every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      // setState(() {});
    });
    retrieveUserInfo();
    _controller.getAllMedicationsData();
  }

  void makeEmergencyCall() async {
    DocumentSnapshot emergencyContactSnapshot = await FirebaseFirestore.instance
        .collection("emergencyContacts")
        .doc(currentUserID)
        .get();

    print('Emergency Contact Snapshot: ${emergencyContactSnapshot.data()}');

    if (emergencyContactSnapshot.exists &&
        emergencyContactSnapshot.data() != null) {
      Map<String, dynamic> emergencyData =
          emergencyContactSnapshot.data() as Map<String, dynamic>;

      if (emergencyData.containsKey('number')) {
        String emergencyNumber = emergencyData['number'];

        if (emergencyNumber.isNotEmpty) {
          try {
            await launch('tel:$emergencyNumber');
            print('Could launch $emergencyNumber');
          } catch (e) {
            print('Error launching $emergencyNumber: $e');
            // Provide user feedback here if needed
          }
        } else {
          print('Emergency contact number is null or empty');
          // Provide user feedback here if needed
        }
      } else {
        print('Invalid data format for emergency contact in the database');
        // Provide user feedback here if needed
      }
    } else {
      print('Emergency contact not found in the database');
      // Provide user feedback here if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            Text("Hi $fullName"),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          const Text("Emergency"),
          IconButton(
            onPressed: () {
              makeEmergencyCall();
            },
            icon: const Icon(
              Icons.contact_emergency,
              color: Colors.red,
              size: 45,
            ),
          ),
        ],
      ),
      body: TimerBuilder.periodic(Duration(minutes: 1), builder: (context) {
        print(' >>>>> Checking time . . .');
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.yMMMMEEEEd()
                            .format(DateTime.now())
                            .toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      DigitalClock(
                        is24HourTimeFormat: false,
                        hourMinuteDigitTextStyle: const TextStyle(
                          fontSize: 35,
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                        showSecondsDigit: false,
                        amPmDigitTextStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundImage: NetworkImage(imageProfile),
                    radius: 45,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _controller.loading == true
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue,
                    )
                  : Expanded(
                      child: Container(
                        color: Colors.grey[50],
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          reverse: false,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _controller.scheduleList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildMedicationCard(
                              _controller.scheduleList[index],
                            );
                          },
                        ),
                      ),
                    ),
            ],
          ),
        );
      }),
    );
  }
}

Widget _buildMedicationCard(EachMedication medicationSchedule) {
  String hexColor = medicationSchedule.colour;

  return Card(
    elevation: 4,
    color: Colors.blue.shade100,
    margin: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Color(
                int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(
                  int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000),
              backgroundImage: const AssetImage("images/logo.png"),
            ),
          ),
          title: Text(
            medicationSchedule.medicationName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    medicationSchedule.selectedAmount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Text(
                    medicationSchedule.selectedDose,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Text(
                'Time: ${_formatTime(medicationSchedule.time)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
              ),
              // Show time rmaining
              Text(
                convertTimeOfDayToDateTime(medicationSchedule.time),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              // Handle "Edit" button click
              Get.to(const EditSchedule());
            },
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
          onTap: () {
            // Handle card tap
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                // Handle "Mark as Not Taken" button click
                // Move medication back to "Drugs To Take"
                // _markAsNotTaken(medication);
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
            ),
            IconButton(
              onPressed: () {
                // Handle "Mark as Taken" button click
                // Move medication to "Drugs Taken"
                // _markAsTaken(medication);
              },
              icon: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ),
      ],
    ),
  );
}
