import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:med_adherence_app/features/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool showProgressBar = false;

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child:
              Column(
                children: [

                  const SizedBox(
                    height: 30,
                  ),
                  Image.asset(
                    "images/logo.png",
                    width: 150,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "Welcome to",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Medical Adherence App ",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 28,
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
                  ElevatedButton(
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      authController.attemptToSignInUser(context);
                      // if(authController.emailController.text.trim().isNotEmpty && authController.passwordController.text.trim().isNotEmpty) {
                      //   setState(() {
                      //     showProgressBar = true;
                      //   });
                      //
                      //   await authController.loginUser(
                      //     authController.emailController.text.trim(),
                      //     authController.passwordController.text.trim(),
                      //   );
                      //
                      //   setState(() {
                      //     showProgressBar = false;
                      //   });
                      // } else {
                      //   Get.snackbar("Email or Password is Missing", "Please fill all fields");
                      // }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade200,
                    ),
                    child: const Text('Login'),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  //already have an account login here button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontSize: 16,
                          // color: Colors.blueAccent,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          // Get.to(SignUpScreen());
                          context.push('/signUp');
                        },
                        child: const Text(
                          "Create Here",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
            ),
          ),
        ),
      ),
    );
  }
}