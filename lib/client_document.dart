import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/GlobalServiceurl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
class ClientDocument extends StatefulWidget {
  const ClientDocument({super.key});

  @override
  State<ClientDocument> createState() => _ClientDocumentState();
}

class _ClientDocumentState extends State<ClientDocument> {
  List<dynamic> _caseData = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _limit = 5;
  int _totalPages = 1;
  String? token;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchToken();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
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
        fetchClientCases(); // Call API after fetching the token
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

  Future<void> fetchClientCases() async {
    if (_isLoading) return; // Prevent multiple requests while loading
    setState(() {
      _isLoading = true;
    });

    final url =
        '${GlobalService.baseUrl}/api/cases/clientcases?page=$_currentPage&limit=$_limit';

    final headers = {
      'token': '$token',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _caseData.addAll(data['caseData'] ?? []);
          _totalPages = data['totalPages'] ?? 1;
          _isLoading = false;
        });

        print('Cases fetched successfully');
      } else {
        print('Failed to load cases: ${response.statusCode} - ${response
            .reasonPhrase}');
        _showErrorDialog('Failed to load cases. Please try again later.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching cases: $e');
      _showErrorDialog('An error occurred while fetching case data.');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // If the user has scrolled to the end of the list, load more data
      if (_currentPage < _totalPages) {
        setState(() {
          _currentPage++;
        });
        fetchClientCases();
      }
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
              'Client Document',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isLoading && _caseData.isEmpty)
            const LinearProgressIndicator(),
          Expanded(
            child: _caseData.isEmpty && !_isLoading
                ? const Center(
              child: Text(
                'No cases available',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: _caseData.length + 1, // Add 1 for the loading indicator
              itemBuilder: (context, index) {
                if (index == _caseData.length) {
                  return _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink();
                }

                final caseItem = _caseData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  elevation: 5,
                  color: Colors.blue[50],// Add a shadow for elevation
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    title: Text(
                      'Case ID: ${caseItem['caseId']}',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue[700],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Client: ${caseItem['clientName']}',
                          style: GoogleFonts.roboto(fontSize: 14),
                        ),
                        Text(
                          'Dispute Type: ${caseItem['disputeType']}',
                          style: GoogleFonts.roboto(fontSize: 14),
                        ),
                        Text(
                          'Arbitrator: ${caseItem['arbitratorName'] ?? 'Not Assigned'}',
                          style: GoogleFonts.roboto(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Show the details dialog when the "Details" button is clicked
                        _showDetailsDialog(context, caseItem);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                      ),
                      child: Text(
                        'Details',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Function to show the details in a dialog box
  void _showDetailsDialog(BuildContext context, Map<String, dynamic> caseItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Details for Case ID: ${caseItem['caseId']}',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue[700],
            ),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client Info Section
                  Text(
                    'Client Information:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Name: ${caseItem['clientName']}'),
                  Text('Email: ${caseItem['clientEmail']}'),
                  Text('Mobile: ${caseItem['clientMobile']}'),
                  Text('Address: ${caseItem['clientAddress']}'),
                  const SizedBox(height: 16),

                  // Respondent Info Section
                  Text(
                    'Respondent Information:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Name: ${caseItem['respondentName']}'),
                  Text('Email: ${caseItem['respondentEmail']}'),
                  Text('Mobile: ${caseItem['respondentMobile']}'),
                  Text('Address: ${caseItem['respondentAddress']}'),
                  const SizedBox(height: 16),

                  // Case Details Section
                  Text(
                    'Case Details:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Amount: ${caseItem['amount']}'),
                  Text('Dispute Type: ${caseItem['disputeType']}'),
                  Text('Arbitrator: ${caseItem['arbitratorName'] ?? 'Not Assigned'}'),
                  Text('Arbitrator Email: ${caseItem['arbitratorEmail'] ?? 'Not Assigned'}'),
                  const SizedBox(height: 16),
                  Text(
                    'Case Resolved: ${caseItem['isCaseResolved'] ? 'Yes' : 'No'}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: caseItem['isCaseResolved'] ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Meetings Section
                  Text(
                    'Meetings:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[700],
                    ),
                  ),
                  caseItem['meetings'].isEmpty
                      ? const Text('No Meetings')
                      : Column(
                    children: caseItem['meetings'].map<Widget>((meeting) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
                          title: Text(meeting['title'], style: GoogleFonts.poppins(fontSize: 14)),
                          subtitle: Text(
                            'Start: ${meeting['start']} - End: ${meeting['end']}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Awards Section
                  Text(
                    'Awards:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue[700],
                    ),
                  ),
                  if (caseItem['awards'] == null || caseItem['awards'].isEmpty)
                    const Text('No Awards')
                  else
                    Column(
                      children: caseItem['awards'].map<Widget>((award) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  award,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  launch(award);
                                },
                                child: const Icon(Icons.link, color: Colors.blue),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: GoogleFonts.poppins(color: Colors.blue[700]),
              ),
            ),
          ],
        );
      },
    );
  }

// Function to open the award link

}

