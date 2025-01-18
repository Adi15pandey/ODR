import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/Admin_main_screen.dart';
import 'package:odr_sandhee/GlobalServiceurl.dart';
import 'package:odr_sandhee/arbitrator_main_screen.dart';
import 'package:odr_sandhee/client_main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOtpAdmin extends StatefulWidget {
  final String storedEmail;

  const VerifyOtpAdmin({super.key, required this.storedEmail});

  @override
  State<VerifyOtpAdmin> createState() => _VerifyOtpAdminState();
}

class _VerifyOtpAdminState extends State<VerifyOtpAdmin> {
  final List<TextEditingController> _emailOtpControllers =
  List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> _phoneOtpControllers =
  List.generate(4, (_) => TextEditingController());

  final String apiUrl = '${GlobalService.baseUrl}/api/auth/login/otp';
  bool isLoading = false;

  String _getOtpFromControllers(List<TextEditingController> controllers) {
    return controllers.map((controller) => controller.text).join();
  }

  Future<void> _verifyOtp() async {
    setState(() {
      isLoading = true;
    });

    try {
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({
        "emailId": widget.storedEmail,
        "otpSMS": _getOtpFromControllers(_phoneOtpControllers),
        "otpMail": _getOtpFromControllers(_emailOtpControllers),
      });

      var response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['token']);
        await prefs.setString('role', responseData['role']);
        await prefs.setString('user_id', responseData['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Verified Successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminMainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Verification Failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildOtpInputRow(List<TextEditingController> controllers) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controllers.length,
            (index) => SizedBox(
          width: 40,
          height: 50,
          child: TextField(
            controller: controllers[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < controllers.length - 1) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        ),
      ).expand((element) => [element, SizedBox(width: 8)]).toList()..removeLast(),
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
            SizedBox(width: 10),
            Text(
              'Verify OTP',
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
                Text(
                  'OTP from Email',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                _buildOtpInputRow(_emailOtpControllers),
                SizedBox(height: 16),
                Text(
                  'OTP from Phone',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                _buildOtpInputRow(_phoneOtpControllers),
                SizedBox(height: 16),
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
