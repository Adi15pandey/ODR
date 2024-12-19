import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/forgot_password.dart';
import 'package:odr_sandhee/main_screen.dart';
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
                              style: GoogleFonts.poppins(
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
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                suffixIcon: Icon(Icons.visibility_off),
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> MainScreen()));
                                  // Process the login
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
          style: GoogleFonts.poppins(fontSize: 14),
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
