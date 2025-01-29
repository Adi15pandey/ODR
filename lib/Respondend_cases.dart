import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/GlobalServiceurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class RespondendCases extends StatefulWidget {
  const RespondendCases({super.key});

  @override
  State<RespondendCases> createState() => _RespondendCasesState();
}

class _RespondendCasesState extends State<RespondendCases> {
  List<dynamic> caseData = [];
  bool isLoading = true;
  String errorMessage = '';
  String?token;

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
      _fetchCases();
    } else {
      print('Token not found');
    }
  }


  Future<void> _fetchCases() async {
    final url = '${GlobalService.baseUrl}/api/cases/allrespondentcases';

    try {
      final headers = {
        'token': '$token',
      };

      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          caseData = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
          'Failed to load cases. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/Images/Group.png',
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Cases', // Add title here
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      )
          : ListView.builder(
        itemCount: caseData.length,
        itemBuilder: (context, index) {
          final caseItem = caseData[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 15.0, vertical: 10.0),
            color: Colors.blue.shade50,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Case ID: ${caseItem['caseId']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Client Name: ${caseItem['clientName']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Respondent Name: ${caseItem['respondentName']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Dispute Type: ${caseItem['disputeType']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Amount: ₹${caseItem['amount']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Divider(
                    height: 20,
                    thickness: 1.5,
                    color: Colors.blueGrey,
                  ),
                  Text(
                    'DateTime: ${_formatDateTime(caseItem['createdAt'])}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'DateTime: ${_formatDateTime(caseItem['updatedAt'])}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Helper method to format date and time
  String _formatDateTime(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    return DateFormat('MMM dd, yyyy hh:mm a').format(parsedDate);
  }
}

