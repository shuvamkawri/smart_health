import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../home_screen/hospital_dashboard_page.dart';
import 'chat.dart';
import 'city.dart';
import 'd.dart';

class TreatPage extends StatefulWidget {

  @override
  _TreatPageState createState() => _TreatPageState();
}
class _TreatPageState extends State<TreatPage> {
  Map<String, dynamic>? _hospitalDetails;
  List<dynamic> doctorList = [];

  @override
  void initState() {
    super.initState();
    _fetchHospitalDetails();
  }

  Future<void> _fetchHospitalDetails() async {
    try {
      final selectedCity = await getSelectedCity(); // Get the selected city from SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String hospitalId = prefs.getString('hospitall_id') ?? ""; // Retrieve the hospitalId from SharedPreferences

      print('Starting the API request...');
      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/hospital/view'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "hospital_id": hospitalId, // Use the retrieved hospitalId
          "city": selectedCity,
        }),
      );

      // Log the request body
      print(
        'Request Body: ${jsonEncode({"hospital_id": hospitalId, "city": selectedCity,})}',
      );

      if (response.statusCode == 201) {
        print('API request was successful, processing the response...');

        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result']['details'] != null) {
          print('API response is valid, updating state...');

          setState(() {
            _hospitalDetails = data['result']['details'];
          });

          // Log the response body
          print('Response Body: ${jsonEncode(data)}');

          // Call the fetchData function to fetch the list of doctors
          fetchData();
        } else {
          print('Error: Invalid API response');
        }
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String hospitalId = prefs.getString('hospitall_id') ?? "";
    String? categoryId = prefs.getString('selectedCategoryID');

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
      Uri.parse('https://metacare.co.in:3002/api/hospital/hospitalCategoryDoctorList'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Treatment Specialist'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HospitalDashboardPage(loggedInEmail: '', cityName: ''),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            _hospitalDetails != null
                ? HospitalDetailsCard(_hospitalDetails)
                : CircularProgressIndicator(), // Loading indicator
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
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
                          builder: (context) => WPage(),
                        ),
                      );
                    },

                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        title: Text(doctor['name']),
                        // Add more doctor information as needed
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HospitalDetailsCard extends StatelessWidget {
  final Map<String, dynamic>? hospitalDetails;

  HospitalDetailsCard(this.hospitalDetails);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 10.0),
        if (hospitalDetails != null && hospitalDetails!['image'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              'https://metacare.co.in:3002${hospitalDetails!['image']}',
              width: 400.0,
              height: 350.0,
              fit: BoxFit.cover,
            ),
          ),
        SizedBox(height: 16.0),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        '${hospitalDetails!['hospital_name']}',
                        style: TextStyle(fontSize: 16.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8.0),
                    Flexible(
                      child: Text(
                        '${hospitalDetails!['address']}',
                        style: TextStyle(fontSize: 16.0),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: Colors.green,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '${hospitalDetails!['mobile']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '${hospitalDetails!['email']}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
                // Add the code for displaying rating here
              ],
            ),
          ),
        ),
      ],
    );
  }
}

