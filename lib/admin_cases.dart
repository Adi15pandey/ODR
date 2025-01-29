import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/Addcaseviafile.dart';
import 'package:odr_sandhee/Filedetailupload.dart';
import 'package:odr_sandhee/GlobalServiceurl.dart';

class AdminCases extends StatefulWidget {
  const AdminCases({Key? key}) : super(key: key);

  @override
  State<AdminCases> createState() => _AdminCasesState();
}

class _AdminCasesState extends State<AdminCases> {
  List<dynamic> cases = [];
  int currentPage = 1;
  int limit = 5;
  bool isLoading = true;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    fetchCases(currentPage, limit);
  }

  Future<void> fetchCases(int page, int limit) async {
    final String apiUrl =
        '${GlobalService.baseUrl}/api/cases/all-cases?page=$page&limit=$limit';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          cases.addAll(data['cases']);
          isLoading = false;
          isLastPage = currentPage >= data['totalPages'];
        });
      } else {
        throw Exception('Failed to load cases');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching cases: $error');
    }
  }

  Future<void> assignArbitrator({
    required String caseId, // caseId is displayed on the UI
    required String arbitratorName,
    required String arbitratorId,
    required String arbitratorEmail,
  }) async {
    final String apiUrl = '${GlobalService.baseUrl}/api/arbitratorappointandnotifyall';
    final headers = {'Content-Type': 'application/json'};

    try {
      // Create the request as per your example
      var request = http.Request('POST', Uri.parse(apiUrl));
      request.body = json.encode({
        "id": caseId, // Sending caseId in the request
        "arbitratorName": arbitratorName,
        "arbitratorId": arbitratorId,
        "arbitratorEmail": arbitratorEmail,
      });
      request.headers.addAll(headers);
      print(request.body);

      // Send the request
      http.StreamedResponse response = await request.send();

      // Check the response status
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);

        // Handling the response message
        if (responseData['message'] ==
            'Arbitrator Appointed and Notification sent successfully') {
          setState(() {
            cases = cases.map((caseItem) {
              // Compare with _id from the response
              if (caseItem['id'] == responseData['updatedCases']['_id']) {
                caseItem['arbitratorName'] =
                responseData['updatedCases']['arbitratorName'];
                caseItem['arbitratorId'] =
                responseData['updatedCases']['arbitratorId'];
                caseItem['arbitratorEmail'] =
                responseData['updatedCases']['arbitratorEmail'];
                caseItem['isArbitratorAssigned'] =
                responseData['updatedCases']['isArbitratorAssigned'];
              }
              return caseItem;
            }).toList();
          });

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arbitrator assigned successfully!')),
          );
        } else {
          // If the response message is unexpected
          throw Exception(
              'Unexpected API response: ${responseData['message']}');
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Error response status: ${response.statusCode}');
        print('Error response body: $responseBody');
        throw Exception(
            'Failed to assign arbitrator. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }


  Future<void> showAssignArbitratorDialog(BuildContext context,
      String caseId) async {
    // Function to fetch arbitrators from the API
    Future<List<Map<String, dynamic>>> fetchArbitrators() async {
       String apiUrl = '${GlobalService.baseUrl}/api/arbitrator/all';
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debug: Print each arbitrator's ID
        (data['user'] as List).forEach((arbitrator) {
          print("Arbitrator ID: ${arbitrator['_id']}");
        });

        return (data['user'] as List)
            .map((arbitrator) =>
        {
          "id": arbitrator['_id'],
          "name": arbitrator['name'],
          "email": arbitrator['emailId'],
          "contact": arbitrator['contactNo'],
          "expertise": arbitrator['areaOfExperties'],
        })
            .toList();
      } else {
        print('Failed to fetch arbitrators: ${response.statusCode} - ${response
            .body}');
        throw Exception('Failed to fetch arbitrators');
      }
    }

    List<Map<String, dynamic>> arbitrators = [];
    List<Map<String, dynamic>> filteredArbitrators = [];
    Map<String, String>? selectedArbitrator;

    try {
      arbitrators = await fetchArbitrators(); // Fetch arbitrators from the API
      filteredArbitrators = List.from(arbitrators); // Initialize filtered list
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching arbitrators: $error')),
      );
      return;
    }

    // Create a stateful widget for the dialog
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              title: Row(
                children: [
                  const Icon(Icons.person, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  const Text(
                    'Arbitrator Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'All Arbitrators',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search arbitrators...',
                        prefixIcon: const Icon(Icons.search, color: Colors
                            .blueAccent),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Colors.blueAccent),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          // Filter arbitrators based on the search query
                          filteredArbitrators = arbitrators
                              .where((arbitrator) =>
                          arbitrator['name']
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                              arbitrator['email']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              arbitrator['contact']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              arbitrator['expertise']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        // Enable horizontal scrolling
                        child: DataTable(
                          columnSpacing: 20,
                          headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          dataTextStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          columns: const [
                            DataColumn(label: Text('Select')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Contact No.')),
                            DataColumn(label: Text('Expertise')),
                          ],
                          rows: filteredArbitrators.map((arbitrator) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Radio<String>(
                                    value: arbitrator['id'],
                                    groupValue: selectedArbitrator?['id'],
                                    onChanged: (String? value) {
                                      setState(() {
                                        selectedArbitrator = {
                                          "id": arbitrator['id'],
                                          "name": arbitrator['name'],
                                          "email": arbitrator['email'],
                                        };
                                      });
                                    },
                                  ),
                                ),
                                DataCell(Text(arbitrator['name'])),
                                DataCell(Text(arbitrator['email'])),
                                DataCell(Text(arbitrator['contact'])),
                                DataCell(Text(arbitrator['expertise'])),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedArbitrator != null) {
                      assignArbitrator(
                        caseId: caseId,
                        arbitratorName: selectedArbitrator!['name']!,
                        arbitratorId: selectedArbitrator!['id']!,
                        arbitratorEmail: selectedArbitrator!['email']!,
                      );
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please select an arbitrator!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Appoint'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> loadMore() async {
    if (!isLoading && !isLastPage) {
      setState(() {
        isLoading = true;
        currentPage++;
      });
      await fetchCases(currentPage, limit);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Row(
          children: [
            Image.asset(
              'assets/Images/Group.png',
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Admin Cases',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Padding around the entire body
        child: Column(
          children: [
            // Horizontal buttons section
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              // Added space below buttons
              child: Row(
                children: [
                  // Add Case via File button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> AddCaseForm()));
                        // Action for Add Case via File button
                      },
                      child: Text('Add Case via File'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        // primary: Colors.blueAccent,
                        // onPrimary: Colors.white,
                        backgroundColor: Colors.blue[500],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16), // Space between buttons
                  // File Upload button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>FileDetailsDialog()));
                        // Action for File Upload button
                      },
                      child: Text('File Upload'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue[500],
                        // primary: Colors.blueAccent,
                        // onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Checking if data is empty or loading
            if (cases.isEmpty && isLoading)
              const Center(child: CircularProgressIndicator())
            else
            // ListView displaying the cases
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent && !isLoading) {
                      loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: cases.length + (isLastPage ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index == cases.length) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final caseItem = cases[index];
                      return Card(
                        margin: const EdgeInsets.all(12.0),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue[50], // Light blue background
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Client Name: ${caseItem['clientName']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Client Mobile: ${caseItem['clientMobile']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Respondent Name: ${caseItem['respondentName']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Dispute Type: ${caseItem['disputeType']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'File Attachment: ${caseItem['fileName'] ??
                                    'No attachment'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Arbitrator: ${caseItem['arbitratorName'] ??
                                          'Not assigned'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (caseItem['isArbitratorAssigned'] == false)
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        showAssignArbitratorDialog(
                                            context, caseItem['_id']);
                                      },
                                      icon: const Icon(
                                          Icons.person_add, size: 18),
                                      label: const Text(
                                        'Assign',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              8.0),
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
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
