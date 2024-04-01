import 'package:work_track/full_apps/m3/homemade/models/user.dart';
import 'package:work_track/full_apps/m3/homemade/views/full_app.dart';
import 'package:work_track/full_apps/m3/homemade/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  late TextEditingController nameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();

  void register() {
    String username = nameController.text;

    // Set the role value as needed, here I set it to 'user'
    UserRole role = UserRole.user;

    // Perform the user registration logic (e.g., create user in the database)

    // After successful registration, navigate to the FullApp screen
    Get.off(FullApp(
      username: username,
      role: role,
    ));
  }

  void goToLogin() {
    Get.off(LogInScreen());
  }
}
