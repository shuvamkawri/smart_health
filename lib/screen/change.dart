import 'package:flutter/material.dart';
import 'package:smarthealth/screen/reset.dart';

class UpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        color: Colors.lightBlue.shade50,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Navigate back
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.keyboard_arrow_left,
                      size: 32,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue.shade50,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Image.asset('assets/logo.png'),
                ),
              ),
              SizedBox(height: 38),
              Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8), // Add spacing for subtext
              Text(
                'Please enter your email address. You will receive a link to create a new password via email.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'New Password',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Implement your logic to change the password
                  // For demonstration purposes, let's assume the password change was successful
                  bool passwordChangedSuccessfully = true;

                  if (passwordChangedSuccessfully) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ResetDisplayPage()), // Navigate to the new page
                    );
                  }
                },
                child: Text('update Password'),
              ),


              SizedBox(height: 260),
            ],
          ),
        ),
      ),
    );
  }
}
