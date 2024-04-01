import 'package:flutter/material.dart';
import 'package:work_track/full_apps/m3/homemade/models/user.dart';

class AuthorizedAccess extends StatelessWidget {
  final Widget child;
  final Widget unauthorizedWidget;
  final UserRole requiredRole;
  final UserRole userRole;

  const AuthorizedAccess({
    Key? key,
    required this.child,
    required this.unauthorizedWidget,
    required this.requiredRole,
    required this.userRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the user has the required role to access the content
    bool authorized = userRole == requiredRole;

    // Return the appropriate widget based on authorization
    return authorized ? child : unauthorizedWidget;
  }
}
