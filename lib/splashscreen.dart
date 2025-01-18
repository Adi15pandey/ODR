import 'package:flutter/material.dart';
import 'package:odr_sandhee/Admin_main_screen.dart';
import 'package:odr_sandhee/arbitrator_main_screen.dart';
import 'package:odr_sandhee/client_main_screen.dart';
import 'package:odr_sandhee/loginscreen.dart';
import 'package:odr_sandhee/respondend_main_screen.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  void _checkTokenAndNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve token and role
    String? token = prefs.getString('auth_token');
    String? role = prefs.getString('role'); // Role can be client, arbitrator, respondent, or admin

    // Simulate a delay for the splash screen
    await Future.delayed(Duration(seconds: 2));

    if (token != null && role != null) {
      // Navigate based on the role
      switch (role) {
        case 'client':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ClientMainScreen())
          );
          break;
        case 'arbitrator':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ArbitratorMainScreen())
          );
          break;
        case 'respondent':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RespondendMainScreen())
          );
          break;
        case 'admin':
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminMainScreen())
          );
          break;
        default:
        // Default to login screen if role is unknown
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
      }
    } else {
      // Navigate to login screen if token is not available
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Image
            Image.asset(
              'assets/Images/Group.png',
              width: 150,
              height: 150,
            ),
            SizedBox(height: 30),

            // App Name
            Text(
              'Welcome to ODR',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),

            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),

            // Loading Text
            // Text(
            //   'Please wait...',
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Colors.white70,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
