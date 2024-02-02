import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smarthealth/screen/patients.dart';

import '../home_screen/hospital_dashboard_page.dart';
import 'country.dart';
import 'dr_list.dart';
import 'my.dart';

class HelpDeskPage extends StatelessWidget {
  Future<List<HelpDeskInfo>> fetchHelpDeskInfo() async {
    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/emergency/customerHelpList'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body);
      List<HelpDeskInfo> helpDeskList =
      data.map((item) => HelpDeskInfo.fromJson(item)).toList();
      return helpDeskList;
    } else {
      throw Exception('Failed to fetch Help Desk data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Desk'),
        // backgroundColor: Colors.grey,
      ),
      body: FutureBuilder<List<HelpDeskInfo>>(
        future: fetchHelpDeskInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available.'));
          } else {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  HelpDeskInfo helpDesk = snapshot.data![index];
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildIconTextRow(
                              Icons.phone,
                              'Contact Number: ${helpDesk.contactNumber}'),
                          _buildIconTextRow(
                              Icons.message,
                              'WhatsApp Number: ${helpDesk.whatsappNumber}'),
                          _buildIconTextRow(Icons.email, ': ${helpDesk.email}'),
                          _buildIconTextRow(
                              Icons.access_time,
                              'Open Calling Time: ${helpDesk.openCallingTime}'),
                          _buildIconTextRow(
                              Icons.access_time,
                              'End Calling Time: ${helpDesk.endCallingTime}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
      backgroundColor: Colors.blue.shade50,
      // Add the bottomNavigationBar here
      bottomNavigationBar: _buildBottomBox(context),
    );
  }

  Widget _buildIconTextRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 8.0),
          Text(text),
        ],
      ),
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
class HelpDeskInfo {
  final String id;
  final String contactNumber;
  final String whatsappNumber;
  final String email;
  final String openCallingTime;
  final String endCallingTime;
  final bool status;
  final bool isDeleted;
  final String createdAt;

  HelpDeskInfo({
    required this.id,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.email,
    required this.openCallingTime,
    required this.endCallingTime,
    required this.status,
    required this.isDeleted,
    required this.createdAt,
  });

  factory HelpDeskInfo.fromJson(Map<String, dynamic> json) {
    return HelpDeskInfo(
      id: json['_id'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      whatsappNumber: json['whatsapp_number'] ?? '',
      email: json['email'] ?? '',
      openCallingTime: json['open_calling_time'] ?? '',
      endCallingTime: json['end_calling_time'] ?? '',
      status: json['status'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}
