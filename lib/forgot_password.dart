import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _smsOtpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _currentStep = 'email'; // Possible values: 'email', 'otp', 'password'

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Please enter your email');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://192.168.1.12:4001/api/resetpassword/userexists');
    try {
      final response = await http.post(
        url,
        body: json.encode({"emailId": email}),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200 && jsonResponse['message'].contains("OTP sent")) {
        _saveEmail(email); // Save email locally
        setState(() {
          _currentStep = 'otp'; // Move to OTP step
        });
        _showMessage('OTP sent successfully to your email and phone.');
      } else {
        _showMessage(jsonResponse['message']);
      }
    } catch (e) {
      _showMessage('Failed to send OTP. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    final smsOtp = _smsOtpController.text.trim();
    final email = await _getEmail();

    if (otp.isEmpty || smsOtp.isEmpty) {
      _showMessage('Please enter both OTPs');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://192.168.1.12:4001/api/resetpassword/verifyotp');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          "otp": otp,
          "otpSMS": smsOtp,
          "emailId": email,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _currentStep = 'password'; // Move to password reset step
        });
        _showMessage('OTP verified successfully. Please reset your password.');
      } else {
        _showMessage(jsonResponse['message']);
      }
    } catch (e) {
      _showMessage('Failed to verify OTP. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final password = _passwordController.text.trim();
    final email = await _getEmail();

    if (password.isEmpty) {
      _showMessage('Please enter your new password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://192.168.1.12:4001/api/resetpassword/updatepassword');
    try {
      final response = await http.put(
        url,
        body: json.encode({
          "emailId": email,
          "password": password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        _showMessage('Password updated successfully.');
        Navigator.pop(context); // Go back to the previous screen
      } else {
        _showMessage(jsonResponse['message']);
      }
    } catch (e) {
      _showMessage('Failed to update password. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  Future<String?> _getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        _currentStep == 'email'
                            ? 'Reset Password'
                            : _currentStep == 'otp'
                            ? 'Verify OTP'
                            : 'Set New Password',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth > 600 ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_currentStep == 'email') ...[
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Enter email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildButton('Send OTP', _sendOtp),
                    ] else if (_currentStep == 'otp') ...[
                      TextField(
                        controller: _otpController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Email OTP',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _smsOtpController,
                        decoration: const InputDecoration(
                          labelText: 'Enter SMS OTP',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildButton('Verify OTP', _verifyOtp),
                    ] else if (_currentStep == 'password') ...[
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Enter new password',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildButton('Reset Password', _resetPassword),
                    ],
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Go back'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[900],
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : Text(label),
      ),
    );
  }
}
