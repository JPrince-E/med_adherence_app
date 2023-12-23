import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:med_adherence_app/features/controllers/auth_controller.dart';
import 'package:med_adherence_app/global.dart';
import 'package:med_adherence_app/utils/app_constants/app_colors.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}


String fullName = '';
String email = '';
String imageProfile =
    'https://firebasestorage.googleapis.com/v0/b/dating-app-a5c06.appspot.com/o/Place%20Holder%2Fprofile_avatar.jpg?alt=media&token=dea921b1-1228-47c2-bc7b-01fb05bd8e2d';


class _EditProfileState extends State<EditProfile> {
  final AuthController authController = Get.find<AuthController>();

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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GetBuilder<AuthController>(
              init: AuthController(),
              builder: (_) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Display the selected image or an empty CircleAvatar
                    authController.imageFILE != null
                        ? CircleAvatar(
                      radius: 80,
                      backgroundColor: AppColors.lighterGray,
                      backgroundImage:
                      FileImage(authController.imageFILE!),
                    )
                        : CircleAvatar(
                      radius: 80,
                      backgroundColor: AppColors.lighterGray,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Trigger the image selection from the gallery

                        // Ensure the UI is updated after image selection
                        setState(() {
                          authController.getFromGallery();
                          authController.update();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade200,
                      ),
                      child: const Text('Select Image'),
                    ),
                    const SizedBox(height: 20),
                    // TextFields for user input
                    TextField(
                      controller: authController.fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: authController.emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: authController.passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    // Sign-up button
                    ElevatedButton(
                      onPressed: () {
                        // SystemChannels.textInput.invokeMethod('TextInput.hide');
                        // authController.attemptToRegisterUser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade200,
                      ),
                      child: const Text('Edit'),
                    ),
                    const SizedBox(height: 16),
                    // Progress Indicator
                    authController.showLoading == true
                        ? const CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.pink),
                    )
                        : Container(),
                  ],
                );
              }),
        ),
      ),
    );
  }
}
