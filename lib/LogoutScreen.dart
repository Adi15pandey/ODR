import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/loginscreen.dart';

class LogoutScreen extends StatelessWidget {
  // This function handles the logout logic
  void _logout(BuildContext context) {
    // Clear any session or authentication data if needed (optional)

    // Navigate back to the login screen (or any screen you prefer)
    Navigator.pushReplacementNamed(context, '/login'); // Replace with your login route name
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You have logged out successfully.',
                style: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              textStyle: TextStyle(fontSize: 40), // Text style
            ),
            child: Text('Logout'), // Text to be displayed on the button
          )


            ],
          ),
        ),
      ),
    );
  }
}
