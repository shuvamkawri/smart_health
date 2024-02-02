import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../home_screen/hospital_dashboard_page.dart';


class CityPage extends StatefulWidget {
  final String? isoCode;
  final String? countryCode;

  CityPage({this.isoCode, this. countryCode});

  @override
  _CityPageState createState() => _CityPageState();
}

class _CityPageState extends State<CityPage> {
  List<Map<String, String>> cityList = [];
  List<Map<String, String>> filteredCityList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCityList();
  }
  Future<void> fetchCityList() async {
    print('Starting the fetchCityList function');

    final requestBody = json.encode({
      'country_code': widget.countryCode, // Replace with the desired country code
      'state_code': widget.isoCode
    });

    print('Request Body: $requestBody');

    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/user/UserCityList'),
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
      body: requestBody,
    );
    print('HTTP POST request sent');

    if (response.statusCode == 201) {
      print('Response status code is 201');

      final data = json.decode(response.body);
      print('Response data decoded');

      if (data['errorCod'] == 200) {
        print('Error code is 200');

        final List<dynamic> dynamicCityList = data['city_list'];
        print('Dynamic city list retrieved');

        final List<Map<String, String>> convertedCityList = dynamicCityList
            .map((dynamic item) =>
        Map<String, String>.from(item as Map<String, dynamic>))
            .toList();
        print('City list converted to the desired format');

        setState(() {
          cityList = filteredCityList = convertedCityList;
        });
        print('City list updated in the state');
      } else {
        print('Error code is not 200');
      }
    } else {
      print('Failed to fetch city data');
    }
  }


  void filterCityList(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      filteredCityList = cityList.where((city) {
        return city['name']!.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    });
  }

  void navigateToHospitalDashboardPage(String cityName) async {
    // Save the selected city name to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', cityName);

    print('Selected City: $cityName'); // Add this print statement to print the city name

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HospitalDashboardPage(
          cityName: cityName,
          loggedInEmail: '',
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('City'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (query) {
                filterCityList(query);
              },
              decoration: InputDecoration(
                labelText: 'Search City',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCityList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Handle city selection here
                    final selectedCity = filteredCityList[index]['name'];
                    navigateToHospitalDashboardPage(selectedCity!);
                  },
                  child: ListTile(
                    title: Text(filteredCityList[index]['name'] ?? ''),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> getSelectedCity() async {
  final prefs = await SharedPreferences.getInstance();
  final selectedCity = prefs.getString('selectedCity') ?? ''; // Default value is an empty string
  print('Selected City: $selectedCity'); // Add this print statement
  return selectedCity;
}

