import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:odr_sandhee/Arbitratormodels.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Arbitratorcases extends StatefulWidget {
  const Arbitratorcases({super.key});

  @override
  State<Arbitratorcases> createState() => _ArbitratorcasesState();
}


class _ArbitratorcasesState extends State<Arbitratorcases> {
  String? token;
  late Future<List<Case>> futureCases;

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
      futureCases = fetchCasesWithToken();
    } else {
      print('Token not found');
    }
  }


  Future<List<Case>> fetchCasesWithToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('Token not found');
    }

    var headers = {
      'token': token,
    };

    try {
      var request = http.Request('GET',
          Uri.parse('https://odr.sandhee.com/api/cases/arbitratorcases'));
      request.headers.addAll(headers);


      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        print('Response Body: $responseBody');


        Map<String, dynamic> jsonResponse;
        try {
          jsonResponse = json.decode(responseBody);
          print('Parsed Response: $jsonResponse');
        } catch (e) {
          throw Exception('Failed to decode JSON: $e');
        }


        if (jsonResponse.containsKey('caseData') &&
            jsonResponse['caseData'] != null) {
          List<dynamic> casesData = jsonResponse['caseData'];


          if (casesData is List) {
            List<Case> cases = casesData.map((caseData) =>
                Case.fromJson(caseData)).toList();
            return cases;
          } else {
            print('caseData is not a list');
            return [];
          }
        } else {
          print('No caseData key found in the response or data is null');
          return [];
        }
      } else {
        print('Failed to load cases: ${response.statusCode} ${response
            .reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('Exception: $e');
      return [];
    }
  }

  int convertToDateNow(String isoTimestamp) {
    final date = DateTime.parse(isoTimestamp); // Ensure this is a valid ISO string
    return date.millisecondsSinceEpoch;
  }

  void showCaseDetail(BuildContext context, Case caseDetail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Case Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Case ID: ${caseDetail.caseId}'),
                Text('Client Name: ${caseDetail.clientName}'),
                Text('Client Email: ${caseDetail.clientEmail}'),
                Text('Client Address: ${caseDetail.clientAddress}'),
                Text('Client Mobile: ${caseDetail.clientMobile}'),
                Text('Respondent Name: ${caseDetail.respondentName}'),
                Text('Respondent Address: ${caseDetail.respondentAddress}'),
                Text('Respondent Email: ${caseDetail.respondentEmail}'),
                Text('Respondent Mobile: ${caseDetail.respondentMobile}'),
                Text('Amount: ${caseDetail.amount}'),
                // Add more fields as necessary
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arbitrator Cases'),
      ),
      body: FutureBuilder<List<Case>>(
        future: futureCases,
        builder: (context, snapshot) {
          // Show loading indicator while waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle errors if any
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Handle case when no data is found
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cases found.'));
          }

          List<Case> cases = snapshot.data!;
          return ListView.builder(
            itemCount: cases.length,
            itemBuilder: (context, index) {
              var caseData = cases[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(caseData.clientName),
                  subtitle: Row(
                    children: [
                      // Handle cases where meeting is not completed
                      if (!caseData.isMeetCompleted)
                        _buildMeetingActions(caseData),

                      // Handle cases where meeting is completed but award is not
                      if (caseData.isMeetCompleted && !caseData.isAwardCompleted)
                        IconButton(
                          icon: Icon(FontAwesomeIcons.award, color: Colors.green),
                          onPressed: () => generateAwardFunc(caseData.caseId),
                        ),

                      // Handle cases where award is completed and available for download
                      if (caseData.isAwardCompleted)
                        GestureDetector(
                          onTap: () => handleDownloadAward(caseData.awards[0]),
                          child: Row(
                            children: [
                              Icon(Icons.cloud_download, color: Colors.green),
                              Text(
                                'Awards',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => showCaseDetail(context, caseData),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

// Method to handle actions based on meetings for a case
  Widget _buildMeetingActions(Case caseData) {
    if (caseData.meetings.isEmpty) {
      return IconButton(
        icon: Icon(Icons.videocam, color: Colors.green),
        onPressed: () {
          if (!caseData.isClickedForMultiple) {
            handleMeetingModal(caseData.caseId);
          }
        },
      );
    } else {
       if  (convertToDateNow(caseData.meetings.last.end.toString()) > DateTime.now().millisecondsSinceEpoch) {
        return Row(
          children: [
            IconButton(
              icon: Icon(FontAwesomeIcons.playCircle, color: Colors.green),
              onPressed: () => handleMeeting(caseData.meetings.last),
            ),
            IconButton(
              icon: Icon(Icons.done, color: Colors.green),
              onPressed: () => handleAllMeetingCompleted(caseData.caseId),
            ),
          ],
        );
      } else {
        return Row(
          children: [
            IconButton(
              icon: Icon(Icons.videocam, color: Colors.green),
              onPressed: () {
                if (!caseData.isClickedForMultiple) {
                  handleMeetingModal(caseData.caseId);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.assignment, color: Colors.green),
              onPressed: () => generateOrderSheet(caseData.caseId),
            ),
            IconButton(
              icon: Icon(Icons.done, color: Colors.green),
              onPressed: () => handleAllMeetingCompleted(caseData.caseId),
            ),
          ],
        );
      }
    }
  }


  void handleMeetingModal(String id) {
    // Your logic for handling the meeting modal
  }

  void handleMeeting(Meeting meeting) {
    // Your logic for handling the meeting
  }

  void handleAllMeetingCompleted(String id) {
    // Your logic for marking all meetings as completed
  }

  void generateOrderSheet(String id) {
    // Your logic for generating the order sheet
  }

  void generateAwardFunc(String id) {
    // Your logic for generating the award
  }

  void handleDownloadAward(Award award) {
    // Your logic for downloading the award
  }
}
  void showCaseDetail(BuildContext context, Case caseDetail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Case Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Case ID: ${caseDetail.caseId}'),
                Text('Client Name: ${caseDetail.clientName}'),
                // Other fields...
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

