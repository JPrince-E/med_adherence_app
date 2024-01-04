import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// import 'package:go_router/go_router.dart';
import 'package:med_adherence_app/features/controllers/auth_controller.dart';
import 'package:med_adherence_app/features/views/login_screen.dart';
import 'package:med_adherence_app/utils/app_constants/app_colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Use Get.find to get the AuthController instance
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              authController.getFromGallery();
                              authController.update();
                            });
                          },
                          icon: const Icon(Icons.image, color: Colors.blue,),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              authController.getFromCamera();
                              authController.update();
                            });
                          },
                          icon: const Icon(Icons.camera_alt, color: Colors.blue),
                        ),
                      ],
                    ),

                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Trigger the image selection from the gallery
                    //
                    //     // Ensure the UI is updated after image selection
                    //     setState(() {
                    //       authController.getFromCamera();
                    //       authController.update();
                    //     });
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.blue.shade200,
                    //   ),
                    //   child: const Text('Select Image'),
                    // ),
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
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        authController.attemptToRegisterUser(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade200,
                      ),
                      child: const Text('Sign Up'),
                    ),
                    const SizedBox(height: 16),
                    // Already have an account? Login here button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.off(const LoginScreen());
                            // context.pushReplacement('/login');
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
