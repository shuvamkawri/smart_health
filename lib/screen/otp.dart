import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:smarthealth/screen/password_change_form.dart';



class OTPVerificationPage extends StatefulWidget {
  final String emailOTP;
  final Function(bool, String) onVerify;
  final String email;
  final String otp;

  OTPVerificationPage({
    required this.emailOTP,
    required this.onVerify,
    required this.email,
    required this.otp,
  });

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  List<TextEditingController> otpControllers =
  List.generate(4, (_) => TextEditingController());
  String verificationMessage = '';

  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    final url = Uri.parse('https://metacare.co.in:3002/api/user/verify-otp');
    final headers = {'Content-Type': 'application/json'};
    final requestBody = {'email': email, 'otp': otp};
    final requestBodyJson = jsonEncode(requestBody);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: requestBodyJson,
      );

      print('Verify OTP Request: email = $email, otp = $otp');
      print('Verify OTP Request URL: $url');
      print('Verify OTP Request Headers: $headers');
      print('Verify OTP Request Body: $requestBodyJson');
      print('Verify OTP Response Status Code: ${response.statusCode}');
      print('Verify OTP Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);

        if (responseBody.containsKey('success')) {
          if (responseBody['success']) {
            print('OTP verification successful.');
            return responseBody;
          } else {
            throw Exception('Invalid OTP');
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  void verifyOTPAndHandleResponse() async {
    String enteredOTP = otpControllers.map((controller) => controller.text).join();
    String enteredEmail = widget.email; // Get the entered email from the widget

    print('Entered Email: $enteredEmail'); // Print entered email
    print('Entered OTP: $enteredOTP'); // Print entered OTP

    try {
      final verificationResponse = await verifyOTP(widget.email, enteredOTP);

      if (verificationResponse.containsKey('success')) {
        if (verificationResponse['success']) {
          // OTP verification successful, navigate to the password change form
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordChangeForm(email: enteredEmail),
            ),
          );


        } else {
          String errorMessage = verificationResponse.containsKey('message')
              ? verificationResponse['message']
              : 'OTP verification failed.';
          widget.onVerify(false, errorMessage);
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      widget.onVerify(false, 'Failed to verify OTP. Please try again later.');
    }
  }


  void resendOTP() {
    // Implement your OTP resend logic here
    // For example: Send OTP to the user's email
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        color: Colors.lightBlue.shade50,
        height: MediaQuery.of(context).size.height,
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
              SizedBox(height: 20),
              Text(
                'Email Verification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Enter OTP',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 4; i++)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue),
                      ),
                      child: TextField(
                        maxLength: 1,
                        controller: otpControllers[i],
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (i < 3) {
                              FocusScope.of(context).nextFocus();
                            } else {
                              FocusScope.of(context).unfocus(); // Dismiss keyboard after last digit
                            }
                          }
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (otpControllers.every((controller) =>
                  controller.text.isNotEmpty)) {
                    verifyOTPAndHandleResponse();
                  } else {
                    // Handle empty fields
                  }
                },
                child: Text('Verify OTP'),
              ),
              SizedBox(height: 10),
              Text(verificationMessage),
              TextButton(
                onPressed: resendOTP,
                child: Text(
                  'Resend OTP ?',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
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
                Navigator.pop(context);
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
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
