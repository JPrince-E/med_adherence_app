import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:med_adherence_app/features/api/firebase_api.dart';
import 'package:med_adherence_app/features/controllers/auth_controller.dart';
import 'package:med_adherence_app/features/controllers/schedule_controller.dart';
import 'package:med_adherence_app/features/views/login_screen.dart';
import 'package:med_adherence_app/features/views/notification_screen.dart';
import 'package:med_adherence_app/firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
    Get.put(AuthController());
    Get.put(ScheduleController());
  });

  await FirebaseApi().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Med App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
        ),
        useMaterial3: true,
      ),

      // /// GoRouter specific params
      // routeInformationProvider: _router.routeInformationProvider,
      // routeInformationParser: _router.routeInformationParser,
      // routerDelegate: _router.routerDelegate,
      home: const LoginScreen(),
      routes: {
        NotificationScreen.route: (context) => const NotificationScreen()
      },
    );
  }

  // BuildContext? get ctx => _router.routerDelegate.navigatorKey.currentContext;
  // final _router = AppRouter.router;
}
