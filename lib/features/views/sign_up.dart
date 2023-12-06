import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:med_adherence_app/features/controllers/auth_controller.dart';
import 'package:med_adherence_app/features/views/login_screen.dart';

class SignUpScreen extends StatefulWidget {

  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController fullNameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  bool showProgressBar = false;

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Choose image circle avatar
              Obx(
                    () => authController.pickedFile.value == null
                    ? const CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage("images/profile.png"),
                  backgroundColor: Colors.black,
                )
                    : Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                    image: DecorationImage(
                      fit: BoxFit.fitHeight,
                      image: FileImage(File(authController.pickedFile.value!.path)),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  authController.showImageSourceDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade200,
                ),
                child: const Text('Select Image'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: fullNameTextEditingController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailTextEditingController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordTextEditingController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async{
                  if(authController.imageFile != null) {
                    if(fullNameTextEditingController.text.trim().isNotEmpty && emailTextEditingController.text
                        .trim()
                        .isNotEmpty &&
                        passwordTextEditingController.text
                            .trim()
                            .isNotEmpty) {
                      setState(() {
                        showProgressBar = true;
                      });
                      await authController.createUser(
                          authController.profileImage!,
                          fullNameTextEditingController.text.trim(),
                          emailTextEditingController.text.trim(),
                  passwordTextEditingController.text.trim(),
                      );
                      setState(() {
                        showProgressBar = false;
                            authController.imageFile = null;
                      });

                    } else {
                      Get.snackbar("A Field is Empty",
                          "Please fill out all fields in text fields.");
                    }
                  } else {
                    Get.snackbar("Image File Missing",
                        "Please pick image from gallery or capture with camera");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade200,
                ),
                child: const Text('Sign Up'),
              ),

              const SizedBox(
                height: 16,
              ),

              //already have an account login here button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: 16,
                      // color: Colors.blueAccent,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Text(
                      "Login Here",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 16,
              ),

              showProgressBar == true
                  ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
