import 'package:flutter/material.dart';
import 'package:odr_sandhee/arbitrator.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> dashboardData;

  @override
  void initState() {
    super.initState();

    dashboardData = Future.delayed(
      Duration(seconds: 2),
          () => {
        'arbitratorCount': 3,
        'clientCount': 6,
        'caseCount': 34,
        'awardCount': 8,
        'recentMeetings': [
          {'clientName': 'Client A', 'arbitrator': 'Arbitrator 1', 'id': 'M001'},
          {'clientName': 'Client B', 'arbitrator': 'Arbitrator 2', 'id': 'M002'},
          {'clientName': 'Client C', 'arbitrator': 'Arbitrator 3', 'id': 'M003'},
        ],
        'upcomingMeetings': [
          {'title': 'Project Meeting', 'time': '10:00 - 11:00 AM', 'date': '2024-12-20'},
          {'title': 'Client Call', 'time': '11:00 - 12:00 PM', 'date': '2024-12-20'},
        ],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>
                                  ArbitratorScreen()));
                            },
                            child: DashboardCard(
                              title: 'Arbitrator',
                              count: data['arbitratorCount'].toString(),
                              icon: Icons.group,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              print('Clients tapped');
                            },
                            child: DashboardCard(
                              title: 'Clients',
                              count: data['clientCount'].toString(),
                              icon: Icons.class_,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              print('Cases tapped');
                            },
                            child: DashboardCard(
                              title: 'Cases',
                              count: data['caseCount'].toString(),
                              icon: Icons.folder_open,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              print('Awards tapped');
                            },
                            child: DashboardCard(
                              title: 'Awards',
                              count: data['awardCount'].toString(),
                              icon: Icons.star,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Upcoming Meetings',
                      style: TextStyle(
                        fontSize: screenWidth > 600 ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.4,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: data['upcomingMeetings'].length,
                      itemBuilder: (context, index) {
                        final meeting = data['upcomingMeetings'][index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(meeting['title']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Time: ${meeting['time']}'),
                                Text('Date: ${meeting['date']}'),
                              ],
                            ),
                            leading: Icon(Icons.calendar_today),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Recent Meetings',
                      style: TextStyle(
                        fontSize: screenWidth > 600 ? 22 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.4,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: data['recentMeetings'].length,
                      itemBuilder: (context, index) {
                        final meeting = data['recentMeetings'][index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            leading: Text(meeting['id']),
                            title: Text(meeting['clientName']),
                            subtitle: Text(meeting['arbitrator']),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;

  DashboardCard({required this.title, required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.purple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue[800],
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth > 600 ? 20 : 16,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: screenWidth > 600 ? 24 : 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
