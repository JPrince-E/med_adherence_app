// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_adherence_app/features/controllers/home_controller.dart';
import 'package:med_adherence_app/features/models/medication_model.dart';
import 'package:med_adherence_app/global.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:med_adherence_app/utils/extension_and_methods/time_extensions.dart';
import 'package:timer_builder/timer_builder.dart';

class HomePage extends StatefulWidget {
  String? userID;

  HomePage({
    super.key,
    this.userID,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

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
    if (_controller.medicationsData.isEmpty == true) {
      _controller.getAllMedicationsData();
      _controller.loading= false;
    }
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
        title: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text("Hi $fullName"),
            ],
          ),
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
      body: _controller.loading == true
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue,
              ),
            )
          : TimerBuilder.periodic(
              const Duration(minutes: 1),
              builder: (context) {
                print(' >>>>> Checking time . . .');
                // Continously check if time for the medication is due
                _controller.updateListWithTime();
                _controller.checkDueSchedules();
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    color: Colors.transparent,
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
                        const SizedBox(height: 13),
                        const Divider(thickness: 1.5, color: Colors.grey),
                        const SizedBox(height: 20),
                        _controller.dueScheduleList.isNotEmpty &&
                                _controller.checkIfAllIsTaken() == false
                            ? const Row(
                                children: [
                                  Text(
                                    "Due Already",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                        _controller.dueScheduleList.isNotEmpty
                            ? Container(
                                color: Colors.grey[50],
                                child: ListView.builder(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  reverse: false,
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: _controller.dueScheduleList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return _buildDueMedicationCard(
                                      _controller.dueScheduleList[index],
                                      index,
                                    );
                                  },
                                ),
                              )
                            : const SizedBox.shrink(),
                        Container(
                          color: Colors.grey[50],
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            reverse: false,
                            physics: const ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _controller.scheduleList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return index == 0
                                  ? _buildUpNextMedicationCard(
                                      _controller.scheduleList[index],
                                    )
                                  : _buildFutureMedicationCard(
                                      _controller.scheduleList[index],
                                    );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDueMedicationCard(EachMedication medicationSchedule, int index) {
    String hexColor = medicationSchedule.colour;

    return medicationSchedule.isTaken == true
        ? const SizedBox.shrink()
        : Card(
            elevation: 4,
            color: Colors.orange,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(
                        int.parse(hexColor.substring(1, 7), radix: 16) +
                            0xFF000000),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(
                          int.parse(hexColor.substring(1, 7), radix: 16) +
                              0xFF000000),
                      backgroundImage: const AssetImage("assets/logo.png"),
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
                          const SizedBox(width: 30),
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
                      // Show time ago
                      Text(
                        convertToTimeAgo(medicationSchedule.time),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Handle card tap
                  },
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Remove this element from the list using its index
                          _controller.removeFromDueList(index);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 45, vertical: 3),
                        ),
                        child: Icon(Icons.cancel, color: Colors.red.shade800),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Show thumbs up dialog here
                          _showCoolDialog();
                          _controller.removeFromDueList(index);
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 45, vertical: 3),
                        ),
                        child:
                            const Icon(Icons.check_circle, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildUpNextMedicationCard(EachMedication medicationSchedule) {
    String hexColor = medicationSchedule.colour;

    return SizedBox(
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                "Up Next",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Card(
            elevation: 4,
            color: Colors.blue.shade600,
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(
                        int.parse(hexColor.substring(1, 7), radix: 16) +
                            0xFF000000),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(
                          int.parse(hexColor.substring(1, 7), radix: 16) +
                              0xFF000000),
                      backgroundImage: const AssetImage("assets/logo.png"),
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
                          const SizedBox(width: 30),
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
                      // Show time remaining
                      Text(
                        convertTimeOfDayToDateTime(medicationSchedule.time),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Handle card tap
                  },
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Remove this from the schedule list
                          _showConfirmationDialog(
                            context,
                            " ${medicationSchedule.medicationName}, ${medicationSchedule.selectedAmount}, ${medicationSchedule.selectedDose}",
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 45, vertical: 3),
                        ),
                        child: Icon(Icons.cancel, color: Colors.red.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureMedicationCard(EachMedication medicationSchedule) {
    String hexColor = medicationSchedule.colour;

    return Card(
      elevation: 4,
      color: Colors.blue.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
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
                    int.parse(hexColor.substring(1, 7), radix: 16) +
                        0xFF000000),
                backgroundImage: const AssetImage("assets/logo.png"),
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
                // Show time remaining
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
            onTap: () {
              // Handle card tap
            },
          ),
        ],
      ),
    );
  }

  _showCoolDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Well done!',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset('assets/thumbs_up.gif', height: 120),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Okay',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, String medicationSummary) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
          ),
          title: const Text(
            'Confirm',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to cancel notification for $medicationSummary?',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Cancel logic here
                    _controller.removeFromFutureList();
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: Text(
                    'YES',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'NO',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

String _formatTime(TimeOfDay time) {
  return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
}
