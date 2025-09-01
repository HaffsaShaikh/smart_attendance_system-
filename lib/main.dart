import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_attendance_system/view/splashscreen.dart';
import 'package:smart_attendance_system/view/boardingscreen.dart';
import 'package:smart_attendance_system/view/register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Attendance System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      routes: {
        '/onboarding': (context) => Boardingscreen(),
        '/register': (context) => Register(),
      },
      home: const SplashScreen(),
    );
  }
}
