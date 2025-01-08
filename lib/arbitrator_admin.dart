import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/add_arbitrator.dart';

class ArbitratorAdmin extends StatefulWidget {
  const ArbitratorAdmin({super.key});

  @override
  State<ArbitratorAdmin> createState() => _ArbitratorAdminState();
}

class _ArbitratorAdminState extends State<ArbitratorAdmin> {
  List<dynamic> arbitrators = []; // To hold the list of arbitrators
  bool isLoading = true; // To show a loader during data fetch
  String? errorMessage; // Original list of arbitrators
  List<dynamic> filteredArbitrators = []; // List for filtered arbitrators
  // To display error messages
  TextEditingController searchController = TextEditingController(); // To display error messages

  @override
  void initState() {
    super.initState();
    fetchArbitrators();
  }

  Future<void> fetchArbitrators() async {
    final url = 'http://192.168.1.22:4001/api/arbitrator/all';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          arbitrators = data['user'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
          'Failed to fetch data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  void filterArbitrators(String query) {
    final filteredList = arbitrators.where((arbitrator) {
      // Check if the name or email contains the search query (case insensitive)
      return arbitrator['name']!.toLowerCase().contains(query.toLowerCase()) ||
          arbitrator['emailId']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredArbitrators = filteredList;

    });
  }


  void showEditDialog(BuildContext context, Map<String, dynamic> arbitrator) {
    final nameController = TextEditingController(text: arbitrator['name']);
    final emailController = TextEditingController(text: arbitrator['emailId']);
    final contactController = TextEditingController(
        text: arbitrator['contactNo']);
    final addressController = TextEditingController(
        text: arbitrator['address']);
    bool status = arbitrator['status'] ?? false;
    final arbitratorId = arbitrator['_id']; // Store the arbitrator's ID

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: const [
              Icon(Icons.edit, color: Colors.blue, size: 28),
              SizedBox(width: 8),
              Text(
                'Edit Client',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update the client details below and click "Save Changes" to confirm.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(color: Colors.black87),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    labelStyle: const TextStyle(color: Colors.black87),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.phone, color: Colors.green),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(color: Colors.black87),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.red),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<bool>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: const TextStyle(color: Colors.black87),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      status ? Icons.toggle_on : Icons.toggle_off,
                      color: status ? Colors.purple : Colors.grey,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: true, child: Text('Active')),
                    DropdownMenuItem(value: false, child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedArbitrator = {
                  'name': nameController.text,
                  'emailId': emailController.text,
                  'contactNo': contactController.text,
                  'address': addressController.text,
                  'status': status,
                };

                // Make PUT request to update the arbitrator
                await updateArbitrator(arbitratorId, updatedArbitrator);

                Navigator.pop(context); // Close dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  // Function to make the PUT request to update the arbitrator
  Future<void> updateArbitrator(String arbitratorId,
      Map<String, dynamic> updatedArbitrator) async {
    final url = 'http://192.168.1.22:4001/api/arbitrator/update/$arbitratorId'; // URL with dynamic ID

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedArbitrator),
      );

      if (response.statusCode == 200) {
        print('Arbitrator updated successfully');
        // Optionally, you can refresh the list of arbitrators after the update
        fetchArbitrators();
      } else {
        print(
            'Failed to update arbitrator. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating arbitrator: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Row(
          children: [
            Image.asset(
              'assets/Images/Group.png',
              height: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Arbitrator ',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Spacer(),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.filter_list,
                size: 20,
                color: Colors.white,
              ),
              onSelected: (String value) {
                filterByStatus(value);
                print('Selected filter: $value');
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'All',
                    child: Text('All'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Active',
                    child: Text('Active'),
                  ),
                  PopupMenuItem<String>(
                    value: 'Inactive',
                    child: Text('Inactive'),
                  ),
                ];
              },
            ),

          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ) // Show error message
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Arbitrators',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      filterArbitrators(value); // Your search filter function
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () {
                    // Navigate to the screen where you can add a new arbitrator
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (
                            context) => const AddArbitrator(), // Replace with your screen
                      ),
                    );
                  },
                ),
              ],
            ),
          ),


          const SizedBox(height: 8),

          // Add the + icon floating button
          Expanded(
            child: ListView.builder(
              itemCount: filteredArbitrators.length,
              itemBuilder: (context, index) {
                final arbitrator = filteredArbitrators[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  color: Colors.blue[50],
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          arbitrator['name'] ?? 'No Name',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                                Icons.email, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              arbitrator['emailId'] ?? 'N/A',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                                Icons.phone, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              arbitrator['contactNo'] ?? 'N/A',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Address: ${arbitrator['address'] ?? 'N/A'}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Expertise: ${arbitrator['areaOfExperties'] ??
                              'N/A'}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Experience: ${arbitrator['experienceInYears'] ??
                              'N/A'} years',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cases Assigned: ${arbitrator['noOfAssignCase'] ??
                              'N/A'}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Add Status Row
                        Row(
                          children: [
                            Icon(
                              arbitrator['status'] != null &&
                                  arbitrator['status']
                                  ? Icons.toggle_on
                                  : Icons.toggle_off,
                              size: 16,
                              color: arbitrator['status'] != null &&
                                  arbitrator['status']
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${arbitrator['status'] != null &&
                                  arbitrator['status']
                                  ? 'Active'
                                  : 'Inactive'}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              showEditDialog(context, arbitrator);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(color: Colors.white),
                            ),
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

// Floating Action Button to add a new arbitrator


    );
  }

  void filterByStatus(String status) {
    List<dynamic> filteredList;

    if (status == 'All') {
      filteredList = arbitrators; // Show all arbitrators
    } else if (status == 'Active') {
      filteredList =
          arbitrators.where((arbitrator) => arbitrator['status'] == true)
              .toList();
    } else if (status == 'Inactive') {
      filteredList =
          arbitrators.where((arbitrator) => arbitrator['status'] == false)
              .toList();
    } else {
      filteredList = arbitrators; // Default to all if unknown status
    }

    setState(() {
      filteredArbitrators = filteredList;
    });
  }

}
