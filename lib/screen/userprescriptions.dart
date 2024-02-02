import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/prescriptiondoctor.dart';

import '../home_screen/hospital_dashboard_page.dart';

class PrescriptionListPage extends StatefulWidget {
  final String doctorId; // Add this field

  PrescriptionListPage({required this.doctorId}); // Update the constructor

  @override
  _PrescriptionListPageState createState() => _PrescriptionListPageState();
}

class _PrescriptionListPageState extends State<PrescriptionListPage> {
  List<Map<String, dynamic>> prescriptions = [];
  String selectedDoctorId = ''; // Initialize it with an empty string

  @override
  void initState() {
    super.initState();
    fetchPrescriptions();
  }

  Future<void> fetchPrescriptions() async {
    print("Fetching prescriptions...");
    final prefs = await SharedPreferences.getInstance();
    final user_id = prefs.getString('user_id') ?? "";

    // Print the values of user_id and widget.doctorId
    print("user_id: $user_id");
    print("doctor_id: ${widget.doctorId}");

    final requestBody = {
      "user_id": user_id,
      "doctor_id": widget.doctorId,
    };

    print("Request Body: $requestBody");

    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/prescription/list'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("Response status code: ${response.statusCode}");

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      print("Prescriptions data: $data");
      setState(() {
        prescriptions = List<Map<String, dynamic>>.from(data['details']);
      });

      if (prescriptions.isEmpty) {
        // Show a pop-up dialog if no prescriptions are found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No Prescriptions Found'),
              content: Text('There are no prescriptions for this doctor.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    // Navigate to the PrescriptionDoctorPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrescriptionDoctorPage(),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      // Handle errors here
      print('Failed to fetch prescriptions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Prescription'),
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
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: prescriptions.length,
        itemBuilder: (context, index) {
          final prescription = prescriptions[index];
          final imageUrl = 'https://metacare.co.in:3002/${prescription['image']}';

          return InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return PrescriptionImagePage(imageUrl: imageUrl);
                },
              ));
            },
            child: Hero(
              tag: imageUrl, // Unique tag for each hero
              child: Card(
                child: Stack(
                  children: <Widget>[
                    // Add an Align widget to center the image
                    Align(
                      alignment: Alignment.center,
                      child: Image.network(
                          imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                    ),
                    // Add an Align widget to position the delete icon
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 34, // Specify the desired width
                          height: 34, // Specify the desired height
                          child: IconButton(
                            icon: Image.asset('assets/trash.png'),
                            onPressed: () {
                              deletePrescription(imageUrl);
                              // Handle delete action here
                            },
                          ),
                        ),
                      ),

                    ),
                    // Add any other prescription details you want to display
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Future<void> deletePrescription(String imageUrl) async {
    // Show a confirmation dialog
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this prescription?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled the deletion
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed the deletion
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Extract the relative path from the imageUrl
        final relativePath = Uri.parse(imageUrl).path;

        // Define the URL and request body
        final deleteUrl = Uri.parse('https://metacare.co.in:3002/api/prescription/delete');
        final requestBody = {"image_url":  relativePath.substring(1)};

        print('Deleting prescription with image URL: $imageUrl'); // Print the image URL

        final response = await http.delete(
          deleteUrl,
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        print('Request URL: ${deleteUrl.toString()}'); // Print the request URL
        print('Request Body: ${jsonEncode(requestBody)}'); // Print the request body
        print('Response status code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          // The prescription was successfully deleted
          print('Prescription deleted successfully');

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Prescription deleted successfully.'),
          ));

          // You can now update the UI to reflect the deletion
          setState(() {
            prescriptions.removeWhere((prescription) =>
            'https://metacare.co.in:3002/${prescription['image']}' == imageUrl);
          });
        } else {
          // Handle errors here
          print('Failed to delete prescription');
        }
      } catch (e) {
        // Handle network or other exceptions here
        print('Exception occurred: $e');
      }
    }
  }


}
class PrescriptionImagePage extends StatelessWidget {
  final String imageUrl;

  PrescriptionImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Image'),
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          backgroundDecoration: BoxDecoration(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
