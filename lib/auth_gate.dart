// auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Import Login Screen
import 'home_screen.dart'; // Import Home Screen
import 'auth_service.dart'; // Import Auth Service

// --- Authentication Gate Widget ---
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Get instance of AuthService (consider using a Provider for better state management)
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      // Listen to authentication state changes
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show Home Screen
        if (snapshot.hasData && snapshot.data != null) {
          return HomeScreen(authService: authService); // Pass authService
        }
        // If user is not logged in, show Login Screen
        else {
          return Scaffold(
            body: Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(builder: (context) => LoginScreen(authService: authService));
              },
            ),
          );
        }
      },
    );
  }
}