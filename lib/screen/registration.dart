import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/sign.dart';

import '../home_screen/hospital_dashboard_page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? _selectedUserType; // Declare this variable for the selected user type
  List<String> _userTypes = ['Pharmacy', 'User', 'Pathology','Hospital']; // Provide your list of user types

  // final TextEditingController _mobileNumberController = TextEditingController();
  TextEditingController _otpController = TextEditingController(); // Declare _otpController at the class level
  @override
  void initState() {
    super.initState();
    //checkLoginStatus();
  }

  // Future<void> checkLoginStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  //   final loggedInEmail = prefs.getString('loggedInEmail') ?? '';
  //
  //   if (isLoggedIn) {
  //     // If the user is already logged in, navigate to HospitalDashboardPage
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) =>
  //             HospitalDashboardPage(loggedInEmail: loggedInEmail),
  //       ),
  //     );
  //   }
  // }
  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  String? _mobileNumberErrorMessage;

  bool _isPasswordVisible = false;
  String _selectedCountryCode = '+1'; // Example default country code
  // List<String> _countryCodes = [
  //   '+1',
  //   '+44',
  //   '+61',
  //   '+81',
  //   '+86',
  //   '+91',
  //   '+234',
  //   '+353',
  //   '+49',
  //   '+33',
  //   '+39',
  //   // Add more country codes as needed
  // ];

  Widget _buildRegistrationForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(),
          SizedBox(height: 8),
          Text(
            'Enter your details to create an account',
            style: TextStyle(
              color: Colors.purpleAccent,
            ),
          ),
          SizedBox(height: 10),
          _buildTextField(
            controller: _firstNameController,
            labelText: 'First Name',
          ),
          SizedBox(height: 10),
          _buildTextField(
            controller: _lastNameController,
            labelText: 'Last Name',
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  // child: _buildTextField(
                  //   controller: _mobileNumberController,
                  //   labelText: 'Mobile Number',
                  //   keyboardType: TextInputType.phone,
                  //   maxLength: null,
                  //   isRequired: false, // Mobile number is not required
                  // ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildTextField(
            controller: _emailController,
            labelText: 'Email',
            isValid: _isValidEmail(),
          ),
          SizedBox(height: 10), // Add space here
          DropdownButtonFormField<String>(
            value: _selectedUserType, // You need to declare _selectedUserType variable
            onChanged: (newValue) {
              setState(() {
                _selectedUserType = newValue;
              });
            },
            items: _userTypes.map((userType) {
              return DropdownMenuItem<String>(
                value: userType,
                child: Text(userType),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'User Type',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          SizedBox(height: 10), // Add space here
          _buildPasswordField(),
          SizedBox(height: 20), // Add space here
          _buildSignUpButton(),
        ],
      ),
    );
  }


  Widget _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/add-user.png', // Replace with your icon asset path
          width: 68, // Adjust the width as needed
          height: 68, // Adjust the height as needed
        ),
        SizedBox(height: 8),
        Text(
          'Create New Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    int? maxLength,
    ValueChanged<String>? onChanged,
    bool? isValid,
    bool isRequired = true,
  }) {
    final isEmpty = controller.text.isEmpty;
    final errorText = (isRequired && isEmpty)
        ? 'This field is required'
        : null;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        errorText: errorText,
        suffixIcon: isValid == null
            ? null
            : Icon(
          isValid ? Icons.check : Icons.clear,
          color: isValid ? Colors.green : Colors.red,
        ),
      ),
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
    );
  }

  // Widget _buildCountryCodeDropdown() {
  //   return Container(
  //     width: 80, // Set your desired width
  //     child: DropdownButtonFormField(
  //       value: _selectedCountryCode,
  //       onChanged: (newValue) {
  //         setState(() {
  //           _selectedCountryCode = newValue as String;
  //         });
  //       },
  //       items: _countryCodes.map((countryCode) {
  //         return DropdownMenuItem(
  //           value: countryCode,
  //           child: Container(
  //             width: 30, // Adjust the width of the dropdown items
  //             child: Text(countryCode),
  //           ),
  //         );
  //       }).toList(),
  //       decoration: InputDecoration(
  //         contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
  //         border: OutlineInputBorder(),
  //         focusedBorder: OutlineInputBorder(
  //           borderSide: BorderSide(color: Colors.blue),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPasswordField() {
    final password = _passwordController.text;
    String? errorText;

    if (password.isNotEmpty) {
      final passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[%@#])[a-zA-Z0-9%@#]{8,}$',
      );

      if (!passwordRegex.hasMatch(password)) {
        errorText =
        'Password must:'
            'Maintain the format below';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            errorText: errorText,
            // Display the error message
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          obscureText: !_isPasswordVisible,
        ),
        SizedBox(height: 10), // Add space here
        Text(
          'Please enter a new password into the fields below:\n'
              '1) Your password must have at least 8 characters.\n'
              '2) Must contain at least one upper case letter, one lower case letter, one number, and one special character (%, @, #).\n'
              '3) Passwords cannot contain < or >.',
          style: TextStyle(
            color: Colors.deepPurple, // Customize the color if needed
            fontSize: 12, // Adjust the font size as needed
          ),
        ),
      ],
    );
  }


  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _performRegistration,
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
      child: Text('Sign up'),
    );
  }

  bool? _isValidEmail() {
    final email = _emailController.text;
    if (email.isEmpty) {
      return null; // Email is optional
    }
    final emailRegex =
    RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword() {
    final password = _passwordController.text;

    // Password must have at least 8 characters, one uppercase letter, one lowercase letter,
    // one number, and one special character (%, @, #).
    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[%@#])[a-zA-Z0-9%@#]{8,}$',
    );

    return passwordRegex.hasMatch(password);
  }


  void _performRegistration() async {
    try {
      final apiUrl = 'https://metacare.co.in:3002/api/user/create';

      // Check if required fields are empty
      if (_firstNameController.text.isEmpty ||
          _lastNameController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _emailController.text.isEmpty) {
        _showSnackBar('Please fill in all required fields.');
        return;
      }

      if (!_isValidPassword()) {
        setState(() {
          _passwordErrorMessage =
          'Password must be 8 characters min with at least 1 uppercase, 1 lowercase, 1 number, and 1 special character';
        });
        return; // Return if the password is invalid
      }

      final isOTPSent = await _generateAndSendOTP(_emailController.text);

      if (isOTPSent) {
        final isOTPDialogConfirmed = await _showOTPDialog(
            context, _emailController.text);

        if (isOTPDialogConfirmed) {
          final enteredOTP = await _showOTPDialog(
              context, _emailController.text);

          if (enteredOTP != null) {
            final isOTPVerified = await _verifyOTP(
                _emailController.text, enteredOTP as String);

            if (isOTPVerified) {
              // Registration can now be attempted
              final requestData = {
                "f_name": _firstNameController.text,
                "l_name": _lastNameController.text,
                "email_id": _emailController.text,
                "status": true,
                "password": _passwordController.text,
                "user_type": _selectedUserType, // Add the selected user type her
              };

              // if (_mobileNumberController.text.isNotEmpty) {
              //   requestData["mobile_no"] = _mobileNumberController.text;
              // }

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
                if (responseData['errorCode'] == 200) {
                  await _showRegistrationSuccessDialog();
                  _showSnackBar('Registered successfully!');
                  _completeRegistration();
                } else {
                  _showSnackBar('Registration failed. Please try again.');
                }
              } else {
                _showSnackBar('Registration failed due to a network error.');
              }
            } else {
              _showSnackBar('OTP verification failed. Registration aborted.');
            }
          } else {
            _showSnackBar('OTP verification canceled. Registration aborted.');
          }
        } else {
          _showSnackBar('OTP verification failed. Registration aborted.');
        }
      } else {
        _showSnackBar('OTP generation failed. Registration aborted.');
      }
    } catch (e) {
      _showSnackBar('An error occurred during registration.');
    }
  }


  Future<void> _completeRegistration() async {
    final apiUrl = 'https://metacare.co.in:3002/api/user/create';

    final requestData = {
      "f_name": _firstNameController.text,
      "l_name": _lastNameController.text,
      "email_id": _emailController.text,
      //"mobile_no": _mobileNumberController.text,
      "status": true,
      "password": _passwordController.text,
      "user_type": _selectedUserType, // Add the selected user type her
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
      if (responseData['errorCode'] == 200) {
        await _showRegistrationSuccessDialog();
        _showSnackBar('Registered successfully!');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      } else {
        print('Registration failed. Error code: ${responseData['errorCode']}');
        _showSnackBar('Registration failed. Please try again.');
      }
    } else {
      _showSnackBar('Registration failed due to a network error.');
    }
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _showRegistrationSuccessDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Successful'),
          content: Text('You have successfully registered.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
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
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(14.0),
          child: Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0.0),
              color: Colors.blue.shade50,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackButton(),
                  SizedBox(height: 16),
                  _buildRegistrationForm(),
                  SizedBox(height: 16),
                  // _buildSocialIcons(),
                  SizedBox(height: 20),
                  _buildSignInLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.0, 36.0, 18.0, 9.0),
      // Adjust top padding here
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Container(
          padding: EdgeInsets.only(top: 8.0), // Adjust top padding for the Icon
          child: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.blue,
          ),
        ),
      ),
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
                MaterialPageRoute(builder: (context) => SignInPage()),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Text(
                'Sign in >',
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
  Future<bool> _generateAndSendOTP(String email) async {
    print('Generating and sending OTP for email: $email');

    final apiUrl = 'https://metacare.co.in:3002/api/user/registrationOTPGenerated';

    final requestData = {
      "email": email,
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
      if (responseData['success'] == true) {
        final generatedOTP = responseData['otp']; // Assuming the server sends the OTP
        print('OTP sent successfully for email: $email, OTP: $generatedOTP');
        return true;
      }
    }
    print('Failed to generate and send OTP for email: $email');
    return false;
  }

  Future<bool> _verifyOTP(String email, String otp) async {
    print('Verifying OTP for email: $email with OTP: $otp'); // Log OTP

    final apiUrl = 'https://metacare.co.in:3002/api/user/verify-otp';

    final requestData = {
      "email": email,
      "otp": otp,
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
      if (responseData['success'] == true) {
        print('OTP verification succeeded for email: $email');
        return true; // Return true to indicate successful verification
      } else {
        print('OTP verification failed for email: $email');
      }
    } else {
      print('Failed to verify OTP for email: $email');
    }

    return false; // Return false in case of any error or failure
  }

  Future<bool> _showOTPDialog(BuildContext context, String email) async {
    TextEditingController _otpController = TextEditingController();

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('OTP Verification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('OTP is sent to the provided email'), // Subtitle
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final enteredOTP = _otpController.text;
                final isOTPVerified = await _verifyOTP(email, enteredOTP);

                if (isOTPVerified) {
                  Navigator.of(context).pop(true); // Close the dialog

                  // Call _completeRegistration after OTP is verified
                  _completeRegistration();
                } else {
                  // Handle case where OTP verification fails
                  // You can show an error message here if needed
                }
              },
              child: Text('Verify'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}