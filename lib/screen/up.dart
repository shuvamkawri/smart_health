import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
class UserPrescriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Prescription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchPrescriptionData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No prescription data available.');
            } else {
              final prescriptionList = snapshot.data;
              return ListView.builder(
                itemCount: prescriptionList!.length,
                itemBuilder: (context, index) {
                  final prescription = prescriptionList[index];
                  final user = prescription['user_id'];
                  final imageUrl =
                      'https://metacare.co.in:3002/${prescription['image']}';

                  return Card(
                    elevation: 5.0,
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        _showImageDialog(context, imageUrl);
                      },
                      child: Column(
                        children: [
                          Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            height: 150, // Adjust the size as needed
                          ),
                          ListTile(
                            title: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Medicine: ',
                                  ),
                                  TextSpan(
                                    text: '${prescription['add_medicine']}',
                                    style: TextStyle(
                                      color: Colors.blue, // Set the color to blue
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quantity: ${prescription['quantity']}'),
                                Text('Customer Name: ${user['f_name']} ${user['l_name']}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchPrescriptionData() async {
    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/pharmacy/prescriptionData'),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "pharmacy_id": "651bbe5369de2c3f9134c3e2"
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> resultList = data['result'];

      // Convert the List<dynamic> to a List<Map<String, dynamic>>
      final List<Map<String, dynamic>> prescriptionList = resultList.map((
          item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      return prescriptionList;
    } else {
      throw Exception('Failed to load prescription data');
    }
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: double.infinity,
            height: 400.0, // Adjust the size as needed
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}
