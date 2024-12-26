import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:odr_sandhee/Arbitratormodels.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';



class Arbitratorcases extends StatefulWidget {
  const Arbitratorcases({super.key});

  @override
  State<Arbitratorcases> createState() => _ArbitratorcasesState();
}


class _ArbitratorcasesState extends State<Arbitratorcases> {
  String searchQuery = '';

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            'Case Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700, // Bold weight
              color: Colors.white,
              letterSpacing: 1.2,
              fontFamily: 'Montserrat', // Use a modern font family
            ),
          ),
          backgroundColor: Color(0xFF2C6A9B), // Softer blue color for the background
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildCaseInfoRow('Case ID', caseDetail.caseId),
                  _buildCaseInfoRow('Client Name', caseDetail.clientName),
                  _buildCaseInfoRow('Client Email', caseDetail.clientEmail),
                  _buildCaseInfoRow('Client Address', caseDetail.clientAddress),
                  _buildCaseInfoRow('Dispute Type', caseDetail.disputeType),
                  _buildCaseInfoRow('File Name', caseDetail.fileName),
                  _buildCaseInfoRow('Client Mobile', caseDetail.clientMobile),
                  _buildCaseInfoRow('Respondent Name', caseDetail.respondentName),
                  _buildCaseInfoRow(
                    'Meeting Status',
                    caseDetail.isMeetCompleted ? "Completed" : "Not Completed",
                    icon: Icons.check_circle,
                    iconColor: caseDetail.isMeetCompleted ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal, // Softer teal color for the button
                padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCaseInfoRow(String label, String value, {IconData? icon, Color? iconColor}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5), // Soft light background color for each row
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12, offset: Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null)
            Icon(icon, color: iconColor ?? Colors.grey, size: 24),
          SizedBox(width: icon != null ? 12 : 0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600, // Semi-bold for labels
                    color: Colors.blueAccent,
                    fontFamily: 'Roboto', // Different font for labels
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                    fontFamily: 'Roboto', // Consistent font style
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


// Helper method to create each info bar
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              value,
              style: TextStyle(color: Colors.black54),
            ),
          ],
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
            Text(
              'Arbitrator Cases',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar below the AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (query) {
                setState(() {

                  searchQuery = query;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by client name...',
                prefixIcon: Icon(Icons.search, color: Colors.blue[800]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: Colors.blue[800]!),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          // FutureBuilder to load the case data
          Expanded(
            child: FutureBuilder<List<Case>>(
              future: futureCases,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }


                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No cases found.'));
                }

                List<Case> cases = snapshot.data!;

                // Filter the cases list based on the search query
                List<Case> filteredCases = cases.where((caseData) {
                  return caseData.clientName
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredCases.length,
                  itemBuilder: (context, index) {
                    var caseData = filteredCases[index];
                    return Card(
                      color: Colors.blue[50],
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            caseData.clientName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (!caseData.isMeetCompleted)
                                  _buildMeetingActions(caseData),

                                if (caseData.isMeetCompleted && !caseData.isAwardCompleted)
                                  IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.award,
                                      color: Colors.green,
                                      size: 20.0,
                                    ),
                                    tooltip: 'Generate Award',
                                    onPressed: () => generateAwardFunc(caseData.id),
                                  ),

                                if (caseData.isAwardCompleted)
                                  GestureDetector(
                                    onTap: () {
                                      final Uri _url = Uri.parse(caseData.awards.first.title);
                                      launchUrl(_url);
                                    },
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
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.info_outline,
                              color: Colors.blueAccent,
                              size: 24.0,
                            ),
                            tooltip: 'Case Details',
                            onPressed: () => showCaseDetail(context, caseData),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }



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

  }

  void handleAllMeetingCompleted(String id) {

  }

  void generateOrderSheet(String id)  {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Upload Award PDF",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (result != null) {
                    File file = File(result.files.single.path!);
                    await uploadOrdersheet(file, id);
                    Navigator.of(context).pop(); // Close the dialog after upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("File uploaded successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // User canceled the picker
                    print("No file selected.");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("No file selected."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.attach_file),
                label: Text("Choose PDF File"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Please choose a PDF file to upload.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        );
      },
    );
  }

  void generateAwardFunc(String id ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Upload Award PDF",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (result != null) {
                    File file = File(result.files.single.path!);
                    await uploadAwardFile(file, id);
                    Navigator.of(context).pop(); // Close the dialog after upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("File uploaded successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    // User canceled the picker
                    print("No file selected.");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("No file selected."),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.attach_file),
                label: Text("Choose PDF File"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent,
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Please choose a PDF file to upload.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        );
      },
    );
  }
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
  Future<void> uploadAwardFile(File file, String id) async {

    var url = Uri.parse('https://odr.sandhee.com/api/cases/uploadawards');


    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      print("No token found. Please login again.");
      return;
    }

    var headers = {
      'bearer': '$token', // Use Bearer token for the Authorization header
    };

    if (!file.path.endsWith('.pdf')) {
      print("Invalid file type. Only PDF files are allowed.");
      return;
    }

    // 4. Create the request
    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields['caseId'] = id
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('application', 'pdf'),
      ));

    print("Request URL: $url");
    print("Headers: $headers");
    print("Fields: ${request.fields}");
    print("File Path: ${file.path}");


    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print("File uploaded successfully.");
        String responseBody = await response.stream.bytesToString();
        print(responseBody);
      } else {
        print("Failed to upload file. Status code: ${response.statusCode}");
        print(response.reasonPhrase);
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }
}
Future<void> uploadOrdersheet(File file, String id) async {

  var url = Uri.parse('https://odr.sandhee.com/api/cases/uploadordersheet');


  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  if (token == null) {
    print("No token found. Please login again.");
    return;
  }

  var headers = {
    'bearer': '$token', // Use Bearer token for the Authorization header
  };

  if (!file.path.endsWith('.pdf')) {
    print("Invalid file type. Only PDF files are allowed.");
    return;
  }

  // 4. Create the request
  var request = http.MultipartRequest('POST', url)
    ..headers.addAll(headers)
    ..fields['caseId'] = id
    ..files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType('application', 'pdf'),
    ));

  print("Request URL: $url");
  print("Headers: $headers");
  print("Fields: ${request.fields}");
  print("File Path: ${file.path}");


  try {
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print("File uploaded successfully.");
      String responseBody = await response.stream.bytesToString();
      print(responseBody);
    } else {
      print("Failed to upload file. Status code: ${response.statusCode}");
      print(response.reasonPhrase);
    }
  } catch (e) {
    print("Error occurred: $e");
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

