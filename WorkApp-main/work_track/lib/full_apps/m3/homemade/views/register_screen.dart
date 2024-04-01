import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/register_controller.dart';
import 'package:work_track/full_apps/m3/homemade/models/user.dart';
import 'package:work_track/full_apps/m3/homemade/views/full_app.dart';
import 'package:work_track/helpers/theme/app_theme.dart';
import 'package:work_track/helpers/theme/constant.dart';
import 'package:work_track/helpers/widgets/my_button.dart';
import 'package:work_track/helpers/widgets/my_spacing.dart';
import 'package:work_track/helpers/widgets/my_text.dart';
import 'package:work_track/helpers/widgets/my_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Import statements remain unchanged

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late RegisterController registerController;
  late ThemeData theme;
  late FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    theme = AppTheme.homemadeTheme;
    _auth = FirebaseAuth.instance;
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    registerController = RegisterController();
  }

  Future<void> registerUser(
      String username, String email, String password) async {
    try {
      // Create a new user with email and password
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Determine the role based on the entered username
        UserRole role =
            username.toLowerCase() == 'admin' ? UserRole.admin : UserRole.user;

        // Store additional information in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'role': role.toString().split('.').last,
        });

        // Show registration success message
        showRegistrationSuccessMessage();

        // Pass the 'name' (username) and 'role' to the FullApp
        Get.to(() => FullApp(username: username, role: role));
      }
    } catch (e) {
      // Handle registration error
      print("Error registering user: $e");
      if (e is FirebaseAuthException) {
        print("Firebase error code: ${e.code}");
        print("Firebase error message: ${e.message}");
        // Show a snackbar or some UI indication here
        Get.snackbar("Registration Error", "Failed to register: ${e.message}");
      }
    }
  }

  void showRegistrationSuccessMessage() {
    Get.snackbar(
      "Registration Successful",
      "You have successfully registered.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
      init: registerController,
      tag: 'register_controller',
      builder: (registerController) {
        return Scaffold(
          body: ListView(
            padding: MySpacing.fromLTRB(24, 44, 24, 0),
            children: [
              MyText.displaySmall(
                'Hey !\nSignup to get started',
                color: theme.colorScheme.primary,
                fontWeight: 700,
              ),
              MySpacing.height(60),
              Padding(
                padding: MySpacing.horizontal(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: "Name",
                        hintText: "Name",
                        labelStyle: MyTextStyle.getStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: 600,
                        ),
                        hintStyle: MyTextStyle.getStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: 600,
                        ),
                        fillColor: theme.colorScheme.primaryContainer,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: MySpacing.all(16),
                        prefixIcon: Icon(
                          LucideIcons.user,
                          size: 20,
                        ),
                        prefixIconColor: theme.colorScheme.primary,
                        focusColor: theme.colorScheme.primary,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      cursorColor: theme.colorScheme.primary,
                      autofocus: true,
                    ),
                    MySpacing.height(24),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: "Email Address",
                        hintText: "Email Address",
                        labelStyle: MyTextStyle.getStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: 600,
                        ),
                        hintStyle: MyTextStyle.getStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: 600,
                        ),
                        fillColor: theme.colorScheme.primaryContainer,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        border: OutlineInputBorder(
                          // borderRadius: BorderRadius all(Radius.circular(24)),
                          borderSide: BorderSide.none,
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: MySpacing.all(16),
                        prefixIcon: Icon(
                          LucideIcons.mail,
                          size: 20,
                        ),
                        prefixIconColor: theme.colorScheme.primary,
                        focusColor: theme.colorScheme.primary,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      cursorColor: theme.colorScheme.primary,
                      autofocus: true,
                    ),
                    MySpacing.height(24),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: "Password",
                        hintText: "Password",
                        labelStyle: MyTextStyle.getStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: 600,
                        ),
                        hintStyle: MyTextStyle.getStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: 600,
                        ),
                        fillColor: theme.colorScheme.primaryContainer,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: MySpacing.all(16),
                        prefixIcon: Icon(
                          LucideIcons.lock,
                          size: 20,
                        ),
                        prefixIconColor: theme.colorScheme.primary,
                        focusColor: theme.colorScheme.primary,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                      cursorColor: theme.colorScheme.primary,
                      autofocus: true,
                    ),
                    MySpacing.height(32),
                    MyButton.block(
                      elevation: 0,
                      borderRadiusAll: Constant.buttonRadius.large,
                      onPressed: () {
                        String email = emailController.text;
                        String password = passwordController.text;
                        registerUser(nameController.text, email, password);
                      },
                      padding: MySpacing.y(20),
                      backgroundColor: theme.colorScheme.primary,
                      child: MyText.titleMedium(
                        "Register",
                        fontWeight: 700,
                        color: theme.colorScheme.onPrimary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    MySpacing.height(16),
                    Center(
                      child: MyButton.text(
                        onPressed: () {
                          registerController.goToLogin();
                        },
                        splashColor: theme.colorScheme.primaryContainer,
                        child: MyText.bodySmall("I already have an account",
                            decoration: TextDecoration.underline,
                            color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
