import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../home_screen/hospital_dashboard_page.dart';
import 'city.dart';
import 'country.dart';
import 'dr_list.dart';
import 'hospital_card.dart';
import 'mapscreen.dart';
import 'my.dart';

class HospitalPage extends StatefulWidget {


  @override
  _HospitalPageState createState() => _HospitalPageState();
}

class _HospitalPageState extends State<HospitalPage> {
  List<Hospital> hospitals = [];
  String _searchKeyword = '';
  String _selectedSortingOption = "All"; // Default sorting option
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchHospitalData();
  }


  Future<void> fetchHospitalData() async {
    try {
      print('Fetching hospital data...');

      // Get the selected city from SharedPreferences
      final selectedCity = await getSelectedCity();
      print('Selected City: $selectedCity');

      final requestBody = {"city": selectedCity};
      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/hospital/list'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Sent POST request to the API');

      if (response.statusCode == 201) {
        print('Response status code: 201 (Created)');

        final data = jsonDecode(response.body);
        print('Received response data: $data');

        final hospitalList = (data['results'] as List)
            .map((json) => Hospital.fromJson(json))
            .toList();
        print('Mapped data to hospitalList: $hospitalList');

        setState(() {
          hospitals = hospitalList;
        });
        print('Hospital data updated.');
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Network Error: $e');
    }
  }


  Future<void> searchHospitals(String keyword) async {
    try {
      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/hospital/search'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "hospital_name": keyword,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        List<dynamic> hospitalList = data['result'];
        setState(() {
          hospitals =
              hospitalList.map((json) => Hospital.fromJson(json)).toList();
        });
      } else {
        // Handle API error
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      // Handle network error
      print('Error: $e');
    }
  }

  // Sorting method to display hospital list based on selected option
  void sortHospitals(String sortingOption) {
    setState(() {
      _selectedSortingOption = sortingOption;

      // Sort the hospital list based on the selected option
      if (sortingOption == "All") {
        // No sorting needed, show the original hospital list
        hospitals.sort((a, b) => a.name.compareTo(b.name));
      } else if (sortingOption == "Top-Rated") {
        // Sort by rating (if your Hospital model has a 'rating' property)
        hospitals.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (sortingOption == "Most Viewed") {
        // Sort by most viewed (if your Hospital model has a 'views' property)
        hospitals.sort((a, b) => b.rating.compareTo(a.rating));
      } else if (sortingOption == "Recommended") {
        // You can define your own recommendation logic here
        // For example, sort based on recommendations provided by the API
        // hospitals.sort((a, b) => ...);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospitals'),
      ),
      body: buildHospitalPageBody(),
      bottomNavigationBar: _buildBottomBox(
          context), // Add the _buildBottomBox here
    );
  }

  Widget buildHospitalPageBody() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
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
              // Positioned(
              //   left: 8.0,
              //   top: 23.0,
              //   child: IconButton(
              //     icon: Icon(Icons.keyboard_arrow_left),
              //     onPressed: () {
              //       Navigator.of(context)
              //           .pop(); // Navigate back when back arrow icon is pressed
              //     },
              //   ),
              // ),
              // Positioned(
              //   right: 8.0,
              //   top: 8.0,
              //   child: IconButton(
              //     icon: Icon(Icons.notifications),
              //     onPressed: () {
              //       // Notification bell icon pressed
              //     },
              //   ),
              // ),
              Positioned(
                left: 56.0,
                right: 56.0,
                top: 16.0,
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.left,
                  onChanged: (value) {
                    _searchKeyword = value;
                  },
                  onSubmitted: (value) {
                    searchHospitals(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search hospital',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16.0),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: GestureDetector(
                      onTap: () {
                        // Handle the location icon tap here
                        openMapScreen();
                      },
                      child: Icon(
                        Icons.location_on, // Add the location icon here
                        color: Colors
                            .blue, // You can customize the color of the icon
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        searchHospitals(_searchKeyword);
                      },
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
                      ElevatedButton(
                        onPressed: () {
                          sortHospitals("All");
                        },
                        style: ElevatedButton.styleFrom(
                          primary: _selectedSortingOption == "All"
                              ? Colors.blue
                              : Colors.white,
                          onPrimary: Colors.black, // Set text color to black
                          minimumSize: Size(100.0, 40.0),
                        ).copyWith(
                          // Change background color when pressed
                          elevation: MaterialStateProperty.all<double>(0.0),
                          backgroundColor: MaterialStateProperty.resolveWith<
                              Color>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors
                                  .blue; // Set deep blue color when pressed
                            }
                            return _selectedSortingOption == "All"
                                ? Colors.blue
                                : Colors.white;
                          }),
                        ),
                        child: Text('All'),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          sortHospitals("Top-Rated");
                        },
                        style: ElevatedButton.styleFrom(
                          primary: _selectedSortingOption == "Top-Rated"
                              ? Colors.blue
                              : Colors.white,
                          onPrimary: Colors.black, // Set text color to black
                          minimumSize: Size(120.0, 40.0),
                        ).copyWith(
                          // Change background color when pressed
                          elevation: MaterialStateProperty.all<double>(0.0),
                          backgroundColor: MaterialStateProperty.resolveWith<
                              Color>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors
                                  .blue; // Set deep blue color when pressed
                            }
                            return _selectedSortingOption == "Top-Rated"
                                ? Colors.blue
                                : Colors.white;
                          }),
                        ),
                        child: Text('Top-rated'),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          sortHospitals("Most Viewed");
                        },
                        style: ElevatedButton.styleFrom(
                          primary: _selectedSortingOption == "Most Viewed"
                              ? Colors.blue
                              : Colors.white,
                          onPrimary: Colors.black, // Set text color to black
                          minimumSize: Size(120.0, 40.0),
                        ).copyWith(
                          // Change background color when pressed
                          elevation: MaterialStateProperty.all<double>(0.0),
                          backgroundColor: MaterialStateProperty.resolveWith<
                              Color>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors
                                  .blue; // Set deep blue color when pressed
                            }
                            return _selectedSortingOption == "Most Viewed"
                                ? Colors.blue
                                : Colors.white;
                          }),
                        ),
                        child: Text('Most viewed'),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          sortHospitals("Recommended");
                        },
                        style: ElevatedButton.styleFrom(
                          primary: _selectedSortingOption == "Recommended"
                              ? Colors.blue
                              : Colors.white,
                          onPrimary: Colors.black, // Set text color to black
                          minimumSize: Size(120.0, 40.0),
                        ).copyWith(
                          // Change background color when pressed
                          elevation: MaterialStateProperty.all<double>(0.0),
                          backgroundColor: MaterialStateProperty.resolveWith<
                              Color>((Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors
                                  .blue; // Set deep blue color when pressed
                            }
                            return _selectedSortingOption == "Recommended"
                                ? Colors.blue
                                : Colors.white;
                          }),
                        ),
                        child: Text('Recommended'),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 130.0,
                left: 8.0,
                right: 8.0,
                bottom: 8.0,
                child: ListView.builder(
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    return HospitalCard(
                      hospital: hospitals[index],
                      onPressedViewDetails: () {
                        fetchHospitalDetails(context, hospitals[index]
                            .hospitalId);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to open the map screen
  void openMapScreen() {
    // Navigate to the map screen by pushing the MapScreen widget onto the navigator stack
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapScreen(
              initialLat: 37.7749, // Replace with your desired initial latitude
              initialLng: -122.4194, // Replace with your desired initial longitude
            ),
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