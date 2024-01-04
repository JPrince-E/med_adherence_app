// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:med_adherence_app/features/views/emergency_settings.dart';
import 'package:med_adherence_app/features/views/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  String? userID;

  ProfileScreen({
    super.key,
    this.userID,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String fullName = '', email = ''
      // location = '', gender = ''
  ;
  // int? age;
  String imageProfile =
      'https://firebasestorage.googleapis.com/v0/b/dating-app-a5c06.appspot.com/o/Place%20Holder%2Fprofile_avatar.jpg?alt=media&token=dea921b1-1228-47c2-bc7b-01fb05bd8e2d';

  retrieveUserInfo() async {
    FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userID)
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
          // location = snapshot.data()!["location"];
          // gender = snapshot.data()!["gender"];
          // age = snapshot.data()!["age"];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.blue.shade800,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(imageProfile),
              backgroundColor: Colors.white, // Add a background color
              foregroundColor: Colors.black, // Add a border color
            ),
            const SizedBox(height: 20),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Icon(
            //       Icons.person_2_outlined,
            //       color: Colors.blue.shade900,
            //       size: 30,
            //     ),
            //     const SizedBox(width: 10),
            //     Text(
            //       fullName,
            //       style: const TextStyle(
            //           fontSize: 24, fontWeight: FontWeight.bold),
            //       textAlign: TextAlign.center,
            //     ),
            //   ],
            // ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_2_outlined,
                        color: Colors.blue.shade900,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        fullName,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: Colors.amber.shade900,
                        size: 30,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // const SizedBox(height: 15),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Icon(
                  //       Icons.supervisor_account_rounded,
                  //       color: Colors.purple.shade900,
                  //       size: 30,
                  //     ),
                  //     const SizedBox(width: 10),
                  //     Text(
                  //       gender,
                  //       style: const TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 15),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Icon(
                  //       Icons.assignment_ind_outlined,
                  //       color: Colors.green.shade800,
                  //       size: 30,
                  //     ),
                  //     const SizedBox(width: 10),
                  //     Text(
                  //       age.toString(),
                  //       style: const TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 15),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Icon(
                  //       Icons.location_on_outlined,
                  //       color: Colors.red.shade900,
                  //       size: 30,
                  //     ),
                  //     const SizedBox(width: 10),
                  //     Text(
                  //       location,
                  //       style: const TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //       textAlign: TextAlign.center,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                shrinkWrap: true,
                children: [
                  // ListTile(
                  //   leading: const Icon(Icons.person, size: 30),
                  //   horizontalTitleGap: 50,
                  //   title: const Text("Edit Profile"),
                  //   onTap: () {
                  //     Get.to(const EditProfile());
                  //   },
                  // ),
                  wrapperContainer(
                    child: ListTile(
                      leading: const Icon(
                        Icons.contact_emergency_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      title: const Text(
                        "Set Up Emergency",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onTap: () {
                        Get.to(EmergencyScreen());
                      },
                    ),
                  ),
                  wrapperContainer(
                    color: Colors.red,
                    child: ListTile(
                      leading: const Icon(
                        Icons.logout,
                        size: 30,
                        color: Colors.white,
                      ),
                      title: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onTap: () {
                        Get.off(const LoginScreen());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget wrapperContainer({required Widget child, Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.blue, // Blue background color
        border: Border.all(color: Colors.orange, width: 2), // Orange border
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(5),
      child: child,
    );
  }
}
