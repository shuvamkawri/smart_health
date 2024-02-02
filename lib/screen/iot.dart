import 'package:flutter/material.dart';
import 'package:smarthealth/screen/patients.dart';

import '../home_screen/hospital_dashboard_page.dart';
import 'airbp.dart';
import 'country.dart';
import 'dr_list.dart';
import 'my.dart';

class IotPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instruments'),
        // backgroundColor: Colors.grey,
        actions: [
          // Add an IconButton with the home icon
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigate to HospitalDashboardPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    HospitalDashboardPage(loggedInEmail: '', cityName: '',)),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.lightBlue.shade50,
            ),
            child: ListView(
              children: [
                // IoETDeviceCard(deviceName: 'Baby 02'),
                // IoETDeviceCard(deviceName: 'ECG'),
                // IoETDeviceCard(deviceName: 'Blood Sugar'),
                // IoETDeviceCard(deviceName: 'Blood pressure'),
                IoETDeviceCard(deviceName: 'AirBp'),
                // IoETDeviceCard(deviceName: 'Smart Watch'),
                // IoETDeviceCard(deviceName: 'Check Me pro'),
                // IoETDeviceCard(deviceName: 'Vcomin'),
              ],
            ),
          ),
        ),
      ),
      // Add the bottomNavigationBar here
      bottomNavigationBar: _buildBottomBox(context),
    );
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
class IoETDeviceCard extends StatelessWidget {
  final String deviceName;

  IoETDeviceCard({required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IoETDevicePage(deviceName: deviceName),
          ),
        );
      },
      child: Container(
        height: 80.0,
        child: Card(
          color: Colors.blue, // Set the background color of the card to blue
          child: Center(
            child: Text(
              deviceName,
              style: TextStyle(
                color: Colors.white, // Set the text color to white for better contrast
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class IoETDevicePage extends StatefulWidget {
  final String deviceName;

  IoETDevicePage({required this.deviceName});

  @override
  _IoETDevicePageState createState() => _IoETDevicePageState();
}

class _IoETDevicePageState extends State<IoETDevicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName),
       // backgroundColor: Colors.grey,
        actions: [
          // Add an IconButton with the home icon
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigate to HospitalDashboardPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HospitalDashboardPage(loggedInEmail: '', cityName: '',)),
              );
            },
          ),
        ],
      ),
      body: MyHomePage(), // Replace this with your existing code or integrate the Bluetooth functionality here
    );
  }
}

