import 'package:flutter/material.dart';

class PatientInfoForm extends StatefulWidget {
  @override
  _PatientInfoFormState createState() => _PatientInfoFormState();
}

class _PatientInfoFormState extends State<PatientInfoForm> {
  // Define TextEditingController for each field to manage input
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController bloodGroupController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              TextFormField(
                controller: bloodGroupController,
                decoration: InputDecoration(labelText: 'Blood Group'),
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number (verified)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Save the patient information and perform any action you need.
                  // For example, you can send the data to a server or update a local database.
                  print('Patient Information Saved:');
                  print('Name: ${nameController.text}');
                  print('Age: ${ageController.text}');
                  print('Blood Group: ${bloodGroupController.text}');
                  print('Email: ${emailController.text}');
                  print('Address: ${addressController.text}');
                  print('Phone Number: ${phoneNumberController.text}');
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
