import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/respondend_main_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:odr_sandhee/main_screen.dart';
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
  final TextEditingController _mobileNumberController = TextEditingController();
  bool _passwordVisible = false;
  bool _otpVisible = false;

  Future<void> _login() async {
    if (userType == 'Client') {
      await _clientLogin();
    } else if (userType == 'Respondent') {

      String dynamicaccountnumber = _accountNumberController.text;
      await _respondentLogin(dynamicaccountnumber);
    }
  }

  Future<void> _clientLogin() async {
    String url = 'https://odr.sandhee.com/api/auth/login';
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

      if (responseData.containsKey('token')) {
        await _saveToken(responseData['token']);
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        _showErrorDialog('Token not found in response');
      }
    } else {
      _showErrorDialog(response.reasonPhrase ?? 'Login failed');
    }
  }

  Future<void> _respondentLogin(String dynamicaccountnumber) async {
    String accountNumberUrl = 'https://odr.sandhee.com/api/cases/casewithaccountnumber/$dynamicaccountnumber';
    var headers = {'Content-Type': 'application/json'};


    var request = http.Request('GET', Uri.parse(accountNumberUrl));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    // Check if the account request was successful
    if (response.statusCode == 200) {
      // Convert the response body to a string
      String responseBody = await response.stream.bytesToString();
      // Parse the JSON response
      var data = json.decode(responseBody);

      // Extract the relevant data (respondentMobile and accountNumber)
      String mobile = data['caseData']['respondentMobile'];
      String accountNumber = data['caseData']['accountNumber'];

      // Print the mobile and account number
      print("Respondent Mobile: $mobile");
      print("Account Number: $accountNumber");

      // Now, you can call the _sendOtp() method with the mobile number
      _sendOtp(mobile, accountNumber); // Assuming _sendOtp() method is updated to take mobile number as a parameter

      // Log the response body (optional for debugging)
      print(responseBody);

      // Show OTP dialog if account fetch is successful
      setState(() {
        _otpVisible = true;
      });
      _showOtpDialog();
    } else {
      // Handle failure if the account fetch fails
      print(response.reasonPhrase);  // Log the error
      _showErrorDialog('Invalid account number');
    }
  }



  Future<void> _sendOtp(String mobile , String accountNo) async {
    String otpUrl = 'https://odr.sandhee.com/api/auth/respondentotp';
    var headers = {'Content-Type': 'application/json'};

    var request = http.Request('POST', Uri.parse(otpUrl));
    request.body = json.encode({
      "accountNumber": accountNo,
      "respondentMobile": mobile,
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();


    String responseBody = await response.stream.bytesToString();
    print("Response Status: ${response.statusCode}");
    print("Response Body: $responseBody");

    if (response.statusCode == 201) {
      print("OTP Sent Successfully0000000000000000000000000000000000");

    } else {
      print("Error: ${response.reasonPhrase}");
      // _showErrorDialog('Failed to send OTP: ${response.reasonPhrase}');
    }
  }


  Future<void> _verifyOtp() async {
    String otpVerifyUrl = 'https://odr.sandhee.com/api/auth/respondentlogin';
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse(otpVerifyUrl));
    request.body = json.encode({
      "accountNumber": _accountNumberController.text,
      "otp": _otpController.text
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    String responseBody = await response.stream.bytesToString();
    print("OTP Verification Response Status: ${response.statusCode}");
    print("OTP Verification Response Body: $responseBody");

    if (response.statusCode == 200) {
      var responseData = json.decode(responseBody);
print("888888y8uy8uy");
      if (responseData.containsKey('token')) {
        await _saveToken(responseData['token']);
        Navigator.push(context, MaterialPageRoute(builder: (context) => RespondendMainScreen()));
      } else {
        _showErrorDialog('Token not found in response');
      }
    } else {
      _showErrorDialog(response.reasonPhrase ?? 'OTP verification failed');
    }
  }


  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      'assets/Images/Group.png',
                      height: 70,
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              '$userType Login',
                              style: TextStyle(
                                fontSize: screenWidth > 600 ? 24 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              _buildRadioButton('Client'),
                              _buildRadioButton('Respondent'),
                            ],
                          ),
                          SizedBox(height: 20),
                          if (userType == 'Respondent') ...[
                            TextFormField(
                              controller: _accountNumberController,
                              decoration: InputDecoration(
                                labelText: 'Account Number',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your account number';
                                }
                                return null;
                              },
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
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
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPassword()));
                                },
                                child: Text('Forgot Password?'),
                              ),
                            ),
                          ],
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _login();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[900],
                              ),
                              child: Text('Login'),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text('or'),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                              },
                              child: Text('Register here'),
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

  Widget _buildRadioButton(String title) {
    return Flexible(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(fontSize: 14),
        ),
        leading: SizedBox(
          width: 24,
          child: Radio<String>(
            value: title,
            groupValue: userType,
            onChanged: (value) {
              setState(() {
                userType = value!;
              });
            },
          ),
        ),
      ),
    );
  }
}
