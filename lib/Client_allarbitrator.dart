import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class ClientAllarbitrator extends StatefulWidget {
  const ClientAllarbitrator({super.key});

  @override
  State<ClientAllarbitrator> createState() => _ClientAllarbitratorState();
}

class _ClientAllarbitratorState extends State<ClientAllarbitrator> {
  List<dynamic> arbitrators = [];
  List<dynamic> filteredArbitrators = [];
  int currentPage = 1;
  int totalPages = 1;
  int pageLimit = 5;
  bool isLoading = false;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchArbitrators();
  }

  Future<void> fetchArbitrators() async {
    setState(() {
      isLoading = true;
    });
    try {
      final url =
          'http://192.168.1.12:4001/api/arbitrator/all?page=$currentPage&limit=$pageLimit';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          arbitrators = data['user'];
          filteredArbitrators = arbitrators;
          totalPages = data['totalPages'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterArbitrators(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredArbitrators = arbitrators;
      } else {
        filteredArbitrators = arbitrators
            .where((arbitrator) =>
        arbitrator['name']
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()) ||
            arbitrator['contactNo']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            arbitrator['emailId']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void showDetailsDialog(Map<String, dynamic> arbitrator) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Details of ${arbitrator['name']}',
            style: GoogleFonts.poppins(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('UID', arbitrator['uid']),
                _buildDetailRow('Contact', arbitrator['contactNo']),
                _buildDetailRow('Email', arbitrator['emailId']),
                _buildDetailRow('Address', arbitrator['address']),
                _buildDetailRow('Expertise', arbitrator['areaOfExperties']),
                _buildDetailRow(
                    'Experience', '${arbitrator['experienceInYears']} years'),
                _buildDetailRow(
                    'No. of Assigned Cases', '${arbitrator['noOfAssignCase']}'),
                _buildDetailRow('Cases Added', '${arbitrator['caseAdded']}'),
                _buildDetailRow('About', arbitrator['about']),
                _buildDetailRow('Role', arbitrator['role']),
                _buildDetailRow('Status',
                    arbitrator['status'] ? "Active" : "Inactive"),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.roboto(
                fontSize: 14.0,
                color: Colors.black54,
              ),
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
            const SizedBox(width: 10),
            Text(
              'All Arbitrator',
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
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: filterArbitrators,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search arbitrators by name, contact, or email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                  ),
                ),
                filled: true,
                fillColor: Colors.blue[50],
              ),
            ),
          ),
          Expanded(
            child: filteredArbitrators.isEmpty
                ? const Center(
              child: Text(
                'No arbitrators found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: filteredArbitrators.length,
              itemBuilder: (context, index) {
                final arbitrator = filteredArbitrators[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  color: Colors.blue[50],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          arbitrator['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Contact: ${arbitrator['contactNo']}',
                          style: GoogleFonts.roboto(
                            fontSize: 14.0,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Email: ${arbitrator['emailId']}',
                          style: GoogleFonts.roboto(
                            fontSize: 14.0,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: ElevatedButton(
                            onPressed: () =>
                                showDetailsDialog(arbitrator),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8.0),
                              ),
                            ),
                            child: const Text('Details'),
                          ),
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
}

