import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen/hospital_dashboard_page.dart';
import 'appointment.dart';
import 'd.dart';
import 'dr_list.dart';
class HPage extends StatefulWidget {
  final String doctorName;
  final String doctorId;
  List<String> selectedScheduleIds = [];

  HPage({required this.doctorName, required this.doctorId});

  @override
  _HPageState createState() => _HPageState();

}

List<String> selectedScheduleIds = [];

class _HPageState extends State<HPage> {

  List<Map<String, dynamic>> scheduleData = [];
  DateTime selectedDate = DateTime.now(); // Store the selected date
  int selectedButtonIndex = -1; // Index of the selected button

  @override
  void initState() {
    super.initState();
    print("Doctor Name: ${widget.doctorName}");
    print("Doctor ID: ${widget.doctorId}");
    fetchData();
  }


  Future<void> fetchData() async {
    // Retrieve the user_id from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';

    if (userId.isEmpty) {
      print('User ID not found in SharedPreferences');
      return;
    }

    String? hospitalId = await getHospitalIdFromSharedPreferences();

    if (hospitalId == null) {
      print('Hospital ID not found in SharedPreferences');
      return;
    }

    final requestBody = {
      "user_id": userId, // Use the retrieved user_id
      "doctor_id": widget.doctorId,
      "hospital_id": hospitalId
    };

    print("Request Body: $requestBody");

    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/schedule/SlotData'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("Response Status Code: ${response.statusCode}");

    if (response.statusCode == 201) {
      final List<dynamic> responseData = jsonDecode(response.body);
      print("Response Data: $responseData");

      setState(() {
        scheduleData = responseData.map((data) => data as Map<String, dynamic>).toList();
      });
      print("Schedule Data: $scheduleData");

      if (scheduleData.isEmpty) {
        // If there are no schedules, display a popup message.
        showNoSlotsAvailableDialog();
      }
    } else {
      print('Failed to fetch data');
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      // Clear selected slots when changing the date
      selectedScheduleIds.clear();
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }


  // Helper function to format the date
  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('dd MMMM ').format(dateTime);
    return formattedDate;
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Doctor Schedule'),
          //backgroundColor: Colors.grey,
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
        body: Column(
          children: <Widget>[
            // Card for doctor name and hospital name
            Card(
              child: ListTile(
                title: Text(scheduleData.isNotEmpty
                    ? scheduleData[0]['doctor']['name']
                    : ''),
                subtitle: Text('Hospital: ' + (scheduleData.isNotEmpty
                    ? scheduleData[0]['hospital']['hospital_name']
                    : '')),
                leading: scheduleData.isNotEmpty
                    ? Image.network(
                  'https://metacare.co.in:3002'+ scheduleData[0]['doctor']['image'],
                  width: 50, // Adjust the width as needed
                  height: 50, // Adjust the height as needed
                  fit: BoxFit.cover, // You can choose the appropriate fit
                )
                    : Container(), // You can use an empty Container if there's no image
              ),
            ),
            // Card(
            //   child: ListTile(
            //     title: Text(scheduleData.isNotEmpty
            //         ? scheduleData[0]['doctor']['name']
            //         : ''),
            //     subtitle: Text('Hospital: ' + (scheduleData.isNotEmpty
            //         ? scheduleData[0]['hospital']['hospital_name']
            //         : '')),
            //   ),
            // ),
            Expanded(
              child: Container(
                color: Colors.blue.shade50,
                child: IntrinsicHeight(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Set the cross-axis count to 2
                      crossAxisSpacing: 2.0, // Add some horizontal spacing
                      mainAxisSpacing: 2.0, // Add some vertical spacing
                    ),
                    itemCount: scheduleData.length,
                    itemBuilder: (context, index) {
                      final scheduleItem = scheduleData[index];
                      final shouldDisplayHeader = index == 0 ||
                          scheduleItem['doctor']['name'] !=
                              scheduleData[index - 1]['doctor']['name'] ||
                          scheduleItem['hospital']['hospital_name'] !=
                              scheduleData[index -
                                  1]['hospital']['hospital_name'];

                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          // Adjust padding to make the card smaller
                          child: Center( // Center the content within the card
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ' ${_formatDate(scheduleItem['week_days'])}',
                                  style: TextStyle(
                                      fontSize: 14.0), // Reduce text size
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (scheduleItem != null && scheduleItem['book_appointment'] != null && !scheduleItem['book_appointment']) {
                                        toggleSelection(index); // Toggle the selection state.
                                        _selectTime(scheduleItem['_id']);
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                                            (states) {
                                          if (selectedButtonIndex == index) {
                                            return Colors.green; // Selected button
                                          } else if (states.contains(MaterialState.pressed)) {
                                            return Colors.blue.shade300; // Button is pressed
                                          }

                                          // If the appointment is already booked, disable the button color
                                          if (scheduleItem != null && scheduleItem['book_appointment']) {
                                            return Colors.grey;
                                          }

                                          return Colors.blue.shade300; // Default color for bookable slots
                                        },
                                      ),
                                    ),
                                    child: Text(
                                      ' ${scheduleItem['start_time']} - ${scheduleItem['end_time']}',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ),
                                )





                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: selectedButtonIndex != -1
            ? Container(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // Pass the selected schedule IDs to the AppointmentPage
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AppointmentPage(selectedScheduleIds: selectedScheduleIds),
              ));
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
            ),
            child: Text(
              'Continue',
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        )
            : null
    );
  }


  void _selectTime(String scheduleId) async {
    // Check if the selected schedule is bookable
    bool isBookable = scheduleData.firstWhere(
          (item) => item['_id'] == scheduleId,
      orElse: () => {'book_appointment': false},
    )['book_appointment'];

    if (isBookable) {
      // If the schedule is bookable, toggle its selection
      if (selectedScheduleIds.contains(scheduleId)) {
        selectedScheduleIds.remove(scheduleId);
      } else {
        selectedScheduleIds.add(scheduleId);
      }

      // Update the UI
      setState(() {});
    }
  }


  // Define a function to toggle the selection state.
  void toggleSelection(int index) {
    setState(() {
      if (selectedButtonIndex == index) {
        selectedButtonIndex =
        -1; // Deselect if the same button is pressed again.
      } else {
        selectedButtonIndex = index;
      }
    });
  }

  Future<String?> getHospitalIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('hospital_id');
  }

  void showNoSlotsAvailableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Slots Available'),
          content: Text('There are no available slots for this doctor.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                // Navigate back to "Dpage"
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DrListPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }


}