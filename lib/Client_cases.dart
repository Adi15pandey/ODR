import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class ClientCases extends StatefulWidget {
  const ClientCases({super.key});

  @override
  State<ClientCases> createState() => _ClientCasesState();
}

class _ClientCasesState extends State<ClientCases> {
  List<dynamic> _caseData = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = false;
  int _currentPage = 1;
  int _limit = 5;
  int _totalPages = 1;
  String? token;
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchToken();
    _scrollController.addListener(_scrollListener);

    _searchController.addListener(() {
      _filterCases();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      String? savedToken = prefs.getString('auth_token');

      if (savedToken != null && savedToken.isNotEmpty) {
        setState(() {
          token = savedToken;
        });
        fetchClientCases();
      } else {
        _showErrorDialog('Token not found. Please log in again.');
      }
    } catch (e) {
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
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final url =
        'http://192.168.1.12:4001/api/cases/clientcases?page=$_currentPage&limit=$_limit';
    final headers = {'token': '$token'};

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _caseData.addAll(data['caseData'] ?? []);
          _filteredData = List.from(_caseData);
          _totalPages = data['totalPages'] ?? 1;
          _isLoading = false;
        });
      } else {
        _showErrorDialog('Failed to load cases. Please try again later.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('An error occurred while fetching case data.');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_currentPage < _totalPages) {
        setState(() {
          _currentPage++;
        });
        fetchClientCases();
      }
    }
  }

  void _filterCases() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredData = _caseData.where((caseItem) {
        return caseItem['clientName'].toLowerCase().contains(query) ||
            caseItem['caseId'].toString().toLowerCase().contains(query);
      }).toList();
    });
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
              'Client Cases',
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Client Name or Case ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          if (_isLoading && _caseData.isEmpty) const LinearProgressIndicator(),
          Expanded(
            child: _filteredData.isEmpty && !_isLoading
                ? const Center(
              child: Text(
                'No cases available',
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              itemCount: _filteredData.length + 1,
              itemBuilder: (context, index) {
                if (index == _filteredData.length) {
                  return _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : const SizedBox.shrink();
                }

                final caseItem = _filteredData[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  elevation: 5,
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                          title: Text(meeting['title'],
                              style: GoogleFonts.poppins(fontSize: 14)),
                          subtitle: Text(
                            'Start: ${meeting['start']} - End: ${meeting['end']}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
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
}
