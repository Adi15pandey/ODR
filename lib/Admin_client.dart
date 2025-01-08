import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/add_client.dart';

class AdminClient extends StatefulWidget {
  const AdminClient({super.key});

  @override
  State<AdminClient> createState() => _AdminClientState();
}

class _AdminClientState extends State<AdminClient> {
  List<dynamic> clients = [];
  List<dynamic> filteredClients = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchClients();
    searchController.addListener(_filterClients);
  }

  String clientUid = '';

  Future<void> fetchClientUid() async {
    final response = await http.get(
        Uri.parse('http://192.168.1.22:4001/api//autouid/client'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        clientUid = data['uid'];
      });
      print('Client UID: $clientUid');
    } else {
      // If the server returns an error
      print('Failed to load client UID');
    }
  }


  Future<void> fetchClients() async {
    const String url = "http://192.168.1.22:4001/api/client/all";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          clients = data['user'] ?? [];
          filteredClients = clients;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load clients');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  void _filterClients() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredClients = clients.where((client) {
        return client['name'].toLowerCase().contains(query) ||
            client['contactNo'].toLowerCase().contains(query) ||
            client['emailId'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_filterClients);
    searchController.dispose();
    super.dispose();
  }

  Future<void> updateClient(String id, String name, String contactNo,
      String email, bool status) async {
    final String url = "http://192.168.1.22:4001/api/client/update/$id";
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": name,
          "contactNo": contactNo,
          "emailId": email,
          "status": status,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client updated successfully')),
        );
        fetchClients(); // Refresh the list
      } else {
        throw Exception('Failed to update client');
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update client')),
      );
    }
  }

  void showEditDialog(Map<String, dynamic> client) {
    final TextEditingController nameController = TextEditingController(
        text: client['name']);
    final TextEditingController contactController = TextEditingController(
        text: client['contactNo']);
    final TextEditingController emailController = TextEditingController(
        text: client['emailId']);
    bool status = client['status'];

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
              onPressed: () {
                updateClient(
                  client['_id'],
                  nameController.text,
                  contactController.text,
                  emailController.text,
                  status,
                );
                Navigator.pop(context);
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
              'Admin Client',
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


      body: Column(
        children: [
          // Search Bar Below the AppBar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'Search Clients',
                      labelStyle: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.blue,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey[400]!,
                            width: 1),
                      ),
                      hintText: 'Search by name or email...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () async {
                    await fetchClientUid(); // Fetch client UID when button is clicked
                    if (clientUid.isNotEmpty) {
                      // Proceed to navigate to AddClient screen only if UID is fetched
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddClient()),
                      );
                    } else {
                      // Handle the case when UID is not available
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to fetch client UID')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredClients.isEmpty
              ? const Center(child: Text('No clients found'))
              : Expanded(
            child: ListView.builder(
              itemCount: filteredClients.length,
              itemBuilder: (context, index) {
                final client = filteredClients[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  color: Colors.blue[50],
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      client['name'] ?? 'Unknown Name',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact: ${client['contactNo'] ?? 'N/A'}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text(
                                'Email: ',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black54),
                              ),
                              Expanded(
                                child: Text(
                                  client['emailId'] ?? 'N/A',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cases Assigned: ${client['noOfAssignCase'] ?? 0}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Status: ${client['status'] == true
                                ? 'Active'
                                : 'Inactive'}',
                            style: TextStyle(
                              color: client['status'] == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: TextButton(
                      onPressed: () => showEditDialog(client),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
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
                );
              },
            ),
          ),
        ],
      ),

    );
  }

  void filterByStatus(String status) {
    List<dynamic> filteredList;

    if (status == 'All') {
      filteredList = clients; // Show all arbitrators
    } else if (status == 'Active') {
      filteredList =
          clients.where((arbitrator) => arbitrator['status'] == true).toList();
    } else if (status == 'Inactive') {
      filteredList =
          clients.where((arbitrator) => arbitrator['status'] == false).toList();
    } else {
      filteredList = clients; // Default to all if unknown status
    }

    setState(() {
      filteredClients = filteredList;
    });
  }
}


