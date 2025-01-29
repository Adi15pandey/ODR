import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/Admin_main_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/GlobalServiceurl.dart';
import 'package:odr_sandhee/client_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Verifyotpclient extends StatefulWidget {
  final String storedEmail;

  const Verifyotpclient({super.key, required this.storedEmail});

  @override
  State<Verifyotpclient> createState() => _VerifyotpclientState();
}

class _VerifyotpclientState extends State<Verifyotpclient> {
  final List<TextEditingController> _emailOtpControllers =
  List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _phoneOtpControllers =
  List.generate(4, (_) => TextEditingController());
  final String apiUrl = '${GlobalService.baseUrl}/api/auth/login/otp';

  bool isLoading = false;

  void _onOtpFieldChanged(String value, int index, List<TextEditingController> controllers) {
    if (value.isNotEmpty && index < 3) {
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  Future<void> _verifyOtp() async {
    setState(() {
      isLoading = true;
    });

    try {
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({
        "emailId": widget.storedEmail,
        "otpSMS": _phoneOtpControllers.map((c) => c.text).join(),
        "otpMail": _emailOtpControllers.map((c) => c.text).join(),
      });

      var request = http.Request('POST', Uri.parse(apiUrl));
      request.body = body;
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('Response: $responseBody');

        var jsonResponse = json.decode(responseBody);

        if (jsonResponse.containsKey('token') &&
            jsonResponse.containsKey('role') &&
            jsonResponse.containsKey('id')) {
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

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ClientMainScreen()),
          );
        } else {
          throw Exception('Token, role, or id missing in the response');
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

  Widget _buildOtpFields(List<TextEditingController> controllers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 50,
          child: TextField(
            controller: controllers[index],
            keyboardType: TextInputType.number,
            maxLength: 1,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              counterText: '', // Removes the length counter below the field
              border: OutlineInputBorder(),
            ),
            onChanged: (value) =>
                _onOtpFieldChanged(value, index, controllers),
          ),
        );
      }),
    );
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
            const SizedBox(width: 10),
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
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'OTP from Email',
                  textAlign: TextAlign.start,
                ),
                _buildOtpFields(_emailOtpControllers),
                const SizedBox(height: 16),
                const Text(
                  'OTP from Phone',
                  textAlign: TextAlign.start,
                ),
                _buildOtpFields(_phoneOtpControllers),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 16.0,color: Colors.white),
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
