import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:odr_sandhee/LogoutScreen.dart';
import 'package:odr_sandhee/Respondend_cases.dart';
import 'package:odr_sandhee/Respondent_meeting.dart';
import 'package:odr_sandhee/arbitrator_Document.dart';
import 'package:odr_sandhee/arbitratorcases.dart';
import 'package:odr_sandhee/arbitratormetings.dart';
import 'package:odr_sandhee/dashboard_screen.dart';
import 'package:odr_sandhee/tickets.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
class RespondendMainScreen extends StatefulWidget {
  const RespondendMainScreen({super.key});

  @override
  State<RespondendMainScreen> createState() => _RespondendMainScreenState();
}

class _RespondendMainScreenState extends State<RespondendMainScreen> {

  Widget _currentScreen = DashboardScreen();
  String? token;

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
      _fetchCaseCompletedData();
      _fetchMeetingData();
      _fetchRecentMeetingData();
    } else {
      print('Token not found');
      _showErrorDialog('Token not found');
    }
  }

  Future<void> _fetchCaseCompletedData() async {
    final url = 'http://192.168.1.12:4001/api/cases/chartdata/respondent';

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
    final url = 'http://192.168.1.12:4001/api/webex/recent-meetings/respondent';
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
    final url = 'http://192.168.1.12:4001/api/webex/recent-fullMeetingDataWithCaseDetails/respondent'; // Your API endpoint for recent meetings
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
              'Dashboard', // Add title here
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
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
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
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
                      'Welcome Back',
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
                    _currentScreen = DashboardScreen();
                  });
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.folder_open,
                text: 'Cases',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RespondendCases()));
                  // Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.meeting_room_sharp,
                text: 'Meetings',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RespondentMeeting()));


                  // Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.file_copy_sharp,
                text: 'Documents',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ArbitratorDocument()));

                  // Navigator.pop(context);
                },
              ),
              // _buildDrawerItem(
              //   icon: Icons.width_normal,
              //   text: 'Tickets',
              //   onTap: () {
              //     Navigator.push(context,
              //         MaterialPageRoute(builder: (context) => TicketsScreen()));
              //   },
              // ),
              Spacer(),
              _buildDrawerItem(
                icon: Icons.logout,
                text: 'Logout',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LogoutScreen()));
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
