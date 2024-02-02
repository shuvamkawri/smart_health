import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/home_screen/hospital_dashboard_page.dart';
import 'package:smarthealth/screen/registration.dart';
import 'package:smarthealth/screen/sign.dart';
import 'Screen3.dart'; // Import the Screen3.dart file

class Screen4 extends StatefulWidget {
  @override
  _Screen4State createState() => _Screen4State();
}

class _Screen4State extends State<Screen4> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Commented out the navigation for right to left swipe
        // if (details.primaryVelocity! < 0) {
        //   Navigator.of(context).pushReplacement(
        //     MaterialPageRoute(builder: (context) => HospitalDashboardPage()),
        //   );
        // } else
        if (details.primaryVelocity! > 0) {
          // If user swipes from left to right (backward)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Screen3()), // Navigate to Screen3
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Set your desired background color
        body: Container(
          width: double.infinity, // Occupy entire screen width
          height: double.infinity, // Occupy entire screen height
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image4.jpeg'), // Set the image path
              fit: BoxFit.cover, // Cover the entire container
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(100),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.black87,
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrationPage()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Create an Account',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()), // Navigate to your sign-in page
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
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
