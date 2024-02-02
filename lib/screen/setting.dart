import 'package:flutter/material.dart';
import 'package:smarthealth/screen/patients.dart';

import '../home_screen/hospital_dashboard_page.dart';
import 'country.dart';
import 'dr_list.dart';
import 'my.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkModeEnabled = false;
  bool arePushNotificationsEnabled = false;
  bool areEmailNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigate to HospitalDashboardPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HospitalDashboardPage(
                        loggedInEmail: '',
                        cityName: '',
                      ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('General Settings'),
              onTap: () {
                // Navigate to the general settings section
                Navigator.pop(context); // Close the drawer
                _navigateToGeneralSettings();
              },
            ),
            ListTile(
              title: Text('Notification Settings'),
              onTap: () {
                // Navigate to the notification settings section
                Navigator.pop(context); // Close the drawer
                _navigateToNotificationSettings();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Center-align the text
            ),

            SizedBox(height: 10), // Add some spacing
            // Text(
            //   'This is where you can configure your app settings.',
            //   style: TextStyle(
            //     fontSize: 16,
            //   ),
            // ),
          ],
        ),
      ),
      // Add the bottomNavigationBar here
      bottomNavigationBar: _buildBottomBox(context),
    );
  }

  void _navigateToGeneralSettings() {
    // Implement navigation to the general settings section
  }

  void _navigateToNotificationSettings() {
    // Implement navigation to the notification settings section
  }

  Widget _buildBottomBox(BuildContext context) {
    return SizedBox(
      height: 60, // Set the desired height here
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                // Navigate to the HospitalDashboardPage when the home button is clicked
                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                    HospitalDashboardPage(
                      loggedInEmail: '', cityName: '',)));
              },
              child: Image.asset('assets/homee.png', width: 34, height: 44),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the DrListPage when the doctor icon is clicked
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DrListPage()));
              },
              child: Image.asset('assets/doctor.png', width: 34, height: 44),
            ),

            GestureDetector(
              onTap: () {
                // Navigate to the HospitalPage when the hospital icon is clicked
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HospitalPage()));
              },
              child: Image.asset('assets/hospital-bed.png', width: 40, height: 48),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the MyAppointmentsPage when the time icon is clicked
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CountryListPage()));
              },
              child: Image.asset('assets/google-maps.png', width: 34, height: 44),
            ),
          ],
        ),
      ),
    );
  }
}