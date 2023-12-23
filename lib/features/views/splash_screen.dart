// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:med_adherence_app/app/helpers/sharedprefs.dart';
import 'package:med_adherence_app/app/resources/app.logger.dart';
import 'package:med_adherence_app/features/shared/global_variables.dart';
import 'package:med_adherence_app/features/shared/spacer.dart';
import 'package:med_adherence_app/features/views/home_screen.dart';
import 'package:med_adherence_app/features/views/login_screen.dart';
import 'package:med_adherence_app/utils/app_constants/app_colors.dart';
import 'package:med_adherence_app/utils/app_constants/app_key_strings.dart';
import 'package:med_adherence_app/utils/app_constants/app_styles.dart';
import 'package:med_adherence_app/utils/app_constants/app_sub_strings.dart';
import 'package:med_adherence_app/utils/screen_util/screen_util.dart';

var log = getLogger('SplashScreen');

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  Animation? sizeAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..forward();

    sizeAnimation = Tween(begin: 20.0, end: 50.0).animate(CurvedAnimation(
        parent: animationController!, curve: const Interval(0.0, 0.5)));

    animationController!.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        log.wtf('Animation completed');
        sleep(const Duration(milliseconds: 200));

        bool accountExisting;
        String existingUsername = await getSharedPrefsSavedString("email");
        log.w('existingUsername: $existingUsername');
        if (existingUsername != '') {
          GlobalVariables.myUsername = existingUsername;
          accountExisting = true;
          log.wtf('GlobalVariables.myUsername: ${GlobalVariables.myUsername}');
        } else {
          accountExisting = false;
        }

        Get.off( accountExisting ? HomeScreen(userID: FirebaseAuth.instance.currentUser!.uid,) : const LoginScreen());

        // context.pushReplacement(
        //   accountExisting ? '/homepage' : '/login',
        // );
      }
    });
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.lighterGray,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.lighterGray,
      ),
      child: Scaffold(
        backgroundColor: AppColors.kPrimaryColor,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '',
                style: AppStyles.subStringStyle(
                    sizeAnimation!.value * 0.3, AppColors.plainWhite),
              ),
              Center(
                child: AnimatedBuilder(
                    animation: animationController!,
                    builder: (context, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image:
                                const AssetImage('images/logo.png'),
                            height: sizeAnimation!.value * 4,
                            width: sizeAnimation!.value * 4,
                          ),
                          Text(
                            AppKeyStrings.medAppName,
                            style: AppStyles.defaultKeyStringStyle(
                                sizeAnimation!.value * 0.75),
                          ),
                          CustomSpacer(screenSize(context).height / 100),
                          Text(
                            AppSubStrings.medAppSub,
                            style: AppStyles.subStringStyle(
                              sizeAnimation!.value * 0.30,
                              AppColors.plainWhite,
                            ),
                          ),
                        ],
                      );
                    }),
              ),
              Text(
                AppSubStrings.yearFUTA,
                style: AppStyles.subStringStyle(16, AppColors.plainWhite),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
