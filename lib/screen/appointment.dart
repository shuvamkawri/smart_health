import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/patients.dart';
import '../home_screen/hospital_dashboard_page.dart';
import 'country.dart';
import 'dr_list.dart';
import 'my.dart'; // Make sure 'MyAppointmentsPage' is imported correctly

class AppointmentPage extends StatefulWidget {
  final List<String> selectedScheduleIds;
  AppointmentPage({required this.selectedScheduleIds});
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

DateTime? selectedDOB; // Initialize selectedDOB as null
String selectedGender = 'Male'; // Default value

class _AppointmentPageState extends State<AppointmentPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _commentController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _bpController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.lightBlue.shade50,
        appBar: AppBar(
          title: Text('Book Appointment'),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HospitalDashboardPage(loggedInEmail: '', cityName: '',),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: refreshPage,
            ),
          ],
        ),

        drawer: buildDrawer(context),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildPatientInfoForm(),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blue,
                            onPrimary: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              // borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Submit',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 16), // Add spacing between the buttons
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleReset,
                          style: ElevatedButton.styleFrom(
                            primary: Colors.blueGrey,
                            onPrimary: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              //  borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Reset',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),


                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        // Add the bottomNavigationBar here
        bottomNavigationBar: _buildBottomBox(context),
      ),
    );
  }


  Widget buildPatientInfoForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Information',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          _buildInputField('Patient Name', _nameController, (value) {
            // Handle onChanged for patient name
          }),
          SizedBox(height: 10),
          _buildInputField('Patient Email', _emailController, (value) {
            // Handle onChanged for patient email
          }),
          SizedBox(height: 10),
          _buildInputField('Patient Phone Number', _phoneController, (value) {
            // Handle onChanged for phone number
          }),
          SizedBox(height: 10),
          _buildInputField('Patient Address', _addressController, (value) {
            // Handle onChanged for address
          }),
          SizedBox(height: 10),
          _buildInputField('Treatment Comment', _commentController, (value) {
            // Handle onChanged for treatment comment
          }),
          SizedBox(height: 10),
          _buildInputField('Height(cm)', _heightController, (value) {
            // Handle onChanged for height
          }),
          SizedBox(height: 10),
          _buildInputField('Weight(kg)', _weightController, (value) {
            // Handle onChanged for weight
          }),
          SizedBox(height: 10),
          _buildInputField('Blood Pressure(mmHg)', _bpController, (value) {
            // Handle onChanged for blood pressure
          }),
          SizedBox(height: 10),
          _buildInputField('Age', _ageController, (value) {
            // Handle onChanged for age
          }),
          SizedBox(height: 10),
          _buildDatePickerField(), // Date of Birth field
          SizedBox(height: 10),
          _buildGenderDropdown(), // Gender dropdown
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      Function(String) onChanged) {
    TextInputType? keyboardType; // Make the variable nullable

    if (label == 'Phone Number') {
      keyboardType =
          TextInputType.phone; // Use phone type input for phone number
    } else if (label == 'Email') {
      keyboardType =
          TextInputType.emailAddress; // Use email type input for email
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      child: label == 'Date of Birth'
          ? _buildDatePickerField()
          : label == 'Gender'
          ? _buildGenderDropdown()
          : TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType ?? TextInputType.text,
        // Provide a default value (e.g., TextInputType.text)
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }


  Widget _buildDatePickerField() {
    return Row(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              ).then((pickedDate) {
                if (pickedDate != null) {
                  setState(() {
                    selectedDOB = pickedDate;
                  });
                }
              });
            },
            child: AbsorbPointer(
              child: TextFormField(
                controller: TextEditingController(
                  text: selectedDOB != null ? "${selectedDOB!.toLocal()}".split(
                      ' ')[0] : '',
                ),
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 35.0), // Adjust the margin as needed
          child: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              ).then((pickedDate) {
                if (pickedDate != null) {
                  setState(() {
                    selectedDOB = pickedDate;
                  });
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      onChanged: (newValue) {
        setState(() {
          selectedGender = newValue!;
        });
      },
      items: ['Male', 'Female', 'Others'].map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Gender',
        border: InputBorder.none,
      ),
    );
  }

  void _handleSubmit() async {
    if (isFormEmpty()) {
      showValidationErrorDialog('Please fill in all the required fields');
    } else {
      bool isPhoneValid = RegExp(r'^[0-9]{10,20}$').hasMatch(_phoneController.text);

      bool isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(
          _emailController.text);

      if (!isPhoneValid) {
        showValidationErrorDialog('Please enter a valid phone number');
      } else if (!isEmailValid) {
        showValidationErrorDialog('Please enter a valid email address');
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String userId = prefs.getString('user_id') ?? '';
        String scheduleId = prefs.getString('selectedScheduleId') ?? '';

        final apiUrl = 'https://metacare.co.in:3002/api/doctor-apointment/create';

        final Map<String, dynamic> requestBody = {
          "user_id": userId,
          "schedule": scheduleId,
          "patient_name": _nameController.text,
          "patient_email": _emailController.text,
          "patient_phone_number": _phoneController.text,
          "patient_address": _addressController.text,
          "treatment_comment": _commentController.text,
          "status": true,
          "height": _heightController.text,
          "weight": _weightController.text,
          "bp": _bpController.text,
          "age": _ageController.text,
          "DOB": selectedDOB != null ? selectedDOB!.toIso8601String() : null,
          "gender": selectedGender,
        };

        print('Request Body: $requestBody');

        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );

        if (response.statusCode == 201) {
          final jsonResponse = json.decode(response.body);

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text(jsonResponse['message']),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyAppointmentsPage(),
                        ),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text(
                    'An error occurred while processing your request.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  Widget buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Appointments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          ListTile(
            title: Text('My Appointments'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyAppointmentsPage()),
              );
            },
            leading: Icon(Icons.calendar_today, color: Colors.blue),
            tileColor: Colors.lightGreen.shade100,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HospitalDashboardPage(loggedInEmail: '', cityName: ''),
                ),
              );
            },
            leading: Icon(Icons.home, color: Colors.blue),
            tileColor: Colors.lightGreen.shade100,
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
    );
  }

  bool isFormEmpty() {
    return _nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _commentController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _bpController.text.isEmpty ||
        _ageController.text.isEmpty ||
        selectedDOB == null;
  }

  void refreshPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => AppointmentPage(selectedScheduleIds: [],),
      ),
    );
  }

  void _handleReset() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _addressController.clear();
      _commentController.clear();
      _heightController.clear();
      _weightController.clear();
      _bpController.clear();
      _ageController.clear();
      selectedDOB = null;
      selectedGender = 'Male'; // Reset gender to the default value
    });
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
              child: Image.asset(
                  'assets/hospital-bed.png', width: 40, height: 48),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the MyAppointmentsPage when the time icon is clicked
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => CountryListPage()));
              },
              child: Image.asset(
                  'assets/google-maps.png', width: 34, height: 44),
            ),
          ],
        ),
      ),
    );
  }

  void showValidationErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
