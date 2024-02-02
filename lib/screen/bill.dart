
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:smarthealth/screen/prescrption_details.dart';


class Prescription {
  final String id;
  final String date;
  final Map<String, dynamic> hospital;
  final Map<String, dynamic> doctor;
  bool archived; // Add this property

  Prescription({
    required this.id,
    required this.date,
    required this.hospital,
    required this.doctor,
    this.archived = false, // Set default value to false
  });
}
class PrescriptionPage extends StatefulWidget {
  @override
  _PrescriptionPageState createState() => _PrescriptionPageState();
}

class _PrescriptionPageState extends State<PrescriptionPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  String doctorId = '';
  int? prescriptionIndex; // Declare it here



  List<Prescription> _prescriptions = [
  ]; // Initialize with your list of prescriptions

  String currentDoctorId = ''; // Store the current doctor's ID


  GlobalKey<State> _dialogKey = GlobalKey<State>();


  void handleSearch(String value) {
    setState(() {
      _searchKeyword = value;
      // Update the UI or fetch data based on the search keyword
    });
  }


  @override
  void initState() {
    super.initState();
    _dialogKey = GlobalKey<State>(); // Initialize _dialogKey here
    fetchPrescriptions(); // Fetch prescriptions using the currentDoctorId
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prescriptions.isNotEmpty) {
      doctorId = _prescriptions[0].doctor['id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.lightBlue.shade50,
            ),

            child: Stack(
              children: [
                Positioned(
                  left: 20.0,
                  right: 20.0,
                  top: 26.0,
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.left,
                    onChanged: handleSearch,
                    onSubmitted: handleSearch,
                    decoration: InputDecoration(
                      hintText: 'Search doctor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(10.0),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.keyboard_arrow_left,
                          color: Colors.blue,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.notifications),
                        onPressed: () {
                          _searchController.clear();
                          _searchKeyword = '';
                          // Call the method to fetch doctor data
                        },
                      ),
                    ),
                  ),
                ),
                // Display prescriptions in a ListView
                Positioned(
                  top: 70.0,
                  // Adjust the position as needed
                  left: 0.0,
                  right: 0.0,
                  bottom: 0.0,
                  child: ListView.builder(
                    itemCount: _prescriptions.length,
                    itemBuilder: (context, index) {
                      final prescription = _prescriptions[index];
                      return Dismissible(
                        key: Key(prescription.id),
                        // Use a unique key for each prescription
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.archive,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await _showArchiveDialog();
                        },
                        child: Card(
                          elevation: 2.0,
                          margin: EdgeInsets.symmetric(vertical: 6.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://metacare.co.in:3002${prescription
                                    .doctor['image']}',
                              ),
                            ),
                            title: Text(
                              'Doctor: ${prescription.doctor['name'] ??
                                  'Unknown Doctor'}',
                              style: TextStyle(
                                color: Colors.red, // Set text color to blue
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   'Hospital: ${prescription
                                //       .hospital['hospital_name'] ??
                                //       'Unknown Hospital'}',
                                //   style: TextStyle(color: Colors.black),
                                //   maxLines: 1,
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                                SizedBox(height: 4.0),
                                Text(
                                  'Date: ${formatDate(prescription.date)}',
                                  style: TextStyle(color: Colors.blue),
                                )
                              ],
                            ),
                            contentPadding: EdgeInsets.all(16.0),
                            onTap: () {
                              // Handle tapping on the list tile
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Image.asset('assets/upload.png'),
                                  onPressed: () {
                                    _showUploadDialog(prescription);
                                  },
                                ),
                                IconButton(
                                  icon: Image.asset('assets/view.png'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PrescriptionDetailsPage(
                                                prescription: prescription),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),


                Positioned(
                  left: 14.0,
                  right: 14.0,
                  bottom: 14.0,
                  // Adjust the position to leave space for the white bar box
                  child: Container(
                    height: 48.0,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Code to execute when the image is tapped
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => PCreateScreen()), // PCreateScreen is the name of the screen you want to navigate to
                            // );
                          },
                          child: Image.asset(
                            'assets/camera.png',
                            width: 44.0,
                            height: 44.0,
                          ),
                        ),

                        IconButton(
                          icon: Image.asset('assets/archieve.png'),
                          onPressed: () {
                            if (prescriptionIndex != null) { // Check if prescriptionIndex is set
                              _archivePrescription(prescriptionIndex!);
                            }
                          },
                        ),


                        IconButton(
                          icon: Image.asset('assets/scan.png'),
                          onPressed: _handleImageScan, // Call the scan method
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Future<void> fetchPrescriptions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? ''; // Get user_id from shared preferences
      String doctorId = prefs.getString('selected_doctor_id') ?? ''; // Get doctor_id from shared preferences

      final Map<String, String> requestBody = {
        'user_id': userId,
        'doctor_id': doctorId, // Add the doctor_id to the request body
      };

      print('User ID: $userId'); // Print the user_id
      print('Doctor ID: $doctorId'); // Print the doctor_id
      print('Request Body: $requestBody'); // Print the request body

      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/prescription/list'),
        headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody), // Encode the request body as JSON
      );

      if (response.statusCode == 201) { // Assuming a successful response has status code 200
        final data = jsonDecode(response.body);
        final prescriptionList = data['details'] as List;

        setState(() {
          _prescriptions = prescriptionList
              .map((item) => Prescription(
            id: item['_id'],
            date: item['created_at'],
            hospital: item['doctor_id'] != null
                ? _mapDoctor(item['doctor_id'])
                : _mapHospital({}),
            doctor: item['doctor_id'] != null
                ? _mapDoctor(item['doctor_id'])
                : _mapHospital({}),
          ))
              .toList();
        });
      } else {
        // Handle specific HTTP error statuses
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle generic error
      print('Error: $e');
    }
  }


  Map<String, dynamic> _mapDoctor(Map<String, dynamic> doctorData) {
    return {
      'id': doctorData['_id'],
      'name': doctorData['name'],
      'specialist': doctorData['specialist'],
      'image': doctorData['image'],
    };
  }
  Map<String, dynamic> _mapHospital(Map<String, dynamic> hospitalData) {
    return {
      'hospital_name': hospitalData['hospital_name'], // Change 'hospital_name' to the actual key in the hospital data
    };
  }


  Future<void> _handleFileUpload(Prescription prescription) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
    );

    if (result == null || result.files.isEmpty) {
      return; // No file selected, exit the function
    }

    PlatformFile file = result.files.first;

    if (file.path == null) {
      print('File path is null');
      return;
    }

    try {
      File fileToUpload = File(file.path!);
      Uint8List fileBytes = await fileToUpload.readAsBytes();
      String base64File = base64Encode(fileBytes);

      final requestBody = {
        "user_id": "", // Initialize with empty string
        "doctor_id": prescription.doctor['id'], // Use the stored doctor ID
        "image": {
          "image": base64File,
          "imgExt": file.extension,
        }
      };

      bool isPdf = file.extension == 'pdf';
      bool isImage = file.extension == 'jpg' || file.extension == 'jpeg';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('user_id') ?? '';
      String doctorId = prescription.doctor['id'];

      showDialog(
        context: context,
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
                    _showMessageDialog(context, 'File uploaded successfully.');
                  } else {
                    _showMessageDialog(
                        context, 'File upload failed. Please try again.');
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


  void _showUploadDialog(Prescription prescription) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _handleFileUpload(
                          prescription); // Pass the prescription object directly
                    },
                    child: Text('Upload File'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showMessageDialog(BuildContext context, String message) {
    showDialog(
      context: _dialogKey.currentContext!,
      builder: (context) {
        return AlertDialog(
          title: Text('Upload Status'),
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

  void _archivePrescription(int prescriptionIndex) async {
    if (prescriptionIndex >= 0 && prescriptionIndex < _prescriptions.length) {
      final prescriptionId = _prescriptions[prescriptionIndex].id;
      final apiUrl =
          'https://metacare.co.in:3002/api/prescription/ArchiveUpdate/$prescriptionId';

      final response = await http.post(apiUrl as Uri, headers: {'accept': '*/*'});

      if (response.statusCode == 201) {
        setState(() {
          _prescriptions[prescriptionIndex].archived = true;
        });
        print('Prescription archived successfully.');
      } else {
        print('Failed to archive prescription. Status code: ${response.statusCode}');
      }
    }
  }



  Future<bool> _showArchiveDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Archive Prescription'),
          content: Text('Are you sure you want to archive this prescription?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Archive'),
            ),
          ],
        );
      },
    );

    return result ?? false; // Return false if result is null
  }






  Future<void> _handleImageScan() async {
    final ImagePicker _picker = ImagePicker();

    // Open the camera to scan an image
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image != null) {
      // Now you can use the 'image' object to access information about the scanned file
      // For example, you can get the file path using 'image.path'
      // You can then process or upload the scanned image using an HTTP request

      // Replace this with your actual processing or upload logic
      // Example HTTP upload request:
      // final response = await http.post(
      //   Uri.parse('your_upload_endpoint'),
      //   headers: {'content-type': 'multipart/form-data'},
      //   body: {'file': await MultipartFile.fromPath('file', image.path)},
      // );

      // Handle the response or errors accordingly
    }
  }

}

// Create a function to format the date
String formatDate(String? date) {
  if (date == null) {
    return 'Unknown Date';
  }
  try {
    final formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    return formattedDate;
  } catch (e) {
    return 'Unknown Date';
  }
}





