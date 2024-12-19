import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class ArbitratorScreen extends StatefulWidget {
  @override
  _ArbitratorScreenState createState() => _ArbitratorScreenState();
}

class _ArbitratorScreenState extends State<ArbitratorScreen> {
  late Future<List<dynamic>> arbitrators;

  @override
  void initState() {
    super.initState();
    arbitrators = fetchArbitrators();
  }

  Future<List<dynamic>> fetchArbitrators() async {
    final response = await http.get(Uri.parse('https://odr.sandhee.com/api/arbitrator/all'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List.from(data['user']);
    } else {
      throw Exception('Failed to load arbitrators');
    }
  }

  void _showDetails(BuildContext context, dynamic arbitrator) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Arbitrator Details',
                      style: GoogleFonts.lora(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildDetailRow('Name:', arbitrator['name']),
                _buildDetailRow('Email:', arbitrator['emailId']),
                _buildDetailRow('Contact No:', arbitrator['contactNo']),
                _buildDetailRow('Arbitrator Number:', arbitrator['uid']),
                _buildDetailRow('Address:', arbitrator['address']),
                _buildDetailRow('Assigned Cases:', arbitrator['noOfAssignCase'].toString()),
                _buildDetailRow('Expertise:', arbitrator['areaOfExperties']),
                _buildDetailRow('About:', arbitrator['about']),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arbitrators', style: GoogleFonts.poppins()),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: arbitrators,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No arbitrators found'));
          } else {
            final arbitratorsData = snapshot.data!;
            return ListView.builder(
              itemCount: arbitratorsData.length,
              itemBuilder: (context, index) {
                final arbitrator = arbitratorsData[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 12,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade300, Colors.purple.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Arbitrator: ${arbitrator['name'] ?? 'No name'}',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.work, size: 22, color: Colors.white70),
                            SizedBox(width: 8),
                            Text(
                              'Experience: ${arbitrator['experienceInYears']} years',
                              style: GoogleFonts.lato(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.account_circle, size: 22, color: Colors.white70),
                            SizedBox(width: 8),
                            TextButton(
                              onPressed: () {
                                _showDetails(context, arbitrator);
                              },
                              child: Text(
                                'Details',
                                style: GoogleFonts.lato(
                                  color: Colors.orangeAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
