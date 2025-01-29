import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/GlobalServiceurl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RespondentMeeting extends StatefulWidget {
  const RespondentMeeting({Key? key}) : super(key: key);

  @override
  State<RespondentMeeting> createState() => _RespondentMeetingState();
}

class _RespondentMeetingState extends State<RespondentMeeting> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> meetingData = [];
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
      fetchMeetings();

    } else {
      print('Token not found');
    }
  }

  Future<void> fetchMeetings() async {

    final url =
        '${GlobalService.baseUrl}/api/webex/all-meetings/respondent'; // API endpoint
    final headers = {
      'token': '$token',
    };
    try {
      var response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          meetingData = List<Map<String, dynamic>>.from(jsonResponse['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String _formatDateTime(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    return DateFormat('MMM dd, yyyy hh:mm a').format(parsedDate);
  }

  bool _isMeetingOver(String endDateTime) {
    final endTime = DateTime.parse(endDateTime);
    return DateTime.now().isAfter(endTime);
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
              'Meeting', // Add title here
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      )
          : ListView.builder(
        itemCount: meetingData.length,
        itemBuilder: (context, index) {
          final meeting = meetingData[index];
          final isOver = _isMeetingOver(meeting['meetings']['end']);

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
                    'Case ID: ${meeting['caseId']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Client Name: ${meeting['clientName']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Respondent Name: ${meeting['respondentName']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Dispute Type: ${meeting['disputeType']}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Meeting Start: ${_formatDateTime(meeting['meetings']['start'])}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Meeting End: ${_formatDateTime(meeting['meetings']['end'])}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 15),
                  isOver
                      ? Text(
                    'Meeting is over.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  )
                      : Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        // Add logic to open meeting link
                        print(
                            'Start Meeting: ${meeting['meetings']['webLink']}');
                      },
                      child: const Text('Start Meeting'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
