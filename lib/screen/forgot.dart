import 'package:flutter/material.dart';
import 'package:smarthealth/api/api_service.dart';

import 'otp.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  String _enteredEmail = '';

  void _onOTPVerify(bool success, String message) {
    if (success) {
      _showSuccessDialog(message);
    } else {
      _showErrorDialog(message);
    }
  }

  void _onGenerateOTP(String email) async {
    print('Generating OTP for Email: $email');

    try {
      final response = await ApiService.generateOTPByEmail(email);

      if (response.containsKey('success') && response['success']) {
        String otp = response['otp'];
        _showSuccessDialog(response['message']);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              emailOTP: otp,
              onVerify: _onOTPVerify, // Use the correct function name
              email: email,
              otp: otp,
            ),
          ),
        );
      } else {
        _showErrorDialog(
            response.containsKey('message') ? response['message'] : 'OTP generation failed.'
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to generate OTP. Please try again later.');
    }
  }






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
                'Forgot Password',
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
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_emailController.text.isNotEmpty) {
                    _enteredEmail = _emailController.text;
                    _onGenerateOTP(_enteredEmail);
                  } else {
                    _showErrorDialog('Please enter your email address.');
                  }
                },
                child: Text('Verify email'),
              ),



              SizedBox(height: 260),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
