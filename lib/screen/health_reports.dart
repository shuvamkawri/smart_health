import 'package:flutter/material.dart';
import 'package:smarthealth/screen/patients.dart';
import 'package:smarthealth/screen/test_report_upload.dart';

import '../home_screen/hospital_dashboard_page.dart';
import 'country.dart';
import 'dr_list.dart';
import 'my.dart';

class HealthReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Reports'), // Set a custom title here
        // backgroundColor: Colors.grey,
      ),
      body: Container(
        padding: EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Colors.lightBlue.shade50,
        ),
        child: ListView(
          children: [
            ReportCard(deviceName: 'All Reports'),
            ReportCard(deviceName: 'Pathological Report'),
            ReportCard(deviceName: 'Diagnosis Report '),
            ReportCard(deviceName: 'Biopsy '),
            ReportCard(deviceName: 'Colonoscopy'),
            ReportCard(deviceName: 'CT Scan '),
            ReportCard(deviceName: 'Electrocardiogram (ECG) '),
            ReportCard(deviceName: 'Electroencephalogram (EEG) '),
            ReportCard(deviceName: 'Gastroscopy'),
            ReportCard(deviceName: 'Eye tests '),
            ReportCard(deviceName: 'Hearing test '),
            ReportCard(deviceName: 'MRI scan'),
            ReportCard(deviceName: 'PET scan'),
            ReportCard(deviceName: 'Ultrasound'),
            ReportCard(deviceName: 'X-rays'),
            ReportCard(
              deviceName: 'Do you want to upload any other reports',
              isPlusIcon: true,
            ),
          ],
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


  class ReportCard extends StatelessWidget {
  final String deviceName;
  final bool isPlusIcon;

  ReportCard({required this.deviceName, this.isPlusIcon = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isPlusIcon) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TestReportUploadPage(), // Navigate to the upload page
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportPage(deviceName: deviceName),
            ),
          );
        }
      },
      child: Container(
        height: 80.0,
        child: Card(
          color: isPlusIcon ? Colors.blue : Colors.blue,
          child: Center(
            child: isPlusIcon
                ? Hero(
              tag: 'plus-icon',
              child: Image.asset(
                'assets/plus.png',
                width: 48.0,
                height: 48.0,
              ),
            )
                : Text(
              deviceName,
              style: TextStyle(
                color: Colors.white,
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
class ReportPage extends StatelessWidget {
  final String deviceName;

  ReportPage({required this.deviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(deviceName),
        // backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Text('Data for $deviceName will be displayed here.'),
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
              child: Image.asset('assets/location.png', width: 34, height: 44),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the MyAppointmentsPage when the time icon is clicked
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => MyAppointmentsPage()));
              },
              child: Image.asset('assets/time.png', width: 34, height: 44),
            ),
          ],
        ),
      ),
    );
  }
}
