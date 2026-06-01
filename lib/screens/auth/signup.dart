import 'package:flutter/material.dart';
import 'package:campus_connect/services/auth_service.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  String _selectedBranch = 'CSE';
  String _selectedYear = '1st Year';
  bool _isLoading = false;
  String _error = '';

  final _branches = ['CSE', 'ECE', 'ME', 'CE', 'EEE'];
  final _years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  Future<void> _signUp() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _error = 'Please fill all fields';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        branch: _selectedBranch,
        year: _selectedYear,
      );
      if(mounted){Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );}
    } catch (e) {
      setState(() {
        _error = 'Sign up failed. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children:[
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'Create Your Account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),

              const SizedBox(height: 8),

              const Text(
                'Join your college community',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              const Text(
                'Email',
                style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 4),

              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'your@email.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Name',
                style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 4),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'John Doe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Branch',
                style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: _selectedBranch,
                decoration: const InputDecoration(
                labelText: '',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book_outlined),
              ),

              items: _branches.map((branch) => 
              DropdownMenuItem(value: branch, child: Text(branch))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              const Text(
                'Year',
                style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: _selectedYear,
                decoration: const InputDecoration(
                labelText: '',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),

              items: _years.map((year) => 
              DropdownMenuItem(value: year, child: Text(year))).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedYear = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              const Text(
                'Password',
                style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 4),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Create a Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outlined),
                ),
              ),

              const SizedBox(height: 8),

              if (_error.isNotEmpty)
                Text(
                  _error,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Sign Up', style: TextStyle(fontSize: 16)),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Already have an account? Login', style: TextStyle(fontSize: 16, color: Colors.indigo)),
              ),
            ]
          )
        )
      ),
    );
  }
}