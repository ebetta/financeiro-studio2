import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;

  const LoginScreen({required this.authService, super.key});

  @override
  LoginScreenState createState() => LoginScreenState(); // Made state public
}

// Made state public
class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true; // To toggle password visibility

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha o email e a senha.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Pass context to the signIn method
      await widget.authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        context,
      );
      // Navigation to HomeScreen is handled by AuthGate
      // No need for SnackBar here as AuthService handles it
    } catch (e) {
      // Error handling is now within AuthService, but we catch any potential rethrow
      if (mounted) {
        // Optionally show a generic error if AuthService doesn't handle all cases
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Erro ao fazer login: ${e.toString()}'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    } finally {
       if (mounted) {
         setState(() {
           _isLoading = false;
         });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pass context to the signInWithGoogle method
      await widget.authService.signInWithGoogle(context);
      // Navigation to HomeScreen is handled by AuthGate
      // No need for SnackBar here as AuthService handles it
    } catch (e) {
      // Error handling is now within AuthService
       if (mounted) {
        // Optionally show a generic error if AuthService doesn't handle all cases
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('Erro ao fazer login com Google: ${e.toString()}'),
        //     backgroundColor: Colors.red,
        //   ),
        // );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _forgotPassword() {
    // Show dialog to get email for password reset
    final TextEditingController resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recuperar Senha'),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Digite o email cadastrado',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isNotEmpty) {
                  Navigator.pop(context); // Close the dialog
                  await widget.authService.sendPasswordResetEmail(email, context);
                } else {
                  // Show error within the dialog if needed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, insira um email.')),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    ).whenComplete(() => resetEmailController.dispose()); // Dispose controller

  }


  void _navigateToSignUp() {
    Navigator.push(
      context,
      // Pass the authService instance to SignUpScreen
      MaterialPageRoute(builder: (context) => const SignUpScreen()), // Corrected: SignUpScreen constructor takes no arguments
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
             constraints: const BoxConstraints(maxWidth: 400), // Max width for content
             child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Replace with your actual logo or styled title
                const Icon(
                  Icons.app_registration, // Temporary logo
                  size: 80,
                  // color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Bem-vindo de volta!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Faça login para continuar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  enabled: !_isLoading,
                  onSubmitted: (_) => _signIn(), // Allow sign in on enter press
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isLoading ? null : _forgotPassword,
                    child: const Text('Esqueceu a senha?'),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign In Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          // Consider using theme color: Theme.of(context).colorScheme.primary
                        ),
                        child: const Text('Entrar'),
                      ),
                const SizedBox(height: 16),

                // OR Separator
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


                // Google Sign In Button
                ElevatedButton.icon(
                      icon: Image.asset(
                           'assets/google_logo.png', // Ensure you have this asset
                            height: 20.0, // Adjust size as needed
                             width: 20.0,
                         ),
                      label: const Text('Entrar com Google'),
                      onPressed: _isLoading ? null : _signInWithGoogle, // Disable when loading
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black87, backgroundColor: Colors.white, // Google button style
                        side: BorderSide(color: Colors.grey.shade300), // Light border
                      ),
                    ),


                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: TextButton(
                        onPressed: _navigateToSignUp, // Use the dedicated function
                        child: const Text('Não tem uma conta? Cadastre-se'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
