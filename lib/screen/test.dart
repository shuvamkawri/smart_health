import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/test_report_upload.dart';
import 'package:smarthealth/screen/testlist.dart';

import '../home_screen/hospital_dashboard_page.dart';

class TestPage extends StatelessWidget {
  final String pathologyId;

  TestPage(this.pathologyId);

  Future<Map<String, dynamic>> _fetchPathologyDetails() async {
    print('Pathology ID: $pathologyId'); // Print the pathologyId

    // Check if pathologyId is null and handle it gracefully
    if (pathologyId == null) {
      throw Exception('Pathology ID is null');
    }

    // Store the pathologyId in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pathologyId', pathologyId);

    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/pathology/View'),
      headers: <String, String>{
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        "_id": pathologyId,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final id = responseData['details']['_id'];
      print('Pathology ID from response: $id'); // Print the _id

      // You can also retrieve the stored pathologyId from shared preferences
      String storedPathologyId = prefs.getString('pathologyId') ?? 'N/A';
      print('Stored Pathology ID: $storedPathologyId');

      return responseData;
    } else {
      throw Exception('Failed to load pathology details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Pathology'),
        //backgroundColor: Colors.grey,
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPathologyDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No data available'),
            );
          } else {
            final pathologyData = snapshot.data!;

            return SingleChildScrollView( // Wrap the Card with SingleChildScrollView
              child: Card(
                elevation: 4,
                margin: EdgeInsets.all(16),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   'Pathology Name:',
                      //   style: TextStyle(
                      //     color: Colors.greenAccent,
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 18,
                      //   ),
                      // ),
                      Text(
                        pathologyData['details']['pathology_name'],
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildInfoRow(Icons.location_on, "Address",
                          pathologyData['details']['address'], Colors.red),
                      _buildInfoRow(Icons.phone, "Contact",
                          pathologyData['details']['contact_number'],
                          Colors.orange),
                      _buildInfoRow(Icons.email, "Email",
                          pathologyData['details']['email'], Colors.purple),
                      _buildInfoRow(Icons.access_time, "Opening Time",
                          pathologyData['details']['opening_time'],
                          Colors.blue),
                      _buildInfoRow(Icons.access_time, "Closing Time",
                          pathologyData['details']['closing_time'],
                          Colors.blue),
                      _buildInfoRow(Icons.star, "Rating",
                          pathologyData['details']['rating'], Colors.yellow),
                      _buildInfoRow(Icons.calendar_today, "Working Days",
                          pathologyData['details']['working_days'],
                          Colors.cyan),
                      _buildInfoRow(Icons.person, "Doctor Name",
                          pathologyData['details']['doctor_name'], Colors.blue),
                      _buildInfoRow(Icons.people, "Total Employees",
                          pathologyData['details']['total_employee'],
                          Colors.green),
                      // Add more fields as needed
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TestList(),
                            ),
                          );
                        },
                        child: Text(
                          'Individual Test',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TestReportUploadPage(),
              ),
            );
          },
          icon: Icon(
            Icons.cloud_upload,
            color: Colors.blueGrey,
          ),
          label: Text(
            'Upload Prescription',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
          ),
        ),
      ),
    );
  }
}
// Function to build an info row with an icon
Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor, // Customize the icon color
        ),
        SizedBox(width: 8), // Add spacing between icon and text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: double.infinity, // Expand the text to the available width
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16, // Customize the font size
                  ),
                  overflow: TextOverflow.ellipsis, // Handle text overflow with ellipsis
                  maxLines: 2, // Set the maximum number of lines to 2
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
