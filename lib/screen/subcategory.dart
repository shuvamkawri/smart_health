import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/treat.dart';
import 'package:smarthealth/screen/view.dart';

import '../home_screen/hospital_dashboard_page.dart'; // Import the html parser package

class SubCategoryPage extends StatelessWidget {
  final List<SubCategory> subCategories;

  SubCategoryPage({required this.subCategories});

  Future<String> getSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedCity = prefs.getString('selectedCity') ?? ''; // Default value is an empty string
    print('Selected City: $selectedCity');
    return selectedCity;
  }

  Future<void> _fetchHospitals(BuildContext context) async {
    // Fetch the treatment_id from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? categoryId = prefs.getString('categoryId');

    if (categoryId != null) {
      // Get the selected city from SharedPreferences
      String selectedCity = await getSelectedCity();

      // Print the request body before sending the POST request
      print('Request Body: {"treatment_id": $categoryId, "city": $selectedCity}');

      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/treatment-category/hospitalList'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "treatment_id": categoryId, // Use the categoryId from SharedPreferences
          "city": selectedCity, // Use the selected city from SharedPreferences
        }),
      );

      if (response.statusCode == 201) { // Check for 200 OK status
        final data = json.decode(response.body);
        final List<dynamic> hospitals = data['results'];

        if (hospitals.isNotEmpty) {
          // Navigate to the HospitalListScreen and pass the hospital data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HospitalListScreen(hospitals: hospitals),
            ),
          );
        } else {
          // Display a message when no hospitals are found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("No hospital found"),
            ),
          );
        }
      } else {
        print("Error: ${response.statusCode}");
      }
    } else {
      print('No categoryId stored in shared preferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disease'),
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
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: subCategories.length,
              itemBuilder: (context, index) {
                final subCategory = subCategories[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 18.0,
                  ),
                  title: Text(
                    subCategory.name,
                    style: TextStyle(
                      color: Colors.black87, // Set the text color to black
                      fontWeight: FontWeight.bold, // Set the text to bold
                      fontSize: 19.0, // Set the font size to 16.0 (adjust the size as needed)
                    ),
                  ),


                    subtitle: Column(
                    children: <Widget>[
                      SizedBox(height: 8.0),
                      Text(
                        subCategory.cleanDescription(),
                        style: TextStyle(
                          color: Colors.black,
                            fontSize: 15.0,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            width: 350.0, // Set the desired width
            height: 40.0, // Set the desired height
            child: TextButton(
              onPressed: () => _fetchHospitals(context),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
              child:Text(
                "Hospital",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0, // Set the desired font size
                  fontWeight: FontWeight.bold, // Make the text bold
                ),
              )

            ),
          )

        ],
      ),
    );
  }
}
class SubCategory {
  final String name;
  final String description;

  SubCategory({required this.name, required this.description});

  String cleanDescription() {
    String descriptionWithoutPTags = description.replaceAll(RegExp(r'<p>|<\/p>'), '');
    return parse(descriptionWithoutPTags)?.documentElement?.text ?? '';
  }
}

class HospitalListScreen extends StatelessWidget {
  final List<dynamic> hospitals;

  HospitalListScreen({required this.hospitals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hospital'),
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
      body: ListView.builder(
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];

          return Card(
            margin: EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () async {
                String hospitalId = hospital['_id'] ?? ''; // Assuming '_id' is the key for hospitalId in your map
                print('Selected Hospital ID: $hospitalId');

                // Store the hospitalId in SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('hospitall_id', hospitalId);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TreatPage(),
                  ),
                );
              },


              child: ListTile(
                leading: Image.network(
                  'https://metacare.co.in:3002${hospital['image']}',
                  width: 50, // Adjust the image width as needed
                  height: 50, // Adjust the image height as needed
                  fit: BoxFit.cover, // Ensure the image covers the available space
                ),
                title: Text(
                  hospital['hospital_name'],
                  style: TextStyle(
                    color: Colors.blue, // Change the title text color to blue
                    fontWeight: FontWeight.bold, // Optional: Adjust the font weight
                  ),
                ),
                subtitle: Text(
                  hospital['address'],
                  style: TextStyle(
                    color: Colors.black, // Change the subtitle text color to black
                  ),
                ),
                // Add more hospital information as needed
              ),
            ),
          );

        },
      ),
    );
  }
}
