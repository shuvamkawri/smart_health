import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/patients.dart';
import 'package:smarthealth/screen/userprescriptions.dart';
import '../home_screen/hospital_dashboard_page.dart';
import 'country.dart';
import 'dr_list.dart';
import 'new.dart';


class PrescriptionDoctorPage extends StatefulWidget {
  @override
  _PrescriptionDoctorPageState createState() => _PrescriptionDoctorPageState();
}

class _PrescriptionDoctorPageState extends State<PrescriptionDoctorPage> {
  static const String apiUrl = 'https://metacare.co.in:3002/api/prescription/myDoctorList';

  List<dynamic> doctors = [];
  Set<String> uniqueHospitalNames = Set(); // Create a Set to store unique hospital names
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDoctorList();
  }

  Future<void> fetchDoctorList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"user_id": userId}),
      );

      if (response.statusCode == 201) { // Change the status code check to 200
        final data = jsonDecode(response.body);
        setState(() {
          doctors = data['result'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch data';
          isLoading = false;
        });
        print('Failed to fetch data');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred';
        isLoading = false;
      });
      print('An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Prescriptions'),
      ),
      backgroundColor: Colors.blue.shade50,

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : doctors.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No doctor found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8), // Add some space between the texts
            GestureDetector(
              onTap: () {
                // Handle the action when the text is clicked
                // For example, navigate to the appointment screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewPage(),
                  ),
                );
              },
              child: Text(
                'Please take an appointment',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showNoDoctorsDialog(context);
              },
              child: Image.asset(
                'assets/empty.jpg',
                width: 400,
                height: 500,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          final doctorName = doctor['schedule']['doctor']['name'];
          final doctorId = doctor['schedule']['doctor']['_id'];
          final hospitalName =
          doctor['schedule']['hospital']['hospital_name'];

          // Check if the hospital name is unique
          if (!uniqueHospitalNames.contains(hospitalName)) {
            uniqueHospitalNames.add(hospitalName); // Add to the Set
          } else {
            return Container(); // Skip this doctor if hospital name is not unique
          }

          saveDoctorIdToSharedPreferences(doctorId);
          final doctorImage =
              'https://metacare.co.in:3002${doctor['schedule']['doctor']['image']}';

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PrescriptionListPage(
                        doctorId: doctorId,
                      ),
                ),
              );
            },
            child: Card(
              elevation: 2.0,
              margin: EdgeInsets.all(20.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(doctorImage),
                  radius: 30,
                ),
                title: Text(doctorName),
                subtitle: Text(hospitalName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        selectDoctor(doctorId);
                        await uploadPrescription(doctorId);
                      },
                      child: Image.asset(
                        'assets/upload.png',
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomBox(context),
    );
  }

  Future<void> uploadPrescription(String doctorId) async {
    try {
      print('Starting prescription upload...');

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ??
          ''; // Get userId from SharedPreferences

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'pdf'],
      );

      if (result == null || result.files.isEmpty) {
        print('No file selected, exiting the function.');
        return;
      }

      final file = result.files.first;
      if (file.path == null) {
        print('File path is null');
        return;
      }

      print('File path: ${file.path}');

      final fileToUpload = File(file.path!);
      final fileBytes = await fileToUpload.readAsBytes();
      final base64File = base64Encode(fileBytes);

      print('File converted to base64.');

      final requestBody = {
        "user_id": userId, // Send the userId obtained from SharedPreferences
        "doctor_id": doctorId, // Use the stored doctor ID
        "image": {
          "image": base64File,
          "imgExt": file.extension,
        }
      };

      final isPdf = file.extension == 'pdf';
      final isImage = file.extension == 'jpg' || file.extension == 'jpeg';

      print('User ID: $userId');

      print('Request Body: $requestBody');

      // Store the context in a local variable
      BuildContext localContext = context;

      showDialog(
        context: localContext, // Use the localContext here
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPdf)
                  Container(
                    height: 300,
                    child: PDFView(
                      filePath: file.path!,
                    ),
                  ),
                if (isImage)
                  Image.memory(
                    Uint8List.fromList(fileBytes),
                    fit: BoxFit.contain,
                  ),
                Text('Do you want to upload this file?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // You already have the userId in the requestBody
                  requestBody['user_id'] = userId;
                  requestBody['doctor_id'] = doctorId;

                  final response = await http.post(
                    Uri.parse(
                        'https://metacare.co.in:3002/api/prescription/create'),
                    headers: {
                      'accept': '*/*',
                      'Content-Type': 'application/json',
                    },
                    body: jsonEncode(requestBody),
                  );

                  if (response.statusCode == 201) {
                    _showMessageDialog(
                        localContext,
                        'File uploaded successfully.'); // Use localContext here
                  } else {
                    _showMessageDialog(
                        localContext,
                        'File upload failed. Please try again.'); // Use localContext here
                  }
                },
                child: Text('Upload'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error during file upload: $e');
    }
  }


  void _showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<void> selectDoctor(String doctorId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selected_doctor_id', doctorId);
    String? selectedDoctorId = prefs.getString('selected_doctor_id');
    print('Selected Doctor ID: $selectedDoctorId');
  }

  Future<void> saveDoctorIdToSharedPreferences(String doctorId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('doctor_id', doctorId);
    print('Doctor ID saved to SharedPreferences: $doctorId');
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

  void showNoDoctorsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('No Doctors Found'),
          content: Text('Please take an appointment first.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Add code here to navigate to the appointment page or take an appointment.
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  }