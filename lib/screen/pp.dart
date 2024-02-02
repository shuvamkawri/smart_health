import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/productscreen.dart';

import '../home_screen/hospital_dashboard_page.dart';

class PPage extends StatefulWidget {
  final String pharmacyName;
  final String pharmacyId;

  PPage({
    required this.pharmacyName,
    required this.pharmacyId,
  });

  @override
  _PPageState createState() => _PPageState();
}
class _PPageState extends State<PPage> {
  File? _selectedFile;
  String _medicineName = '';
  String _medicineQuantity = '';
  bool _fileUploaded = false; // Track whether the file is uploaded
  List<Map<String, String>> _medicineList = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload to Pharmacy'),
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
      body: ListView(
        children: [
          SizedBox(height: 20),
          Text(
            'Pharmacy Name: ${widget.pharmacyName}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2, // Number of columns in the grid
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              ElevatedButton.icon(
                onPressed: _fileUploaded ? null : _pickFile,
                icon: Icon(Icons.attach_file),
                label: Text(
                  _fileUploaded ? 'File Uploaded' : 'Pick a Prescription File',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.blue,
                ),
              ),
              if (_selectedFile != null)
                ElevatedButton(
                  onPressed: _uploadFile,
                  child: Text('Upload Prescription'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.blue,
                  ),
                ),
              ElevatedButton(
                onPressed: _addMedicine,
                child: Text('Add Medicine'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.blue,
                ),
              ),
            ],
          ),
          // ElevatedButton.icon(
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) =>
          //             ProductScreen(), // Replace with your desired screen
          //       ),
          //     );
          //   },
          //   icon: Icon(
          //     Icons.shopping_cart,
          //     color: Colors.blue,
          //   ),
          //   label: Text(
          //     'Order Details',
          //     style: TextStyle(
          //       color: Colors.blue,
          //       fontSize: 16,
          //     ),
          //   ),
          //   style: ElevatedButton.styleFrom(
          //     primary: Colors.white,
          //   ),
          // ),
        ],
      ),
    );
  }


  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
    );

    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    } else {
      setState(() {
        _selectedFile = null;
      });
    }
  }

  Future<void> _uploadFile() async {
    print('Starting file upload process...');

    if (_selectedFile == null) {
      print('No file selected.');
      _showSnackBar('No file selected.');
      return;
    }

    if (_fileUploaded) {
      _showSnackBar(
          'File is already uploaded.'); // Show a message if the file is already uploaded
      return;
    }

    print('File selected: ${_selectedFile!.path}');

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ??
        ''; // Get userId from SharedPreferences

    if (userId == null) {
      print('User ID not available.');
      _showSnackBar('User ID not available.');
      return;
    }

    print('User ID: $userId');
    print('Pharmacy ID: ${widget.pharmacyId}');

    final base64String = _getFileBase64String(_selectedFile!);
    if (base64String == null) {
      print('Error reading file.');
      _showSnackBar('Error reading file.');
      return;
    }

    print('Base64 String generated.');

    final medicineData = [
      {
        "medicine_name": _medicineName,
        "qu": _medicineQuantity,
      },
      // Add more medicines and quantities as needed
    ];

    final requestData = {
      "user_id": userId,
      "pharmacy_id": widget.pharmacyId,
      "prescription_id": userId, // Update this field accordingly
      "add_medicine": _medicineName,
      "quantity": _medicineQuantity,
      "medicine": _medicineList, // Pass the medicine data list here
      "image": base64String,
      "imageExt": _getFileExtension(_selectedFile!.path),
    };
    print('Request Data: $requestData'); // Print the requestData


    final apiUrl = 'https://metacare.co.in:3002/api/pharmacy-upload/userCreate';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 201) {
        print('File uploaded successfully');
        setState(() {
          _fileUploaded = true; // Update the flag to indicate successful upload
        });
        _showSuccessDialog();
      } else {
        print('File upload failed with status code: ${response.statusCode}');
        _showSnackBar(
            'File upload failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending the request: $e');
      _showSnackBar('Error sending the request: $e');
    }
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload Successful'),
          content: Text('The file has been uploaded successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id'); // Use the correct key
    print('User ID: $userId');
    return userId;
  }

  String? _getFileBase64String(File file) {
    try {
      final fileBytes = file.readAsBytesSync();
      return base64Encode(fileBytes);
    } catch (e) {
      return null;
    }
  }

  String _getFileExtension(String filePath) {
    return filePath
        .split('.')
        .last
        .toLowerCase();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _addMedicine() {
    List<Map<String, String>> newMedicines = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String medicineName = '';
        String medicineQuantity = '';

        return AlertDialog(
          title: Text('Add Medicine'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(labelText: 'Medicine Name'),
                onChanged: (value) {
                  setState(() {
                    medicineName = value;
                  });
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Quantity'),
                onChanged: (value) {
                  setState(() {
                    medicineQuantity = value;
                  });
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (medicineName.isNotEmpty && medicineQuantity.isNotEmpty) {
                  newMedicines.add({
                    "medicine_name": medicineName,
                    "qu": medicineQuantity,
                  });
                  setState(() {
                    _medicineList.addAll(newMedicines);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Finish'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}