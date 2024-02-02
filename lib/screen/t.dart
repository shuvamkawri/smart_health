import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/view.dart';
import '../home_screen/hospital_dashboard_page.dart';
import 'd.dart';

class TdoctorPage extends StatefulWidget {
  final String? selectedTreatmentId; // Add a parameter to accept the selected treatment ID

  TdoctorPage({this.selectedTreatmentId, required String treatmentId});

  @override
  _TdoctorPageState createState() => _TdoctorPageState();
}


class _TdoctorPageState extends State<TdoctorPage> {
  List<dynamic> doctorList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? hospitalId = await getHospitalIdFromSharedPreferences();
    String? categoryId = widget.selectedTreatmentId ??
        prefs.getString('selected_treatment_id');

    if (hospitalId == null || categoryId == null) {
      // Handle the case where either hospitalId or categoryId is null.
      // You may want to show an error message or take appropriate action.
      return;
    }

    final requestPayload = {
      "hospital_id": hospitalId,
      "category_id": categoryId,
    };

    print('Request Payload: $requestPayload');

    final response = await http.post(
      Uri.parse(
          'https://metacare.co.in:3002/api/hospital/hospitalCategoryDoctorList'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestPayload),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      final result = data['results']['result'];

      setState(() {
        doctorList = result;
      });

      if (result.isEmpty) {
        // Show a dialog when no doctors are found
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("No Doctors Found"),
              content: Text("There are no doctors available at the moment."),
              actions: <Widget>[
                TextButton(
                  child: Text("OK"),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? storedHospitalId = prefs.getString('hospital_id');
                    // Navigate to the 'ViewPage' with the hospitalId (provide a default value if it's null)
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewPage(hospitalId: storedHospitalId ?? ''),
                      ),
                    );
                  },
                )



              ],
            );
          },
        );
      }
    }
  }


  Future<String?> getHospitalIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hospitalId = prefs.getString('hospital_id'); // Retrieve as string
    print('Retrieved Hospital ID from SharedPreferences: $hospitalId');
    return hospitalId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors'),
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
      backgroundColor: Colors.blue.shade50,
      body: ListView.builder(
        itemCount: doctorList.length,
        itemBuilder: (context, index) {
          final doctor = doctorList[index];
          final imageUrl = 'https://metacare.co.in:3002${doctor['image']}';

          return GestureDetector(
            onTap: () async {
              final doctorTID = doctor['_id'];

              // Store the doctor TID in shared preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('doctorTID', doctorTID);

              print('Doctor TID: $doctorTID');

              // Retrieve the stored doctor TID
              final storedDoctorTID = prefs.getString('doctorTID');
              print('Stored Doctor TID: $storedDoctorTID');

              // Navigating to DPage when tapping the card.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DPage(),
                ),
              );
            },

            child: Card(
              // Use a Card widget to display each doctor's information.
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(imageUrl),
                ),
                title: Text(doctor['name']),
                // You can add more fields as needed
              ),
            ),
          );
        },
      ),
    );
  }
}