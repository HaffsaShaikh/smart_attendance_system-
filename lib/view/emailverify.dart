import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_attendance_system/controller/auth_controller.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  final AuthController authController = Get.put(AuthController());

  @override
  void initState() {
    super.initState();
    authController.checkEmailVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("We have sent you a verification email"),
              const SizedBox(height: 20),
              Obx(() {
                if (authController.coolDown.value == 0) {
                  return ElevatedButton(
                    onPressed: () {
                      authController.startCoolDown();
                    },
                    child: const Text(
                      "Resend Email",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      Text(
                        "Please wait ${authController.coolDown.value} seconds",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
