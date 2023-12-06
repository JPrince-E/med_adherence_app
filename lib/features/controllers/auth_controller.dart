import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med_adherence_app/features/models/person.dart' as personModel;
import 'package:med_adherence_app/features/views/home_screen.dart';
import 'package:med_adherence_app/features/views/login_screen.dart';

class AuthController extends GetxController {
  static AuthController authController = Get.find();

  late Rx<User?> firebaseCurrentUser;

  late Rx<File?> pickedFile = Rx<File?>(null);

  File? get profileImage => pickedFile.value;
  XFile? imageFile;

  Future<void> pickImage(String inputSource) async {
    imageFile = await ImagePicker().pickImage(
      source:
          inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );

    if (imageFile != null) {
      Get.snackbar(
        "Profile Image",
        "You have successfully picked your profile image.",
      );

      pickedFile.value = File(imageFile!.path);
      update(); // Trigger reactivity

      // Close the dialog
      Get.close(
          1); // Use the identifier (1 in this case) associated with the dialog
    }
  }

  pickedImageFileFromGallery() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      Get.snackbar(
        "Profile Image",
        "You have successfully picked your profile image.",
      );

      pickedFile.value = File(imageFile!.path);
      // Close the dialog
      Get.close(
          1); // Use the identifier (1 in this case) associated with the dialog
    }
  }

  captureImageFromPhoneCamera() async {
    imageFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (imageFile != null) {
      Get.snackbar(
        "Profile Image",
        "You have successfully captured your profile image using the camera.",
      );

      pickedFile.value = File(imageFile!.path);
      // Close the dialog
      Get.close(
          1); // Use the identifier (1 in this case) associated with the dialog
    }
  }

  void showImageSourceDialog() {
    Get.defaultDialog(
      barrierDismissible: true,
      title: "Add Image",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              await captureImageFromPhoneCamera();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade200,
            ),
            child: const Text("Camera"),
          ),
          ElevatedButton(
            onPressed: () async {
              await pickedImageFileFromGallery();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade200,
            ),
            child: const Text("Gallery"),
          ),
        ],
      ),
    );
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    Reference referenceStorage = FirebaseStorage.instance
        .ref()
        .child("Profile Images")
        .child(FirebaseAuth.instance.currentUser!.uid);

    UploadTask task = referenceStorage.putFile(imageFile);
    TaskSnapshot snapshot = await task;

    String downloadUrlOfImage = await snapshot.ref.getDownloadURL();

    return downloadUrlOfImage;
  }

  createUser(
    File imageProfile,
    String fullName,
    String email,
    String password,
  ) async {
    try{
      //1. authenticate user and create user with Email and Password
      UserCredential credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //2. upload image to storage
      String urlOfDownloadedImage = await uploadImageToStorage(imageProfile);

      //3. save user info to firestore database
      personModel.Person personInstance = personModel.Person(
          //personal Info
          uid: FirebaseAuth.instance.currentUser!.uid,
          imageProfile: urlOfDownloadedImage,
          fullName: fullName,
          email: email,
          password: password,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(personInstance.toJson());

      Get.snackbar("Account Created", "Congratulation, your account has been created");
      Get.off(() => HomeScreen(userID: FirebaseAuth.instance.currentUser!.uid,));
    } catch (errorMsg) {
      Get.snackbar(
          "Account Creation Unsuccessful", "Error occurred: $errorMsg");
    }
  }

  loginUser(String emailUser, String passwordUser) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailUser, password: passwordUser);

      Get.snackbar("Logged in Successful", "You are logged in successfully.");

      Get.off(() => HomeScreen(userID: FirebaseAuth.instance.currentUser!.uid,));
    } catch(errorMsg) {
      Get.snackbar("Login Unsuccessful", "Error occurred: $errorMsg");
    }
  }

  checkIfUserIsLoggedIn(User? currentUser) {
    if(currentUser == null) {
      Get.to(const LoginScreen());
    }else {
      Get.off(() => HomeScreen(userID: FirebaseAuth.instance.currentUser!.uid,));

    }
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();

    firebaseCurrentUser = Rx<User?>(FirebaseAuth.instance.currentUser);
    firebaseCurrentUser.bindStream(FirebaseAuth.instance.authStateChanges());

    ever(firebaseCurrentUser, checkIfUserIsLoggedIn);

  }

}
