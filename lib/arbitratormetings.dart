import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Arbitratormetings extends StatefulWidget {
  const Arbitratormetings({super.key});

  @override
  State<Arbitratormetings> createState() => _ArbitratormetingsState();
}

class _ArbitratormetingsState extends State<Arbitratormetings> {
  List<dynamic> recentMeetingData = [];
  String? token;

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
      _fetchMeetingData();
    } else {
      print('Token not found');
      _showErrorDialog('Token not found');
    }
  }


  Future<void> _fetchMeetingData() async {
    final url = 'https://odr.sandhee.com/api/webex/all-meetings/arbitrator';
    final headers = {
      'token': '$token',
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Recent Meeting API Response: $data');

        setState(() {
          recentMeetingData = data['data'];
        });
      } else {
        _showErrorDialog('Failed to fetch recent meeting data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching recent meeting data: $e');
      _showErrorDialog('An error occurred: $e');
    }
  }

  // Method to show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }
  Widget _buildRecentMeetingList() {
    if (recentMeetingData.isEmpty) {
      return const Center(
        child: Text(
          'No recent meetings available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView( // Wrap the entire Column in a SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Recent Meetings',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue[800],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Vertical Scrollable List
            ListView.builder(
              shrinkWrap: true,  // Ensures it takes up only as much space as needed
              physics: NeverScrollableScrollPhysics(), // Disable scrolling here since the parent is already scrollable
              itemCount: recentMeetingData.length,
              itemBuilder: (context, index) {
                return _buildMeetingCard(recentMeetingData[index]);
              },
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildMeetingCard(var meeting) {
    String meetingDate = meeting['meetings']['start'] != null
        ? DateTime.parse(meeting['meetings']['start']).toLocal().toString().split(' ')[0]
        : 'No Date';
    String meetingTime = meeting['meetings']['start'] != null
        ? DateTime.parse(meeting['meetings']['start']).toLocal().toString().split(' ')[1]
        : 'No Time';

    String respondentName = meeting['respondentName'] ?? 'No Respondent';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Case ID Title
              Text(
                'Case ID: ${meeting['caseId']}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 8),

              // Client Name
              Text(
                'Client: ${meeting['clientName']}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 8),

              // Arbitrator Name
              Text(
                'Arbitrator: ${meeting['arbitratorName']}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 8),

              // Respondent Name
              Text(
                'Respondent: $respondentName',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(height: 8),

              // Date and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Date: $meetingDate',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Time: $meetingTime',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              InkWell(
                onTap: () {
                  launch(meeting['meetings']['webLink']);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[500]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'Join Meeting',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            Expanded(
              child: Text(
                'Arbitrator Meetings',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                overflow: TextOverflow.ellipsis, // Handles text overflow
              ),
            ),
          ],
        ),
      ),

      body: _buildRecentMeetingList(),
    );
  }
}
