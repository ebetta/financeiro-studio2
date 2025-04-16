// home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart'; // Import Auth Service

// --- Home Screen Widget ---
class HomeScreen extends StatelessWidget {
  final AuthService authService; // Receive AuthService instance

  const HomeScreen({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    // Get the current user (should not be null here due to AuthGate)
    final User? user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        // Title of the app bar
        title: const Text('Tela Inicial'),
        // Logout button in the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            // Call signOut method on press
            onPressed: () async {
              await authService.signOut(context);
              // AuthGate will handle navigation back to LoginScreen
            },
          ),
        ],
      ),
      // Body of the home screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display welcome message
            Text(
              'Login realizado com sucesso!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            // Display user's email or display name if available
            if (user != null)
              Text(
                'Bem-vindo, ${user.displayName ?? user.email ?? 'Usuário'}!', // Show display name or email
                 style: Theme.of(context).textTheme.titleMedium,
              ),
             const SizedBox(height: 20),
             // TODO: Add other home screen content here
             const Text('Conteúdo da sua aplicação aqui...'),
          ],
        ),
      ),
    );
  }
}