import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_adherence_app/utils/app_constants/app_colors.dart';

class AppMainWrapper extends StatelessWidget {
  final MaterialApp child;
  const AppMainWrapper({super.key, 
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle().copyWith(
        statusBarColor: AppColors.scaffoldBackgroundColor(context),
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.scaffoldBackgroundColor(context),
      ),
    );
    return MediaQuery(
      data: const MediaQueryData().copyWith(
        textScaleFactor: 1,
        devicePixelRatio: 1,
      ),
      child: child,
    );
  }
}
