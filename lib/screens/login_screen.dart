import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/storage_keys.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLogin = true; // Toggle between login and register

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Toggle between Login and Register views
  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  // Login function
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      // Handle successful login
      await _apiService.saveTokens(response['access_token'], response['refresh_token']);
      final permissions = await _apiService.getUserPermissions(response['access_token']);
      await _apiService.savePermissions(permissions);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login successful')));
      Navigator.pushReplacementNamed(context, '/dashboard'); // Navigate to home screen
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    }
  }

  // Register function
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _passwordController.text, // Assuming password and confirmation match
        _phoneController.text,
      );

      // Handle successful registration
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful')));
      setState(() {
        _isLogin = true; // Switch to login after successful registration
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!_isLogin) // Show Name and Phone fields only in Register form
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                ),
              if (!_isLogin) // Phone number field in Register form
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  validator: (value) => value?.isEmpty ?? true ? 'Phone number is required' : null,
                ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value?.isEmpty ?? true ? 'Email is required' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) => value?.isEmpty ?? true ? 'Password is required' : null,
                obscureText: true,
              ),
              if (!_isLogin) // Password confirmation in Register form
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  obscureText: true,
                ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    if (_isLogin) {
                      _login();
                    } else {
                      _register();
                    }
                  }
                },
                child: Text(_isLogin ? 'Login' : 'Register'),
              ),
              TextButton(
                onPressed: _toggleForm,
                child: Text(_isLogin
                    ? 'Don’t have an account? Register here'
                    : 'Already have an account? Login here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
