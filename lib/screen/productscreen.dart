import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductScreen extends StatelessWidget {
  Future<List<Map<String, dynamic>>> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';

    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/pharmacy-upload/userPrescriptionData'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "user_id": userId,
      }),
    );

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      final result = jsonResponse['result'];
      return List<Map<String, dynamic>>.from(result);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch data and display it in a ListView
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Details'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No data available');
          } else {
            final data = snapshot.data;

            return ListView.builder(
              itemCount: data!.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final imageUrl = 'https://metacare.co.in:3002/${item['image']}';

                // Extract medicine name and quantity from the 'medicine' list
                final List<dynamic> medicines = item['medicine'];
                final List<Widget> medicineWidgets = [];

                for (var medicine in medicines) {
                  final medicineName = medicine['medicine_name'];
                  final medicineQuantity = medicine['qu'];
                  final medicineWidget = ListTile(
                    title: Text('Medicine: $medicineName'),
                    subtitle: Text('Quantity: $medicineQuantity'),
                  );
                  medicineWidgets.add(medicineWidget);
                }

                return PrescriptionCard(imageUrl, medicineWidgets);
              },
            );
          }
        },
      ),
    );
  }
}
class PrescriptionCard extends StatelessWidget {
  final String imageUrl;
  final List<Widget> medicineWidgets;

  PrescriptionCard(this.imageUrl, this.medicineWidgets);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft, // Align the button to the left
            child: TextButton(
              onPressed: () {
                // Show the image in a larger view with pinch-to-zoom using photo_view
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ProductImageScreen(imageUrl);
                    },
                  ),
                );
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                textStyle: MaterialStateProperty.all<TextStyle>(
                  TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              child: Text('View '),
            ),
          ),
          ...medicineWidgets, // Display medicine names and quantities
        ],
      ),
    );
  }
}

class ProductImageScreen extends StatelessWidget {
  final String imageUrl;

  ProductImageScreen(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription View'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
