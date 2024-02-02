import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smarthealth/screen/view.dart';

class HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final VoidCallback onPressedViewDetails;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  HospitalCard({required this.hospital, required this.onPressedViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160.0,
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
                      hospital.rating.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              ListTile(
                leading: _buildCircleAvatar(),
                title: _buildTitle(context),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCircleAvatar() {
    return Container(
      width: 60.0,
      height: 100.0,
      decoration: BoxDecoration(
        color: Colors.lightBlue.shade50,
        borderRadius: BorderRadius.circular(50.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200,
            blurRadius: 10.0,
            spreadRadius: 0.0,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundImage: hospital.image,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: Text(
            hospital.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
        ),
        SizedBox(height: 4.0),
        Flexible(
          child: Text(
            hospital.address,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () {
            // Navigate to the ViewPage with the hospitalId
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewPage(hospitalId: hospital.hospitalId),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.blue, // Set the background color
            onPrimary: Colors.white, // Set the text color
          ),
          child: Text('View Detail'),
        ),

      ],
    );
  }
}
  class Hospital {
  final String hospitalId;
  final String name;
  final ImageProvider<Object>? image;
  final double rating;
  final String address;

  Hospital({
  required this.hospitalId,
  required this.name,
  required this.image,
  required this.rating,
  required this.address,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
  return Hospital(
  hospitalId: json['_id'] ?? '',
  name: json['hospital_name'] ?? '',
  image: json['image'] != null
  ? NetworkImage('https://metacare.co.in:3002/${json['image']}') as ImageProvider<Object>
      : AssetImage('path/to/placeholder_image.png') as ImageProvider<Object>, // Replace with your placeholder image
  rating: double.parse(json['rating'] ?? '0'),
  address: json['Address'] ?? '',
  );
  }
  }


Future<void> fetchHospitalDetails(BuildContext context, String hospitalId) async {
  try {
    final response = await http.post(
      Uri.parse('https://metacare.co.in:3002/api/hospital/view/$hospitalId'),
      headers: {
        'accept': '*/*',
      },
      body: '',
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['result'] != null && data['result']['details'] != null) {
        // Process the fetched details and show them in a dialog or another widget
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Hospital Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${data['result']['details']['hospital_name'] ?? 'N/A'}'),
                Text('Address: ${data['result']['details']['Address'] ?? 'N/A'}'),
                Text('Mobile: ${data['result']['details']['mobile'] ?? 'N/A'}'),
                Text('Rating: ${data['result']['details']['rating'] ?? 'N/A'}'),
                // Add more fields as needed
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      } else {
        // Handle null or missing data in the API response
        print('Error: Invalid API response');
      }
    } else {
      // Handle API error
      print('Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    // Handle network error
    print('Error: $e');
  }
}
