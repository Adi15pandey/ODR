import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/GlobalServiceurl.dart';
import 'package:odr_sandhee/RegisterVerifyotp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // Dispose the controllers when the widget is destroyed
    idController.dispose();
    nameController.dispose();
    contactController.dispose();
    emailController.dispose();
    addressController.dispose();
    aboutController.dispose();
    passwordController.dispose(); // Dispose of password controller
    super.dispose();
  }

  // Fetch Client ID from the API
  Future<void> fetchClientId() async {
    try {
      var response = await http.get(Uri.parse('${GlobalService.baseUrl}/api/autouid/client'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          idController.text = data['uid']; // Set the client ID in the controller
        });
      } else {
        print('Failed to load client ID');
      }
    } catch (e) {
      print("Error fetching client ID: $e");
    }
  }

  // Register Client


// Register Client
  Future<void> registerClient() async {
    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request(
      'POST',
      Uri.parse('${GlobalService.baseUrl}/api/auth/register'),
    );
    request.body = json.encode({
      "name": nameController.text,
      "password": passwordController.text,
      "contactNo": contactController.text,
      "emailId": emailController.text,
      "about": aboutController.text,
      "address": addressController.text,
      "uid": idController.text,
      "role":"client",
    });
    if (nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        contactController.text.isEmpty ||
        emailController.text.isEmpty ||
        addressController.text.isEmpty ||
        aboutController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('Error Response: $responseBody');
        print('Status Code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully!')),
        );

        // Save email locally using shared_preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', emailController.text);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterVerifyotp(
              email: emailController.text, // Pass the email to the next screen
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to register client.')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred.')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    fetchClientId(); // Fetch client ID when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Row(
          children: [
            Image.asset(
              'assets/Images/Group.png',
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Register',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),

          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),

              // Client ID (Read-Only)
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: 'Client ID',
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                enabled: false, // Read-only field
              ),
              const SizedBox(height: 15),

              // Name
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Contact
              TextField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Contact',
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Email Address
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Address
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // About
              TextField(
                controller: aboutController,
                maxLines: 3, // Multi-line input
                decoration: InputDecoration(
                  labelText: 'About',
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Password
              TextField(
                controller: passwordController,
                obscureText: true, // Hides password input
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Call the API to register the client
                    registerClient();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
