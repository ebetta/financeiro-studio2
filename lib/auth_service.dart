// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // For checking platform
import 'package:flutter/material.dart'; // Required for BuildContext

// --- Authentication Service Class ---
class AuthService {
  // Firebase Auth instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Google Sign-In instance
  // *** IMPORTANT FOR WEB ***
  // The clientId parameter MUST be provided for Google Sign-In on Web.
  // Obtain this value from your Google Cloud Console -> APIs & Services -> Credentials
  // (OAuth 2.0 Client IDs -> Web client). It usually ends with .apps.googleusercontent.com
  final GoogleSignIn _googleSignIn = GoogleSignIn(
      clientId: kIsWeb
          ? '387671815228-an28o53qsg5hs7od34f9f6lguc24im98.apps.googleusercontent.com' // <-- REPLACE THIS WITH YOUR ACTUAL WEB CLIENT ID
          : null,
      );

  // --- Stream to listen for authentication state changes ---
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // --- Get current user ---
  User? get currentUser => _firebaseAuth.currentUser;

  // --- Sign in with Email and Password ---
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      // Attempt to sign in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      String message;
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Email ou senha inválidos.';
      } else if (e.code == 'invalid-email') {
        message = 'O formato do email é inválido.';
      } else {
        message = 'Ocorreu um erro no login: ${e.code}'; // Use e.code for brevity
      }
      // Check if context is still valid before showing SnackBar
      if (!context.mounted) return null;
      // Show error message using ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message), backgroundColor: Colors.redAccent),
      );
      // Log error (optional, consider using a logging package)
      // print("Error signing in: ${e.message}");
      return null;
    } catch (e) {
      // Check if context is still valid before showing SnackBar
      if (!context.mounted) return null;
      // Handle other potential errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ocorreu um erro inesperado: $e'),
            backgroundColor: Colors.redAccent),
      );
      // Log error (optional)
      // print("Unexpected error during sign in: $e");
      return null;
    }
  }

  // --- Sign in with Google ---
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    GoogleSignInAccount? googleUser;
    try {
      // Start the Google Sign-In process
      if (kIsWeb) {
        googleUser = await _googleSignIn.signIn();
      } else {
        googleUser = await _googleSignIn.signIn();
      }

      // If the user cancels the sign-in
      if (googleUser == null) {
        // Check if context is still valid
        if (!context.mounted) return null;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login com Google cancelado.')),
        );
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return userCredential;

    } on FirebaseAuthException catch (e) {
      // Check if context is still valid
      if (!context.mounted) return null;
      // Handle Firebase specific errors during Google Sign-In
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro no login com Google (Firebase): ${e.code}'), // Use e.code
            backgroundColor: Colors.redAccent),
      );
      // Log error (optional)
      // print("Firebase Auth error during Google Sign-In: ${e.message}");
      // Ensure Google Sign-In is signed out if Firebase fails
      await _googleSignIn.signOut();
      return null;
    } catch (e) {
       // Check if context is still valid
       if (!context.mounted) return null;
       // Handle other potential errors (e.g., network issues)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro no login com Google: $e'),
            backgroundColor: Colors.redAccent),
      );
      // Log error (optional)
      // print("Error during Google Sign-In: $e");
      // Ensure Google Sign-In is signed out on error
       await _googleSignIn.signOut();
      return null;
    }
  }

  // --- Forgot Password ---
  Future<void> sendPasswordResetEmail(String email, BuildContext context) async {
    try {
      // Send password reset email
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      // Check if context is still valid
      if (!context.mounted) return;
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Email de redefinição de senha enviado para $email.'),
            backgroundColor: Colors.green),
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors
      String message;
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        message = 'Email não encontrado ou inválido.';
      } else {
        message = 'Erro ao enviar email: ${e.code}'; // Use e.code
      }
       // Check if context is still valid
       if (!context.mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message), backgroundColor: Colors.redAccent),
      );
       // Log error (optional)
      // print("Error sending password reset email: ${e.message}");
    } catch (e) {
       // Check if context is still valid
       if (!context.mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Ocorreu um erro inesperado: $e'),
            backgroundColor: Colors.redAccent),
      );
       // Log error (optional)
      // print("Unexpected error sending password reset email: $e");
    }
  }

  // --- Sign Out ---
  Future<void> signOut(BuildContext context) async {
    try {
      // Sign out from Google first if applicable
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      // Sign out from Firebase
      await _firebaseAuth.signOut();
       // Check if context is still valid
       if (!context.mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout realizado com sucesso.')),
      );
    } catch (e) {
      // Check if context is still valid
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao fazer logout: $e'),
            backgroundColor: Colors.redAccent),
      );
       // Log error (optional)
      // print("Error signing out: $e");
    }
  }

  // --- TODO: Implement Sign Up if needed ---
  // Future<UserCredential?> signUpWithEmailAndPassword(String email, String password, BuildContext context) async { ... }
}