import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'city.dart';

class LocationPage extends StatefulWidget {
  final String selectedCountry;
  final String countryName;

  LocationPage({
    required this.selectedCountry,
    required this.countryName,
  });

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  List<Map<String, String>> stateList = [];
  String? selectedState;

  @override
  void initState() {
    super.initState();
    fetchStateList();
  }

  Future<void> fetchStateList() async {
    final selectedCountry = widget.selectedCountry;

    print('Fetching state list for country: $selectedCountry');

    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/user/UserStateList'),
      headers: {
        'accept': '*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"country_name": selectedCountry}),
    );

    print('API Request: ${response.request}');
    print('API Response Status Code: ${response.statusCode}');

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      print('API Response Data: $data');

      if (data['errorCod'] == 200) {
        final List<dynamic> dynamicStateList = data['state_list'];
        print('Dynamic State List: $dynamicStateList');

        final List<Map<String, String>> convertedStateList = dynamicStateList
            .map((dynamic item) =>
        Map<String, String>.from(item as Map<String, dynamic>))
            .toList();
        print('Converted State List: $convertedStateList');

        setState(() {
          stateList = convertedStateList;
        });
      } else {
        // Handle the error
        print('Error Code: ${data['errorCod']}');
      }
    } else {
      // Handle the error
      print('Failed to fetch state data');
    }
  }

  void navigateToCityPage(String? state) {
    final selectedState = stateList.firstWhere(
          (element) => element['name'] == state,
      orElse: () => {'isoCode': '', 'countryCode': ''},
    );
    final isoCode = selectedState['isoCode'];
    final countryCode = selectedState['countryCode'];

    if (isoCode!.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CityPage(isoCode: isoCode, countryCode: countryCode),
        ),
      );
    } else {
      print('Invalid isoCode for state: $state');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: Center(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: stateList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                final selectedState = stateList[index]['name'];
                navigateToCityPage(selectedState);
              },
              child: Card(
                color: Colors.blue.shade50,
                elevation: 5,
                margin: EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/empire.png', width: 50, height: 50),
                    Text(
                      stateList[index]['name']!,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
