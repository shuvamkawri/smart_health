import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/patients.dart';
import 'package:smarthealth/screen/schedule.dart';
import '../home_screen/hospital_dashboard_page.dart';

import 'b.dart';
import 'country.dart';
import 'dr_list.dart';
import 'my.dart';

class DoctorCard extends StatelessWidget {
  final String doctorName;
  final String education;
  final String image;
  final String rating;
  final String experience;
  final String amount;
  final String doctorId;

  DoctorCard({
    required this.doctorName,
    required this.education,
    required this.image,
    required this.rating,
    required this.experience,
    required this.amount,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.network(
            'https://metacare.co.in:3002$image',
            height: 65.0,
            width: 65.0,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8.0),
          Text(
            doctorName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            // Truncate or ellipsis long education text
            education,
            maxLines: 2, // You can adjust this as needed
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$experience years',
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          Text(
            '₹$amount',
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          SizedBox(height: 3.0),
          buildRatingStars(rating),
          SizedBox(height: 3.0),
          SizedBox(height: 1.0), // Add some spacing
          Container(
            height: 30.0, // Set the desired button height
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the SchedulePage when "Book Appointment" is pressed
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BPage(),
                  ),
                );

              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Set the background color to blue
              ),
              child: Text('Book Now'),
            ),

          )

        ],
      ),
    );
  }

  Widget buildRatingStars(String rating) {
    double ratingValue = double.tryParse(rating) ?? 0.0;
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < ratingValue.floor() ? Icons.star : Icons.star_border,
          color: Colors.yellow,
        );
      }),
    );
  }
}

  class NewPage extends StatefulWidget {
  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {

  Future<String> getSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedCity = prefs.getString('selectedCity') ??
        ''; // Default value is an empty string
    print('Selected City: $selectedCity'); // Add this print statement
    return selectedCity;
  }

  Map<String, String> hospitalIdMap = {};

  Future<List<String>> fetchHospitals() async {
    final selectedCity = await getSelectedCity(); // Get the selected city from SharedPreferences

    final requestBody = {
      "city": selectedCity, // Use the selected city in the request body
    };

    final hospitalResponse = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/hospital/list'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (hospitalResponse.statusCode == 201) {
      final List<dynamic> hospitalData = jsonDecode(
          hospitalResponse.body)['results'];

      if (hospitalData is List) {
        final hospitals = List<String>.from(hospitalData.map((item) {
          final name = item['hospital_name'] as String;
          final id = item['_id'] as String;
          hospitalIdMap[name] = id; // Store the _id corresponding to the name

          // Save the hospital ID in shared preferences
          // saveHospitalIdToSharedPreferences(id);

          return name;
        }));
        return hospitals;
      } else {
        throw Exception('Invalid API response');
      }
    } else {
      throw Exception('Failed to load hospitals');
    }
  }


  Future<List<Map<String, dynamic>>> fetchSpecialists() async {
    print('Fetching specialists...');

    final String? storedHospitalId = await getHospitalIdFromSharedPreferences();

    if (storedHospitalId == null) {
      print('Hospital ID not found in SharedPreferences');
      throw Exception('Hospital ID not found in SharedPreferences');
    }

    final Map<String, dynamic> requestBody = {
      "hospital_id": storedHospitalId,
    };

    print('Request Body: $requestBody'); // Print the request body

    final specialistResponse = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/schedule/doctorSpecialist'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print('HTTP Request Sent');

    if (specialistResponse.statusCode == 201) {
      print('Response received with status code 201');
      final specialistData = jsonDecode(specialistResponse.body)['result'];
      print('Response Body: $specialistData'); // Print the response body

      List<Map<String, dynamic>> specialists = List<Map<String, dynamic>>.from(
          specialistData);
      print('Specialist names extracted');

      return specialists;
    } else {
      print('Failed to load specialists');
      throw Exception('Failed to load specialists');
    }
  }

  Future<void> searchDoctor() async {
    // Reset the doctorCards list before making a new search
    setState(() {
      doctorCards = [];
    });

    final String? hospitalId = await getHospitalIdFromSharedPreferences();
    final String? specialistId = await getSpecialistIdFromSharedPreferences();

    if (hospitalId != null && specialistId != null) {
      final requestBody = {
        "hospital_id": hospitalId, // Include hospital ID in the request body
        "specialist_id": specialistId,
      };

      // Print the request body
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/schedule/findSpeDoctor'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Raw Response: ${response.body}');

      if (response.statusCode == 201) {
        final doctorData = jsonDecode(response.body);

        // Print the response data
        print('Doctor Data: $doctorData');

        if (doctorData is List) {
          if (doctorData.isEmpty) {
            // Handle the case where there are no doctors available
            print('API Error: There are no Doctors Available');
            // Display the error message in a Snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'There are no doctors available for the selected criteria.'),
              ),
            );
            // Reset the selections and clear the doctor search results
            setState(() {
              selectedHospital = null;
              selectedSpecialist = null;
              doctorCards = [];
            });
          } else {
            final doctors = parseDoctorData(doctorData);
            // Update the UI with doctor cards
            setState(() {
              doctorCards = doctors;
            });
          }
        } else {
          // Handle other API errors
          print('API Error: Invalid response format');
        }
      } else {
        // Handle other API errors
        print('API Error: ${response.statusCode}');
        // You can handle other status codes (e.g., 404 for not found) as needed
      }
    } else {
      // Handle error in getting hospital/specialist IDs
      print('Error: Hospital or Specialist ID not found');
    }
  }

  // Example usage in your parsing function
  List<DoctorCard> parseDoctorData(dynamic doctorData) {
    List<DoctorCard> doctors = [];

    for (var doctor in doctorData) {
      DoctorCard doctorCard = DoctorCard(
        doctorId: doctor['doctor']['_id'],
        doctorName: doctor['doctor']['name'],
        education: doctor['doctor']['education'][0],
        image: doctor['doctor']['image'],
        experience: doctor['doctor']['experience'],
        rating: doctor['doctor']['rating'],
        amount: doctor['doctor']['amount'],
      );

      doctors.add(doctorCard);

      // Save doctorId to shared preferences
      saveDoctorIdToSharedPreferences(doctorCard.doctorId);

      // Print the doctor card information
      print("Doctor ID: ${doctorCard.doctorId}");
      print("Doctor Name: ${doctorCard.doctorName}");
      // Add more print statements for other properties if needed
      // ...

      print("\n");
    }

    return doctors;
  }

  // Function to save doctorId to shared preferences
  // Function to save doctorId to shared preferences
  void saveDoctorIdToSharedPreferences(String doctorId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctorIId', doctorId);
    print("Saved doctorId to SharedPreferences: $doctorId");
  }


  late Future<List<String>> hospitalsFuture;
  late Future<List<Map<String, dynamic>>> specialistsFuture;

  String? selectedHospital;
  String? selectedSpecialist;
  List<DoctorCard> doctorCards = [];

  @override
  void initState() {
    super.initState();
    hospitalsFuture = fetchHospitals();
    specialistsFuture =
    fetchSpecialists() as Future<List<Map<String, dynamic>>>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Appointment'),
        // backgroundColor: Colors.grey,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: refreshPage,
          ),
        ],
      ),

      body: Container(
        // Set the background color to blue
        color: Colors.blue.shade50,
        child: Column(
          children: <Widget>[

            // Hospital Dropdown
            FutureBuilder<List<String>>(
              future: hospitalsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final hospitals = snapshot.data;
                  return DropdownButton<String>(
                    isExpanded: true,
                    value: selectedHospital,
                    hint: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Select Hospital'),
                    ),
                    items: hospitals!.map((String hospital) {
                      return DropdownMenuItem<String>(
                        value: hospital,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            // Add padding to the text
                            child: Text(hospital),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedHospital = newValue;
                        if (newValue != null) {
                          final hospitalId = hospitalIdMap[newValue];
                          print(
                              'Selected Hospital: $newValue, _id: $hospitalId');
                          // Store the hospital ID in shared preferences
                          saveeHospitalIdToSharedPreferences(hospitalId!);
                        }
                      });
                    },

                  );
                }
              },
            ),

            // Specialist Dropdown
            FutureBuilder<List<Map<String, dynamic>>>(
              future: specialistsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final specialists = snapshot.data;
                  return DropdownButton<String>(
                    isExpanded: true,
                    value: selectedSpecialist,
                    hint: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Select Specialist'),
                    ),
                    items: specialists!.map((Map<String, dynamic> specialist) {
                      return DropdownMenuItem<String>(
                        value: specialist['_id'],
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            // Add padding to the text
                            child: Text(specialist['category']),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedSpecialist = newValue;
                        // Save the selected specialist ID to SharedPreferences
                        saveSpecialistIdToSharedPreferences(newValue!);
                      });
                    },
                  );
                }
              },
            ),

            // Search Doctor Button
            Center(
              child: Container(
                width: 220.0, // Set the desired width
                margin: EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: searchDoctor, // Call the searchDoctor function
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueAccent,
                    // Set the background color to light blue
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Rounded corners
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    // Adjust the padding here
                    child: Text(
                      'Search Doctor',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Doctor Cards Grid View
            if (doctorCards.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: doctorCards.length,
                  itemBuilder: (context, index) {
                    return doctorCards[index];
                  },
                ),
              ),
            if (doctorCards.isEmpty)
              Center(
                child: Text(
                  'No doctors available for the selected criteria.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBox(context),
    );
  }

  Future<String?> getHospitalIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hospitalId = prefs.getString(
        'h_id'); // Retrieve the "h_id" as a string
    print('Retrieved Hospital ID from SharedPreferences: $hospitalId');
    return hospitalId;
  }


// Function to save hospital ID to shared preferences
  void saveeHospitalIdToSharedPreferences(String hospitalId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('h_id', hospitalId);
    print("Saved selected hospital ID to SharedPreferences: $hospitalId");

    // Print the "h_id" value
    print("h_id: $hospitalId");
  }


// Function to save specialist ID to SharedPreferences
  void saveSpecialistIdToSharedPreferences(String specialistId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('specialistId', specialistId);
    print("Saved specialistId to SharedPreferences: $specialistId");
  }

// Function to retrieve specialist ID from SharedPreferences
  Future<String?> getSpecialistIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? specialistId = prefs.getString(
        'specialistId'); // Retrieve as a string
    print('Retrieved Specialist ID from SharedPreferences: $specialistId');
    return specialistId;
  }

  void refreshPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => NewPage(),
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