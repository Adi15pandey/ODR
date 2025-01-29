import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/GlobalServiceurl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ArbitratorDocument extends StatefulWidget {
  const ArbitratorDocument({super.key});

  @override
  State<ArbitratorDocument> createState() => _ArbitratorDocumentState();
}

class _ArbitratorDocumentState extends State<ArbitratorDocument> {
  String? token;
  bool _isLoading = true;
  List<dynamic> _caseData = [];
  List<dynamic> _filteredCaseData = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchToken();
    _searchController.addListener(_filterDocuments); // Add listener to search input
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
      _fetchData();
    } else {
      print('Token not found');
    }
  }

  Future<void> _fetchData() async {
    final response = await http.get(
      Uri.parse('${GlobalService.baseUrl}/api/cases/arbitratorcases'),
      headers: {'token': '$token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _caseData = data['caseData'];
        _filteredCaseData = _caseData;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  // Search filter function
  void _filterDocuments() {
    String query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCaseData = _caseData.where((caseItem) {
        return caseItem['clientName'].toLowerCase().contains(query) ||
            caseItem['respondentName'].toLowerCase().contains(query) ||
            caseItem['arbitratorName'].toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
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
              'Documents',
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
                labelText: 'Search by Client, Respondent, or Arbitrator',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: _filteredCaseData.length,
              itemBuilder: (context, index) {
                final caseItem = _filteredCaseData[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.blue[50],
                  shadowColor: Colors.blue[50]!.withOpacity(0.3),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      'Client Name: ${caseItem['clientName']}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue[800],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Respondent Name: ${caseItem['respondentName']}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Arbitrator: ${caseItem['arbitratorName']}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            _showDocumentDetailsDialog(context, caseItem);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 22,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Details',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    color: Colors.red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (caseItem['attachments'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Attachments:',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...caseItem['attachments'].map<Widget>((attachment) {
                                return GestureDetector(
                                  onTap: () {
                                    final Uri uri = Uri.parse(attachment['url'] ?? '');
                                    print(uri);
                                    launchUrl(uri);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.download,
                                          color: Colors.blue,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          attachment['name'] ?? 'No name available',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            color: Colors.blue,
                                            fontSize: 14,
                                            decoration: TextDecoration.underline,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                      ],
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

  void _showDocumentDetailsDialog(BuildContext context, Map<String, dynamic> caseItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            'Document Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
              fontFamily: 'Montserrat',
            ),
          ),
          backgroundColor: Color(0xFF2C6A9B),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildDetailRow('Client Name', caseItem['clientName']),
                  _buildDetailRow('Respondent Name', caseItem['respondentName']),
                  _buildDetailRow('Arbitrator', caseItem['arbitratorName']),
                  _buildDetailRow('Case ID', caseItem['caseId'] ?? 'N/A'),
                  _buildDetailRow('Client Email', caseItem['clientEmail'] ?? 'N/A'),
                  _buildDetailRow('Arbitrator Email', caseItem['arbitratorEmail'] ?? 'N/A'),
                  _buildDetailRow('Respondent Email', caseItem['respondentEmail'] ?? 'N/A'),
                  _buildDetailRow('Claimant Number', caseItem['claimantNumber'] ?? 'N/A'),
                  _buildDetailRow('Recording', caseItem['recording'] ?? 'N/A'),
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

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black12, offset: Offset(0, 3))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
