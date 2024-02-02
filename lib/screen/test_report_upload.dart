import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../home_screen/hospital_dashboard_page.dart';

class TestReportUploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upolad Test Report'),
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
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            await _uploadTestReport(context);
          },
          icon: Icon(Icons.upload_file),
          label: Text(
            'Choose Test Report',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
          ),
        ),
      ),
    );
  }

  Future<void> _uploadTestReport(BuildContext context) async {
    print('Start of _uploadTestReport');

    // Retrieve user_id and pathology_id from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    String? pathologyId = prefs.getString('pathologyId');
    print('User ID from SharedPreferences: $userId');
    print('Pathology ID from SharedPreferences: $pathologyId');

    if (userId == null || pathologyId == null) {
      // Handle the case where user_id or pathology_id is not available
      print('User ID or Pathology ID is missing. Showing error dialog.');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Missing Information'),
            content: Text(
                'User ID or Pathology ID is missing. Please check your settings.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    print('File picked: ${result != null ? result.files.single.name : 'None'}');

    if (result != null) {
      String filePath = result.files.single.path!;
      print('File path: $filePath');

      // Show a confirmation dialog with the selected file name and image
      bool confirmUpload = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirm Upload'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Do you want to upload the following file?\n\n${result.files.single.name}'),
                SizedBox(height: 16.0),
                Image.file(
                  File(filePath),
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Proceed with the upload
                },
                child: Text('Upload'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Cancel the upload
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );

      if (confirmUpload == true) {
        // Read the file as bytes and convert to base64
        List<int> bytes = await File(filePath).readAsBytes();
        String base64Image = base64Encode(bytes);
        print('File converted to base64');

        // Send a POST request to the API
        final response = await http.post(
          Uri.parse('https://metacare.co.in:3002/api/pathology/reportUpload'),
          headers: <String, String>{
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            "user_id": userId,
            "pathology_id": pathologyId,
            "status": true,
            "report_image": base64Image,
            "imageExt": "jpg",
          }),
        );
        print('POST request sent');

        if (response.statusCode == 201) {
          // Successfully uploaded
          final responseData = json.decode(response.body);
          final reportImage = responseData['pathology_data']['report_image'];
          print(
              'Test report uploaded successfully! Report image: $reportImage');
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Test Report Upload'),
                content: Text('Test report uploaded successfully!'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        } else {
          // Handle errors here
          print('Failed to upload test report. Status code: ${response
              .statusCode}');
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Test Report Upload Failed'),
                content: Text(
                    'Failed to upload test report. Please try again.'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        print('Upload canceled.');
      }
    } else {
      print('No file picked. Aborting upload.');
    }

    print('End of _uploadTestReport');
  }
}
