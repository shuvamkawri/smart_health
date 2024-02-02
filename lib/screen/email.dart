import 'package:flutter/material.dart';

class EmailCustomerCarePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Customer Care'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS0J3R6Uwnqkbf2ixL1Qb_oavnvO5d_CR6Cmw&usqp=CAU'), // Replace with your network avatar image URL
                  radius: 30,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Doe', // Replace with the customer care executive's name
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Customer Care Executive', // Replace with the designation or role
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Subject: Inquiry Regarding Product',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Dear Customer Care,',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'I am writing to inquire about your products. Can you please provide me with more information regarding...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Replace with your action to send the email
                // For example, you can use the mailer package to send emails.
                print('Sending Email...');
              },
              child: Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}
