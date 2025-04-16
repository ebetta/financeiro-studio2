// login_screen.dart
import 'package:flutter/material.dart';
import 'auth_service.dart'; // Import Auth Service

// --- Login Screen Widget ---
class LoginScreen extends StatefulWidget {
  final AuthService authService; // Receive AuthService instance

  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for email and password text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // State variable for loading indicator
  bool _isLoading = false;
  // State variable for password visibility
  bool _isPasswordVisible = false;

  // --- Handle Email/Password Login ---
  Future<void> _signInWithEmail() async {
    // Prevent multiple clicks while loading
    if (_isLoading) return;
    setState(() => _isLoading = true); // Show loading indicator

    // Get email and password from controllers
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validate inputs (basic)
    if (email.isEmpty || password.isEmpty) {
       // Check context before showing SnackBar (although less likely needed here)
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Por favor, preencha email e senha.'), backgroundColor: Colors.orangeAccent),
         );
       }
       setState(() => _isLoading = false); // Hide loading
       return;
    }

    // Call the sign-in method from AuthService
    // Pass the current context
    await widget.authService.signInWithEmailAndPassword(email, password, context);

    // Hide loading indicator (AuthGate will handle navigation if successful)
    // Check if the widget is still mounted before calling setState
    if (mounted) {
       setState(() => _isLoading = false);
    }
  }

  // --- Handle Google Sign-In ---
  Future<void> _signInWithGoogle() async {
     if (_isLoading) return;
     setState(() => _isLoading = true); // Show loading indicator

     // Call the Google sign-in method, passing context
     await widget.authService.signInWithGoogle(context);

     // Hide loading indicator (AuthGate will handle navigation if successful)
     if (mounted) {
        setState(() => _isLoading = false);
     }
  }

   // --- Handle Forgot Password ---
  void _forgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      // Check context before showing SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, digite seu email para redefinir a senha.'), backgroundColor: Colors.orangeAccent),
        );
      }
      return;
    }
    // Pass context to the method
    widget.authService.sendPasswordResetEmail(email, context);
  }


  // Dispose controllers when the widget is removed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused screenSize variable

    return Scaffold(
      // Prevent overflow when keyboard appears
      resizeToAvoidBottomInset: true,
      body: Center(
        // Use SingleChildScrollView to allow scrolling on smaller screens
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
             constraints: const BoxConstraints(maxWidth: 400), // Max width for web/tablet
             child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch
              children: <Widget>[
                // --- App Logo/Title ---
                // TODO: Replace with your actual logo or styled title (e.g., Image.asset('assets/your_logo.png'))
                Icon(Icons.lock_outline, size: 60, color: Theme.of(context).primaryColor),
                const SizedBox(height: 20),
                Text(
                  'Bem-vindo!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                 Text(
                  'Faça login para continuar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 40),

                // --- Email Field ---
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined), // Simple icon
                  ),
                  enabled: !_isLoading, // Disable when loading
                ),
                const SizedBox(height: 16),

                // --- Password Field ---
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // Hide/show password
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline), // Simple icon
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                   enabled: !_isLoading, // Disable when loading
                ),
                const SizedBox(height: 8),

                // --- Forgot Password Button ---
                 Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _forgotPassword, // Disable when loading
                    child: const Text('Esqueceu a senha?'),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Login Button ---
                _isLoading
                    ? const Center(child: CircularProgressIndicator()) // Show loading indicator
                    : ElevatedButton(
                        onPressed: _signInWithEmail,
                        child: const Text('ENTRAR'),
                      ),
                const SizedBox(height: 16),

                 // --- OR Separator ---
                 Row(
                   children: <Widget>[
                     const Expanded(child: Divider()),
                     Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
                       child: Text('OU', style: Theme.of(context).textTheme.bodySmall),
                     ),
                     const Expanded(child: Divider()),
                   ],
                 ),
                 const SizedBox(height: 16),

                // --- Google Sign-In Button ---
                ElevatedButton.icon(
                  // Ensure you have 'assets/google_logo.png' in your project
                  // and declared in pubspec.yaml
                  icon: Image.asset(
                    'assets/google_logo.png',
                    height: 20.0,
                    // Provide a fallback in case the image fails to load
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 24),
                  ),
                  label: const Text('Entrar com Google'),
                  onPressed: _isLoading ? null : _signInWithGoogle, // Disable when loading
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black87, backgroundColor: Colors.white, // Google button style
                    side: BorderSide(color: Colors.grey.shade300), // Light border
                  ),
                ),

                // --- TODO: Add Sign Up Button/Link if needed ---
                // Padding(
                //   padding: const EdgeInsets.only(top: 20.0),
                //   child: TextButton(
                //     onPressed: () { /* TODO: Navigate to Sign Up Screen */ },
                //     child: const Text('Não tem uma conta? Cadastre-se'),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}