// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:med_adherence_app/features/models/medication_model.dart';
import 'package:med_adherence_app/features/views/edit_schedule.dart';
import 'package:med_adherence_app/global.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

String _formatTime(TimeOfDay time) {
  return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}

bool isToTake = true;
List<Medication> medicationsToTake = [];
List<Medication> medicationsTaken = [];

class _HomePageState extends State<HomePage> {
  // late Timer _timer;
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

    // _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) {
    //   _updateTime();
    // });

    // _updateTime();
  }

  // void _updateTime() {
  //   DateTime now = DateTime.now();
  //   formattedTime.value = DateFormat('h:mm a').format(now);

  //   String newFormattedDate = DateFormat('E MMM d').format(now);
  //   if (formattedDate.value != newFormattedDate) {
  //     formattedDate.value = newFormattedDate;

  //     // Check if the current time has passed the scheduled time for each medication
  //     moveMedicationsToTaken(now);
  //   }
  // }

  void moveMedicationsToTaken(DateTime now) {
    FirebaseFirestore.instance
        .collection("schedule")
        .doc(currentUserID)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        List<Medication> medicationsList = [];
        for (var med in snapshot.data()!["medications"]) {
          medicationsList.add(Medication.fromDataSnapshot(med));
        }

        // Filter medications whose times have passed
        List<Medication> medicationsToMove = medicationsList
            .where((med) =>
                med.times.isNotEmpty &&
                med.times.any((time) => DateTime(
                        now.year, now.month, now.day, time.hour, time.minute)
                    .isBefore(now)))
            .toList();

        // Move medications to "Drugs Taken" for the specific occurrence
        for (var medication in medicationsToMove) {
          for (var time in medication.times) {
            if (DateTime(now.year, now.month, now.day, time.hour, time.minute)
                .isBefore(now)) {
              // Move only the specific occurrence to "Drugs Taken"
              _markAsTaken(medication.copyWith(times: [
                time
              ])); // Update the copy of the medication with only the specific time
            }
          }
        }
      }
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Obx(() => Text(
                //       "$formattedDate\n${formattedTime.value}",
                //       style: const TextStyle(
                //         color: Colors.black,
                //         fontSize: 25,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     )),

                DigitalClock(
                  hourDigitDecoration: BoxDecoration(
                      color: Colors.yellow,
                      border: Border.all(color: Colors.blue, width: 2)),
                  minuteDigitDecoration: BoxDecoration(
                      color: Colors.yellow,
                      border: Border.all(color: Colors.red, width: 2)),
                  secondDigitDecoration: BoxDecoration(
                      color: Colors.blueGrey,
                      border: Border.all(color: Colors.blue),
                      shape: BoxShape.circle),
                  secondDigitTextStyle: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Colors.white),
                ),
                CircleAvatar(
                  backgroundImage: NetworkImage(imageProfile),
                  radius: 45,
                ),
              ],
            ),
            const SizedBox(height: 24),
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

            DateTime now = DateTime.now();
            List<Medication> drugsToTake = medicationsList
                .where((med) =>
                    med.times.isNotEmpty &&
                    med.times.any((time) => DateTime(now.year, now.month,
                            now.day, time.hour, time.minute)
                        .isAfter(now)))
                .toList();

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

            DateTime now = DateTime.now();
            List<Medication> drugsTaken = medicationsList
                .where((med) =>
                    med.times.isNotEmpty &&
                    med.times.any((time) => DateTime(now.year, now.month,
                            now.day, time.hour, time.minute)
                        .isBefore(now)))
                .toList();

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
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8.0),
        if (medications.isNotEmpty)
          ...medications.map(
            (medication) {
              // Create a card for each time associated with the medication
              return Column(
                children: medication.times
                    .map((time) =>
                        _buildMedicationCard(medication, time, isToTake))
                    .toList(),
              );
            },
          ),
        if (medications.isEmpty)
          const Center(
            child: Text("No Medication in this category"),
          ),
      ],
    ),
  );
}

Widget _buildMedicationCard(
    Medication medication, TimeOfDay time, bool isToTake) {
  String hexColor = medication.colour;

  return Card(
    color: Colors.blue.shade200,
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
                    width: 30,
                  ),
                  Text(
                    medication.selectedDose,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              Text(
                'Time: ${_formatTime(time)}',
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
                _markAsNotTaken(medication);
              },
              icon: const Icon(Icons.cancel, color: Colors.red),
            ),
            IconButton(
              onPressed: () {
                // Handle "Mark as Taken" button click
                // Move medication to "Drugs Taken"
                _markAsTaken(medication);
              },
              icon: const Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ),
      ],
    ),
  );
}

void _markAsTaken(Medication medication) {
  // Add logic to mark medication as taken and move it to "Drugs Taken"
  // You can update the Firestore data or use other state management solutions
}

void _markAsNotTaken(Medication medication) {
  // Add logic to mark medication as not taken and move it back to "Drugs To Take"
  // You can update the Firestore data or use other state management solutions
}
