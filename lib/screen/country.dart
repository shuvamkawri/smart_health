import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'location.dart';

class CountryListPage extends StatefulWidget {
  @override
  _CountryListPageState createState() => _CountryListPageState();
}

class _CountryListPageState extends State<CountryListPage> {
  List<dynamic> countries = [];
  String selectedCountry = '';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    fetchData();
    loadSelectedCountry();
  }

  Future<void> fetchData() async {
    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/user/UserCountryList'),
      headers: {'accept': '*'},
      body: '',
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        countries = data['Country_list'];
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void _onCountrySelected(String countryName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCountry', countryName);
    final storedCountry = prefs.getString('selectedCountry');

    if (storedCountry != null) {
      print('Stored selected country: $storedCountry');

      // Pass the selectedCountry and countryName to LocationPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPage(
            selectedCountry: selectedCountry,
            countryName: countryName,
          ),
        ),
      );
    } else {
      print('Failed to retrieve selected country from SharedPreferences');
    }

    setState(() {
      selectedCountry = countryName;
    });
  }

  Future<void> loadSelectedCountry() async {
    final prefs = await SharedPreferences.getInstance();
    final storedCountry = prefs.getString('selectedCountry');
    if (storedCountry != null) {
      setState(() {
        selectedCountry = storedCountry;
      });
    }
  }

  List<dynamic> _filteredCountries() {
    if (searchText.isEmpty) {
      return countries;
    } else {
      return countries.where((country) {
        final countryName = country['name'].toLowerCase();
        return countryName.contains(searchText.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Country List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Country',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries().length,
              itemBuilder: (context, index) {
                final country = _filteredCountries()[index];
                return ListTile(
                  title: Text(country['name']),
                  subtitle: Text(country['isoCode']),
                  onTap: () {
                    _onCountrySelected(country['name']);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Selected country: $selectedCountry'),
        ),
      ),
    );
  }
}
