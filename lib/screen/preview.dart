import 'package:flutter/material.dart';

class PreviewPage extends StatelessWidget {
  final String hospitalName;
  final String treatmentName;
  final String subTreatmentName;
  final String doctorName;
  final String timeSlot;
  final String patientName;
  final String patientEmail;
  final String patientPhoneNumber;
  final String patientAddress;
  final String treatmentComment;

  PreviewPage({
    required this.hospitalName,
    required this.treatmentName,
    required this.subTreatmentName,
    required this.doctorName,
    required this.timeSlot,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhoneNumber,
    required this.patientAddress,
    required this.treatmentComment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Display the submitted data in a readable format
            Text('Hospital: $hospitalName'),
            Text('Treatment: $treatmentName'),
            Text('Sub Treatment: $subTreatmentName'),
            Text('Doctor: $doctorName'),
            Text('Time Slot: $timeSlot'),
            Text('Patient Name: $patientName'),
            Text('Patient Email: $patientEmail'),
            Text('Patient Phone Number: $patientPhoneNumber'),
            Text('Patient Address: $patientAddress'),
            Text('Treatment Comment: $treatmentComment'),

            // Add a button to allow users to edit the form
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous page (EditPage)
              },
              child: Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
}
