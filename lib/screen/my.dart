import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/patients.dart';

import '../home_screen/hospital_dashboard_page.dart';
import 'country.dart';
import 'dr_list.dart';

class MyAppointmentsPage extends StatefulWidget {
  @override
  _MyAppointmentsPageState createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? '';

      // Print the user ID for debugging purposes
      print('User ID: $userId');

      final Map<String, dynamic> requestBody = {
        "user_id": userId,
      };

      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/doctor-apointment/list'),
        headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody), // Encode the request body as JSON
      );

      // Print the response status code
      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // Print the received data
        print('Received data: $data');

        if (data != null && data['result'] is List) {
          setState(() {
            appointments = List<Map<String, dynamic>>.from(data['result']);
          });

          // Print a success message
          print('Appointments fetched successfully.');

          // Store appointment IDs in SharedPreferences
          List<String> appointmentIds = [];
          for (var appointment in appointments) {
            appointmentIds.add(appointment['_id']);
            // Store appointment_id separately in SharedPreferences
            prefs.setString('appointment_id', appointment['_id']);
          }
          // Print the stored appointment IDs
          print('Stored Appointment IDs: $appointmentIds');
        } else {
          print('Failed to fetch appointments: Incorrect data format');
        }
      } else {
        print('Failed to fetch appointments: ${response.statusCode}');
      }
    } catch (error) {
      // Print the error message
      print('Error fetching appointments: $error');
    }
  }

  Widget _buildAppointmentCard(Map<String, dynamic>? appointment) {
    if (appointment == null) {
      return Container(); // or any other suitable widget
    }

    final appointmentId = appointment['_id']; // Get the appointment ID
    final isCanceled = appointment['cancel'] ??
        false; // Check if the appointment is canceled

    final patientName = appointment['patient_name'] ?? '';
    final rawDate = appointment['schedule']['week_days'] ?? '';
    String formattedDate = '';
    try {
      final dateTime = DateTime.parse(rawDate);
      formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      formattedDate = 'Invalid Date';
    }

    final hospitalMap = appointment['schedule']['hospital'] as Map<
        String,
        dynamic>? ?? {};
    final hospitalName = hospitalMap['hospital_name'] ?? '';

    final doctorMap = appointment['schedule']['doctor'] as Map<String,
        dynamic>? ?? {};
    final doctorName = doctorMap['name'] ?? '';
    final doctorImage = doctorMap['image'] ?? '';

    final specialistCategory = appointment['schedule']['specialist']['category'] ??
        '';

    final startTime = appointment['schedule']['start_time'] ?? '';
    final endTime = appointment['schedule']['end_time'] ?? '';
    final timeRange = '$startTime - $endTime';
    String? selectedAppointmentId;

    return Card(
      elevation: 5.0,
      color: isCanceled ? Colors.brown.shade200 : Colors.white,
      // Set the card color based on the 'cancel' field
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Booked For $patientName',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCanceled ? Colors.black.withOpacity(0.5) : Colors
                          .black,
                      decoration: isCanceled
                          ? TextDecoration.combine([
                        TextDecoration.lineThrough,
                      ])
                          : TextDecoration.none,
                      decorationColor: isCanceled ? Colors.black : null,
                      // Set the line-through color
                      decorationThickness: isCanceled
                          ? 2.0
                          : null, // Increase the line thickness as desired
                    ),
                  ),
                ),


                SizedBox(height: 4.0),
                Text(
                  '$doctorName',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '$specialistCategory',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  '$hospitalName',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  'Date: $formattedDate',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  'Time: $timeRange',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 120,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: isCanceled ? Colors.grey : Colors.cyan.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                onPressed: () async {
                  // Display a confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Confirm Appointment Cancellation"),
                        content: Text("Do you want to cancel this appointment?"),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            child: Text("Confirm"),
                            onPressed: () async {
                              // Store the appointment ID in shared preferences
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              if (appointmentId != null && appointmentId.isNotEmpty) {
                                await prefs.setString('selected_appointment_id', appointmentId);

                                // Now, retrieve the selected appointment ID from shared preferences
                                String? selectedAppointmentId = await prefs.getString('selected_appointment_id');

                                if (selectedAppointmentId != null) {
                                  // Define the API endpoint
                                  final apiUrl = 'https://metacare.co.in:3002/api/doctor-apointment/doctorApartmentCancel';

                                  // Prepare the request payload
                                  final requestPayload = {
                                    "apartment_id": selectedAppointmentId,
                                  };

                                  // Make the HTTP POST request
                                  final response = await http.post(
                                    Uri.parse(apiUrl),
                                    headers: {
                                      'accept': '*/*',
                                      'Content-Type': 'application/json',
                                    },
                                    body: json.encode(requestPayload),
                                  );

                                  // Handle the response
                                  if (response.statusCode == 201) {
                                    final Map<String, dynamic> data = json.decode(response.body);
                                    final String message = data['message'];
                                    print('Cancellation response body: ${response.body}');
                                    print('Cancellation response: $message');

                                    // Show the "Appointment Cancelled" pop-up
                                    Navigator.of(context).pop(); // Close the confirmation dialog

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Appointment Cancelled"),
                                          content: Text("Your appointment has been cancelled."),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text("OK"),
                                              onPressed: () {
                                                // Close the "Appointment Cancelled" pop-up
                                                Navigator.of(context).pop();

                                                // Navigate to the "hospitaldashboared" page
                                                Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) => HospitalDashboardPage(loggedInEmail: '', cityName: '',), // Replace with your actual page name
                                                  ),
                                                );
                                              },
                                            ),

                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    // Handle errors or other status codes as needed
                                    print('Error: ${response.statusCode}');
                                  }
                                } else {
                                  print('Selected Appointment ID not found in shared preferences.');
                                }
                              } else {
                                print('Invalid Appointment ID. It cannot be null or empty.');
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.black),
                ),
                child: Text(
                  isCanceled ? "Cancelled" : "Cancel",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Add the doctor's image
          if (doctorImage != null)
            Positioned(
              top: 0, // Adjust this value as needed to position the image
              right: 0, // Adjust this value as needed to position the image
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                child: Image.network(
                  'https://metacare.co.in:3002$doctorImage',
                  // Use the full image URL
                  width: 90, // Set the desired width for the image
                  height: 110, // Set the desired height for the image
                  fit: BoxFit.cover, // Adjust the fit as needed
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HospitalDashboardPage(loggedInEmail: '', cityName: ''),
          ),
        );
        return false; // Do not pop the current page
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Appointments'),
          automaticallyImplyLeading: false, // Remove the back button
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: refreshPage,
            ),
          ],
        ),
        body: Container(
          color: Colors.lightBlue.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                // child: IconButton(
                //   icon: Icon(
                //     Icons.keyboard_arrow_left,
                //     size: 30,
                //     color: Colors.blue,
                //   ),
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                // ),
              ),
              appointments.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                child: ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    return _buildAppointmentCard(appointments[index]);
                  },
                ),
              ),
            ],
          ),
        ),
        // Add the bottomNavigationBar here
        bottomNavigationBar: _buildBottomBox(context),
      ),
    );
  }

  void refreshPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MyAppointmentsPage(),
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
