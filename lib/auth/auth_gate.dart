// AUTH GATE

// Unauthenticated - Login page
// authenticated - dashboard page

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login_screen.dart';
import '../pages/dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // listen to auth state change
      stream: Supabase.instance.client.auth.onAuthStateChange,

      // build appropriate page based on auth state
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // check if there is a valid session currently
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return DashboardScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
