import 'package:flutter/material.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'signup.dart';
import 'splash.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final AuthService _authService = AuthService();

    bool _isLoading = false;
    String _error = '';

    Future<void> _login() async {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      try {
        await _authService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Navigate to splash screen on successful login
        if(mounted){Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
        );}
      } catch (e) {
        setState(() {
          _error = 'Login failed. Please check your credentials.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    @override
    void dispose() {
      _emailController.dispose();
      _passwordController.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text (
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              if (_error.isNotEmpty)
                Text(
                  _error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Login', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.indigo),
                ),
                child: const Text('Create an Account', style: TextStyle(fontSize: 16, color: Colors.indigo)),
              ),
            ]
          ),
        )
      ),
    );
  }
}