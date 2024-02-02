import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/forgot.dart';
import 'package:smarthealth/screen/pharmacyReg.dart';
import 'package:smarthealth/screen/pharmacyinterface.dart';

import 'package:smarthealth/screen/registration.dart';
import '../home_screen/hospital_dashboard_page.dart';
import 'country.dart';
import 'location.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String loggedInEmail = ''; // Declare loggedInEmail here
  bool _isPasswordVisible = false;
  String loggedInUserId = '';
  @override
  void initState() {
    super.initState();
    // checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final loggedInEmail = prefs.getString('loggedInEmail') ?? '';

    if (isLoggedIn) {
      // If the user is already logged in, navigate to HospitalDashboardPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HospitalDashboardPage(loggedInEmail: loggedInEmail, cityName: '',),
        ),
      );
    }
  }

  bool _isValidEmail() {
    final email = _emailController.text;
    final emailRegex =
    RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  // void _performSignIn() async {
  //   final bool isSignInSuccessful = await _signInUser();
  //
  //   if (isSignInSuccessful) {
  //     final String loggedInEmail = _emailController.text;
  //     final String loggedInUserId = await _getUserIdFromApiResponse(); // Retrieve the user ID from your API response
  //
  //     // Store the login information in shared preferences
  //     await _storeUserLoginInfo(loggedInEmail, loggedInUserId);
  //
  //     // Navigate to HospitalDashboardPage after successful sign-in
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) =>
  //             HospitalDashboardPage(loggedInEmail: loggedInEmail),
  //       ),
  //     );
  //   }
  // }
  void _performSignIn() async {
    final bool isSignInSuccessful = await _signInUser();

    if (isSignInSuccessful) {
      // Print the logged-in email from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final loggedInEmail = prefs.getString('loggedInEmail') ?? ''; // Retrieve the email from shared preferences
      print('Logged in email: $loggedInEmail');

      // Retrieve the user ID from the API response
      final String loggedInUserId = await _getUserIdFromApiResponse();

      // Store user login info and navigate to HospitalDashboardPage
      await _storeUserLoginInfo(loggedInEmail, loggedInUserId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              HospitalDashboardPage(loggedInEmail: loggedInEmail, cityName: '',),
        ),
      );
    }
  }


  Future<void> _storeProfileUpdatedStatus(bool isProfileUpdated) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isProfileUpdated', isProfileUpdated);

    print(
        'Profile updated status stored in shared preferences: $isProfileUpdated');
  }


  Future<String> _getUserIdFromApiResponse() async {
    final apiUrl = 'http://192.46.212.177:3025/api/user/login';

    final Map<String, dynamic> requestData = {
      "email_id": _emailController.text,
      "password": _passwordController.text,
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

      if (responseData['details'] != null &&
          responseData['details']['id'] != null) {
        final String userId = responseData['details']['id'];
        return userId;
      } else {
        throw Exception('User ID not found in API response');
      }
    } else {
      throw Exception('API request failed');
    }
  }



  Future<bool> _signInUser() async {
    final apiUrl = 'https://metacare.co.in:3002/api/user/login';

    final Map<String, dynamic> requestData = {
      "email_id": _emailController.text,
      "password": _passwordController.text,
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
      print("API Response Data: $responseData");

      if (responseData['errorCode'] != 200) {
        // Sign-in failed, show an error message
        if (responseData['errorMessage'] != null) {
          // Display the error message from the server
          _showSignInErrorDialog(responseData['errorMessage']);
        } else {
          // If there's no specific error message from the server, show a generic message
          _showSignInErrorDialog('Invalid email or password. Please try again.');
        }
        return false;
      } else {
        if (responseData['details'] != null) {
          final String userType = responseData['details']['user_type'];
          if (userType == 'Pharmacy') {
            if (responseData['details']['profile_updated'] == false) {
              // Navigate to PharmacyProfileForm if profile_updated is false
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PharmacyProfileForm()));
            } else {
              // Navigate to hospital dashboard page if profile_updated is true
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PharmacyInterface(
                    pharmacyName: '', // Add the necessary values
                    email: loggedInEmail, // Pass the email parameter
                    address: '',
                    licenseNumber: '',
                    gstNumber: '',
                    panNumber: '',
                  ),
                ),
              );
            }
          } else if (userType == 'User') {
            // Navigate to hospital dashboard page for "user" type
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CountryListPage()));
          }

          if (responseData['details']['token'] != null) {
            final String token = responseData['details']['token'];
            final String userId = responseData['details']['id'];

            // Store complete response in shared preferences
            await _storeUserResponse(responseData);

            await _storeUserLoginInfo(loggedInEmail, loggedInUserId);


            print("Sign-in successful. Token: $token");
            print("User ID: $userId"); // Print the user ID
            return true;
          } else {
            // Handle the case when the API response does not contain the expected data
            return false;
          }
        } else {
          // Handle the case when the API response does not contain the expected data
          return false;
        }
      }
    } else {
      // HTTP request failed, show an error message
      _showSignInErrorDialog('An error occurred. Please try again later.');
      return false;
    }
  }

  // Future<void> _storeUserResponse(Map<String, dynamic> responseData) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // Serialize the responseData map to JSON
  //   final String responseJson = jsonEncode(responseData);
  //   prefs.setString('user_response', responseJson);
  //
  //   // Store the email_id separately in shared preferences
  //   final String emailId = responseData['details']['email_id'] ?? '';
  //   prefs.setString('email_id', emailId);
  //
  //   print('Data stored in shared preferences: $responseJson');
  //   print('Email ID stored: $emailId');
  // }
  Future<void> _storeUserResponse(Map<String, dynamic> responseData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Serialize the responseData map to JSON
    final String responseJson = jsonEncode(responseData);
    prefs.setString('user_response', responseJson);

    // Store the email_id separately in shared preferences
    final String emailId = responseData['details']['email_id'] ?? '';
    final String userId = responseData['details']['id'] ?? ''; // Add this line to store the user ID
    prefs.setString('email_id', emailId);
    prefs.setString('user_id', userId); // Store the user ID

    print('Data stored in shared preferences: $responseJson');
    print('Email ID stored: $emailId');
    print('User ID stored: $userId'); // Print the user ID
  }





  Future<void> _storeUserLoginInfo(String userEmail, String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setString('loggedInEmail', userEmail);
    prefs.setString('loggedInUserId', userId); // Store the user ID as well

    print('User login info stored in shared preferences');
    print('Logged in email: $userEmail'); // Print the logged-in email
    print('User IIIIID: $userId'); // Print the user ID
  }

  void _showSignInErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign-In Failed'),
          content: Text(errorMessage),
          actions: [
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


  Widget _buildSignInLink() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                'Already have an account?',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistrationPage()),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text(
                'Sign up >',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0), // Remove padding
          child: Stack(
            children: [
              Container( // Use a container to fill the entire screen
                width: double.infinity, // Fill the width of the screen
                height: double.infinity, // Fill the height of the screen
                color: Colors.white, // Set background color
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 16),
                      Center(
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.6,
                          height: MediaQuery
                              .of(context)
                              .size
                              .width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Image.asset('assets/logo.png'),
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.05),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          // Add an icon to the left of the input field
                          border: OutlineInputBorder(), // Add a border around the input field
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.blue),
                          // Customize icon color
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons
                                  .visibility_off,
                              color: Colors.blue, // Customize icon color
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey), // Customize border color
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blue), // Customize border color
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12.0,
                              horizontal: 16.0),
                          // Adjust content padding
                          labelStyle: TextStyle(color: Colors
                              .blue), // Customize label color
                        ),
                        obscureText: !_isPasswordVisible,
                      ),


                      // "Forgot Password" text button
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      ElevatedButton(
                        onPressed: _performSignIn,
                        // This should trigger the _performSignIn function
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                          // Set the background color
                          onPrimary: Colors.white,
                          // Set the text color
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          // Adjust padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8.0), // Apply rounded corners
                          ),
                          textStyle: TextStyle(
                            fontSize: 15.0, // Customize font size
                          ),
                        ),
                        child: Text('Sign In'),
                      ),


                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      // _buildSocialIcons(),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                      _buildSignInLink(),
                      SizedBox(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
