import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smarthealth/screen/patients.dart';
import 'dart:convert';

import '../home_screen/hospital_dashboard_page.dart';
import 'country.dart';
import 'dr_list.dart';
import 'my.dart';

class EmergencyPage extends StatefulWidget {
  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  List<Map<String, dynamic>>? data; // List to store the emergency data

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch the data when the page initializes
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/emergency/list'),
      headers: {
        'accept': '*/*',
      },
      body: '',
    );

    if (response.statusCode == 201) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        data = jsonData.cast<Map<String, dynamic>>();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Service'),
        // backgroundColor: Colors.grey,
      ),
      backgroundColor: Colors.blue.shade100,
      // Set the background color of the body to blue
      body: data == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: data!.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              onTap: () => showPhoneNumber(data![index]['phon_number']),
              title: Text(data![index]['service_type']),
            ),
          );
        },
      ),
      // Add the bottomNavigationBar here
      bottomNavigationBar: _buildBottomBox(context),
    );
  }


  void showPhoneNumber(String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Contact Number'),
          content: Text(phoneNumber),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
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