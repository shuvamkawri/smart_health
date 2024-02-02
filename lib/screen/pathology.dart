import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smarthealth/screen/patients.dart';
import 'dart:convert';

import 'package:smarthealth/screen/test.dart';

import '../home_screen/hospital_dashboard_page.dart';
import 'city.dart';
import 'country.dart';
import 'dr_list.dart';
import 'my.dart';

class PathologyPage extends StatefulWidget {
  @override
  _PathologyPageState createState() => _PathologyPageState();
}

class _PathologyPageState extends State<PathologyPage> {
  List<dynamic> pathologyList = [];

  @override
  void initState() {
    super.initState();
    fetchPathologyList();
  }

  Future<void> fetchPathologyList() async {
    try {
      print('Fetching selected city...');
      final String selectedCity = await getSelectedCity(); // Get the city from SharedPreferences
      print('Selected City: $selectedCity');

      final Map<String, String> requestBody = {
        "city": selectedCity, // Use the selected city
      };
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/pathology/list'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody['errorCode'] == 0) {
          List<dynamic> details = responseBody['details'];

          setState(() {
            pathologyList = details;
          });
        } else {
          throw Exception('Error: ${responseBody['errorCode']}');
        }
      } else {
        throw Exception('Failed to load pathology list');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('Pathology '),
            //  backgroundColor: Colors.grey,
            floating: false,
            pinned: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search Labs',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onChanged: (String query) {
                  // Handle search query changes here
                },
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                final pathology = pathologyList[index];
                final imagePath = 'https://metacare.co.in:3002${pathology['image']}'; // Path to the image

                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    leading: Image.network(
                      imagePath, // Load the image from the URL
                      width: 48,
                      height: 48,
                      fit: BoxFit
                          .cover, // Ensure the image covers the available space
                    ),
                    title: Text(
                      pathology['pathology_name'],
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(pathology['address']),
                    trailing: Text('Rating: ${pathology['rating']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                            TestPage(pathology['_id'])),
                      );
                    },
                  ),
                );
              },
              childCount: pathologyList.length,
            ),
          ),
        ],
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