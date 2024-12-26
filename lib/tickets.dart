import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _queryController = TextEditingController();
  final _categoryController = TextEditingController();

  String? _ticketId;
  String?token;
  Color _ticketColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }
  Future<void> _fetchToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    await prefs.reload();

    String? savedToken = prefs.getString('auth_token');

    if (savedToken != null && savedToken.isNotEmpty) {
      setState(() {
        token = savedToken;
      });
      print('Token fetched: $token');
     _fetchTicketData();
     _handleAddNewTicket();
    } else {
      print('Token not found');
    }
  }
  Future<void> _fetchTicketData() async {
    try {
      final response = await http.get(
        Uri.parse('https://odr.sandhee.com/api/tickets/new-ticketId'),
        headers: {
          'token': '$token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _ticketId = responseData['ticketId'];
          _ticketColor = Colors.green; // Change color to green on success
        });
      } else {
        setState(() {
          _ticketColor = Colors.red; // Change color to red on failure
        });
        _showSnackBar('Failed to fetch Ticket ID');
      }
    } catch (e) {
      setState(() {
        _ticketColor = Colors.red; // Change color to red on error
      });
      _showSnackBar('Error: $e');
    }
  }

  // Show a snack bar for messages
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _queryController.dispose();
    _categoryController.dispose();
    super.dispose();
  }


  Future<void> _handleAddNewTicket() async {
    var headers = {
      'token': '$token',
      'Content-Type': 'application/json',
    };

    if (_ticketId == null || _ticketId!.isEmpty) {
      return;
    }
    if (_nameController.text.isEmpty) {
      _showSnackBar('Name is required.');
      return;
    }
    if (_contactController.text.isEmpty) {
      _showSnackBar('Contact Number is required.');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showSnackBar('Email is required.');
      return;
    }
    if (_categoryController.text.isEmpty) {
      _showSnackBar('Category is required.');
      return;
    }
    if (_queryController.text.isEmpty) {
      _showSnackBar('Query is required.');
      return;
    }

    var formData = {
      'ticketId': _ticketId,
      'name': _nameController.text,
      'contactNumber': _contactController.text,
      'email': _emailController.text,
      'category': _categoryController.text,
      'query': _queryController.text,
    };
    print('Form Data: $formData');

    var request = http.Request('POST', Uri.parse('https://odr.sandhee.com/api/tickets/new-ticket'));
    request.headers.addAll(headers);
    request.body = json.encode(formData);

    try {
      http.StreamedResponse response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        print('Response body: ${responseBody.body}');
        _showSnackBar('Ticket raised successfully!');

        setState(() {
          _nameController.clear();
          _contactController.clear();
          _emailController.clear();
          _categoryController.clear();
          _queryController.clear();
        });
        _fetchTicketData();
      } else {
        print('Error response status: ${response.statusCode}');
        print('Error response body: ${responseBody.body}');
        _showSnackBar('Failed to raise ticket. Please try again.');
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
              'Raise Ticket',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_ticketId != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Ticket ID: $_ticketId',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _ticketColor,
                        ),
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
              SizedBox(height: 24.0),
              _buildTextField(
                controller: _nameController,
                label: 'Name',
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                controller: _contactController,
                label: 'Contact Number',
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                controller: _categoryController,
                label: 'Category',
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                controller: _queryController,
                label: ' Enter a Query',
                maxLines: 6,
              ),
              SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _handleAddNewTicket,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, padding: EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: screenWidth * 0.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Adjust border radius for a rounded effect
                    ), // Text color
                    elevation: 5, // Adding shadow for a raised effect
                    shadowColor: Colors.purple.withOpacity(0.4), // Shadow color for elevation
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Raise Ticket'),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        labelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }
}
