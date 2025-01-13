import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class AddArbitrator extends StatefulWidget {
  const AddArbitrator({super.key});

  @override
  State<AddArbitrator> createState() => _AddArbitratorState();
}

class _AddArbitratorState extends State<AddArbitrator> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final TextEditingController areaOfExpertiseController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    contactController.dispose();
    emailController.dispose();
    addressController.dispose();
    aboutController.dispose();
    areaOfExpertiseController.dispose();
    experienceController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Fetch Arbitrator ID from the API
  Future<void> fetchArbitratorId() async {
    try {
      var response = await http.get(Uri.parse('http://192.168.1.12:4001/api/autouid/arbitrator'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          idController.text = data['uid'];
        });
      } else {
        print('Failed to load arbitrator ID');
      }
    } catch (e) {
      print("Error fetching arbitrator ID: $e");
    }
  }

  // Register Arbitrator
  Future<void> registerArbitrator() async {
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
      'POST',
      Uri.parse('http://192.168.1.12:4001/api/auth/register'),
    );

    // Adding the "role": "arbitrator" field
    request.body = json.encode({
      "name": nameController.text,
      "password": passwordController.text,
      "contactNo": contactController.text,
      "emailId": emailController.text,
      "about": aboutController.text,
      "address": addressController.text,
      "uid": idController.text,
      "areaOfExpertise": areaOfExpertiseController.text,
      "experience": experienceController.text,
      "role": "arbitrator",  // New field added
    });

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print("Response: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Arbitrator registered successfully!')),
        );
      } else {
        String responseBody = await response.stream.bytesToString();
        var errorData = json.decode(responseBody);
        String errorMessage = errorData['message'] ?? 'Failed to register arbitrator.';

        if (errorMessage == 'Failed to send OTP via email.') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mock success: OTP sending skipped.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

    @override
  void initState() {
    super.initState();
    fetchArbitratorId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Row(
          children: [
            Image.asset(
              'assets/Images/Group.png',
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Add Arbitrator',
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
                'Arbitrator Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: idController,
                decoration: InputDecoration(
                  labelText: 'Arbitrator ID',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                enabled: false,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Contact',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: aboutController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'About',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: areaOfExpertiseController,
                decoration: InputDecoration(
                  labelText: 'Area of Expertise',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: experienceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Experience (Years)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    registerArbitrator();
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
                    'Save Arbitrator',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

