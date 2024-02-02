import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/s.dart';
import '../home_screen/hospital_dashboard_page.dart';

class BPage extends StatefulWidget {
  @override
  _BPageState createState() => _BPageState();
}

class _BPageState extends State<BPage> {
  Map<String, dynamic> doctorDetails = {};
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
  }

  Future<void> fetchDoctorDetails() async {
    // Retrieve the doctor ID from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? doctorId = prefs.getString('doctorIId');
    print('Doctor ID from SharedPreferences: $doctorId');

    if (doctorId == null) {
      print('Doctor ID is not available in SharedPreferences.');
      // Handle the case where the doctor ID is not available in shared preferences
      return;
    }

    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/doctor/details'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "doctor_id": doctorId,
      }),
    );

    print('HTTP Request Sent');

    if (response.statusCode == 201) {
      setState(() {
        doctorDetails = json.decode(response.body)['details']['result'];
        print('Doctor Details Retrieved: $doctorDetails');
      });
    } else {
      print(
          'Failed to load doctor details. Status Code: ${response.statusCode}');
      throw Exception('Failed to load doctor details');
    }
  }
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Details'),
        // backgroundColor: Colors.grey,
        actions: [
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
      body: doctorDetails.isNotEmpty
          ? SingleChildScrollView(
        child: Card(
          elevation: 4,
          margin: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.network(
                'https://metacare.co.in:3002' + doctorDetails['image'],
                width: double.infinity,
                height: screenSize.width * 0.8,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${doctorDetails['name']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    // Specialist category
                    buildInfoRow(Icons.local_hospital, Colors.green, '${doctorDetails['specialist']['category']}'),
                    // Location
                    buildInfoRow(Icons.location_on, Colors.blue, '${doctorDetails['city']}, ${doctorDetails['state']}'),
                    // Email
                    buildInfoRow(Icons.email, Colors.blueGrey, '${doctorDetails['email_id']}'),
                    // Gender
                    buildInfoRow(Icons.person, Colors.blueAccent, 'Gender: ${doctorDetails['gender']}'),
                    // Phone
                    buildInfoRow(Icons.phone, Colors.green, '${doctorDetails['mobile_number']}'),
                    // Experience

                    buildInfoRow(Icons.app_registration_sharp, Colors.black, 'Reg:${doctorDetails['registration_number']}'),
                    //reg
                    buildInfoRow(Icons.business, Colors.lightBlueAccent, 'Experience: ${doctorDetails['experience']} years'),
                    // Education
                    buildInfoRow(Icons.school, Colors.redAccent, '${doctorDetails['education']}'),
                    // Rating
                    buildRatingRow(double.parse(doctorDetails['rating'])),
                    // Biography
                    Text(
                      'Biography: ${isExpanded ? doctorDetails['biography'].replaceAll(RegExp(r'<\/?p[^>]*>'), '') : doctorDetails['biography'].replaceAll(RegExp(r'<\/?p[^>]*>'), '').substring(0, 150)}',
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Text(
                        isExpanded ? "Show less" : "Show more",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 110, // Set the width of the button as needed
                      height: 35, // Set the height of the button as needed
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0), // Adjust the radius value as needed
                        color: Colors.blue,
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SPage(
                                doctorName: doctorDetails['name'],
                                doctorId: doctorDetails['_id'],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white, // Change the text color if needed
                            fontSize: 16, // Set the font size as needed
                            fontWeight: FontWeight.normal, // Set the font weight as needed
                          ),
                        ),
                      ),
                    )

                  ],
                ),
              ),
            ],
          ),
        ),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildInfoRow(IconData icon, Color iconColor, String text) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: iconColor,
        ),
        SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildRatingRow(double rating) {
    return Row(
      children: <Widget>[
        Icon(
          Icons.star,
          color: Colors.brown,
        ),
        SizedBox(width: 12),
        Text(
          'Rating: $rating',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Add your star rating widget here (e.g., buildRatingStars)
      ],
    );
  }
}