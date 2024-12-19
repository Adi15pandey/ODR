import 'package:flutter/material.dart';

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
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchTicketData();
  }

  Future<void> _fetchTicketData() async {

    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _ticketId = '';
      _userName = 'Aditya pandey';
    });
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

  void _raiseTicket() {
    if (_formKey.currentState!.validate()) {
      // Handle form submission
      print('Ticket Raised');
      // You can handle the form submission here, e.g., send the data to the backend
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Raise a Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_ticketId != null && _userName != null)
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Ticket ID: $_ticketId',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Name: $_userName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                label: 'Query',
                maxLines: 6,
              ),
              SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _raiseTicket,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: screenWidth * 0.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text('Raise Ticket'),
                ),
              ),
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
