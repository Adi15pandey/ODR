import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/GlobalServiceurl.dart';

class RegisterVerifyotp extends StatefulWidget {
  final String email; // Pass the email as an argument to this screen

  const RegisterVerifyotp({super.key, required this.email});

  @override
  State<RegisterVerifyotp> createState() => _RegisterVerifyOtpState();
}

class _RegisterVerifyOtpState extends State<RegisterVerifyotp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpSMSController = TextEditingController();
  final TextEditingController _otpMailController = TextEditingController();

  Future<void> verifyOtp() async {

    if (!_formKey.currentState!.validate()) return;

    // API URL and headers
     String apiUrl = '${GlobalService.baseUrl}/api/auth/register/otp';
    final Map<String, dynamic> payload = {
      "emailId": widget.email, // Using the email passed to the screen
      "otpSMS": _otpSMSController.text,
      "otpMail": _otpMailController.text,
    };

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      // Hide loading indicator
      if (Navigator.canPop(context)) Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Display the response token and role
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verified! Role: ${responseData['role']}'),
          ),
        );

        print('Token: ${responseData['token']}');
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      // Hide loading indicator in case of an error
      if (Navigator.canPop(context)) Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _otpSMSController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP (SMS)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP received via SMS';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _otpMailController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter OTP (Mail)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP received via email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: verifyOtp,
                child: const Text('Verify OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
