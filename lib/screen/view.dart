import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/patients.dart';
import 'package:smarthealth/screen/schedule.dart';
import 'package:smarthealth/screen/t.dart';
import 'dart:convert';
import '../home_screen/hospital_dashboard_page.dart';
import 'city.dart';
import 'country.dart';
import 'dr_list.dart';
import 'h.dart';
import 'my.dart';


class DoctorInfo {
  final String id;
  final String name;
  final String specialist;
  final String experience;
  final String city;
  final String state;
  final String mobileNumber;
  final String email;
  final String rating;
  final String biography;
  final String image;
  final String education;
  final String registration_number;

  DoctorInfo({
    required this.id,
    required this.name,
    required this.specialist,
    required this.experience,
    required this.city,
    required this.state,
    required this.mobileNumber,
    required this.email,
    required this.rating,
    required this.biography,
    required this.image,
    required this.education,
    required this.registration_number,
  });
}

class ViewPage extends StatefulWidget {
  final String hospitalId;

  ViewPage({required this.hospitalId});

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
  Map<String, dynamic>? _hospitalDetails;
  List<DoctorInfo> doctorList = [];
  List<TreatmentInfo> treatmentList = [];

  @override
  void initState() {
    super.initState();
    _fetchHospitalDetails();
    _fetchDoctorList();
    _fetchTreatmentList();
    _printStoredHospitalId(); // Call the function to print the stored hospitalId
  }


  Future<void> _fetchDoctorList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(
          'hospital_id', widget.hospitalId); // Store hospitalId as string

      print('Hospital ID: ${widget.hospitalId}'); // Print hospitalId

      final response = await http.post(
        Uri.parse(
            'https://metacare.co.in:3002/api/hospital/hospitalDoctorList'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "hospital_id": widget.hospitalId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results']['result'] != null) {
          setState(() {
            final doctorData = data['results']['result'];
            doctorList = doctorData.map<DoctorInfo>((doctor) {
              return DoctorInfo(
                id: doctor['_id'],
                name: doctor['name'] ?? 'N/A',
                specialist: doctor['specialist']['category'] ?? 'N/A',
                experience: doctor['experience'] ?? 'N/A',
                city: doctor['city'] ?? 'N/A',
                state: doctor['state'] ?? 'N/A',
                mobileNumber: doctor['mobile_number'] ?? 'N/A',
                email: doctor['email_id'] ?? 'N/A',
                rating: doctor['rating'] ?? 'N/A',
                biography: doctor['biography'] ?? 'N/A',
                image: doctor['image'] ?? 'N/A',
                education: doctor['education'] ?? 'N/A',
                  registration_number:doctor['registration_number'] ?? 'N/A',
              );
            }).toList();
          });

          // Print each DoctorInfo object
          for (var doctorInfo in doctorList) {
            print('Doctor ID: ${doctorInfo.id}');
            print('Doctor Name: ${doctorInfo.name}');
            // Print other properties as needed
          }
        } else {
          print('Error: Invalid API response');
        }
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchHospitalDetails() async {
    try {
      final selectedCity = await getSelectedCity(); // Get the selected city from SharedPreferences
      print('Starting the API request...');
      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/hospital/view'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "hospital_id": widget.hospitalId,
          "city": selectedCity, // Use the selected city from SharedPreferences
        }),
      );

      // Log the request body
      print(
          'Request Body: ${jsonEncode({ "hospital_id": widget.hospitalId,"city": selectedCity,})}');

      if (response.statusCode == 201) {
        print('API request was successful, processing the response...');

        final data = jsonDecode(response.body);
        if (data['result'] != null && data['result']['details'] != null) {
          print('API response is valid, updating state...');

          setState(() {
            _hospitalDetails = data['result']['details'];
          });

          // Log the response body
          print('Response Body: ${jsonEncode(data)}');
        } else {
          print('Error: Invalid API response');
        }
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }


  Future<void> _fetchTreatmentList() async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://metacare.co.in:3002/api/hospital/hospitalCategoryList'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "hospital_id": widget.hospitalId,
        }),
      );
      print('Response Body: ${response
          .body}'); // Add this line to print the response body


      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results']['result'] != null) {
          setState(() {
            final treatmentData = data['results']['result']['treatment'];
            treatmentList = treatmentData.map<TreatmentInfo>((treatment) {
              return TreatmentInfo(
                id: treatment['treatment_id']['_id'], // Add the _id field
                name: treatment['treatment_id']['category'] ?? 'N/A',
                imageUrl: 'https://metacare.co.in:3002${treatment['treatment_id']['image']}' ??
                    'N/A',
              );
            }).toList();
          });
        } else {
          print('Error: Invalid API response for treatment list');
        }
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' About Hospitals'),
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
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.lightBlue.shade50,
          ),
          padding: EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 5),
              // Align(
              //   alignment: Alignment.topLeft,
              //   child: GestureDetector(
              //     onTap: () {
              //       Navigator.pop(context);
              //     },
              //     // child: Container(
              //     //   padding: EdgeInsets.all(16.0),
              //     //   child: Icon(
              //     //     Icons.keyboard_arrow_left,
              //     //     size: 32,
              //     //     color: Colors.blue,
              //     //   ),
              //     // ),
              //   ),
              // ),
              SizedBox(height: 10.0),
              if (_hospitalDetails != null &&
                  _hospitalDetails!['image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    'https://metacare.co.in:3002${_hospitalDetails!['image']}',
                    width: 400.0,
                    height: 350.0,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 16.0),
              // Displaying information in a Card
              if (_hospitalDetails != null) ...[
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_hospital, // Use the location_on icon
                              color: Colors.blue, // Change the color as needed
                            ),
                            SizedBox(width: 8.0), // Add some spacing
                            Flexible(
                              child: Text(
                                '${_hospitalDetails!['hospital_name']}',
                                style: TextStyle(fontSize: 16.0),
                                overflow: TextOverflow.ellipsis,
                                // Specify the overflow behavior
                                maxLines: 1, // Set the maximum number of lines
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on, // Use the location_on icon
                              color: Colors.blue, // Change the color as needed
                            ),
                            SizedBox(width: 8.0), // Add some spacing
                            Flexible(
                              child: Text(
                                '${_hospitalDetails!['address']}',
                                style: TextStyle(fontSize: 16.0),
                                overflow: TextOverflow.ellipsis,
                                // Specify the overflow behavior
                                maxLines: 1, // Set the maximum number of lines
                              ),
                            ),
                          ],
                        ),


                        Row(
                          children: [
                            Icon(
                              Icons.phone, // Use the phone icon
                              color: Colors.green, // Change the color as needed
                            ),
                            SizedBox(width: 8.0), // Add some spacing
                            Text(
                              '${_hospitalDetails!['mobile']}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.email, // Use the email icon
                              color: Colors.grey, // Change the color as needed
                            ),
                            SizedBox(width: 8.0), // Add some spacing
                            Text(
                              '${_hospitalDetails!['email']}',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),

                        buildRatingStars(double.parse(
                            _hospitalDetails!['rating'])),
                      ],
                    ),
                  ),
                ),
              ],
              if (_hospitalDetails != null) ...[
                // Doctor Card
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (DoctorInfo doctor in doctorList)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  if (doctor.image != null)
                                    ClipOval(
                                      child: Image.network(
                                        'https://metacare.co.in:3002${doctor.image}',
                                        width: 150.0,
                                        height: 150.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          ' ${doctor.name}',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8.0), // Add space
                                        Text(
                                          ' ${doctor.education}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        SizedBox(height: 8.0), // Add space
                                        Text(
                                          '${doctor.specialist}   ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        SizedBox(height: 8.0), // Add space
                                        Text(
                                          'Reg: ${doctor.registration_number}   ',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14.0,
                                          ),
                                        ),
                                        SizedBox(height: 8.0), // Add space
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Exp${doctor.experience} Y',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                            SizedBox(width: 8.0), // Add space
                                            Row(
                                              children: List.generate(
                                                5,
                                                    (index) {
                                                  final rating = double.tryParse(doctor.rating) ?? 0.0;
                                                  return Icon(
                                                    index < rating ? Icons.star : Icons.star_border,
                                                    color: Colors.yellow,
                                                    size: 16.0,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0), // Add space
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>HPage (
                                            doctorName: doctor.name,
                                            doctorId: doctor.id,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                          if (states.contains(MaterialState.hovered)) {
                                            return Colors.green.withOpacity(0.8);
                                          }
                                          return Colors.blue.shade300;
                                        },
                                      ),
                                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                                            (Set<MaterialState> states) {
                                          if (states.contains(MaterialState.hovered)) {
                                            return Colors.white;
                                          }
                                          return Colors.black;
                                        },
                                      ),
                                      elevation: MaterialStateProperty.all(8.0),
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(),
                                      ),
                                    ),
                                    child: Text(
                                      'Book Now',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.0), // Add space
                              Divider(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 6.0),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Treatments',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemCount: treatmentList.length,
                          itemBuilder: (context, index) {
                            final treatment = treatmentList[index];
                            return GestureDetector(
                              onTap: () async {
                                if (doctorList.isNotEmpty) {
                                  // Navigate to TdoctorPage
                                  final selectedTreatment = treatmentList[index];
                                  final selectedTreatmentId = selectedTreatment.id;

                                  SharedPreferences prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('selected_treatment_id', selectedTreatmentId);

                                  final storedTreatmentId = prefs.getString('selected_treatment_id');
                                  print('Selected Treatment ID: $selectedTreatmentId');
                                  print('Stored Treatment ID: $storedTreatmentId');

                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) {
                                      return TdoctorPage(
                                        treatmentId: selectedTreatmentId,
                                      );
                                    },
                                  ));
                                } else {
                                  // Display a dialog if no doctors are available and prevent navigation
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('No Doctors Available'),
                                        content: Text('There are no doctors available for this treatment.'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  Image.network(
                                    treatment.imageUrl,
                                    width: 48.0,
                                    height: 48.0,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    treatment.name,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )



                      ],
                    ),
                  ),
                )


              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBox(context),
    );
  }
  void _printStoredHospitalId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedHospitalId = prefs.getString(
        'hospital_id'); // Retrieve as string
    print('Stored Hospital ID in SharedPreferences: $storedHospitalId');
  }

  Future<String?> getHospitalIdFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? hospitalId = prefs.getString('hospital_id'); // Retrieve as string
    print('Retrieved Hospital ID from SharedPreferences: $hospitalId');
    return hospitalId;
  }

  Widget buildRatingStars(double rating) {
    List<Icon> stars = [];

    for (int i = 0; i < 5; i++) {
      if (i < rating) {
        stars.add(Icon(Icons.star, color: Colors.yellow));
      } else {
        stars.add(Icon(Icons.star_border, color: Colors.yellow));
      }
    }

    return Row(
      children: stars,
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
class TreatmentInfo {
  final String id;
  final String name;
  final String imageUrl;

  TreatmentInfo({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}


