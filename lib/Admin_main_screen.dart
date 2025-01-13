import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/Admin_client.dart';
import 'package:odr_sandhee/LogoutScreen.dart';
import 'package:odr_sandhee/admin_cases.dart';
import 'package:odr_sandhee/admin_documents.dart';
import 'package:odr_sandhee/arbitrator_admin.dart';
import 'package:odr_sandhee/arbitratorclient.dart';
import 'package:odr_sandhee/meeting_admin.dart';
import 'package:odr_sandhee/tickets.dart';
import 'dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  Widget _currentScreen = DashboardScreen();
  String? token;


  int arbitrations = 0;
  int uniqueClients = 0;
  int totalCases = 0;
  int awards = 0;
  List<dynamic> caseData = [];
  List<dynamic> meetingData = [];
  List<dynamic> recentMeetingData = [];
  bool isLoading = true;

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
      _fetchCounts();
      _fetchCaseCompletedData();
      _fetchMeetingData();
      _fetchRecentMeetingData();
    } else {
      print('Token not found');
      _showErrorDialog('Token not found');
    }
  }

  Future<void> _fetchCounts() async {
    final url = 'http://192.168.1.22:4001/api/global/counts';

    final headers = {
      'token': '$token', // Ensure $token contains the actual token value
    };

    try {
      // Making the GET request
      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      // Sending the request
      http.StreamedResponse response = await request.send();

      // Handling the response
      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        print('Counts API Response: $data');

        // Update the state with fetched data
        setState(() {
          arbitrations = data['arbitrators'] ?? 0; // Updated key to match 'arbitrators'
          uniqueClients = data['clients'] ?? 0;    // Updated key to match 'clients'
          totalCases = data['cases'] ?? 0;         // Updated key to match 'cases'
        });
      } else {
        // Handle non-successful response
        print('Failed to fetch data. Status code: ${response.statusCode}');
        _showErrorDialog(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Error fetching counts: $e');
      _showErrorDialog('An error occurred: $e');
    }
  }


  Future<void> _fetchCaseCompletedData() async {
    final url = 'http://192.168.1.22:4001/api/cases/chartdata/client';

    final headers = {
      'token': '$token',
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Case Completed API Response000000000000: $data');

        setState(() {
          caseData = data;
          isLoading = false;
        });
      } else {
        _showErrorDialog(
            'Failed to fetch case data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching case data: $e');
      _showErrorDialog('An error occurred: $e');
    }
  }

  Future<void> _fetchMeetingData() async {
    final url = 'http://192.168.1.22:4001/api/webex/recent-meetings';
    final headers = {
      'token': '$token',
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Upcoming Meeting API Response: $data'); // Print the fetched data

        setState(() {
          meetingData = data['data']; // Access the 'data' field in the response
          isLoading = false;
        });
      } else {
        _showErrorDialog('Failed to fetch meeting data. Status code: ${response
            .statusCode}');
      }
    } catch (e) {
      print('Error fetching meeting data: $e');
      _showErrorDialog('An error occurred: $e');
    }
  }

  Future<void> _fetchRecentMeetingData() async {
    final url = 'http://192.168.1.22:4001/api/webex/recent-fullMeetingDataWithCaseDetails'; // Your API endpoint for recent meetings
    final headers = {
      'token': '$token',
    };

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Recent Meeting API Response: $data');

        setState(() {
          recentMeetingData =
          data['data'];
        });
      } else {
        _showErrorDialog(
            'Failed to fetch recent meeting data. Status code: ${response
                .statusCode}');
      }
    } catch (e) {
      print('Error fetching recent meeting data: $e');
      _showErrorDialog('An error occurred: $e');
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
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
              'Dashboard',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blue[50],
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Images/Group.png',
                      height: 70,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(
                icon: Icons.dashboard,
                text: 'Dashboard',
                onTap: () {
                  setState(() {
                    _currentScreen = AdminMainScreen();
                  });
                  Navigator.pop(context);
                },
              ),
              ExpansionTile(
                leading: Icon(Icons.people_rounded, color: Colors.blue[800]),
                title: Text(
                  'User',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                children: [
                  _buildDrawerItem(
                    icon: Icons.person,
                    text: 'Arbitrator',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ArbitratorAdmin()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline,
                    text: 'Client',
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => AdminClient()));
                    },
                  ),
                ],
              ),
              _buildDrawerItem(
                icon: Icons.folder_open,
                text: 'Cases',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminCases()));

                },
              ),
              _buildDrawerItem(
                icon: Icons.meeting_room_sharp,
                text: 'Meetings',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MeetingAdmin()));

                  // Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.file_copy_sharp,
                text: 'Documents',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDocuments()));

                  // Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.width_normal,
                text: 'Tickets',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TicketsScreen()));
                },
              ),
              SizedBox(height: 160),
              _buildDrawerItem(
                icon: Icons.logout,
                text: 'Logout',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LogoutScreen()));
                },
              ),
            ],
          ),
        ),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to a page for Arbitrations
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArbitratorAdmin()), // Replace with your actual page
                      );
                    },
                    child: _buildCountCard('Arbitrations', arbitrations),
                  ),

                  GestureDetector(
                    onTap: () {
                      // Navigate to a page for Unique Clients
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminClient()), // Replace with your actual page
                      );
                    },
                    child: _buildCountCard('Unique Clients', uniqueClients),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      // Navigate to the Total Cases screen when the title is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminCases()),
                      );
                    },
                    child: _buildCountCard('Total Cases', totalCases),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to the Awards screen when the title is tapped
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => AwardsScreen()),
                      // );
                    },
                    child: _buildCountCard('Awards', awards),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildChart(),
              const SizedBox(height: 20),
              _buildMeetingList(),
              const SizedBox(height: 20),
              _buildRecentMeetingList(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCountCard(String title, int count) {
    return Card(
      color: Colors.blue[100],
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$count',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.add,
                  color: Colors.blue[900],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (caseData.isEmpty) {
      return Center(
        child: Text('No data available'),
      );
    }

    List<BarChartGroupData> barGroups = [];
    List<Color> barColors = [Colors.blue, Colors.red, Colors.green, Colors.orange];

    for (var i = 0; i < caseData.length; i++) {
      var weekData = caseData[i];
      List<BarChartRodData> barRods = [];
      int colorIndex = 0;

      weekData.forEach((key, value) {
        if (key != 'week') {
          barRods.add(BarChartRodData(
            toY: value.toDouble(),
            color: barColors[colorIndex % barColors.length],
            width: 15,
          ));
          colorIndex++;
        }
      });

      barGroups.add(BarChartGroupData(
        x: i,
        barRods: barRods,
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: Text(
              'Case Completed',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(caseData[value.toInt()]['week']);
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipMargin: 8, // Distance from the tooltip to the bar
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      var personName = caseData[groupIndex].keys.firstWhere((key) => key != 'week');
                      return BarTooltipItem(
                        '${caseData[groupIndex]['week']} - $personName: ${rod.toY}',
                        TextStyle(color: Colors.white),
                      );
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingList() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (meetingData.isEmpty) {
      return Center(
        child: Text('No upcoming meetings'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Upcoming Meetings',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            // To use inside a Column
            physics: NeverScrollableScrollPhysics(),
            // Disable scroll inside ListView
            itemCount: meetingData.length,
            itemBuilder: (context, index) {
              var meeting = meetingData[index];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 5.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meeting['title'] ?? 'No Title',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        meeting['time'] ?? 'No Time',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          // Handle link tap, e.g., open in browser
                          launch(meeting['link']);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              'Join Meeting',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMeetingList() {
    if (recentMeetingData.isEmpty) {
      return Center(
        child: Text(
          'No recent meetings available',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Recent Meetings',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blue[800],
              ),
            ),
          ),
          SizedBox(height: 10),

          // Horizontal Scrollable List
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var meeting in recentMeetingData)
                  _buildMeetingCard(meeting),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(var meeting) {
    String meetingDate = meeting['startTime'] != null
        ? DateTime.parse(meeting['startTime']).toLocal().toString().split(' ')[0]
        : 'No Date';
    String meetingTime = meeting['startTime'] != null
        ? DateTime.parse(meeting['startTime']).toLocal().toString().split(' ')[1]
        : 'No Time';

    String respondentName = meeting['respondentName'] ?? 'No Respondent';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: Colors.blue[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Case ID Title
              Text(
                'Case ID: ${meeting['caseId']}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 8),

              // Client Name
              Text(
                'Client: ${meeting['clientName']}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blue[600],
                ),
              ),
              SizedBox(height: 8),

              // Arbitrator Name
              Text(
                'Arbitrator: ${meeting['arbitratorName']}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blue[600],
                ),
              ),
              SizedBox(height: 8),

              // Respondent Name
              Text(
                'Respondent: $respondentName',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.blue[600],
                ),
              ),
              SizedBox(height: 8),

              // Date and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Date: $meetingDate',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Time: $meetingTime',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),


              InkWell(
                onTap: () {
                  launch(meeting['webLink']);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[700]!, Colors.blue[500]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Join Meeting',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),  // Smaller radius for more subtle rounding
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),  // Softer shadow for a lighter feel
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.blue[800], // Icon color
            size: 24,  // Slightly smaller icon size
          ),
          title: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 14,  // Adjusted font size for better balance
              fontWeight: FontWeight.w500,
              color: Colors.blue[800], // Text color
            ),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Reduced padding
          tileColor: Colors.transparent, // Transparent background
        ),
      ),
    );
  }
}