import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/Admin_main_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/arbitrator_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Verifyotparbitrator extends StatefulWidget {
  final String storedEmail;

  const Verifyotparbitrator({super.key, required this.storedEmail});

  @override
  State<Verifyotparbitrator> createState() => _VerifyotparbitratorState();
}

class _VerifyotparbitratorState extends State<Verifyotparbitrator> {
  final TextEditingController _emailOtpController = TextEditingController();
  final TextEditingController _phoneOtpController = TextEditingController();
  final String apiUrl = 'http://192.168.1.12:4001/api/auth/login/otp';

  bool isLoading = false;

  Future<void> _verifyOtp() async {
    setState(() {
      isLoading = true;
    });

    try {
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({
        "emailId": widget.storedEmail,
        "otpSMS": _phoneOtpController.text,
        "otpMail": _emailOtpController.text,
      });

      var request = http.Request('POST', Uri.parse(apiUrl));
      request.body = body;
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('Response: $responseBody');

        var jsonResponse = json.decode(responseBody);

        // Extract and save the token, role, and id
        if (jsonResponse.containsKey('token')) {
          String token = jsonResponse['token'];
          String role = jsonResponse['role'];
          String id = jsonResponse['id'];

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setString('role', role);
          await prefs.setString('user_id', id);

          print('Token saved: $token');
          print('Role saved: $role');
          print('ID saved: $id');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP Verified Successfully')),
          );

          // Navigate to ArbitratorMainScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ArbitratorMainScreen()),
          );
        } else {
          throw Exception('Token not found in the response');
        }
      } else {
        print('Error: ${response.reasonPhrase}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Verification Failed')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/Images/Group.png',
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Verify Otp',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Center(
        child: Card(
          elevation: 8.0, // Add shadow to the card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Padding inside the card
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wraps content to its size
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailOtpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP from Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneOtpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP from Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900], // Button color
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 16.0),
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
