import 'package:flutter/material.dart';
import 'dart:convert'; // Import this to work with JSON data
import 'package:http/http.dart' as http;
import 'package:smarthealth/screen/patients.dart';

import 'package:smarthealth/screen/shop.dart';

import '../home_screen/hospital_dashboard_page.dart';
import 'city.dart';
import 'country.dart';
import 'dr_list.dart';
import 'my.dart';

class PharmaceuticalsPage extends StatefulWidget {
  @override
  _PharmaceuticalsPageState createState() => _PharmaceuticalsPageState();
}

class _PharmaceuticalsPageState extends State<PharmaceuticalsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Pharmacy> pharmacyList = []; // List to store pharmacy data

  @override
  void initState() {
    super.initState();
    _fetchPharmacyList(); // Fetch pharmacy data when the widget initializes
  }

  Future<void> _fetchPharmacyList() async {
    print('Fetching selected city from shared preferences...');
    final selectedCity = await getSelectedCity(); // Get the city from shared preferences
    print('Selected city retrieved: $selectedCity');

    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/pharmacy/list'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "city": selectedCity, // Use the retrieved city from shared preferences
      }),
    );

    if (response.statusCode ==
        201) { // Check for a valid status code (e.g., 200 for success)
      print('Pharmacy data request succeeded. Parsing response...');
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> pharmacyData = data['results']['result'];

      setState(() {
        print('Updating pharmacyList with fetched data...');
        pharmacyList =
            pharmacyData.map((data) => Pharmacy.fromJson(data)).toList();
      });
      print('pharmacyList updated successfully.');
    } else {
      // Handle errors here, e.g., show an error message
      print('Error: Failed to fetch pharmacy list. Status Code: ${response
          .statusCode}');
      // You can display an error message to the user or take appropriate action here.
    }
  }


  Future<void> _fetchPharmacySearch({String? name, String? address}) async {
    final Map<String, dynamic> requestData = {
      "pharmacy_name": name,
      "address": address,
    };

    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/pharmacy/name'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> pharmacyData = data['result']['result'];

      List<Pharmacy> filteredList = pharmacyData
          .map((data) => Pharmacy.fromJson(data))
          .where((pharmacy) {
        // Filter pharmacies by name and address based on the search query
        final String pharmacyName = pharmacy.name.toLowerCase();
        final String pharmacyAddress = pharmacy.address.toLowerCase();
        final String queryText = name?.toLowerCase() ?? '';
        final String queryAddress = address?.toLowerCase() ?? '';

        return pharmacyName.contains(queryText) ||
            pharmacyAddress.contains(queryAddress);
      }).toList();

      setState(() {
        // Update the pharmacyList with the filtered data
        pharmacyList = filteredList;
      });
    } else {
      // Handle errors here, e.g., show an error message
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacy'),
        //backgroundColor: Colors.grey,
      ),
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        padding: EdgeInsets.all(10.0),
        child: _buildShopCard(context), // Pass the context to _buildShopCard
      ),
      // Add the bottomNavigationBar here
      bottomNavigationBar: _buildBottomBox(context),
    );
  }

  Widget _buildShopCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.lightBlue.shade50,
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          Container(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.black),
              onChanged: (query) {
                print('Search query: $query');
                _fetchPharmacySearch(
                  name: query,
                  address: null,
                );
              },
              decoration: InputDecoration(
                // prefixIcon: IconButton(
                //  // icon: Icon(Icons.keyboard_arrow_left),
                //   onPressed: () {
                //     Navigator.pop(context); // Use the context here
                //   },
                // ),
                hintText: 'Shop Name',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  height: 1.5,
                ),
                alignLabelWithHint: true,
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                suffixIcon: IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    // Implement the functionality when the bell icon is pressed
                    // For example, show notifications or navigate to a notification page
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          // ElevatedButton(
          //   onPressed: () {
          //     // Implement the login functionality here
          //   },
          //   child: Text('Login'),
          // ),
          SizedBox(height: 10),
          // OutlinedButton(
          //   onPressed: () {
          //     // Navigate to the PharmacyReg.dart page when the button is pressed
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => PharmacyReg()), // Replace with your actual page name
          //     );
          //   },
          //   child: Text('Sign Up Pharmacy'),
          // ),

          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: pharmacyList.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildPharmacyCard(pharmacyList[index] as Pharmacy);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(Pharmacy pharmacy) {
    return GestureDetector(
      onTap: () {
        // Navigate to the shop details page when the card is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopDetailsPage(pharmacy),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://metacare.co.in:3002${pharmacy.image}',
            ),
            radius: 30,
          ),
          title: Text(
            pharmacy.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          subtitle: Text(
            pharmacy.address,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
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

class Pharmacy {
  final String id;
  final String name;
  final String registrationId;
  final String address;
  final String openingTime;
  final String closingTime;
  final String contactNumber;
  final String email;
  final String website;
  final String licenseNumber;
  final String totalEmployee;
  final String doctorName;
  final String biography;
  final String gstNumber;
  final String panNumber;
  final bool status;
  final String image; // Add the image property

  Pharmacy({
    required this.id,
    required this.name,
    required this.registrationId,
    required this.address,
    required this.openingTime,
    required this.closingTime,
    required this.contactNumber,
    required this.email,
    required this.website,
    required this.licenseNumber,
    required this.totalEmployee,
    required this.doctorName,
    required this.biography,
    required this.gstNumber,
    required this.panNumber,
    required this.status,
    required this.image, // Include the image property in the constructor
  });

  factory Pharmacy.fromJson(Map<String, dynamic> json) {
    return Pharmacy(
      id: json['_id'] ?? '',
      name: json['pharmacy_name'] ?? '',
      registrationId: json['registration_id'] ?? '',
      address: json['address'] ?? '',
      openingTime: json['opening_time'] ?? '',
      closingTime: json['closing_time'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      totalEmployee: json['total_emplyee'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      biography: json['biography'] ?? '',
      gstNumber: json['gst_number'] ?? '',
      panNumber: json['pan_number'] ?? '',
      status: json['status'] ?? false,
      image: json['image'] ?? '', // Map the 'image' field from the JSON
    );
  }
}
