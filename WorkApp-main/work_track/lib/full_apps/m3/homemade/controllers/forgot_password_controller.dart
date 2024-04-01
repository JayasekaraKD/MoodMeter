import 'package:work_track/full_apps/m3/homemade/models/user.dart';
import 'package:work_track/full_apps/m3/homemade/views/full_app.dart';
import 'package:work_track/full_apps/m3/homemade/views/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  late TextEditingController emailController = TextEditingController();

  void forgotPassword() {
    Get.off(FullApp(
      username: '',
      role: UserRole.user,
    ));
    // Navigator.of(context, rootNavigator: true).pushReplacement(
    //   MaterialPageRoute(builder: (context) => FullApp()),
    // );
  }

  void goToRegister() {
    Get.off(RegisterScreen());
    // Navigator.of(context, rootNavigator: true).pushReplacement(
    //   MaterialPageRoute(builder: (context) => RegisterScreen()),
    // );
  }
}
