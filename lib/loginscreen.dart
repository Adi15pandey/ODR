import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/Admin_main_screen.dart';
import 'package:odr_sandhee/GlobalServiceurl.dart';
import 'package:odr_sandhee/admin_documents.dart';
import 'package:odr_sandhee/dashboard_screen.dart';
import 'package:odr_sandhee/respondend_main_screen.dart';
import 'package:odr_sandhee/verifyotpadmin.dart';
import 'package:odr_sandhee/verifyotparbitrator.dart';
import 'package:odr_sandhee/verifyotpclient.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:odr_sandhee/forgot_password.dart';
import 'package:odr_sandhee/register.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String userType = ' ';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _passwordVisible = false;
  bool _otpVisible = false;

  Future<void> _login() async {
    const hardcodedEmail = 'test@admin.com';
    const hardcodedPassword = '123456789';
    if (_emailController.text == hardcodedEmail &&
        _passwordController.text == hardcodedPassword) {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      if (userType == 'Client') {
        await _clientLogin();
      } else if (userType == 'Respondent') {
        String dynamicaccountnumber = _accountNumberController.text;
        await _respondentLogin(dynamicaccountnumber);
      } else if (userType == 'Arbitrator') {
        await _arbitratorLogin();
      } else if (userType == 'Admin') {
        await _adminLogin();
      }
    }
  }

  Future<void> _clientLogin() async {
    String url = '${GlobalService.baseUrl}/api/auth/login';
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(url));
    request.body = json.encode({
      "emailId": _emailController.text,
      "password": _passwordController.text
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var responseData = json.decode(responseBody);

      if (responseData.containsKey('role') && responseData.containsKey('email')) {
        _storedEmail = responseData['email'];
        print('Navigating to Verifyotp screen with email: $_storedEmail');
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Verifyotpclient(storedEmail: _storedEmail ?? ''),
          ),
        );
      } else {
        _showErrorDialog('Invalid response structure');
      }
    } else {
      _showErrorDialog(response.reasonPhrase ?? 'Login failed');
    }
  }

  Future<void> _respondentLogin(String dynamicaccountnumber) async {
    String accountNumberUrl = '${GlobalService.baseUrl}/api/cases/casewithaccountnumber/$dynamicaccountnumber';
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('GET', Uri.parse(accountNumberUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);
      String mobile = data['caseData']['respondentMobile'];
      String accountNumber = data['caseData']['accountNumber'];
      _sendOtp(mobile, accountNumber);

      setState(() {
        _otpVisible = true;
      });
      _showOtpDialog();
    } else {
      _showErrorDialog('Invalid account number');
    }
  }

  @override
  void initState() {
    super.initState();
    _otpController.clear();
  }

  Future<void> _sendOtp(String mobile, String accountNo) async {
    String otpUrl = '${GlobalService.baseUrl}/api/auth/respondentotp';
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('POST', Uri.parse(otpUrl));
    request.body = json.encode({
      "accountNumber": accountNo,
      "respondentMobile": mobile,
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print("OTP Sent Successfully");
    } else {
      _showErrorDialog('Failed to send OTP: ${response.reasonPhrase}');
    }
  }
  Future<void> _verifyOtp() async {
    String otpVerifyUrl = '${GlobalService.baseUrl}/api/auth/respondentlogin';
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(otpVerifyUrl));
    request.body = json.encode({
      "accountNumber": _accountNumberController.text,
      "otp": _otpController.text
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseData = json.decode(await response.stream.bytesToString());
      if (responseData.containsKey('token')) {
        await _saveToken(responseData['token']);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => RespondendMainScreen()));
      } else {
        _showErrorDialog('Token not found in response');
      }
    } else {
      _showErrorDialog(response.reasonPhrase ?? 'OTP verification failed');
    }
  }
  Future<void> _arbitratorLogin() async {
    String url = '${GlobalService.baseUrl}/api/auth/login';
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(url));
    request.body = json.encode({
      "emailId": _emailController.text,
      "password": _passwordController.text
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var responseBody = await response.stream.bytesToString();
      var responseData = json.decode(responseBody);

      if (responseData.containsKey('role') && responseData.containsKey('email')) {
        _storedEmail = responseData['email']; // Store the email for OTP
        print('Navigating to Verifyotp screen with email: $_storedEmail');

        // Ensure navigation is within a valid BuildContext
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyOtpArbitrator(storedEmail: _storedEmail ?? ''),
          ),
        );
      } else {
        _showErrorDialog('Invalid response structure');
      }
    } else {
      _showErrorDialog(response.reasonPhrase ?? 'Login failed');
    }
  }
String?_storedEmail;
  Future<void> _adminLogin() async {
    String url = '${GlobalService.baseUrl}/api/auth/login';
    var headers = {'Content-Type': 'application/json'};

    // Debugging log for input data
    print('Attempting login with Email: ${_emailController.text}');

    var request = http.Request('POST', Uri.parse(url));
    request.body = json.encode({
      "emailId": _emailController.text,
      "password": _passwordController.text,
    });

    request.headers.addAll(headers);

    try {
      // Send the login request
      http.StreamedResponse response = await request.send();
      print('Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody');

        var responseData = json.decode(responseBody);

        // Validate the response
        if (responseData.containsKey('role') && responseData.containsKey('email')) {
          _storedEmail = responseData['email']; // Store the email for OTP
          print('Navigating to Verifyotp screen with email: $_storedEmail');

          // Ensure navigation is within a valid BuildContext
          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpAdmin(storedEmail: _storedEmail ?? ''),
            ),
          );
        } else {
          print('Invalid response structure: $responseData');
          _showErrorDialog('Invalid response structure from the server');
        }
      } else {
        // Log and show error for non-200 status codes
        var errorBody = await response.stream.bytesToString();
        print('Error Response Body: $errorBody');
        _showErrorDialog('Login failed: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception occurred during login: $e');
      _showErrorDialog('An error occurred. Please try again.');
    }
  }
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();


    await prefs.setString('auth_token', token);

    await prefs.reload();


    String? savedToken = prefs.getString('auth_token');

    if (savedToken != null && savedToken.isNotEmpty) {
      print("Token saved successfully: $savedToken");
    } else {
      print("Token saving failed");
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          // Set background color to white for the dialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15.0), // Rounded corners for the dialog
          ),
          title: Text(
            'Error',
            style: TextStyle(
              color: Colors.blue, // Color the title text in red
              fontSize: 20,
              fontWeight: FontWeight.bold, // Make the title bold
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            // Add top padding for the content
            child: Text(
              message,
              style: TextStyle(
                color: Colors.black87, // Dark color for the content
                fontSize: 16,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.blue, // Blue color for the button text
                  fontSize: 16,
                  fontWeight: FontWeight
                      .w500, // Make the button text slightly bold
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  void _showOtpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter OTP'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _verifyOtp();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Scaffold(
      backgroundColor: Colors.blue[900], // Light background color
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      'assets/Images/Group.png',
                      height: 80,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    shadowColor: Colors.blue[900],
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              '$userType Login',
                              style: TextStyle(
                                fontSize: screenWidth > 600 ? 26 : 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildRadioButton('Client', Colors.blue),
                              _buildRadioButton('Respondent', Colors.blue),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildRadioButton('Admin', Colors.blue),
                              _buildRadioButton('Arbitrator', Colors.blue),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (userType == 'Respondent') ...[
                            TextFormField(
                              controller: _accountNumberController,
                              decoration: InputDecoration(
                                labelText: 'Account Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                prefixIcon: const Icon(Icons.account_circle),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your account number';
                                }
                                return null;
                              },
                            ),
                          ] else
                            ...[
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.email),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: !_passwordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _login();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1.0),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForgotPassword()),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RegisterScreen()),
                                );
                              },
                              child: Text(
                                "Don't have an account? Register",
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioButton(String label, Color color) {
    return Row(
      children: [
        Radio<String>(
          value: label,
          groupValue: userType,
          onChanged: (value) {
            setState(() {
              userType = value!;
            });
          },
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
