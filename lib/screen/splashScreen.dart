import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthealth/screen/sign.dart';
import '../home_screen/hospital_dashboard_page.dart';
import 'Screen1.dart';

class SplashScreenPage extends StatelessWidget {
  void navigateToScreen1(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => Screen1(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            navigateToScreen1(context);
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/b.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Text(
                  'Smart Healthcare',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => navigateToScreen1(context),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 9.0),
                  child: Image.asset(
                    'assets/nextt.png',
                    width: 48,
                    height: 48,
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
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final loggedInEmail = prefs.getString('loggedInEmail') ?? '';

    print("Logged in email: $loggedInEmail"); // Print the logged-in email

    // Delay for a moment to show the splash screen
    await Future.delayed(Duration(seconds: 2));

    navigateToCorrectScreen(isLoggedIn, loggedInEmail);
  }

  void navigateToCorrectScreen(bool isLoggedIn, String loggedInEmail) {
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HospitalDashboardPage(loggedInEmail: loggedInEmail, cityName: '',),
      ));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => SignInPage(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
