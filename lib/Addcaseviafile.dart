import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/GlobalServiceurl.dart';

class AddCaseForm extends StatefulWidget {
  @override
  _AddCaseFormState createState() => _AddCaseFormState();
}

class _AddCaseFormState extends State<AddCaseForm> {
  final _formKey = GlobalKey<FormState>();
  final Dio _dio = Dio();

  List<PlatformFile>? _selectedFiles = [];
  TextEditingController _caseIdController = TextEditingController();
  TextEditingController _clientNameController=TextEditingController();
  TextEditingController _respondentNameController =TextEditingController();
  TextEditingController _clientMobileController = TextEditingController();
  TextEditingController _clientEmailController = TextEditingController();
  TextEditingController _clientAddressController = TextEditingController();
  TextEditingController _respondentMobileController = TextEditingController();
  TextEditingController _respondentEmailController = TextEditingController();
  TextEditingController _respondentAddressController = TextEditingController();
  TextEditingController _disputeTypeController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _cardNoController = TextEditingController();


  List<dynamic> _clients = [];
  String? _selectedClientId;
  String? _selectedRespondentId;

  @override
  void initState() {
    super.initState();
    fetchCaseId();
    fetchClients();
  }

  void fetchCaseId() async {
    try {
      final response = await _dio.get(
          'http://192.168.0.109:4001/api/cases/auto-caseid');
      setState(() {
        _caseIdController.text = response.data['data'];
      });
    } catch (e) {
      print("Error fetching case ID: $e");
    }
  }

  void fetchClients() async {
    try {
      final response = await _dio.get('${GlobalService.baseUrl}/api/client/all');
      setState(() {
        _clients = response.data['user'];
      });
    } catch (e) {
      print("Error fetching clients: $e");
    }
  }

  void _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
    }
  }

  void _populateClientData(String clientId) {
    final client = _clients.firstWhere((c) => c['_id'] == clientId);
    setState(() {
      _clientMobileController.text = client['contactNo'] ?? '';
      _clientEmailController.text = client['emailId'] ?? '';
      _clientAddressController.text = client['address'] ?? '';
      _clientNameController.text=client['name']??'';
    });
  }

  void _populateRespondentData(String respondentId) {
    final respondent = _clients.firstWhere((c) => c['_id'] == respondentId);
    setState(() {
      _respondentMobileController.text = respondent['contactNo'] ?? '';
      _respondentEmailController.text = respondent['emailId'] ?? '';
      _respondentAddressController.text = respondent['address'] ?? '';
      _respondentNameController.text=respondent['name']??'';
    });
  }

  List<dynamic> _filterRespondents(String? selectedClientId) {
    return _clients
        .where((client) => client['_id'] != selectedClientId)
        .toList();
  }

  List<dynamic> _filterClients(String? selectedRespondentId) {
    return _clients
        .where((client) => client['_id'] != selectedRespondentId)
        .toList();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Log the values of the required fields
        String clientName = _clientNameController.text.trim();
        String respondentName = _respondentNameController.text.trim();

        print("Client Name: $clientName");
        print("Respondent Name: $respondentName");

        // Create the caseData object as a map
        final caseData = {
          "caseId": _caseIdController.text.trim(),
          "clientId": _selectedClientId ?? '',
          "clientMobile": _clientMobileController.text.trim(),
          "clientEmail": _clientEmailController.text.trim(),
          "clientAddress": _clientAddressController.text.trim(),
          "clientName": clientName,
          "respondentId": _selectedRespondentId ?? '',
          "respondentMobile": _respondentMobileController.text.trim(),
          "respondentEmail": _respondentEmailController.text.trim(),
          "respondentAddress": _respondentAddressController.text.trim(),
          "respondentName": respondentName, // Ensure this is not empty
          "disputeType": _disputeTypeController.text.trim(),
          "disputeAmount": int.tryParse(_amountController.text) ?? 0,
          "accountNumber": _accountNumberController.text.trim(),
          "cardNumber": _cardNoController.text.trim(),
        };
        if (clientName.isEmpty || respondentName.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Client Name and Respondent Name are required.')),
          );
          return; // Exit if required fields are empty
        }

        final stringifiedCaseData = json.encode(caseData);
        final payload = {
          "caseData": stringifiedCaseData,
        };

        var headers = {'Content-Type': 'application/json'};
        var request = http.Request(
          'POST',
          Uri.parse('${GlobalService.baseUrl}/api/cases/addcase'),
        );

        request.body = json.encode(payload);
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        // Log response for debugging
        print("Status Code: ${response.statusCode}");
        print("Reason: ${response.reasonPhrase}");

        // Parse the response
        final responseBody = await response.stream.bytesToString();
        print("Response Body: $responseBody");

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = json.decode(responseBody);

          if (responseData['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Case added successfully')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(responseData['message'] ?? 'Error occurred')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Server error: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        print("Exception: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildDropdown(
      String label, List<dynamic> items, String? selectedItem, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedItem,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((item) => DropdownMenuItem<String>(
        value: item['_id'],
        child: Text(item['name']),
      ))
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRespondents = _filterRespondents(_selectedClientId);
    final filteredClients = _filterClients(_selectedRespondentId);

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
              'Add Case',
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
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _caseIdController,
                  readOnly: true,
                  decoration: InputDecoration(labelText: 'Case ID'),
                ),
                _buildDropdown(
                  'Client Name',
                  filteredClients,
                  _selectedClientId,
                      (value) {
                    setState(() {
                      _selectedClientId = value;
                      _populateClientData(value!);
                      _selectedRespondentId = null;
                    });
                  },
                ),
                TextFormField(
                  controller: _clientMobileController,
                  decoration: InputDecoration(labelText: 'Client Mobile'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _clientEmailController,
                  decoration: InputDecoration(labelText: 'Client Email'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _clientAddressController,
                  decoration: InputDecoration(labelText: 'Client Address'),
                  readOnly: true,
                ),
                _buildDropdown(
                  'Respondent Name',
                  filteredRespondents,
                  _selectedRespondentId,
                      (value) {
                    setState(() {
                      _selectedRespondentId = value;
                      _populateRespondentData(value!);
                    });
                  },
                ),
                TextFormField(
                  controller: _respondentMobileController,
                  decoration: InputDecoration(labelText: 'Respondent Mobile'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _respondentEmailController,
                  decoration: InputDecoration(labelText: 'Respondent Email'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _respondentAddressController,
                  decoration: InputDecoration(labelText: 'Respondent Address'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: _cardNoController,
                  decoration: InputDecoration(labelText: 'Card Number'),
                  readOnly: false,
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Amount'),
                  readOnly: false,
                ),
                TextFormField(
                  controller: _accountNumberController,
                  decoration: InputDecoration(labelText: 'Account number'),
                  readOnly: false,
                ),
                TextFormField(
                  controller: _disputeTypeController,
                  decoration: InputDecoration(labelText: 'Dispute type'),
                  readOnly: false,
                ),

                ElevatedButton(
                  onPressed: _pickFiles,
                  child: Text('Choose Files'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,  // Choose a color that suits your theme
                    padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), // Rounded corners
                    ),
                    textStyle: TextStyle(
                      fontSize: 16, // Slightly larger text for better readability
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  _selectedFiles != null && _selectedFiles!.isNotEmpty
                      ? '${_selectedFiles!.length} files selected'
                      : 'No files selected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),

                SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Add Case'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 30.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
