import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'bill.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PrescriptionDetailsPage extends StatefulWidget {
  final Prescription prescription;

  PrescriptionDetailsPage({required this.prescription});

  @override
  _PrescriptionDetailsPageState createState() =>
      _PrescriptionDetailsPageState();
}

class _PrescriptionDetailsPageState extends State<PrescriptionDetailsPage> {
  List<String> doctorPrescriptions = [];
  List<String> selectedImages = [];


  @override
  void initState() {
    super.initState();
    requestPermission(); // Request permission here
    fetchDoctorPrescriptions();
  }

  Future<void> fetchDoctorPrescriptions() async {
    try {
      final response = await http.post(
        Uri.parse('https://metacare.co.in:3002/api/prescription/details'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "doctor_id": widget.prescription.doctor['id'],
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as List<dynamic>;

        // Extract the doctor ID dynamically from the response
        final doctorId = data.isNotEmpty
            ? data[0]['doctor_id'] // Assuming doctor_id is the same for all prescriptions
            : widget.prescription.doctor['id'];

        // Extract images from the response
        final images = data
            .where((item) => item['doctor_id'] == doctorId)
            .map((item) => item['image'])
            .cast<String>()
            .toList();

        setState(() {
          doctorPrescriptions = images;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Widget to display PDF files using flutter_pdfview
  Future<File> downloadPdfFile(String pdfUrl) async {
    var fileName = pdfUrl
        .split('/')
        .last;
    try {
      var data = await http.get(Uri.parse(pdfUrl));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$fileName");
      File pdfFile = await file.writeAsBytes(bytes);
      print('PDF Downloaded: ${pdfFile.path}');
      return pdfFile;
    } catch (e) {
      print('Error downloading PDF: $e');
      throw Exception("Error downloading PDF file");
    }
  }

  Widget buildPdfWidgetFromUrl(String pdfUrl) {
    return FutureBuilder<File>(
      future: downloadPdfFile(pdfUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          File? pdfFile = snapshot.data;
          if (pdfFile != null) {
            return Container(
              height: 100, // Set a fixed height for the container
              child: PDFView(
                filePath: pdfFile.path,
                // PDFView properties...
              ),
            );
          } else {
            return Text('Error downloading PDF');
          }
        } else if (snapshot.hasError) {
          return Text('Error downloading PDF');
        } else {
          return CircularProgressIndicator(); // Loading indicator
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prescription Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display doctor, hospital, and prescription details
            // Text(
            //   'Doctor ID: ${widget.prescription.doctor['id'] ?? 'Unknown ID'}',
            //   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            // ),
            // Text(
            //   'Doctor: ${widget.prescription.doctor['name'] ??
            //       'Unknown Doctor'}',
            //   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            // ),
            SizedBox(height: 8.0),
            // Text(
            //   'Hospital: ${widget.prescription.hospital['hospital_name'] ??
            //       'Unknown Hospital'}',
            //   style: TextStyle(fontSize: 16.0),
            // ),
            SizedBox(height: 8.0),
            // Text(
            //   'Specialist: ${widget.prescription.doctor['specialist'] ??
            //       'Unknown Specialist'}',
            //   style: TextStyle(fontSize: 16.0),
            // ),
            SizedBox(height: 18.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(
                //   'Prescription',
                //   style: TextStyle(
                //     fontSize: 24.0,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.blue,
                //    // decoration: TextDecoration.underline,
                //     decorationColor: Colors.purpleAccent,
                //     decorationThickness: 2,
                //   ),
                // ),
              ],
            ),
            SizedBox(height: 16.0),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              alignment: WrapAlignment.center,
              children: [
                for (var prescriptionImage in doctorPrescriptions)
                  Container(
                    width: 400,
                    height: 300,
                    child: Center(
                      child: Column(
                        children: [
                          if (prescriptionImage.toLowerCase().endsWith('.pdf'))
                            buildPdfWidgetFromUrl(
                              'https://metacare.co.in:3002/$prescriptionImage',
                            )
                          else if (prescriptionImage.toLowerCase().startsWith('http'))
                            Image.network(
                              prescriptionImage,
                              width: 250,
                              height: 250,
                              fit: BoxFit.cover,
                            )
                          else
                            Image.network(
                              'https://metacare.co.in:3002/$prescriptionImage',
                              width: 250,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          if (prescriptionImage.toLowerCase().endsWith('.pdf'))
                            SizedBox(height: 8),
                          if (prescriptionImage.toLowerCase().endsWith('.pdf'))
                            ElevatedButton(
                              onPressed: () async {
                                await downloadAndSavePdf(
                                  'https://metacare.co.in:3002/$prescriptionImage',
                                );
                              },
                              child: Text('Download PDF'),
                            ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              // Add the delete functionality here
                              deletePrescription(prescriptionImage);
                            },
                            child: Image.asset(
                              'assets/delete.png', // Path to your delete icon asset
                              width: 24, // Adjust the width as needed
                              height: 24, // Adjust the height as needed
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (doctorPrescriptions.isEmpty)
                  Text('You have no prescription .'),
              ],
            )

          ],
        ),
      ),
    );
  }

  void requestPermission() async {
    await Permission.storage.request();
  }

  Future<void> downloadAndSavePdf(String pdfUrl) async {
    var fileName = pdfUrl
        .split('/')
        .last;
    try {
      var data = await http.get(Uri.parse(pdfUrl));
      var bytes = data.bodyBytes;

      // Request storage permission if not granted
      var status = await Permission.storage.request();
      if (status.isGranted) {
        // Get the Downloads directory
        Directory downloadsDirectory = Directory(
            '/storage/emulated/0/Download');
        File file = File("${downloadsDirectory.path}/$fileName");
        await file.writeAsBytes(bytes);
        print('PDF Downloaded and Saved: ${file.path}');

        // Show a confirmation message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded and saved.'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('Permission denied');
      }
    } catch (e) {
      print('Error downloading and saving PDF: $e');

      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading and saving PDF.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void deletePrescription(String prescriptionUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this prescription?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                // Delete the prescription
                deletePrescriptionFromServer(prescriptionUrl);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deletePrescriptionFromServer(String prescriptionUrl) async {
    try {
      final Uri deleteUri = Uri.parse('https://metacare.co.in:3002/api/prescription/delete');

      // Create a JSON request body
      final Map<String, dynamic> requestBody = {
        "image_url": prescriptionUrl,
      };

      // Print the prescription URL and image URL
      print('Deleting Prescription URL (DELETE API): $deleteUri');
      print('Image URL to be deleted: $prescriptionUrl');

      final response = await http.delete(
        deleteUri,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Remove the deleted prescription from the list
        setState(() {
          doctorPrescriptions.remove(prescriptionUrl);
        });
        print('Prescription deleted successfully');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

}
