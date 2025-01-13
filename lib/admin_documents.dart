import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';  // Import Google Fonts package

class AdminDocuments extends StatefulWidget {
  const AdminDocuments({super.key});

  @override
  State<AdminDocuments> createState() => _AdminDocumentsState();
}

class _AdminDocumentsState extends State<AdminDocuments> {
  List<dynamic> cases = [];
  bool isLoading = true;
  int page = 1;
  int limit = 5;

  @override
  void initState() {
    super.initState();
    fetchCases();
  }

  Future<void> fetchCases() async {
    setState(() {
      isLoading = true;
    });

    final url = 'http://192.168.1.12:4001/api/cases/all-cases?page=$page&limit=$limit';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        cases = data['cases'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Failed to load data');
    }
  }

  void showCaseDetailsDialog(dynamic caseData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Case Details - ${caseData['caseId']}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailText('Client Name', caseData['clientName']),
                  _buildDetailText('Client Email', caseData['clientEmail']),
                  _buildDetailText('Client Mobile', caseData['clientMobile']),
                  _buildDetailText('Respondent Name', caseData['respondentName']),
                  _buildDetailText('Arbitrator Name', caseData['arbitratorName']),
                  _buildDetailText('Arbitrator Email', caseData['arbitratorEmail']),
                  SizedBox(height: 10),
                  _buildDetailText(
                      'Attachments', caseData['attachments'].isEmpty ? 'No Attachments' : caseData['attachments'].join(', ')),
                  _buildDetailText(
                      'OrderSheet', caseData['orderSheet'].isEmpty ? 'No OrderSheet' : caseData['orderSheet'].join(', ')),
                  _buildDetailText('Awards', caseData['awards'].isEmpty ? 'No Awards' : caseData['awards'].join(', ')),
                  _buildDetailText('Recordings', caseData['recordings'].isEmpty ? 'No Recordings' : caseData['recordings'].join(', ')),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailText(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue.shade800,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Documents',
          style: GoogleFonts.poppins(fontSize: 20),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: cases.length,
        itemBuilder: (context, index) {
          final caseData = cases[index];
          return Card(
            color: Colors.blue.shade50,
            margin: const EdgeInsets.all(8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client: ${caseData['clientName']}',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Respondent: ${caseData['respondentName']}',
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              subtitle: Text(
                'Arbitrator: ${caseData['arbitratorName']}',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => showCaseDetailsDialog(caseData),
              ),
            ),
          );
        },
      ),
    );
  }
}
