import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';// Import the intl package

class MeetingAdmin extends StatefulWidget {
  const MeetingAdmin({super.key});

  @override
  State<MeetingAdmin> createState() => _MeetingAdminState();
}

class _MeetingAdminState extends State<MeetingAdmin> {
  List<dynamic> meetings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMeetings();
  }

  // Fetch meetings from the API
  Future<void> fetchMeetings() async {
    final String apiUrl = 'http://192.168.1.22:4001/api/webex/all-meetings';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          meetings = data['data']; // Extract meetings from the 'data' field
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load meetings');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching meetings: $error');
    }
  }

  // Function to launch URL
  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(Uri.encodeFull(url));
      if (await canLaunchUrl(uri)) {
        print('Launching URL: $uri');
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Cannot launch URL: $uri');
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  // Function to check if the meeting time is over
  bool isMeetingOver(String endTime) {
    final DateTime end = DateTime.parse(endTime);
    final DateTime now = DateTime.now();
    return now.isAfter(end);
  }

  // Function to format date and time
  String formatDateTime(String dateTime) {
    final DateTime parsedDate = DateTime.parse(dateTime);
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(parsedDate);
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
              'Admin Meeting ',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          final String startTime = meeting['meetings']['start'];
          final String endTime = meeting['meetings']['end'];
          final bool meetingOver = isMeetingOver(endTime);

          return Card(
            color: Colors.blue.shade50,
            elevation: 5,
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Case ID: ${meeting['caseId']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Client: ${meeting['clientName']}',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Respondent: ${meeting['respondentName']}',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dispute Type: ${meeting['disputeType']}',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Arbitrator: ${meeting['arbitratorName']}',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'Start Date and Time: ${formatDateTime(startTime)}',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 5),
                      Text(
                        'End Date and Time: ${formatDateTime(endTime)}',
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  meetingOver
                      ? Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Time Over',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                      : InkWell(
                    onTap: () {
                      launch(meeting['meetings']['webLink']);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Join Meeting',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
