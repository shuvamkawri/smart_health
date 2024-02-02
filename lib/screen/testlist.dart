import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen/hospital_dashboard_page.dart';

class TestList extends StatefulWidget {
  @override
  _TestListState createState() => _TestListState();
}

class _TestListState extends State<TestList> {
  List<Map<String, dynamic>> testItems = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? pathologyId = prefs.getString('pathologyId'); // Retrieve pathologyId from SharedPreferences

    print('pathologyId from SharedPreferences: $pathologyId');

    final url = 'https://metacare.co.in:3002/api/pathology/pathologyTestList';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "pathology_id": pathologyId, // Use the retrieved pathologyId
        }),
      );

      print('Response Status Code: ${response.statusCode}');

      if (response.statusCode == 201) { // Check for the status code 200
        final Map<String, dynamic> data = json.decode(response.body);
        print('Response Data: $data');

        if (data.containsKey('result') && data['result'] is Map) {
          final Map<String, dynamic> result = data['result'];

          if (result.containsKey('pathologyTest') && result['pathologyTest'] is List) {
            setState(() {
              testItems = List<Map<String, dynamic>>.from(result['pathologyTest']);
            });
          }
        }
      }
    } catch (error) {
      print('Error: $error');
    }
  }
  Widget _buildList() {
    if (testItems.isEmpty) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        itemCount: testItems.length,
        itemBuilder: (context, index) {
          final item = testItems[index];
          final title = item['pathologyTest_id']['name'] ?? 'Name not available';
          final description = item['pathologyTest_id']['description'] ?? 'Description not available';
          final sanitizedDescription = _stripHtmlTags(description);

          return Card(
            child: ListTile(
              title: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0, // Set the font size for the title
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
              subtitle: Text(
                sanitizedDescription,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0, // Set the font size for the description
                ),
              ),
            ),
          );
        },
      );
    }
  }

// Function to remove HTML tags from description
  String _stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test List'),
        //backgroundColor: Colors.grey,
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
      body: _buildList(),
    );
  }
}
