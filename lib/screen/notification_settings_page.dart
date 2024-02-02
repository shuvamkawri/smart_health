import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  void _sendNotificationByEmail(BuildContext context) {
    String email = emailController.text;
    // Replace the print statement with code to send an email notification
    print('Sending notification via email to $email');
  }

  void _sendNotificationByPhone(BuildContext context) {
    String phoneNumber = phoneNumberController.text;
    // Replace the print statement with code to send a phone notification
    print('Sending notification via phone to $phoneNumber');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email Address'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendNotificationByEmail(context),
              child: Text('Send Notification via Email'),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendNotificationByPhone(context),
              child: Text('Send Notification via Phone'),
            ),
          ],
        ),
      ),
    );
  }
}
