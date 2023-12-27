// ignore_for_file: avoid_print

// /*
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
      body: Padding(
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
                      DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
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
      ),
    );
  }
}

// Widget _viewToTake(double height) {
//   return SingleChildScrollView(
//     child: SizedBox(
//       child: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection('schedule').snapshots(),
//         builder: (context, AsyncSnapshot snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
//             return const Center(
//               child: Text("No Schedule Available"),
//             );
//           } else {
//             List<Medication> medicationsList = [];
//             for (var med in snapshot.data.docs) {
//               medicationsList.add(Medication.fromDataSnapshot(med));
//             }

//             DateTime now = DateTime.now();
//             List<Medication> drugsToTake = medicationsList
//                 .where((med) =>
//                     med.times.isNotEmpty &&
//                     med.times.any((time) => DateTime(now.year, now.month,
//                             now.day, time.hour, time.minute)
//                         .isAfter(now)))
//                 .toList();

//             return SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   _buildMedicationList(drugsToTake),
//                   const SizedBox(height: 16.0),
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//     ),
//   );
// }

// Widget _buildMedicationList(List<Medication> medications) {
//   return SingleChildScrollView(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(height: 8.0),
//         if (medications.isNotEmpty)
//           ...medications.map(
//             (medication) {
//               // Create a card for each time associated with the medication
//               return Column(
//                 children: medication.times
//                     .map((time) =>
//                         _buildMedicationCard(medication, time, isToTake))
//                     .toList(),
//               );
//             },
//           ),
//         if (medications.isEmpty)
//           const Center(
//             child: Text("No Medication in this category"),
//           ),
//       ],
//     ),
//   );
// }

Widget _buildMedicationCard(EachMedication medicationSchedule) {
  String hexColor = medicationSchedule.colour;

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
