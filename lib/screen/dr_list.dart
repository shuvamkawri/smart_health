import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/patients.dart';
import '../home_screen/hospital_dashboard_page.dart';
import 'appointment.dart';
import 'city.dart';
import 'country.dart';
import 'doctordetails.dart';
import 'my.dart';

class DrListPage extends StatefulWidget {
  @override
  _DrListPageState createState() => _DrListPageState();
}

class _DrListPageState extends State<DrListPage> {
  List<Doctor> doctors = [];
  String _searchKeyword = '';
  String _selectedSortingOption = "All";
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctorData();
  }

  Future<void> fetchDoctorData() async {
    try {
      print('Sending a POST request to fetch doctor data...');

      // Get the selected city from SharedPreferences
      final selectedCity = await getSelectedCity();
      print('Selected City: $selectedCity');

      // Define the JSON payload with the selected city
      final Map<String, String> payload = {
        "city": selectedCity,
      };
      print('Request payload: $payload');

      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/doctor/list'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      print('Received a response with status code: ${response.statusCode}');

      // Print the entire response body for debugging
      final data = jsonDecode(response.body);
      print('Response body: $data');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Processing JSON response...');

        List<dynamic> doctorList = data['results']['details'] as List<dynamic>;
        List<String> doctorIds = doctorList.map((doctor) {
          return doctor['_id'] as String;
        }).toList();
        print('Doctor IDs: $doctorIds');

        // Store the doctor IDs in SharedPreferences
        await storeDoctorIdsInSharedPreferences(doctorIds);

        setState(() {
          doctors = doctorList
              .map((json) => Doctor.fromJson(json as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });

        print('Doctor data fetched successfully.');
      } else {
        handleApiError(response);
      }
    } catch (e) {
      print('An error occurred: $e');
      handleNetworkError(e);
    }
  }


  Future<void> searchDoctors(String keyword) async {
    try {
      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/doctor/search'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "hospital_name": '', // Empty hospital name field
          "specialist": '', // Empty specialist field
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        List<dynamic> doctorList = data['results']['details'];

        // Perform smart search based on the entered keyword
        List<Doctor> filteredDoctors = doctorList
            .where((doctor) =>
        doctor['specialist']
            .toString()
            .toLowerCase()
            .contains(keyword.toLowerCase()) ||
            doctor['hospital_names']
                .toString()
                .toLowerCase()
                .contains(keyword.toLowerCase()))
            .map((json) => Doctor.fromJson(json))
            .toList();

        setState(() {
          doctors = filteredDoctors;
        });
      } else {
        handleApiError(response);
      }
    } catch (e) {
      handleNetworkError(e);
    }
  }


  void handleApiError(http.Response response) {
    print('Error: ${response.statusCode} - ${response.body}');
    setState(() {
      doctors = [];
      _isLoading = false;
    });
  }

  void handleNetworkError(dynamic error) {
    print('Error: $error');
    setState(() {
      doctors = [];
      _isLoading = false;
    });
  }

  void sortDoctors(String sortingOption) {
    setState(() {
      _selectedSortingOption = sortingOption;

      if (sortingOption == "All") {
        doctors.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortingOption == "Top-Rated") {
        doctors.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (sortingOption == "Most Viewed") {
        doctors.sort((a, b) => b.views.compareTo(a.views));
      } else if (sortingOption == "Recommended") {
        // Define your recommendation logic here
        doctors.sort((a, b) => b.experience.compareTo(a.experience));
      }
    });
  }

  // Updated onChanged callback to trigger search when the user enters a keyword
  void handleSearch(String keyword) {
    setState(() {
      _searchKeyword = keyword;
      if (_searchKeyword.isEmpty) {
        // If the search field is empty, fetch all doctors
        fetchDoctorData();
      } else {
        // Perform the search based on the entered keyword
        searchDoctors(_searchKeyword);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor'),
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.lightBlue.shade50,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 56.0,
                  right: 56.0,
                  top: 16.0,
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.left,
                    onChanged: handleSearch,
                    onSubmitted: (value) {
                      handleSearch(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search doctor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(16.0),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 80.0,
                  left: 8.0,
                  right: 8.0,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        buildSortingButton("All"),
                        buildSortingButton("Top-Rated"),
                        buildSortingButton("Most Viewed"),
                        buildSortingButton("Recommended"),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  )
                else
                  Positioned(
                    top: 140.0,
                    left: 8.0,
                    right: 8.0,
                    bottom: 8.0,
                    child: ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        return DoctorCard(
                          doctor: doctors[index],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      // Add the bottomNavigationBar here
      bottomNavigationBar: _buildBottomBox(context),
    );
  }

  ElevatedButton buildSortingButton(String option) {
    return ElevatedButton(
      onPressed: () {
        sortDoctors(option);
      },
      style: ElevatedButton.styleFrom(
        primary: _selectedSortingOption == option ? Colors.blue : Colors.white,
        onPrimary: Colors.black,
        minimumSize: Size(120.0, 40.0),
      ),
      child: Text(option),
    );
  }

  Future<void> storeDoctorIdsInSharedPreferences(List<String> doctorIds) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('doctorIds', doctorIds);

    // Print the stored doctor IDs
    print('Stored Doctor IDs: $doctorIds');
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

class Doctor {
  final String doctorId;
  final String name;
  final String imageUrl;
  final double rating;
  final String address;
  final int views;
  final String specialist;
  final double amount;
  final String experience;
  final String biography;
  final List<String> hospitalNames;
  final List<String> hospitalIds;
  final List<String> education;
  final List<String> cities; // Use the list of cities

  Doctor({
    required this.doctorId,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.address,
    required this.views,
    required this.specialist,
    required this.amount,
    required this.experience,
    required this.biography,
    required this.hospitalNames,
    required this.hospitalIds,
    required this.education,
    required this.cities, // Use the list of cities
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? hospitalList = json['hospital'] as List<dynamic>? ??
        [];
    final List<String> hospitalNames = [];
    final List<String> hospitalIds = [];
    final List<String> cities = [];

    hospitalList!.forEach((hospitalData) {
      final String hospitalName = (hospitalData as Map<String,
          dynamic>?)?['hospital']['hospital_name'] as String? ?? '';
      final String hospitalId = (hospitalData as Map<String,
          dynamic>?)?['hospital']['_id'] as String? ?? '';
      final String city = (hospitalData as Map<String,
          dynamic>?)?['hospital']['city'] as String? ?? '';

      hospitalNames.add(hospitalName);
      hospitalIds.add(hospitalId);
      cities.add(city);
    });

    List<String> extractEducation(Map<String, dynamic> json) {
      final String educationString = json['education'] as String? ?? '';
      final cleanedEducationString =
      educationString.replaceAll(
          RegExp(r'\[|\]'), ''); // Remove square brackets

      return cleanedEducationString.isNotEmpty
          ? cleanedEducationString.split(',').map((e) => e.trim()).toList()
          : [];
    }

    final List<String> educationList = extractEducation(json);

    return Doctor(
      doctorId: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUrl: json['image'] != null
          ? 'https://metacare.co.in:3002${json['image'] as String}'
          : '',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating'] as String) ?? 0.0,
      address: json['address'] as String? ?? '',
      views: int.tryParse(json['likes'] as String) ?? 0,
      specialist: json['specialist']['category'] as String? ?? '',
      hospitalNames: hospitalNames,
      hospitalIds: hospitalIds,
      education: educationList,
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount'] as String) ?? 0.0,
      experience: json['experience'] as String? ?? '',
      biography: json['biography'] as String? ?? '',
      cities: cities, // Assign the list of cities
    );
  }
}

  class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorDetailsPage(doctor: doctor),
        ),
      );
    },
    child: Container(
      height: 200.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Card(
          color: Colors.white,
          child: Stack(
            children: [
              Positioned(
                left: 16.0,
                bottom: 16.0,
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 4.0),
                    Text(
                      doctor.rating.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                right: 16.0,
                bottom: 16.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentPage(selectedScheduleIds: [],),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  child: Text('Details'),
                ),
              ),

              ListTile(
                leading: Container(
                  width: 70.0,
                  height: 110.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 70.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 15.0, // Adjust the blur radius as needed
                              offset: Offset(0, 16), // Adjust the shadow offset as needed
                            ),
                          ],
                        ),
                      ),
                      ClipOval(
                        child: Image.network(
                          doctor.imageUrl,
                          width: 55.0, // Set the desired width for the image
                          height: 80.0, // Set the desired height for the image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,

                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '${doctor.specialist} - ${doctor.hospitalNames.join(", ")}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),


                    SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(Icons.currency_rupee),
                        SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            '${doctor.amount.toStringAsFixed(2)} | Exp: ${doctor.experience}years',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          '${doctor.views}',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
