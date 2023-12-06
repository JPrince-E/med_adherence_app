import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:med_adherence_app/features/models/medication_model.dart';
import 'package:med_adherence_app/features/views/edit_schedule.dart';
import 'package:med_adherence_app/global.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Timer _timer;
  RxString formattedTime = RxString('');
  RxString formattedDate = RxString('');

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
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveUserInfo();
    retrieveMedInfo();

    // Set up a periodic timer to update the time every minute
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
                      // color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Text(
                  "   |   ",
                  style: TextStyle(
                      // color: Colors.grey,
                      ),
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
                      // color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            isToTake
                ? _view(screenHeight * 0.56)
                : Container(
                    color: Colors.red,
                  ),
          ],
        ),
      ),
    );
  }
}

Widget _view(double height) {
  return SingleChildScrollView(
    child: SizedBox(
      height: height,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('schedule').snapshots(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("...");
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
            print("1");
            return const Center(
              child: Text("No Schedule Available"),
            );
          } else {
            print("2");
            return ListView.builder(
              itemCount: snapshot.data.docs.length ?? 0,
              itemBuilder: (context, index) {
                Medication medication =
                    Medication.fromDataSnapshot(snapshot.data.docs[index]);

                String hexColor = medication.colour;
                return Card(
                  color: Colors.blue.shade200,
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
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
                        Text(
                          medication.selectedAmount,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                        Text(
                          medication.selectedDose,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        // Handle edit button click
                        Get.to(const EditSchedule());
                      },
                    ),
                    onTap: () {
                      // Handle card tap
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    ),
  );
}
