// ignore_for_file: unused_import, library_prefixes, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:med_adherence_app/app/helpers/sharedprefs.dart';
import 'package:med_adherence_app/app/resources/app.logger.dart';
import 'package:med_adherence_app/app/services/snackbar_service.dart';
import 'package:med_adherence_app/features/models/create_account_model.dart'
    as personModel;
import 'package:med_adherence_app/features/models/create_account_model.dart';
import 'package:med_adherence_app/features/shared/global_variables.dart';
import 'package:med_adherence_app/features/views/home_screen.dart';
import 'package:med_adherence_app/features/views/login_screen.dart';

var log = getLogger('CreateAuthController');

class AuthController extends GetxController {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  AuthController();

  bool showLoading = false;
  String errMessage = '', userExisting = ' ';

  File? imageFILE;
  String? imageUrl;

  void resetValues() {
    errMessage = "";
    showLoading = false;
    update();
  }

  updateVals() {
    update();
  }

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

  /// Upload image from gallery
  getFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      imageFILE = File(pickedFile.path);
      update();
    }
  }

  /// Snap image with Camera
  getFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      imageFILE = File(pickedFile.path);
      update();
    }
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


  void gotoSignInUserPage(BuildContext context) {
    print('Going to sign in user page');
    resetValues();
    Get.off(() => LoginScreen);
    // context.push('/login');
  }

  void gotoHomepage(BuildContext context) async {
    await saveSharedPrefsStringValue("fullName", emailController.text.trim());
    await saveSharedPrefsStringValue("imageProfile", imageUrl!);
    print('Going to homepage page');
    resetValues();
    update();
    Get.off(HomeScreen(
      userID: FirebaseAuth.instance.currentUser!.uid,
    ));
    update();
    // context.go('/homepage');
  }

  void attemptToSignInUser(BuildContext context) {
    print('attemptToSignInUser . . .');
    errMessage = '';

    if (emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty) {
      print('signing in user . . .');
      showLoading = true;
      errMessage = '';
      update();
      checkIfUserExistsForSignIn(context);
    } else {
      errMessage = 'All fields must be filled, and with no spaces';
      print("Errormessage: $errMessage");
      showLoading = false;
      update();
    }
  }



  Future<void> checkIfUserExistsForSignIn(BuildContext context) async {
    print('checking If User Exists');

    try {
      // Check if user data exists in Firestore
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: emailController.text.trim())
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // User exists in Firestore, sign in the user
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // If successful, navigate to the desired screen
        GlobalVariables.myUsername = emailController.text.trim();
        print("GlobalVariables.myUsername: ${GlobalVariables.myUsername}");

        Get.off(() => HomeScreen(
          userID: FirebaseAuth.instance.currentUser!.uid,
        ));
      } else {
        // User does not exist in Firestore
        print('User does not exist in Firestore');
        errMessage = "Error! User data not found";
        showLoading = false;
        update();
      }
    } catch (error) {
      // Handle Firestore error or authentication error
      print('Error: $error');
      errMessage = "Error! Unable to check user data";
      showLoading = false;
      update();
    }
  }

  Future<void> checkIfUserExistsInFirestore(BuildContext context) async {
    try {
      // Check if user data exists in Firestore
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: emailController.text.trim())
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // User exists in Firestore, navigate to home screen
        Get.off(() => HomeScreen(
          userID: FirebaseAuth.instance.currentUser!.uid,
        ));
      } else {
        // User does not exist in Firestore
        print('User does not exist in Firestore');
        errMessage = "Error! User data not found";
        showLoading = false;
        update();
      }
    } catch (error) {
      // Handle Firestore error
      print('Firestore error: $error');
      errMessage = "Error! Unable to check user data";
      showLoading = false;
      update();
    }
  }


  Future<void> registerUser(BuildContext context) async {
    if (imageFILE != null) {
      try {
        // Display loading indicator
        showLoading = true;
        update();

        // Create the user with email and password
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Upload image to cloud storage
        final firebaseStorage = FirebaseStorage.instance;
        var file = File(imageFILE!.path);
        var snapshot = await firebaseStorage
            .ref()
            .child(
            'user_profile_images/${userCredential.user!.uid}')
            .putFile(file);

        // Generate download URL
        var downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrl = downloadUrl;

        // Create UserAccountModel instance
        UserAccountModel createAccountData = UserAccountModel(
          uid: userCredential.user!.uid,
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          imageProfile: imageUrl,
        );

        // Save user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(createAccountData.toJson());
        update();

        // // Display success message
        // showCustomSnackBar(
        //   context,
        //   "User ${emailController.text.trim()} created",
        //       () {},
        //   Colors.green,
        //   1000,
        // );

        // Update state and navigate to home screen
        GlobalVariables.myUsername = emailController.text.trim();
        update();
        Get.snackbar(
          "Account Created",
          "Congratulations, your account has been created",
        );
        errMessage = "";
        showLoading = false;
        update();
        Get.off(() => HomeScreen(
          userID: FirebaseAuth.instance.currentUser!.uid,
        ));
        // gotoHomepage(context);
      } catch (error) {
        // Handle registration error
        print('------------------------------------------------------------------Error from here>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: $error');
        Get.snackbar(
          "Account Creation Unsuccessful",
          "Error occurred: $error",
        );
        print('------------------------------------------------------------------Error from here>>>>>>>>>>>>>>>>>>>>>>>>: $error');
        showLoading = false;
        update();
      }
      update();
    }
    update();
  }








  // Future<void> checkIfUserExistsForSignIn(BuildContext context) async {
  //   print('checking If User Exists');
  //
  //   try {
  //     // Sign in the user with email and password
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //       email: emailController.text.trim(),
  //       password: passwordController.text.trim(),
  //     );
  //
  //     // If successful, navigate to the desired screen
  //     GlobalVariables.myUsername = emailController.text.trim();
  //     print("GlobalVariables.myUsername: ${GlobalVariables.myUsername}");
  //     Get.off(() => HomeScreen(
  //           userID: FirebaseAuth.instance.currentUser!.uid,
  //         ));
  //     // context.pushReplacement('/homepage');
  //   } catch (error) {
  //     // Handle the authentication error
  //     print('Authentication error: $error');
  //     errMessage = "Error! Username or password incorrect";
  //     showLoading = false;
  //     update();
  //   }
  // }

  void attemptToRegisterUser(BuildContext context) {
    print('attemptToRegisterUser . . .');
    errMessage = '';
    showLoading = true;
    update();

    if (emailController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty) {
      print('Registering user . . .');
      showLoading = true;
      errMessage = '';
      update();
      registerUser(context);
      // checkIfUserExistsForCreateAccount(context);
    } else {
      errMessage = 'All fields must be filled, and with no spaces';
      print("Errormessage: $errMessage");
      showLoading = false;
      update();
    }
  }

  Future<void> checkIfUserExistsForCreateAccount(BuildContext context) async {
    print('checking If User Exists');
    final ref = FirebaseDatabase.instance.ref();
    final snapshot =
        await ref.child('user_details/${emailController.text.trim()}').get();
    if (snapshot.exists) {
      print("User exists: ${snapshot.value}");
      UserAccountModel userAccountModel =
          userAccountModelFromJson(jsonEncode(snapshot.value).toString());
      print(
          "UserAccountModel: ${userAccountModel.toJson()} \nUsername: ${userAccountModel.email}");

      userExisting = emailController.text.trim();
      showLoading = false;
      update();
      // Get.off(() => HomeScreen(
      //       userID: FirebaseAuth.instance.currentUser!.uid,
      //     ));
      // context.pushReplacement('/homepage');
    } else {
      print('User does not exist. Creating new user . . .');
      registerUser(context);
    }
  }

  // Future<void> registerUser(BuildContext context) async {
  //   if (imageFILE != null) {
  //     try {
  //       // Display loading indicator
  //       showLoading = true;
  //       update();
  //
  //       // Create the user with email and password
  //       UserCredential userCredential =
  //           await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //         email: emailController.text.trim(),
  //         password: passwordController.text.trim(),
  //       );
  //
  //       // Upload image to cloud storage
  //       final firebaseStorage = FirebaseStorage.instance;
  //       var file = File(imageFILE!.path);
  //       var snapshot = await firebaseStorage
  //           .ref()
  //           .child(
  //               'own_the_city/user_profile_images/${userCredential.user!.uid}')
  //           .putFile(file);
  //
  //       // Generate download URL
  //       var downloadUrl = await snapshot.ref.getDownloadURL();
  //       imageUrl = downloadUrl;
  //
  //       // Create UserAccountModel instance
  //       UserAccountModel createAccountData = UserAccountModel(
  //         uid: userCredential.user!.uid,
  //         fullName: fullNameController.text.trim(),
  //         email: emailController.text.trim(),
  //         password: passwordController.text.trim(),
  //         imageProfile: imageUrl,
  //       );
  //
  //       // Save user data to Realtime Database
  //       DatabaseReference ref = FirebaseDatabase.instance
  //           .ref("user_details/${createAccountData.email}");
  //       await ref.set(createAccountData.toJson());
  //
  //       // Display success message
  //       showCustomSnackBar(
  //         context,
  //         "User ${emailController.text.trim()} created",
  //         () {},
  //         Colors.green,
  //         1000,
  //       );
  //
  //       // Update state and navigate to homepage
  //       GlobalVariables.myUsername = emailController.text.trim();
  //       Get.snackbar(
  //         "Account Created",
  //         "Congratulations, your account has been created",
  //       );
  //       errMessage = "";
  //       showLoading = false;
  //       update();
  //       gotoHomepage(context);
  //     } catch (error) {
  //       // Handle registration error
  //       Get.snackbar(
  //         "Account Creation Unsuccessful",
  //         "Error occurred: $error",
  //       );
  //       showLoading = false;
  //       update();
  //     }
  //   }
  // }


  loginUser(String emailUser, String passwordUser) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailUser, password: passwordUser);

      Get.snackbar("Logged in Successful", "You are logged in successfully.");

      Get.off(() => HomeScreen(
            userID: FirebaseAuth.instance.currentUser!.uid,
          ));
    } catch (errorMsg) {
      Get.snackbar("Login Unsuccessful", "Error occurred: $errorMsg");
    }
  }

  checkIfUserIsLoggedIn(User? currentUser) {
    if (currentUser == null) {
      Get.to(const LoginScreen());
    } else {
      Get.off(() => HomeScreen(
            userID: FirebaseAuth.instance.currentUser!.uid,
          ));
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
