// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Import generated Firebase options
import 'auth_gate.dart'; // Import the AuthGate widget

// --- Firebase Initialization ---
// Ensure you have run `flutterfire configure` and have firebase_options.dart
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  // Use DefaultFirebaseOptions.currentPlatform for platform-specific config
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Run the app
  runApp(const MyApp());
}

// --- Main Application Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application name
      title: 'Flutter Firebase Auth',
      // Application theme
      // TODO: Customize theme based on style guidelines (Color, Typography)
      theme: ThemeData(
        primarySwatch: Colors.teal, // Example primary color
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // Example font, choose one based on guidelines
        // Define text themes, button themes, input decoration themes here
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal.shade400, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.teal, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.teal, // Text color
          ),
        ),
      ),
      // Hide the debug banner
      debugShowCheckedModeBanner: false,
      // Set the initial screen using AuthGate
      home: const AuthGate(),
    );
  }
}
