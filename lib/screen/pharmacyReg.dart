import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PharmacyProfileForm extends StatefulWidget {
  @override
  _PharmacyProfileFormState createState() => _PharmacyProfileFormState();
}

class _PharmacyProfileFormState extends State<PharmacyProfileForm> {
  final TextEditingController pharmacyNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController registrationIdController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController openingTimeController = TextEditingController();
  final TextEditingController closingTimeController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController totalEmployeeController = TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController biographyController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();
  final TextEditingController panNumberController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController imageExtController = TextEditingController();
  XFile? _pickedImage;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final filePath = pickedImage.path;
      final fileName = filePath.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();

      if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
        setState(() {
          _pickedImage = pickedImage;
          imageController.text = filePath;
          imageExtController.text = fileExtension; // Set the image extension
        });
      } else {
        // If the extension is not jpg or jpeg, assume jpeg and update the extension
        setState(() {
          _pickedImage = pickedImage;
          imageController.text = filePath;
          imageExtController.text = 'jpeg';
        });
      }
    }
  }


  Future<void> _submitForm() async {
    final apiUrl = 'https://metacare.co.in:3002/api/pharmacy/pharmacyCreate';

    final Map<String, dynamic> requestData = {
      "user_type": "pharmacy",
      "pharmacy_name": pharmacyNameController.text,
      "email_id": emailController.text,
      "registration_id": registrationIdController.text,
      "address": addressController.text,
      "pin_code": pinCodeController.text,
      "opening_time": openingTimeController.text,
      "closing_time": closingTimeController.text,
      "contact_number": contactNumberController.text,
      "website": websiteController.text,
      "license_number": licenseNumberController.text,
      "total_employee": totalEmployeeController.text,
      "doctor_name": doctorNameController.text,
      "biography": biographyController.text,
      "gst_number": gstNumberController.text,
      "pan_number": panNumberController.text,
      "image": imageController.text,
      "imageExt": imageExtController.text,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      // Handle success response here
      print("Pharmacy created successfully.");
      print("Response Data: $responseData");
    } else {
      // Handle error response here
      print("Failed to create pharmacy.");
      print("Response Code: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacy Profile Form'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildInputField('Pharmacy Name', pharmacyNameController),
            SizedBox(height: 15.0),
            _buildInputField('Email', emailController),
            SizedBox(height: 15.0),
            _buildInputField('Registration ID', registrationIdController),
            SizedBox(height: 15.0),
            _buildInputField('Address', addressController),
            SizedBox(height: 15.0),
            _buildInputField('Pin Code', pinCodeController),
            SizedBox(height: 15.0),
            _buildInputField('Opening Time', openingTimeController),
            SizedBox(height: 15.0),
            _buildInputField('Closing Time', closingTimeController),
            SizedBox(height: 15.0),
            _buildInputField('Contact Number', contactNumberController),
            SizedBox(height: 15.0),
            _buildInputField('Website', websiteController),
            SizedBox(height: 15.0),
            _buildInputField('License Number', licenseNumberController),
            SizedBox(height: 15.0),
            _buildInputField('Total Employee', totalEmployeeController),
            SizedBox(height: 15.0),
            _buildInputField('Doctor Name', doctorNameController),
            SizedBox(height: 15.0),
            _buildInputField('Biography', biographyController),
            SizedBox(height: 15.0),
            _buildInputField('GST Number', gstNumberController),
            SizedBox(height: 15.0),
            _buildInputField('PAN Number', panNumberController),
            _buildImageUploadField('Image', imageController),
            _buildInputField('Image Extension', imageExtController),
            if (_pickedImage != null) Image.file(File(_pickedImage!.path)),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Image File',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
