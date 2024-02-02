import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smarthealth/screen/reset.dart';

class PasswordChangeForm extends StatefulWidget {
  final String email;

  PasswordChangeForm({required this.email});

  @override
  _PasswordChangeFormState createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends State<PasswordChangeForm> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController reEnterNewPasswordController = TextEditingController();

  bool _isUpdatingPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Change'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
              TextFormField(
                controller: reEnterNewPasswordController,
                decoration: InputDecoration(labelText: 'Re-enter New Password'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUpdatingPassword ? null : _updatePassword,
                child: _isUpdatingPassword
                    ? CircularProgressIndicator()
                    : Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updatePassword() async {
    String newPassword = newPasswordController.text;
    String reEnterNewPassword = reEnterNewPasswordController.text;

    if (!_isValidPasswordChange()) {
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
    });

    final url = Uri.parse('https://metacare.co.in:3002/api/user/update-password');
    final headers = {'Content-Type': 'application/json'};
    final requestBody = {
      'email': widget.email,
      'password': newPassword,
    };
    final requestBodyJson = jsonEncode(requestBody);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: requestBodyJson,
      );

      if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        if (responseBody.containsKey('errorCode') &&
            responseBody['errorCode'] == 0) {
          print('Password updated successfully');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetDisplayPage(),
            ),
          );
        } else {
          print('Password update failed: ${responseBody['message']}');
        }
      } else {
        print('Failed to update password. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating password: $e');
    }

    setState(() {
      _isUpdatingPassword = false;
    });
  }

  bool _isValidPasswordChange() {
    String newPassword = newPasswordController.text;
    String reEnterNewPassword = reEnterNewPasswordController.text;

    if (newPassword.isEmpty || reEnterNewPassword.isEmpty) {
      print('Please fill all the fields');
      return false;
    } else if (newPassword != reEnterNewPassword) {
      print('New Passwords do not match');
      return false;
    } else {
      return true;
    }

    return false;
  }
}
