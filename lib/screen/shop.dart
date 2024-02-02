import 'package:flutter/material.dart';
import 'package:smarthealth/screen/pharmaceuticals.dart';
import 'package:smarthealth/screen/pp.dart';

import '../home_screen/hospital_dashboard_page.dart';

class ShopDetailsPage extends StatelessWidget {
  final Pharmacy pharmacy;

  // Constructor to receive the Pharmacy data from the previous page
  ShopDetailsPage(this.pharmacy);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacy Details'),
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
                  body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                  elevation: 5,
                  color: Colors.white,
                  child: SingleChildScrollView( // Use a SingleChildScrollView here
                  child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                  Row(
                    children: [
                      Icon(Icons.business, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '${pharmacy.name}',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Address: ${pharmacy.address}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Contact Number: ${pharmacy.contactNumber}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 8),
             Row(
                 children: [
                 Icon(Icons.email, color: Colors.blueGrey),

                  Text(
                        '  Email: ${pharmacy.email}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.web, color: Colors.blue),

              Text(
                  'Website: ${pharmacy.website}',
                  style:TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
              ),
            ],
          ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.assignment, color: Colors.blue), // Icon for license number
                      SizedBox(width: 8),
                      Text(
                        'License Number: ${pharmacy.licenseNumber}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people, color: Colors.blue), // Icon for total employees
                      SizedBox(width: 8),
                      Text(
                        'Total Employees: ${pharmacy.totalEmployee}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue), // Icon for doctor name
                      SizedBox(width: 8),
                      Text(
                        'Doctor Name: ${pharmacy.doctorName}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 18),
                  Row(
                    children: [
                      Icon(Icons.description, color: Colors.blueGrey), // Icon for biography
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Biography: ${pharmacy.biography.replaceAll(RegExp(r'<[^>]*>'), '')}',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.blue), // Icon for GST Number
                      SizedBox(width: 8),
                      Text(
                        'GST Number: ${pharmacy.gstNumber}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.credit_card, color: Colors.blue), // Icon for PAN Number
                      SizedBox(width: 8),
                      Text(
                        'PAN Number: ${pharmacy.panNumber}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                Text(
                  'Status: ${pharmacy.status ? 'Active' : 'Inactive'}',
                  style: TextStyle(
                    fontSize: 15,
                    color: pharmacy.status ? Colors.green : Colors.red,
                  ),
                ),
                  SizedBox(height: 16), // Add some spacing between the button and the image
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PPage(pharmacyName: pharmacy.name, pharmacyId: pharmacy.id),
                          ),
                        );
                      },
                      child: Text('Prescription upload'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue.shade400,
                      ),
                    ),
                  ),

                  SizedBox(height: 16), // Add some spacing between the button and the image
                  Center(
                    child: Image.asset(
                      'assets/f.jpg', // Replace with the actual image path
                      width: 50, // Set the width as needed
                      height: 50, // Set the height as needed
                    ),
                  ),
                ],
                ),
                ),
                ),
                ),
                ),
                );
              }
            }