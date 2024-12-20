import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:odr_sandhee/LogoutScreen.dart';
import 'package:odr_sandhee/arbitrator.dart';
import 'package:odr_sandhee/tickets.dart';

import 'dashboard_screen.dart'; // Import the DashboardScreen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Widget _currentScreen = DashboardScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Text(
          '',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
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
                    _currentScreen = DashboardScreen();
                  });
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.people_rounded,
                text: 'All Arbitrator',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ArbitratorScreen()));
                  // Update with the corresponding screen

                },
              ),
              _buildDrawerItem(
                icon: Icons.folder_open,
                text: 'Cases',
                onTap: () {
                  // Update with the corresponding screen
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.meeting_room_sharp,
                text: 'Meetings',
                onTap: () {
                  // Update with the corresponding screen
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.file_copy_sharp,
                text: 'Documents',
                onTap: () {
                  // Update with the corresponding screen
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                icon: Icons.width_normal,
                text: 'Tickets',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> TicketsScreen()));


                  // Navigator.pop(context);
                },
              ),
              SizedBox(height: 160),
              _buildDrawerItem(
                icon: Icons.logout,
                text: 'Logout',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LogoutScreen()));
                  
                  // Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: _currentScreen,
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue[800],
      ),
      title: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.blue[900],
        ),
      ),
      onTap: onTap,
    );
  }
}
