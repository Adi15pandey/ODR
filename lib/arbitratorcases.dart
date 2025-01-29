import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:odr_sandhee/Arbitratormodels.dart';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/GlobalServiceurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';



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
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _fetchToken();
      if (token != null && token!.isNotEmpty) {
        setState(() {
          futureCases = fetchCasesWithToken();
        });
      }
    } catch (e) {
      print('Error during initialization: $e');
    }
  }

  Future<void> _fetchToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // Ensure the latest data is fetched

      String? savedToken = prefs.getString('auth_token');

      if (savedToken != null && savedToken.isNotEmpty) {
        setState(() {
          token = savedToken;
        });
        print('Token fetched: $token');
      } else {
        print('Token not found');
      }
    } catch (e) {
      print('Error fetching token: $e');
    }
  }

  Future<List<Case>> fetchCasesWithToken() async {
    try {
      if (token == null || token!.isEmpty) {
        throw Exception('Token is null or empty');
      }

      final headers = {'token': token!};
      var request = http.Request(
        'GET',
        Uri.parse('${GlobalService.baseUrl}/api/cases/arbitratorcases'),
      );
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

        if (jsonResponse.containsKey('caseData') && jsonResponse['caseData'] != null) {
          List<dynamic> casesData = jsonResponse['caseData'];

          if (casesData is List) {
            print('Cases parsed successfully.');
            return casesData.map((caseData) => Case.fromJson(caseData)).toList();
          } else {
            print('caseData is not a list');
            return [];
          }
        } else {
          print('No caseData key found or it is null');
          return [];
        }
      } else {
        print('Failed to load cases: ${response.statusCode} ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('Exception in fetchCasesWithToken: $e');
      return [];
    }
  }


  int convertToDateNow(String isoTimestamp) {
    final date = DateTime.parse(isoTimestamp);
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
                backgroundColor: Colors.teal,
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
                    fontWeight: FontWeight.w600,
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
            handleMeetingModal(context,caseData.id);
          }
        },
      );
    } else {
       if  (convertToDateNow(caseData.meetings.last.end.toString()) > DateTime.now().millisecondsSinceEpoch) {
        return Row(
          children: [
            InkWell(
              onTap: () {
                final String urlString = caseData.meetings.last.webLink;

                if (urlString.isEmpty) {
                  print('Invalid URL: $urlString');
                  return;
                }

                launch(urlString).then((bool success) {
                  if (!success) {
                    print('Could not launch $urlString');
                  }
                }).catchError((e) {
                  print('Error launching URL: $e');
                });
              },
              child: Icon(
                FontAwesomeIcons.playCircle,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 15),
            InkWell(
              onTap: () => handleAllMeetingCompleted(context, caseData.id),
              child: Icon(
                Icons.done,
                color: Colors.green,
              ),
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
                  handleMeetingModal(context,caseData.id);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.assignment, color: Colors.green),
              onPressed: () => generateOrderSheet(caseData.id),
            ),
            IconButton(
              icon: Icon(Icons.done, color: Colors.green),
              onPressed: () => handleAllMeetingCompleted(context,caseData.id),
            ),
          ],
        );
      }
    }
  }

  Future<void> handleMeetingModal(BuildContext context, String id) async {
    TextEditingController _titleController = TextEditingController();
    DateTime _startDateTime = DateTime.now();
    Duration _duration = Duration(hours: 1);

    await showDialog(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), // Rounded corners for dialog
              ),
              title: Text(
                'Schedule Meeting',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Title Input
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Meeting Title',
                          labelStyle: TextStyle(color: Colors.blueAccent),
                          hintText: 'Enter a meaningful title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Start Date and Time Picker
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, color: Colors.blueAccent),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: _startDateTime,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                );
                                if (pickedDate != null) {
                                  final TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.fromDateTime(_startDateTime),
                                  );
                                  if (pickedTime != null) {
                                    setState(() {
                                      _startDateTime = DateTime(
                                        pickedDate.year,
                                        pickedDate.month,
                                        pickedDate.day,
                                        pickedTime.hour,
                                        pickedTime.minute,
                                      );
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                DateFormat('yyyy-MM-dd HH:mm').format(_startDateTime),
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Duration Dropdown
                      DropdownButtonFormField<Duration>(
                        value: _duration,
                        decoration: InputDecoration(
                          labelText: 'Meeting Duration',
                          labelStyle: TextStyle(color: Colors.blueAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            child: Text('30 minutes'),
                            value: Duration(minutes: 30),
                          ),
                          DropdownMenuItem(
                            child: Text('45 minutes'),
                            value: Duration(minutes: 45),
                          ),
                          DropdownMenuItem(
                            child: Text('50 minutes'),
                            value: Duration(minutes: 50),
                          ),
                          DropdownMenuItem(
                            child: Text('60 minutes'),
                            value: Duration(minutes: 60),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _duration = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                // Cancel Button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                // Schedule Button
                ElevatedButton(
                  onPressed: () async {
                    String trimmedTitle = _titleController.text.trim();

                    if (trimmedTitle.isEmpty) {
                      _showMessageDialog(context, 'Error', 'Please enter a title');
                      return;
                    }

                    Navigator.of(context).pop();
                    _showLoadingDialog(context);
                    await _scheduleMeeting(
                      context,
                      id,
                      trimmedTitle,
                      _startDateTime,
                      _duration,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Schedule',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );

          },
        );
      },
    );
  }
  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-ddTHH:mm:ss').format(dateTime);
  }
  Future<void> _scheduleMeeting(BuildContext context, String id, String title, DateTime startDateTime, Duration duration) async {
    String formattedStartTime = formatDateTime(startDateTime);
    String formattedEndTime = formatDateTime(startDateTime.add(duration));
    print('Scheduling meeting...');
    print('Case ID: $id');
    print('Title: $title');
    print('Start Time: $formattedStartTime');
    print('End Time: $formattedEndTime');

    try {
      // API Headers
      var headers = {
        'Content-Type': 'application/json'
      };
      var request = http.Request('POST', Uri.parse('${GlobalService.baseUrl}/api/webex/create-meeting'));
      request.body = json.encode({
        "caseId": id.toString(),
        "startTime": formattedStartTime,
        "endTime": formattedEndTime,
        "title": title
      });
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201) {
        print(await response.stream.bytesToString());
        print("sheduled Meeting");
      }
      else {
        print("8444444444444");
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error: $e');




    }
  }
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Scheduling..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMessageDialog(BuildContext context, String title, String message) {

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void handleMeeting(Meeting meeting) async {
    final Uri meetingUrl = Uri.parse(meeting.webLink);

    if (!meetingUrl.hasScheme || !meetingUrl.isAbsolute) {
      print('Invalid URL: ${meeting.webLink}');
      return;
    }

    if (await canLaunchUrl(meetingUrl)) {
      await launchUrl(
        meetingUrl,
        mode: LaunchMode.externalApplication,
      );
    } else {
      print('Could not launch ${meeting.webLink}');
    }
  }

  Future<void> handleAllMeetingCompleted(BuildContext context, String caseId) async {
    var url = Uri.parse('${GlobalService.baseUrl}/api/cases/uploadordersheet');


    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      print("No token found. Please login again.");
      return;
    }
    if (!isValidObjectId(caseId)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid caseId format')));
      return;
    }


    bool? result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('Do you want to end the meeting forever?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      try {
        var headers = {

          'token': '$token',
          'Content-Type': 'application/json',
        };

        var request = http.Request('PUT', Uri.parse('http://192.168.0.109:4001/api/cases/updatemeetstatus'));

        // Send the valid caseId to the API
        request.body = json.encode({
          "id": caseId,
        });
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          // Correctly handle the response body
          String responseBody = await response.stream.bytesToString();
          print(responseBody);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Meeting ended successfully')));
        } else {
          // Handle failure
          print('Error Response: ${response.statusCode} ${await response.stream.bytesToString()}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update meet status')));
        }
      } catch (e) {
        // Handle any errors
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

// Helper function to validate MongoDB ObjectId
  bool isValidObjectId(String id) {
    final objectIdRegExp = RegExp(r'^[0-9a-fA-F]{24}$');
    return objectIdRegExp.hasMatch(id);
  }





  void generateOrderSheet(String id)  {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Generate Ordersheet.",
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

  Future<void> uploadAwardFile(File file, String id) async {

    var url = Uri.parse('http://192.168.0.109:4001/api/cases/uploadawards');


    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      print("No token found. Please login again.");
      return;
    }

    var headers = {
      'token': '$token',
    };

    if (!file.path.endsWith('.pdf')) {
      print("Invalid file type. Only PDF files are allowed.");
      return;
    }
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

  var url = Uri.parse('http://192.168.0.109:4001/api/cases/uploadordersheet');


  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('auth_token');

  if (token == null) {
    print("No token found. Please login again.");
    return;
  }

  var headers = {
    'token': '$token',
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

