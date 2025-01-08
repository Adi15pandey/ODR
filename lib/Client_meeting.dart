import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


class ClientMeeting extends StatefulWidget {
  const ClientMeeting({super.key});

  @override
  State<ClientMeeting> createState() => _ClientMeetingState();
}

class _ClientMeetingState extends State<ClientMeeting> {
  List<Map<String, dynamic>> _meetings = [];
  bool _isLoading = true;
  String?token;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }
  Future<void> _fetchToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Reload preferences to ensure the latest data
      await prefs.reload();

      String? savedToken = prefs.getString('auth_token');

      if (savedToken != null && savedToken.isNotEmpty) {
        setState(() {
          token = savedToken;
        });
        print('Token fetched: $token');
        _fetchMeetings(); // Call API after fetching the token
      } else {
        print('Token not found');
        _showErrorDialog('Token not found. Please log in again.');
      }
    } catch (e) {
      print('Error fetching token: $e');
      _showErrorDialog('An error occurred while fetching the token.');
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<void> _fetchMeetings() async {
    const String url = "http://192.168.1.3:4001/api/webex/all-meetings/client";
    final headers = {
      'token': '$token', // Ensure $token contains the actual token value
    };
    try {
      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        final jsonData = json.decode(responseBody);
        setState(() {
          _meetings = List<Map<String, dynamic>>.from(jsonData['data']);
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching meetings: $e')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
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
              'Client Meeting',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _meetings.isEmpty
          ? const Center(child: Text('No meetings available'))
          : ListView.builder(
        itemCount: _meetings.length,
        itemBuilder: (context, index) {
          final meeting = _meetings[index];
          final meetingStartTime = DateTime.parse(meeting['meetings']['start']);
          final meetingEndTime = DateTime.parse(meeting['meetings']['end']);
          final now = DateTime.now();

          // Check if the meeting is over or not
          bool isMeetingOver = now.isAfter(meetingEndTime);
          bool isMeetingNotStarted = now.isBefore(meetingStartTime);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(0),
                title: Text(
                  'Case ID: ${meeting['caseId']}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue[700],
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client: ${meeting['clientName']}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Text(
                        'Respondent: ${meeting['respondentName']}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Text(
                        'Dispute Type: ${meeting['disputeType']}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Text(
                        'Arbitrator: ${meeting['arbitratorName']}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Start: ${DateFormat.yMd().add_jm().format(meetingStartTime)}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      Text(
                        'End: ${DateFormat.yMd().add_jm().format(meetingEndTime)}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                trailing: isMeetingOver
                    ? const Text(
                  'Meeting Over',
                  style: TextStyle(color: Colors.red),
                )
                    : isMeetingNotStarted
                    ? ElevatedButton(
                  onPressed: () {
                    final link = meeting['meetings']['webLink'];
                    if (link != null && link.isNotEmpty) {
                      launch(link);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                  child: const Text('Start Meeting'),
                )
                    : const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}
