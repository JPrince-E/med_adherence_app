// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:med_adherence_app/features/views/emergency_settings.dart';
import 'package:med_adherence_app/features/views/home_page.dart';
import 'package:med_adherence_app/features/views/profile_screen.dart';
import 'package:med_adherence_app/features/views/schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  String? userID;

  HomeScreen({
    super.key,
    this.userID,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int screenIndex = 0;
  String senderName = "";
  List tabScreenList = [
    const HomePage(),
    ScheduleScreen(
      userID: FirebaseAuth.instance.currentUser!.uid,
    ),
    // const NotificationScreen(),
    ProfileScreen(
      userID: FirebaseAuth.instance.currentUser!.uid,
    ),
  ];

  String fullName = '';
  String email = '';
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
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    retrieveUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(
                fullName,
              ),
              accountEmail: Text(
                email,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(imageProfile),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.contact_emergency,
              ),
              title: const Text('Emergency'),
              onTap: () {
                Get.to(EmergencyScreen());
                setState(() {
                  screenIndex = 0;
                  Navigator.pop(context);
                });
              },
            ),

            const Spacer(), // Added to push the following items to the bottom
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (indexNumber) {
          setState(() {
            screenIndex = indexNumber;
          });
        },
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue.shade600,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        currentIndex: screenIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              size: 30,
            ),
            label: "Create",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(
          //     Icons.notifications,
          //     size: 30,
          //   ),
          //   label: "",
          // ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: "Profile",
          ),
        ],
      ),
      body: tabScreenList[screenIndex],
    );
  }
}
