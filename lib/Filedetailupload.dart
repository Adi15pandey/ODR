
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/GlobalServiceurl.dart';
import 'package:path/path.dart';


class FileDetailsDialog extends StatefulWidget {
  @override
  _FileDetailsDialogState createState() => _FileDetailsDialogState();
}

class _FileDetailsDialogState extends State<FileDetailsDialog> {
  final String currentDate = DateFormat('d MMMM yyyy').format(DateTime.now());
  String? selectedFilePath;
  String? selectedEmail;
  String? selectedDisputeType;
  List<String> clientEmails = [];
  bool isLoadingEmails = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFilePath = result.files.single.path;
      });
    }
  }

  Future<void> _fetchClientEmails() async {
    setState(() {
      isLoadingEmails = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${GlobalService.baseUrl}/api/client/all'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['user'] != null) {
          setState(() {
            clientEmails = data['user']
                .map<String>((user) =>
            '${user['name']} , ${user['contactNo']})')
                .toList();
            isLoadingEmails = false;
          });
        } else {
          throw Exception('Invalid response structure');
        }
      } else {
        throw Exception('Failed to fetch client emails');
      }
    } catch (e) {
      setState(() {
        isLoadingEmails = false;
      });
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error fetching client data: $e')),
      );
    }
  }


  Future<void> _submitForm() async {
    try {
      Uri uri = Uri.parse('http://192.168.0.109:4001/api/cases/bulkupload');
      String filePath = selectedFilePath!;

      File file = File(filePath);

      if (!file.existsSync()) {
        print('File not found at: $filePath');
        return;
      }

      // Constructing FormData
      var request = http.MultipartRequest('POST', uri);

      // Add fields to the form data
      request.fields.addAll({
        'clientName': 'Rajat',
        'clientId': '677f51273afc06c76d48adfc',
        'clientEmail': 'rajat.agrawal@recqarz.com',
        'clientAddress': 'Delhi',
        'clientMobile': '6260175117',
        'disputeType': 'Fraud',

      });

      // Add the file to the form data
      request.files.add(await http.MultipartFile.fromPath(
        'excelFile',
        filePath,
        filename: basename(filePath),
      ));

      // Sending the request
      http.StreamedResponse response = await request.send();

      // Handling the response
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Upload Successful: $responseBody');
      } else {
        String errorBody = await response.stream.bytesToString();
        print('Error ${response.statusCode}: ${response.reasonPhrase}');
        print('Server Response: $errorBody');
      }
    } catch (e) {
      print('Unexpected Error: $e');
    }
  }


  // Future<void> _submitForm() async {
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('http://192.168.0.109:4001/api/cases/bulkupload'),
  //     );
  //
  //     // Adding fields to the request
  //     request.fields.addAll({
  //       'clientName': 'Rajat', // Replace with dynamic value if needed
  //       'clientId': '677f51273afc06c76d48adfc', // Replace with dynamic value if needed
  //       'clientEmail': 'rajat.agrawal@recqarz.com', // Replace with dynamic value if needed
  //       'clientAddress': 'Delhi', // Replace with dynamic value if needed
  //       'clientMobile': '6260175117', // Replace with dynamic value if needed
  //       'disputeType': 'Fraud', // Replace with dynamic value if needed
  //     });
  //
  //     // Adding file to the request
  //     String filePath = selectedFilePath!;
  //
  //     request.files.add(await http.MultipartFile.fromPath('excelFile', filePath));
  //
  //     // Sending the request
  //     http.StreamedResponse response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       // Parse and print response
  //       String responseBody = await response.stream.bytesToString();
  //       var responseData = json.decode(responseBody);
  //       print('Upload Successful: ${responseData['message']}');
  //     } else {
  //       // Print server error
  //       print('Error ${response.statusCode}: ${response.reasonPhrase}');
  //       String errorBody = await response.stream.bytesToString();
  //       print('Server Response: $errorBody');
  //     }
  //   } catch (e) {
  //     // Handle exceptions
  //     print('Unexpected Error: $e');
  //   }
  // }


  // Future<void> _submitForm() async {
  //   if (selectedEmail == null ||
  //       selectedFilePath == null ||
  //       selectedDisputeType == null ||
  //       selectedDisputeType!.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           'Please fill all required fields and upload a file.',
  //         ),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('${GlobalService.baseUrl}/api/cases/bulkupload'),
  //     );
  //
  //     // Add fields to the request
  //     request.fields.addAll({
  //       'clientName': 'Rajat', // Replace with dynamic value
  //       'clientId': '677f51273afc06c76d48adfc', // Replace with dynamic value
  //       'clientEmail': "rajat.agrawal@recqarz.com", // Replace with dynamic value
  //       'clientAddress': 'Delhi',
  //       'clientMobile': '6260175117', // Replace with dynamic value
  //       'disputeType': "fraud", // Replace with dynamic value
  //     });
  //
  //     print(request.fields);
  //
  //     // Check if the file path exists
  //     if (selectedFilePath == null || selectedFilePath!.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Please select a file to upload.')),
  //       );
  //       return;
  //     }
  //
  //     // Add the file to the request
  //     var file = await http.MultipartFile.fromPath(
  //       'excelFile',
  //       selectedFilePath!,
  //     );
  //
  //     // Ensure the file is of the correct type
  //     if (file.filename != null && !file.filename!.endsWith('.xlsx')) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Invalid file type. Please upload an Excel file.'),
  //         ),
  //       );
  //       return;
  //     }
  //
  //     request.files.add(file);
  //
  //     var response = await request.send();
  //
  //     // Check if the response was successful
  //     if (response.statusCode == 200) {
  //       final responseBody = await response.stream.bytesToString();
  //       final responseData = jsonDecode(responseBody);
  //
  //       if (responseData['success'] == true) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('File uploaded successfully!')),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Server error: ${responseData['message']}')),
  //         );
  //       }
  //     } else {
  //       // Print the response body for more insights in case of failure
  //       final responseBody = await response.stream.bytesToString();
  //       print('Server Error: ${response.statusCode}');
  //       print('Response Body: $responseBody'); // This will print the full response body
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to upload file. Error: $responseBody'),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     // Catch and display any unexpected errors
  //     print('Unexpected Error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }


  @override
  void initState() {
    super.initState();
    _fetchClientEmails();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      // Makes the dialog occupy full screen
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      // Remove rounded corners
      child: Scaffold(
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
                'File Detail',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Information
                Text(
                  'File Name: Excel',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Date: $currentDate',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),

                // Dropdown Field
                _buildDropdownField('Client Email *'),
                SizedBox(height: 16),

                // Text Field
                _buildTextField('Dispute Type *', 'Fraud'),
                SizedBox(height: 16),

                // File Upload Field
                _buildFileUploadField(),
                SizedBox(height: 16),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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

  Widget _buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        isLoadingEmails
            ? Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<String>(
          items: clientEmails.map((email) {
            return DropdownMenuItem<String>(
              value: email,
              child: Text(email),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedEmail = value;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Search for an email...',
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: hint,
          onChanged: (value) {
            selectedDisputeType = value;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Excel File *',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 40,
                      color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'Upload file',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Only .xlsx file is allowed.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Selected file: ${selectedFilePath ?? 'None'}',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
