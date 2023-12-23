import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:med_adherence_app/app/services/navigation_service.dart';
import 'package:med_adherence_app/features/views/edit_schedule.dart';
import 'package:med_adherence_app/features/views/emergency_settings.dart';
import 'package:med_adherence_app/features/views/home_page.dart';
import 'package:med_adherence_app/features/views/home_screen.dart';
import 'package:med_adherence_app/features/views/login_screen.dart';
import 'package:med_adherence_app/features/views/sign_up.dart';
import 'package:med_adherence_app/features/views/splash_screen.dart';

class AppRouter {
  static final router = GoRouter(
    navigatorKey: NavigationService.navigatorKey,
    // initialLocation: '/createAccountView',
    // initialLocation: '/homepageView',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      /// App Pages
      GoRoute(
        path: '/homepage',
        builder: (context, state) => HomeScreen(userID: FirebaseAuth.instance.currentUser!.uid,),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signUp',
        builder: (context, state) => SignUpScreen(),
      ),
      GoRoute(
        path: '/editSchedule',
        builder: (context, state) => const EditSchedule(),
      ),
      GoRoute(
        path: '/emergencySettings',
        builder: (context, state) => EmergencyScreen(),
      ),
    ],
  );
}
