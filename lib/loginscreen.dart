import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/Admin_main_screen.dart';
import 'package:odr_sandhee/arbitrator_main_screen.dart';
import 'package:odr_sandhee/respondend_main_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:odr_sandhee/client_main_screen.dart';
import 'package:odr_sandhee/forgot_password.dart';
import 'package:odr_sandhee/register.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String userType = ' '; // Default userType set to 'Client'
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _passwordVisible = false;
  bool _otpVisible = false;

  Future<void> _login() async {
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

      if (responseData.containsKey('token') && responseData.containsKey('role')) {
        await _saveToken(responseData['token']);

        if (responseData['role'] == 'client') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ClientMainScreen()));
        } else {
          _showErrorDialog('Invalid role');
        }
      } else {
        _showErrorDialog('Invalid response structure');
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

  Future<void> _sendOtp(String mobile, String accountNo) async {
    String otpUrl = 'https://odr.sandhee.com/api/auth/respondentotp';
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
    String otpVerifyUrl = 'https://odr.sandhee.com/api/auth/respondentlogin';
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
        Navigator.push(context, MaterialPageRoute(builder: (context) => RespondendMainScreen()));
      } else {
        _showErrorDialog('Token not found in response');
      }
    } else {
      _showErrorDialog(response.reasonPhrase ?? 'OTP verification failed');
    }
  }

  Future<void> _arbitratorLogin() async {
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

      if (responseData.containsKey('token') && responseData.containsKey('role')) {
        await _saveToken(responseData['token']);  // Save the token

        if (responseData['role'] == 'arbitrator') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ArbitratorMainScreen()));
        }
        else {
          _showErrorDialog('Invalid role');
        }
      } else {
        _showErrorDialog('Invalid response structure');
      }
    } else {
      _showErrorDialog(response.reasonPhrase ?? 'Login failed');
    }
  }
  Future<void> _adminLogin() async {
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

      if (responseData.containsKey('token') && responseData.containsKey('role')) {
        await _saveToken(responseData['token']);  // Save the token

        if (responseData['role'] == 'admin') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminMainScreen()));
        }
        else {
          _showErrorDialog('Invalid role');
        }
      } else {
        _showErrorDialog('Invalid response structure');
      }
    } else {
      _showErrorDialog(response.reasonPhrase ?? 'Login failed');
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildRadioButton('Client'),
                              _buildRadioButton('Respondent'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildRadioButton('Admin'),
                              _buildRadioButton('Arbitrator'),
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
                                return null;
                              },
                            ),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_passwordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
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
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await _login();
                                }
                              },
                              child: Text('Login'),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ForgotPassword()),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                                );
                              },
                              child: Text(
                                'Don\'t have an account? Register',
                                style: TextStyle(
                                  color: Colors.blue,
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
  Widget _buildRadioButton(String type) {
    return Row(
      children: [
        Radio<String>(
          value: type,
          groupValue: userType,
          onChanged: (value) {
            setState(() {
              userType = value!;
            });
          },
        ),
        Text(type),
      ],
    );
  }
}
