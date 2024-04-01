import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:work_track/full_apps/m3/homemade/controllers/login_controller.dart';
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
import 'package:firebase_auth/firebase_auth.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  late ThemeData theme;
  late LogInController logInController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    theme = AppTheme.homemadeTheme;
    logInController = LogInController();
  }

  Future<void> loginUser(String email, String password) async {
    try {
      // Sign in user
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user information after successful login
      User? user = _auth.currentUser;

      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userData.exists) {
          // Get the username and role from the user data
          String username = userData.get('username');
          String roleString = userData.get('role');
          UserRole role =
              roleString == 'admin' ? UserRole.admin : UserRole.user;
          print('User Role: $role');
          // Login successful
          showLoginSuccessMessage(); // Show a success message

          // Navigate to the FullApp with the obtained username and role
          Get.to(FullApp(username: username, role: role));
        } else {
          print('User data not found in Firestore.');
          // Handle this case accordingly
        }
      }
    } catch (e) {
      // Handle login error
      print("Error logging in: $e");
      if (e is FirebaseAuthException) {
        print("Firebase error code: ${e.code}");
        print("Firebase error message: ${e.message}");
        Get.snackbar("Login Error", "Failed to log in: ${e.message}");
      }
    }
  }

  void showLoginSuccessMessage() {
    Get.snackbar(
      "Login Successful",
      "You have successfully logged in.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LogInController>(
      init: logInController,
      tag: 'log_in_controller',
      builder: (logInController) {
        return Scaffold(
          body: ListView(
            padding: MySpacing.fromLTRB(24, 44, 24, 0),
            children: [
              MyText.displaySmall(
                'Hello!\nWelcome to WorkTrack',
                color: theme.colorScheme.primary,
                fontWeight: 700,
              ),
              MySpacing.height(80),
              Padding(
                padding: MySpacing.horizontal(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(24),
                          ),
                          borderSide: BorderSide.none,
                        ),
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
                        focusedBorder: OutlineInputBorder(
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
                      obscureText: true, // Hide password
                    ),
                    MySpacing.height(16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: MyButton.text(
                        onPressed: () {
                          logInController.goToForgotPassword();
                        },
                        padding: MySpacing.y(4),
                        splashColor: theme.colorScheme.primaryContainer,
                        child: MyText.bodySmall(
                          "Forgot Password?",
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    MySpacing.height(16),
                    MyButton.block(
                      elevation: 0,
                      borderRadiusAll: Constant.buttonRadius.large,
                      onPressed: () {
                        // Get the values from the text controllers
                        String email = emailController.text;
                        String password = passwordController.text;

                        // Call the login function with user-entered values
                        loginUser(email, password);
                      },
                      padding: MySpacing.y(20),
                      backgroundColor: theme.colorScheme.primary,
                      splashColor: theme.colorScheme.primaryContainer,
                      child: MyText.bodyMedium(
                        "Log In",
                        fontWeight: 700,
                        color: theme.colorScheme.onPrimary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    MySpacing.height(16),
                    Center(
                      child: MyButton.text(
                        onPressed: () {
                          logInController.goToRegister();
                        },
                        splashColor: theme.colorScheme.primaryContainer,
                        child: MyText.bodySmall(
                          "I haven't an account",
                          decoration: TextDecoration.underline,
                          color: theme.colorScheme.primary,
                        ),
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
