import 'package:flutter/material.dart';

class ContactCustomerCarePage extends StatefulWidget {
  @override
  _ContactCustomerCarePageState createState() => _ContactCustomerCarePageState();
}

class _ContactCustomerCarePageState extends State<ContactCustomerCarePage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form data is valid, handle the form submission here
      String name = nameController.text;
      String email = emailController.text;
      String message = messageController.text;

      // Replace this with your action to submit the contact form
      // For example, you can send an email to customer care or save the information in a database.
      print('Contact Form Submitted:');
      print('Name: $name');
      print('Email: $email');
      print('Message: $message');

      // Show a confirmation dialog to the user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Form Submitted'),
          content: Text('Your form has been submitted successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Customer Care'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  // You can add additional email validation logic if needed
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: messageController,
                maxLines: 5,
                decoration: InputDecoration(labelText: 'Message'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
