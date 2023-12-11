import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:med_adherence_app/features/models/medication_model.dart';
import 'package:med_adherence_app/features/views/edit_schedule.dart';
import 'package:med_adherence_app/global.dart';
import 'package:collection/collection.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  RxString formattedTime = RxString('');
  RxString formattedDate = RxString('');

  late String medicationTime = '';

  bool isToTake = true;

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

  String medicationName = '';
  String selectedAmount = '';
  String selectedDose = '';
  String noOfTimes = '';
  String noOfDays = '';
  String times = '';
  String colour = '';

  retrieveMedInfo() async {
    FirebaseFirestore.instance
        .collection("schedule")
        .doc(currentUserID)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        setState(() {
          medicationName = snapshot.data()!["medicationName"];
          selectedAmount = snapshot.data()!["selectedAmount"];
          selectedDose = snapshot.data()!["selectedDose"];
          noOfTimes = snapshot.data()!["noOfTimes"];
          noOfDays = snapshot.data()!["noOfDays"];
          times = snapshot.data()!["times"];
          colour = snapshot.data()!["colour"];

          medicationTime = snapshot.data()!["medicationTime"];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    retrieveUserInfo();
    retrieveMedInfo();

    _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      _updateTime();
    });

    _updateTime();
  }

  void _updateTime() {
    DateTime now = DateTime.now();
    formattedTime.value = DateFormat('h:mm a').format(now);

    String newFormattedDate = DateFormat('E MMM d').format(now);
    if (formattedDate.value != newFormattedDate) {
      formattedDate.value = newFormattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

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
              // Handle emergency button press
            },
            icon: const Icon(
              Icons.contact_emergency,
              color: Colors.red,
              size: 45,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Obx(() => Text(
                      "$formattedDate\n${formattedTime.value}",
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    )),
                CircleAvatar(
                  backgroundImage: NetworkImage(imageProfile),
                  radius: 45,
                ),
              ],
            ),
            const SizedBox(
              height: 24,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      isToTake = true;
                    });
                  },
                  child: const Text(
                    "Drugs To Take",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Text(
                  "   |   ",
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isToTake = false;
                    });
                  },
                  child: const Text(
                    "Drugs Taken",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            isToTake
                ? _viewToTake(screenHeight * 0.56)
                : _viewTaken(screenHeight * 0.56)
          ],
        ),
      ),
    );
  }
}

Widget _viewToTake(double height) {
  return SingleChildScrollView(
    child: SizedBox(
      height: height,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('schedule').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
            return const Center(
              child: Text("No Schedule Available"),
            );
          } else {
            List<Medication> medicationsList = [];
            for (var med in snapshot.data.docs) {
              medicationsList.add(Medication.fromDataSnapshot(med));
            }

            List<Medication> drugsToTake = [];
            List<Medication> drugsTaken = [];

            DateTime now = DateTime.now();

            for (var med in medicationsList) {
              List<TimeOfDay> medicationTimes = med.times;

              if (medicationTimes.isNotEmpty) {
                bool shouldAddToDrugsToTake = false;
                for (var time in medicationTimes) {
                  DateTime medicationDateTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    time.hour,
                    time.minute,
                  );

                  if (medicationDateTime.isAfter(now)) {
                    shouldAddToDrugsToTake = true;
                  } else {
                    drugsTaken.add(med);
                  }
                }

                if (shouldAddToDrugsToTake) {
                  drugsToTake.add(med);
                }
              }
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildMedicationList("Drugs To Take", drugsToTake),
                  const SizedBox(height: 16.0),
                ],
              ),
            );
          }
        },
      ),
    ),
  );
}

Widget _viewTaken(double height) {
  return SingleChildScrollView(
    child: SizedBox(
      height: height,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('schedule').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
            return const Center(
              child: Text("No Schedule Available"),
            );
          } else {
            List<Medication> medicationsList = [];
            for (var med in snapshot.data.docs) {
              medicationsList.add(Medication.fromDataSnapshot(med));
            }

            List<Medication> drugsTaken = [];

            DateTime now = DateTime.now();

            for (var med in medicationsList) {
              List<TimeOfDay> medicationTimes = med.times;

              if (medicationTimes.isNotEmpty) {
                bool shouldAddToDrugsToTake = false;
                for (var time in medicationTimes) {
                  DateTime medicationDateTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    time.hour,
                    time.minute,
                  );

                  if (medicationDateTime.isAfter(now)) {
                    shouldAddToDrugsToTake = true;
                  } else {
                    drugsTaken.add(med);
                  }
                }
              }
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildMedicationList("Drugs Taken", drugsTaken),
                  const SizedBox(height: 16.0),
                ],
              ),
            );
          }
        },
      ),
    ),
  );
}


Widget _buildMedicationList(String title, List<Medication> medications) {
  String? medicationTime;
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0),
        if (medications.isNotEmpty)
          ...medications.map(
              (medication) => _buildMedicationCard(medication)),
        if (medications.isEmpty)
          const Center(
            child: Text("No Medication in this category"),
          ),
      ],
    ),
  );
}

Widget _buildMedicationCard(Medication medication) {
  String hexColor = medication.colour;

  // Extract the relevant time directly from the medication object
  TimeOfDay? relevantTime = medication.times.isNotEmpty ? medication.times.first : null;


  return Card(
    color: Colors.blue.shade200,
    margin: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000),
              backgroundImage: const AssetImage("images/logo.png"),
            ),
          ),
          title: Text(
            medication.medicationName,
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
                    medication.selectedAmount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(
                    width: 1,
                  ),
                  Text(
                    medication.selectedDose,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  if (relevantTime != null)
                    Text(
                      'Time: ${_formatTime(relevantTime)}', // Display the relevant time
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
              if (relevantTime != null)
                Text(
                  'Relevant Time: ${_formatTime(relevantTime)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              // Handle "Edit" button click
              Get.to(const EditSchedule());
            },
            icon: Icon(Icons.edit, color: Colors.white),
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
                _markAsNotTaken(medication);
              },
              icon: Icon(Icons.cancel, color: Colors.red),
            ),
            IconButton(
              onPressed: () {
                // Handle "Mark as Taken" button click
                // Move medication to "Drugs Taken"
                _markAsTaken(medication);
              },
              icon: Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ),
      ],
    ),
  );
}

String _formatTime(TimeOfDay time) {
  return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}


void _markAsTaken(Medication medication) {
  // Add logic to mark medication as taken and move it to "Drugs Taken"
  // You can update the Firestore data or use other state management solutions
}

void _markAsNotTaken(Medication medication) {
  // Add logic to mark medication as not taken and move it back to "Drugs To Take"
  // You can update the Firestore data or use other state management solutions
}
